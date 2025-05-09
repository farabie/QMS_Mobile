// ticket_by_user_state.dart

part of 'ticket_by_user_bloc.dart';

@immutable
abstract class TicketByUserState {}

class TicketInitial extends TicketByUserState {}

class TicketLoading extends TicketByUserState {}

class TicketByUserLoaded extends TicketByUserState {
  final List<TicketByUser> cmTickets;
  final List<TicketByUser> pmTickets;

  TicketByUserLoaded({
    required this.cmTickets,
    required this.pmTickets,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TicketByUserLoaded &&
        other.cmTickets == cmTickets &&
        other.pmTickets == pmTickets;
  }

  @override
  int get hashCode => cmTickets.hashCode ^ pmTickets.hashCode;
}

class TicketError extends TicketByUserState {
  final String message;

  TicketError(this.message);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TicketError && other.message == message;
  }

  @override
  int get hashCode => message.hashCode;
}
