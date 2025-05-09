part of 'installation_records_username_bloc.dart';

@immutable
sealed class InstallationRecordsUsernameState {}

class InstallationRecordsUsernameInitial extends InstallationRecordsUsernameState {}

class InstallationRecordsUsernameLoading extends InstallationRecordsUsernameState {}

class InstallationRecordsUsernameLoaded extends InstallationRecordsUsernameState {
  final List<InstallationRecords> records;
  
  InstallationRecordsUsernameLoaded(this.records);
}

class InstallationRecordsUsernameError extends InstallationRecordsUsernameState {
  final String message;

  InstallationRecordsUsernameError(this.message);
}
