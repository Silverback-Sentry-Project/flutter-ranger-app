import 'dart:async';

import 'package:fpdart/fpdart.dart';

import '../../error/failure.dart';
import '../../models/user.dart';

abstract class AuthRepository {
  Stream<User?> get currentUser;

  Future<Either<Failure, void>> signInAnonymously();

  Future<Either<Failure, void>> signInWithGoogle(String idToken);

  Future<Either<Failure, void>> sendSignInLinkToEmail(String email);

  bool isSignInWithEmailLink(Uri link);

  Future<Either<Failure, void>> signInWithEmailLink(Uri link, {String? email});

  void signOut();

  Future<String?> getIdToken({bool forceRefresh = false});
}