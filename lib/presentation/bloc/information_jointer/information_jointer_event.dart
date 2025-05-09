part of 'information_jointer_bloc.dart';

@immutable
sealed class InformationJointerEvent {}

class FetchInformationJointer extends InformationJointerEvent {
  final String servicePoint;

  FetchInformationJointer(this.servicePoint);
}
