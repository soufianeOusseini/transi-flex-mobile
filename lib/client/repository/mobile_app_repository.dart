 import 'package:dartz/dartz.dart';

import '../../core/exceptions.dart';
import '../../core/failures.dart';
import '../datasource/mobile_app_data_source.dart';
import '../model/mobile_app.dart';

class MobileAppRepository {

  final MobileAppDataSource mobileAppDataSource;

  MobileAppRepository({required this.mobileAppDataSource});

  Future<Either<Failure, MobileApp>> getMobileAppState() async {
    try {
      final mobileApp = await mobileAppDataSource.getMobileAppState();
      return Right(mobileApp);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Erreur inconnue: ${e.toString()}'));
    }
  }
}
