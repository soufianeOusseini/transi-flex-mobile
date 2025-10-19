import 'package:transi_flex_mobile/authentification/datasource/user_datasource.dart';

import '../../core/exceptions.dart';
import '../../core/failures.dart';
import '../datasource/auth_local_datasource.dart';
import '../model/auth_request.dart';
import '../model/user.dart';

import 'package:dartz/dartz.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login(LoginRequest request);
  Future<Either<Failure, User>> register(RegisterRequest request);
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, User?>> getCurrentUser();
  Future<Either<Failure, bool>> refreshToken();
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, User>> login(LoginRequest request) async {
    try {
      final user = await remoteDataSource.login(request);
      await localDataSource.cacheUser(user);
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Erreur inconnue: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User>> register(RegisterRequest request) async {
    try {
      final user = await remoteDataSource.register(request);
      await localDataSource.cacheUser(user);
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Erreur inconnue: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      await localDataSource.clearCachedUser();
      return const Right(null);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Erreur lors de la déconnexion'));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final user = await localDataSource.getCachedUser();
      return Right(user);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erreur lors de la récupération de l\'utilisateur'));
    }
  }

  @override
  Future<Either<Failure, bool>> refreshToken() async {
    try {
      final success = await remoteDataSource.refreshToken();
      return Right(success);
    } catch (e) {
      return Left(NetworkFailure(message: 'Erreur lors du rafraîchissement du token'));
    }
  }
}