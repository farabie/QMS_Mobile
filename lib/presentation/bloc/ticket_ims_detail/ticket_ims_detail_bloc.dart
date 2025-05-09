import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qms_application/data/models/models.dart';
import 'package:qms_application/data/source/sources.dart';

part 'ticket_ims_detail_event.dart';
part 'ticket_ims_detail_state.dart';

class TicketImsDetailBloc extends Bloc<TicketImsDetailEvent, TicketImsDetailState> {
  final TicketImsSource ticketImsSource;

  TicketImsDetailBloc({required this.ticketImsSource}): super(TicketImsDetailInitial()) {
    on<FetchTicketImsTicketDetail>(_onFecthTicketImsDetail);
  }

  Future<void> _onFecthTicketImsDetail (FetchTicketImsTicketDetail event, Emitter<TicketImsDetailState> emit) async{
    emit(TicketImsDetailLoading());

    try{
      final ticketImsDetail = await ticketImsSource.listDetailTicketIMS(event.ticketNumber);
      if(ticketImsDetail != null) {
        emit(TicketImsDetailLoaded(ticketImsDetail));
      }else {
        emit(TicketImsDetailNotFound());
      }
    }
    catch(e) {
      emit(TicketImsDetailError(e.toString()));
    }
  }
}
