import 'package:flutter/material.dart';
import 'package:qms_application/data/models/models.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qms_application/data/source/sources.dart';


part 'installation_records_event.dart';
part 'installation_records_state.dart';


class InstallationRecordsBloc extends Bloc<InstallationRecordsEvent,InstallationRecordsState> {
  final InstallationSource installationSource;

  InstallationRecordsBloc({required this.installationSource}) : super(InstallationRecordsInitial()) {
    on<FetchInstallationRecords>(_onFetchInstallationRecords);
  }

  Future<void> _onFetchInstallationRecords(FetchInstallationRecords event, Emitter<InstallationRecordsState> emit) async{
    emit(InstallationRecordsLoading());
    try {
      final installationRecord = await installationSource.getInstallationRecord(event.qmsId);
      if(installationRecord != null) {
        emit(InstallationRecordsLoaded(installationRecord));
      }else{
        emit(InstallationRecordsError('Failed to get installation records'));
      }
    }catch(e) {
      emit(InstallationRecordsError(e.toString()));
    }
  }
} 
