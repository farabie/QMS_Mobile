part of 'ticket_detail_bloc.dart';

@immutable
sealed class TicketDetailState {}

class TicketDetailInitial extends TicketDetailState {}

class TicketDetailLoading extends TicketDetailState {}

class TicketDetailLoaded extends TicketDetailState {
  final TicketDetail ticketDetail; // Change to a single TicketDetail

  TicketDetailLoaded(this.ticketDetail);
}

class TicketDetailError extends TicketDetailState {
  final String message;

  TicketDetailError(this.message);
}
