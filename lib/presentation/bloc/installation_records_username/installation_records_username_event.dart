part of 'installation_records_username_bloc.dart';

@immutable
sealed class InstallationRecordsUsernameEvent {}

class FetchInstallationRecordsUsername extends InstallationRecordsUsernameEvent {
  final String username;

  FetchInstallationRecordsUsername(this.username);
}
