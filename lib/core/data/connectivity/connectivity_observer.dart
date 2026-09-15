import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

abstract class ConnectivityObserver {
  Stream<bool> get isOnline;
}

class ConnectivityObserverImpl implements ConnectivityObserver {
  @override
  Stream<bool> get isOnline => Connectivity().onConnectivityChanged
      .map((results) => results.any((r) => r != ConnectivityResult.none))
      .distinct();
}