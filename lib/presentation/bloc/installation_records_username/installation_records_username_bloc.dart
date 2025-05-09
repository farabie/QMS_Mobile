import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qms_application/data/models/models.dart';
import 'package:qms_application/data/source/sources.dart';

part 'installation_records_username_event.dart';
part 'installation_records_username_state.dart';

class InstallationRecordsUsernameBloc extends Bloc<
    InstallationRecordsUsernameEvent, InstallationRecordsUsernameState> {
  final InstallationSource installationSource;

  InstallationRecordsUsernameBloc({required this.installationSource})
      : super(InstallationRecordsUsernameInitial()) {
    on<FetchInstallationRecordsUsername>(_onFetchInstallationRecordsUsername);
  }

  Future<void> _onFetchInstallationRecordsUsername(
      FetchInstallationRecordsUsername event,
      Emitter<InstallationRecordsUsernameState> emit) async {
    emit(InstallationRecordsUsernameLoading());

    try {
      final installationRecordsUsername = await installationSource
          .getInstallationRecordByUsername(event.username);

      if (installationRecordsUsername != null && installationRecordsUsername.isNotEmpty) {
        emit(InstallationRecordsUsernameLoaded(installationRecordsUsername));
      } else {
        emit(InstallationRecordsUsernameError(
            'Installation History Empty'));
      }
    } catch (e) {
      emit(InstallationRecordsUsernameError(e.toString()));
    }
  }
}
