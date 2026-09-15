import 'package:equatable/equatable.dart';
import 'domain_enums.dart';

class User extends Equatable {
  final String uid;
  final String? email;
  final String? displayName;
  final UserRole role;
  final String? parkId;
  final bool isGuest;

  const User({
    required this.uid,
    this.email,
    this.displayName,
    this.role = UserRole.public,
    this.parkId,
    this.isGuest = false,
  });

  String get displayNameOrFallback {
    final name = displayName?.trim();
    if (name != null && name.isNotEmpty) return name;
    if (email != null && email!.isNotEmpty) return email!.split('@').first;
    return 'Anonymous';
  }

  bool get isRanger => role == UserRole.ranger;

  User copyWith({
    String? uid,
    String? email,
    String? displayName,
    UserRole? role,
    String? parkId,
    bool? isGuest,
  }) =>
      User(
        uid: uid ?? this.uid,
        email: email ?? this.email,
        displayName: displayName ?? this.displayName,
        role: role ?? this.role,
        parkId: parkId ?? this.parkId,
        isGuest: isGuest ?? this.isGuest,
      );

  @override
  List<Object?> get props => [uid, email, displayName, role, parkId, isGuest];
}