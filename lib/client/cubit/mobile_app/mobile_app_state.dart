part of 'mobile_app_cubit.dart';

enum MobileAppStatus { initial, loading, success, failed, error }

class MobileAppState extends Equatable {
  final MobileAppStatus status;
  final MobileApp? mobileApp;
  final String? errorMessage;

  const MobileAppState({
    required this.status,
    this.mobileApp,
    this.errorMessage,
  });

  factory MobileAppState.initial() {
    return const MobileAppState(status: MobileAppStatus.initial);
  }

  MobileAppState copyWith({
    MobileAppStatus? status,
    MobileApp? mobileApp,
    String? errorMessage,
  }) {
    return MobileAppState(
      status: status ?? this.status,
      mobileApp: mobileApp ?? this.mobileApp,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, mobileApp, errorMessage];
}
