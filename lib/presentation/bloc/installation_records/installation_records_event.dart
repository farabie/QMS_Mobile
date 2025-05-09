part of 'installation_records_bloc.dart';

@immutable
sealed class InstallationRecordsEvent {}

class FetchInstallationRecords extends InstallationRecordsEvent {
  final String qmsId;

  FetchInstallationRecords(this.qmsId);
}