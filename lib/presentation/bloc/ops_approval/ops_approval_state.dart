part of 'ops_approval_bloc.dart';

@immutable
sealed class OpsApprovalState {}

class OpsApprovalInitial extends OpsApprovalState {}

class OpsApprovalLoading extends OpsApprovalState {}

class OpsApprovalLoaded extends OpsApprovalState {
  final List<OpsApproval> records;

  OpsApprovalLoaded(this.records);
}

class OpsApprovalError extends OpsApprovalState {
  final String message;

  OpsApprovalError(this.message);
}
