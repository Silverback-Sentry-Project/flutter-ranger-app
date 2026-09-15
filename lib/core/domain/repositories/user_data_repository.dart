import 'dart:async';

abstract class UserDataRepository {
  Stream<bool?> get darkThemeConfig;

  Future<void> setDarkThemeConfig(bool? dark);

  Stream<String?> get pendingEmailLinkAddress;

  Future<void> setPendingEmailLinkAddress(String? email);

  Stream<bool> get pendingAnonymousAuth;

  Future<void> setPendingAnonymousAuth(bool pending);
}