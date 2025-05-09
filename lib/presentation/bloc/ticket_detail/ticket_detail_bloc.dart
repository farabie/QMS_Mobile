import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qms_application/data/models/models.dart';
import 'package:qms_application/data/source/sources.dart';

part 'ticket_detail_event.dart';
part 'ticket_detail_state.dart';

class TicketDetailBloc extends Bloc<TicketDetailEvent, TicketDetailState> {
  final TicketDetailSource ticketDetailSource;

  TicketDetailBloc({required this.ticketDetailSource}) : super(TicketDetailInitial()) {
    on<FetchTicketDetail>(_onFetchTicketDetail);
  }

  Future<void> _onFetchTicketDetail(
      FetchTicketDetail event, Emitter<TicketDetailState> emit) async {
    emit(TicketDetailLoading());
    try {
      final ticketDetail = await ticketDetailSource.listDetailTicket(event.ticketNumber);
      if (ticketDetail != null) {
        emit(TicketDetailLoaded(ticketDetail)); // Emit single TicketDetail
      } else {
        emit(TicketDetailError('Failed to fetch ticket details'));
      }
    } catch (e) {
      emit(TicketDetailError(e.toString()));
    }
  }
}
