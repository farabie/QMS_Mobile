part of 'installation_bloc.dart';

abstract class InstallationState {}

class InstallationInitial extends InstallationState {}

class InstallationLoading extends InstallationState {}

class InstallationTypesLoading extends InstallationState {
  final InstallationState previousState;
  InstallationTypesLoading(this.previousState);
}

class InstallationStepsLoading extends InstallationState {
  final InstallationState previousState;
  InstallationStepsLoading(this.previousState);
}

class InstallationTypesLoaded extends InstallationState {
  final List<InstallationType> installationTypes;

  InstallationTypesLoaded(this.installationTypes);
}

class InstallationStepsLoaded extends InstallationState {
  final List<InstallationStep> installationSteps;

  InstallationStepsLoaded(this.installationSteps);
}

class InstallationError extends InstallationState {
  final String message;

  InstallationError(this.message);
}
