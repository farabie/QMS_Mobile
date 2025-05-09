part of 'ticket_by_user_bloc.dart';

@immutable
sealed class TicketByUserEvent {}

class FetchTicketByUserCM extends TicketByUserEvent {
  final String username;
  FetchTicketByUserCM(this.username);
}

class FetchTicketByUserPM extends TicketByUserEvent {
  final String username;
  FetchTicketByUserPM(this.username);
}

