import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qms_application/data/models/models.dart';
import 'package:qms_application/data/source/sources.dart';

part 'information_jointer_event.dart';
part 'information_jointer_state.dart';

class InformationJointerBloc
    extends Bloc<InformationJointerEvent, InformationJointerState> {
  final InformationJointerSource informationJointerSource;

  InformationJointerBloc({required this.informationJointerSource})
      : super(InformationJointerInitial()) {
    on<FetchInformationJointer>(_onFetchInformationJointer);
  }

  Future<void> _onFetchInformationJointer(FetchInformationJointer event,
      Emitter<InformationJointerState> emit) async {
    emit(InformationJointerLoading());

    try {
      final informationJointer =
          await InformationJointerSource.getInformationJointerSource(
              event.servicePoint);

      if (informationJointer != null) {
        emit(InformationJointerLoaded(informationJointer));
      } else {
        emit(InformationJointerError('No Information Jointer'));
      }
    } catch (e) {
      emit(InformationJointerError(e.toString()));
    }
  }
}
