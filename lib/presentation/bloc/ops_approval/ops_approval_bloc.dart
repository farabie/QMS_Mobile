import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qms_application/data/models/models.dart';
import 'package:qms_application/data/source/sources.dart';

part 'ops_approval_event.dart';
part 'ops_approval_state.dart';

class OpsApprovalBloc extends Bloc<OpsApprovalEvent, OpsApprovalState> {
  final OpsApprovalSource opsApprovalSource;

  OpsApprovalBloc({required this.opsApprovalSource})
      : super(OpsApprovalInitial()) {
    on<FetchOpsApproval>(_onFetchOpsApproval);
  }

  Future<void> _onFetchOpsApproval(
      FetchOpsApproval event,
      Emitter<OpsApprovalState> emit) async {
    emit(OpsApprovalLoading());

    try {
      final opsApproval = await opsApprovalSource
          .getApprovalOps(event.clusterName);

      if (opsApproval != null) {
        emit(OpsApprovalLoaded(opsApproval));
      } else {
        emit(OpsApprovalError(
            'Installation History Empty'));
      }
    } catch (e) {
      emit(OpsApprovalError(e.toString()));
    }
  }
}
