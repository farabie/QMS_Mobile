part of 'installation_step_records_bloc.dart';

@immutable
sealed class InstallationStepRecordsState {}

class InstallationStepRecordsInitial extends InstallationStepRecordsState {}

class InstallationStepRecordsLoading extends InstallationStepRecordsState {}

class InstallationStepRecordsLoaded extends InstallationStepRecordsState {
  final List<InstallationStepRecords> records;

  InstallationStepRecordsLoaded(this.records);
}

class InstallationStepRecordsError extends InstallationStepRecordsState {
  final String message;

  InstallationStepRecordsError(this.message);
}
