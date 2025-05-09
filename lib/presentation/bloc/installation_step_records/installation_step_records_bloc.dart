import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qms_application/data/models/models.dart';
import 'package:qms_application/data/source/sources.dart';

part 'installation_step_records_event.dart';
part 'installation_step_records_state.dart';

class InstallationStepRecordsBloc extends Bloc<InstallationStepRecordsEvent, InstallationStepRecordsState> {
  final InstallationSource installationSource;

  InstallationStepRecordsBloc({required this.installationSource}) : super(InstallationStepRecordsInitial()) {
    on<FetchInstallationStepRecords>(_onFetchInstallationStepRecords);
  }

  Future<void> _onFetchInstallationStepRecords(FetchInstallationStepRecords event, Emitter<InstallationStepRecordsState> emit) async {
    emit(InstallationStepRecordsLoading());
    try {
      final installationStepRecords = await installationSource.getInstallationStepRecords(event.qmsId);
      if(installationStepRecords != null) {
        emit(InstallationStepRecordsLoaded(installationStepRecords));
      }else {
        emit(InstallationStepRecordsError('Failed to get installation step records'));
      }
    }
    catch(e) {
      emit(InstallationStepRecordsError(e.toString()));
    }
  }
}
