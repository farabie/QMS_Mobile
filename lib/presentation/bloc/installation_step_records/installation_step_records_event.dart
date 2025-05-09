part of 'installation_step_records_bloc.dart';

@immutable
sealed class InstallationStepRecordsEvent {}

class FetchInstallationStepRecords extends InstallationStepRecordsEvent {
  final String qmsId;

  FetchInstallationStepRecords(this.qmsId);
}