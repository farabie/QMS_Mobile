import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qms_application/data/models/models.dart';
import 'package:qms_application/data/source/sources.dart';

part 'ticket_by_user_event.dart';
part 'ticket_by_user_state.dart';

class TicketByUserBloc extends Bloc<TicketByUserEvent, TicketByUserState> {
  final TicketByUserSource ticketSource;

  TicketByUserBloc(this.ticketSource) : super(TicketInitial()) {
    on<FetchTicketByUserCM>(_onFetchTicketByUserCM);
    on<FetchTicketByUserPM>(_onFetchTicketByUserPM);
  }

  List<TicketByUser> _cmTickets = [];
  List<TicketByUser> _pmTickets = [];

  Future<void> _onFetchTicketByUserCM(
    FetchTicketByUserCM event,
    Emitter<TicketByUserState> emit,
  ) async {
    emit(TicketLoading());
    try {
      final tickets = await ticketSource.listTicketByUserCM(event.username);
      if (tickets != null) {
        _cmTickets = tickets;
        emit(TicketByUserLoaded(
          cmTickets: _cmTickets,
          pmTickets: _pmTickets,
        ));
      } else {
        emit(TicketError('Failed to load CM tickets'));
      }
    } catch (e) {
      emit(TicketError(e.toString()));
    }
  }

  Future<void> _onFetchTicketByUserPM(
    FetchTicketByUserPM event,
    Emitter<TicketByUserState> emit,
  ) async {
    emit(TicketLoading());
    try {
      final tickets = await ticketSource.listTicketByUserPM(event.username);
      if (tickets != null) {
        _pmTickets = tickets;
        // Optionally emit combined state here if details are available
        emit(TicketByUserLoaded(
          cmTickets: _cmTickets,
          pmTickets: _pmTickets,
        ));
      } else {
        emit(TicketError('Failed to load PM tickets'));
      }
    } catch (e) {
      emit(TicketError(e.toString()));
    }
  }
}


