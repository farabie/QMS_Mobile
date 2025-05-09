part of 'installation_records_bloc.dart';

@immutable
sealed class InstallationRecordsState {}

class InstallationRecordsInitial extends InstallationRecordsState {}

class InstallationRecordsLoading extends InstallationRecordsState {}

class InstallationRecordsLoaded extends InstallationRecordsState {
  final InstallationRecords record;

  InstallationRecordsLoaded(this.record);
}

class InstallationRecordsError extends InstallationRecordsState {
  final String message;

  InstallationRecordsError(this.message);
}
