part of '../models.dart';

class InstallationStep {
    final int? id;
    final int? installationTypeId;
    final int? stepNumber;
    final String? stepDescription;
    final int? imageLength;
    final String? isOptional;
    final String? isEnvironment;

    InstallationStep({
        this.id,
        this.installationTypeId,
        this.stepNumber,
        this.stepDescription,
        this.imageLength,
        this.isOptional,
        this.isEnvironment
    });

    factory InstallationStep.fromJson(Map<String, dynamic> json) => InstallationStep(
        id: json["id"],
        installationTypeId: json["installation_type_id"],
        stepNumber: json["step_number"],
        stepDescription: json["step_description"],
        imageLength: json["image_length"],
        isOptional: json["is_optional"],
        isEnvironment: json["is_environment"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "installation_type_id": installationTypeId,
        "step_number": stepNumber,
        "step_description": stepDescription,
        "image_length": imageLength,
        "is_optional": isOptional,
        "is_environment": isEnvironment,
    };
}