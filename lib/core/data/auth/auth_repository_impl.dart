import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:fpdart/fpdart.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../constants/app_constants.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/device_session_repository.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../models/domain_enums.dart';
import '../../error/failure.dart';
import '../../models/user.dart';
import '../../service_locator.dart';
import '../../notifications/fcm_topics.dart';

class AuthRepositoryImpl implements AuthRepository {
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;
  final StreamController<User?> _userController =
      StreamController<User?>.broadcast();

  AuthRepositoryImpl() {
    _auth.authStateChanges().listen(_onAuthChanged);
  }

  StreamSubscription<fb.User?>? _pendingEmailSub;

  @override
  Stream<User?> get currentUser => _userController.stream;

  void _onAuthChanged(fb.User? fbUser) {
    _pendingEmailSub?.cancel();
    _pendingEmailSub = null;
    if (fbUser == null) {
      _userController.add(null);
      return;
    }
    _buildUser(fbUser);
  }

  Future<void> _buildUser(fb.User fbUser) async {
    try {
      final tokenResult = await fbUser.getIdTokenResult();
      final claims = tokenResult.claims ?? {};
      final role = UserRole.fromClaim(claims['role'] as String?);
      final parkId = claims['park_id'] as String?;
      final isGoogle = fbUser.providerData
          .any((p) => p.providerId == 'google.com');
      if (role == UserRole.ranger && !isGoogle && !fbUser.isAnonymous) {
        final hasEmail = fbUser.email != null && fbUser.email!.isNotEmpty;
        if (!hasEmail) {
          signOut();
          _userController.add(null);
          return;
        }
      }
      final user = User(
        uid: fbUser.uid,
        email: fbUser.email,
        displayName: fbUser.displayName,
        role: role,
        parkId: parkId,
        isGuest: fbUser.isAnonymous,
      );
      _userController.add(user);
      try {
        await sl<FcmTopicManager>().syncTopics(user.role, user.parkId);
      } catch (_) {}
    } catch (_) {
      _userController.add(null);
    }
  }

  Future<void> _afterSignIn(fb.User fbUser) async {
    try {
      await sl<FcmTokenRepository>().syncToken();
    } catch (_) {}
    await _buildUser(fbUser);
  }

  @override
  Future<Either<Failure, void>> signInAnonymously() async {
    try {
      final creds = await _auth.signInAnonymously();
      if (creds.user == null) return left(AuthFailure('Anonymous sign-in failed'));
      return right(null);
    } catch (e) {
      return left(AuthFailure('$e'));
    }
  }

  @override
  Future<Either<Failure, void>> signInWithGoogle(String idToken) async {
    try {
      final credential = fb.GoogleAuthProvider.credential(idToken: idToken);
      final creds = await _auth.signInWithCredential(credential);
      if (creds.user == null) return left(AuthFailure('Google sign-in failed'));
      await _afterSignIn(creds.user!);
      return right(null);
    } catch (e) {
      return left(AuthFailure('$e'));
    }
  }

  @override
  Future<Either<Failure, void>> sendSignInLinkToEmail(String email) async {
    try {
      await _auth.sendSignInLinkToEmail(
        email: email,
        actionCodeSettings: fb.ActionCodeSettings(
          url: AppConstants.signInLinkUrl,
          handleCodeInApp: true,
          androidPackageName: AppConstants.androidPackageName,
          androidInstallApp: true,
        ),
      );
      return right(null);
    } catch (e) {
      return left(AuthFailure('$e'));
    }
  }

  @override
  bool isSignInWithEmailLink(Uri link) {
    return _auth.isSignInWithEmailLink(link.toString());
  }

  @override
  Future<Either<Failure, void>> signInWithEmailLink(
    Uri link, {
    String? email,
  }) async {
    try {
      if (email == null || email.isEmpty) {
        return left(AuthFailure('Email is required for email-link sign-in'));
      }
      final creds =
          await _auth.signInWithEmailLink(email: email, emailLink: link.toString());
      if (creds.user == null) return left(AuthFailure('Email sign-in failed'));
      await _afterSignIn(creds.user!);
      return right(null);
    } catch (e) {
      return left(AuthFailure('$e'));
    }
  }

  @override
  void signOut() async {
    try {
      await sl<FcmTopicManager>().clearTopics();
    } catch (_) {}
    await GoogleSignIn.instance.signOut().catchError((_) {});
    await _auth.signOut().catchError((_) {});
    try {
      await sl<DeviceSessionRepository>().clearLocalSession();
      await sl<NotificationRepository>().clearAll();
    } catch (_) {}
  }

  @override
  Future<String?> getIdToken({bool forceRefresh = false}) async {
    try {
      final token = await _auth.currentUser?.getIdToken(forceRefresh);
      return token;
    } catch (_) {
      return null;
    }
  }

  void dispose() {
    _userController.close();
    _pendingEmailSub?.cancel();
  }
}