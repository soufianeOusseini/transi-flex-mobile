import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:transi_flex_mobile/client/model/mobile_app.dart';

import '../../../core/exceptions.dart';
import '../../../core/failures.dart';
import '../../repository/mobile_app_repository.dart';

part 'mobile_app_state.dart';

class MobileAppCubit extends Cubit<MobileAppState> {
  final MobileAppRepository repository;

  MobileAppCubit({required this.repository}) : super(MobileAppState.initial());

  Future<void> getMobileAppState() async {
    emit(state.copyWith(status: MobileAppStatus.loading));

    final result = await repository.getMobileAppState();

    result.fold(
          (failure) {
        if (failure is ServerFailure) {
          emit(state.copyWith(
            status: MobileAppStatus.failed,
            errorMessage: failure.message,
          ));
        } else if (failure is NetworkFailure) {
          emit(state.copyWith(
            status: MobileAppStatus.error,
            errorMessage: failure.message,
          ));
        } else {
          emit(state.copyWith(
            status: MobileAppStatus.error,
            errorMessage: failure.message,
          ));
        }
      },
          (mobileApp) {
        emit(state.copyWith(
          status: MobileAppStatus.success,
          mobileApp: mobileApp,
          errorMessage: null,
        ));
      },
    );
  }

  void reset() {
    emit(MobileAppState.initial());
  }
}