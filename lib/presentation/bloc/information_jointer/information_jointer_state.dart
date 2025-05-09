part of 'information_jointer_bloc.dart';

@immutable
sealed class InformationJointerState {}

class InformationJointerInitial extends InformationJointerState {}

class InformationJointerLoading extends InformationJointerState {}

class InformationJointerLoaded extends InformationJointerState {
  final List<InformationJointer> records;

  InformationJointerLoaded(this.records);
}

class InformationJointerError extends InformationJointerState {
  final String message;

  InformationJointerError(this.message);
}


