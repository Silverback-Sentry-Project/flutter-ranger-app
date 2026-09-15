import 'dart:async';

import 'package:hive/hive.dart';

import '../../domain/repositories/user_data_repository.dart';
import '../hive_database.dart';

class UserDataRepositoryImpl implements UserDataRepository {
  static const _keyDarkTheme = 'dark_theme';
  static const _keyPendingEmailLinkAddress = 'pending_email_link_address';
  static const _keyPendingAnonymousAuth = 'pending_anonymous_auth';

  late final StreamController<bool?> _darkController;
  late final StreamController<String?> _emailController;
  late final StreamController<bool> _anonymousController;
  StreamSubscription<BoxEvent>? _sub;

  UserDataRepositoryImpl() {
    _darkController = StreamController<bool?>.broadcast();
    _emailController = StreamController<String?>.broadcast();
    _anonymousController = StreamController<bool>.broadcast();
  }

  void _ensureSubscription() {
    if (_sub != null) return;
    final box = HiveDatabase.settingsBox;
    _sub = box.watch().listen((event) {
      if (event.key == _keyDarkTheme) {
        _darkController.add(event.value as bool?);
      } else if (event.key == _keyPendingEmailLinkAddress) {
        _emailController.add(event.value as String?);
      } else if (event.key == _keyPendingAnonymousAuth) {
        _anonymousController.add(event.value as bool? ?? false);
      }
    });
  }

  @override
  Stream<bool?> get darkThemeConfig {
    _ensureSubscription();
    return _darkController.stream;
  }

  @override
  Future<void> setDarkThemeConfig(bool? dark) =>
      HiveDatabase.settingsBox.put(_keyDarkTheme, dark);

  @override
  Stream<String?> get pendingEmailLinkAddress {
    _ensureSubscription();
    return _emailController.stream;
  }

  @override
  Future<void> setPendingEmailLinkAddress(String? email) =>
      HiveDatabase.settingsBox.put(_keyPendingEmailLinkAddress, email);

  @override
  Stream<bool> get pendingAnonymousAuth {
    _ensureSubscription();
    return _anonymousController.stream;
  }

  @override
  Future<void> setPendingAnonymousAuth(bool pending) =>
      HiveDatabase.settingsBox.put(_keyPendingAnonymousAuth, pending);
}