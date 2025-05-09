part of 'ops_approval_bloc.dart';

@immutable
sealed class OpsApprovalEvent {}


class FetchOpsApproval extends OpsApprovalEvent {
  final String clusterName;

  FetchOpsApproval(this.clusterName);
}