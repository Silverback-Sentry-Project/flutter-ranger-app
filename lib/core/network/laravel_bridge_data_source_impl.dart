import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../domain/repositories/auth_repository.dart';
import '../error/failure.dart';
import '../models/incident.dart';
import '../service_locator.dart';
import 'laravel_bridge_data_source.dart';

class LaravelBridgeDataSourceImpl implements LaravelBridgeDataSource {
  static const String _baseUrl =
      String.fromEnvironment('LARAVEL_BASE_URL', defaultValue: '');

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  @override
  Future<Either<Failure, void>> postIncidentEvent(
    IncidentModel incident,
    String eventType,
  ) async {
    if (_baseUrl.isEmpty) return right(null);
    try {
      final token = await sl<AuthRepository>().getIdToken();
      if (token == null) return right(null);
      final after = incident.toFirestoreMap()..remove('answers');
      final data = <String, dynamic>{
        'docId': incident.id,
        'eventType': eventType,
        'after': after,
      };
      await _dio.post(
        '/mobile/incidents',
        data: data,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return right(null);
    } on DioException catch (e) {
      return left(ServerFailure('$e'));
    } catch (e) {
      return left(UnknownFailure('$e'));
    }
  }
}