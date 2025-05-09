part of '../sources.dart';

class InstallationSource {
  static const _baseURL = '${URLs.host}/api';

  Future<List<InstallationType>?> listInstallationTypes() async {
    try {
      final response =
          await http.get(Uri.parse('$_baseURL/installation-types'));
      DMethod.logResponse(response);

      if (response.statusCode == 200) {
        final List<dynamic> resBody = jsonDecode(response.body);
        return resBody
            .map((e) => InstallationType.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      } else {
        DMethod.log('Failed to load installation types: ${response.statusCode}',
            colorCode: 1);
        return null;
      }
    } catch (e) {
      if (e is http.ClientException) {
        DMethod.log('Network error: ${e.message}', colorCode: 1);
      } else {
        DMethod.log('Error: ${e.toString()}', colorCode: 1);
      }
      return null;
    }
  }

  Future<List<InstallationStep>?> listInstallationSteps(int installationTypeId,
      {String? isOptional}) async {
    try {
      String url =
          '$_baseURL/installation-steps/?installation_type_id=$installationTypeId';

      if (isOptional != null) {
        url += '&is_optional=$isOptional';
      }

      final response = await http.get(Uri.parse(url));
      DMethod.logResponse(response);

      if (response.statusCode == 200) {
        final List<dynamic> resBody = jsonDecode(response.body);
        return resBody
            .map((e) => InstallationStep.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      } else {
        DMethod.log(
            'Failed to load category installation steps: ${response.statusCode}',
            colorCode: 1);
        return null;
      }
    } catch (e) {
      if (e is http.ClientException) {
        DMethod.log('Network error: ${e.message}', colorCode: 1);
      } else {
        DMethod.log('Error: ${e.toString()}', colorCode: 1);
      }
      return null;
    }
  }

  static Future<bool> stepInstallation({
    int? installationStepId,
    int? stepNumber,
    int? imageLength,
    String? qmsId,
    String? qmsInstallationStepId,
    String? typeOfInstallation,
    String? categoryOfEnvironment,
    String? description,
    List<XFile>? photos,
    String? activeStatus,
    String? status,
  }) async {
    try {
      var uri = Uri.parse('$_baseURL/installation-step-records');
      var request = http.MultipartRequest('POST', uri);

      // Add headers
      request.headers.addAll({
        'Accept': 'application/json',
      });

      // Add text fields
      request.fields['installation_step_id'] =
          installationStepId?.toString() ?? '';
      request.fields['step_number'] = stepNumber?.toString() ?? '';
      request.fields['image_length'] = imageLength?.toString() ?? '';
      request.fields['qms_id'] = qmsId ?? '';
      request.fields['qms_installation_step_id'] = qmsInstallationStepId ?? '';
      request.fields['type_of_installation'] = typeOfInstallation ?? '';
      request.fields['category_of_environment'] = categoryOfEnvironment ?? '';
      request.fields['description'] = description ?? '';
      request.fields['active_status'] = activeStatus ?? '';
      request.fields['status'] = status ?? '';

      // Attach multiple photos to the request
      if (photos != null && photos.isNotEmpty) {
        for (var photo in photos) {
          // Get the original file name using the `path` package
          String originalFileName = path.basename(photo.path);
          var stream = http.ByteStream(photo.openRead());
          var length = await photo.length();

          var multipartFile = http.MultipartFile(
            'photos[]', // This matches the key expected by the API
            stream,
            length,
            filename:
                originalFileName, // Use the original file name from path package
          );
          request.files.add(multipartFile);
        }
      }

      // Send the request
      var response = await request.send();

      // Log the response and return success/failure
      var responseData = await http.Response.fromStream(response);
      DMethod.logResponse(responseData);

      return response.statusCode == 201;
    } catch (e) {
      DMethod.log(e.toString(), colorCode: 1);
      return false;
    }
  }

  static Future<Map<String, dynamic>?> installationGenerateSteps({
    String? qmsId,
    String? isOptional,
    String? typeOfInstallationName,
    int? typeOfInstallationId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseURL/installation-generate-step-records'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          "qms_id": qmsId,
          "is_optional": isOptional,
          "type_of_installation": typeOfInstallationName,
          "type_of_installation_id": typeOfInstallationId,
        }),
      );

      DMethod.logResponse(response);

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      DMethod.log(e.toString(), colorCode: 1);
      return null; // Gagal
    }
  }

  static Future<bool> stepInstallationUpdate({
    required String? qmsInstallationStepId,
    required int? revisionId,
    String? description,
    List<XFile>? photos,
    String? activeStatus,
    String? categoryOfEnvironment,
  }) async {
    try {
      var uri = Uri.parse('$_baseURL/installation-step-record/update');
      var request = http.MultipartRequest('POST', uri);

      // Add headers
      request.headers.addAll({
        'Accept': 'application/json',
      });

      // Add text fields
      request.fields['qms_installation_step_id'] = qmsInstallationStepId ?? '';
      request.fields['revision_id'] = revisionId?.toString() ?? '';
      request.fields['description'] = description ?? '';
      request.fields['active_status'] = activeStatus ?? '';
      request.fields['category_of_environment'] = categoryOfEnvironment ?? '';

      // Attach multiple photos to the request
      if (photos != null && photos.isNotEmpty) {
        for (var photo in photos) {
          String originalFileName = path.basename(photo.path);
          var stream = http.ByteStream(photo.openRead());
          var length = await photo.length();

          var multipartFile = http.MultipartFile(
            'photos[]',
            stream,
            length,
            filename: originalFileName,
          );
          request.files.add(multipartFile);
        }
      }

      // Send the request
      var response = await request.send();

      // Log the response and return success/failure
      var responseData = await http.Response.fromStream(response);
      DMethod.logResponse(responseData);

      // return response.statusCode == 201;

      var jsonResponse = json.decode(responseData.body);

      // Check if the message indicates success
      return jsonResponse['message'] == 'Record updated successfully';
    } catch (e) {
      DMethod.log(e.toString(), colorCode: 1);
      return false;
    }
  }

  static Future<bool> environmentalInformationUpdate({
    required String? qmsInstallationStepId,
    required int? revisionId,
    String? description,
    List<XFile>? photos,
    String? activeStatus,
    String? categoryOfEnvironment,
  }) async {
    try {
      var uri = Uri.parse('$_baseURL/environmental-information/update');
      var request = http.MultipartRequest('POST', uri);

      // Add headers
      request.headers.addAll({
        'Accept': 'application/json',
      });

      // Add text fields
      request.fields['qms_installation_step_id'] = qmsInstallationStepId ?? '';
      request.fields['revision_id'] = revisionId?.toString() ?? '';
      request.fields['description'] = description ?? '';
      request.fields['active_status'] = activeStatus ?? '';
      request.fields['category_of_environment'] = categoryOfEnvironment ?? '';

      // Attach multiple photos to the request
      if (photos != null && photos.isNotEmpty) {
        for (var photo in photos) {
          String originalFileName = path.basename(photo.path);
          var stream = http.ByteStream(photo.openRead());
          var length = await photo.length();

          var multipartFile = http.MultipartFile(
            'photos[]',
            stream,
            length,
            filename: originalFileName,
          );
          request.files.add(multipartFile);
        }
      }

      // Send the request
      var response = await request.send();

      // Log the response and return success/failure
      var responseData = await http.Response.fromStream(response);
      DMethod.logResponse(responseData);

      // return response.statusCode == 201;

      var jsonResponse = json.decode(responseData.body);

      // Check if the message indicates success
      return jsonResponse['message'] == 'Record updated successfully';
    } catch (e) {
      DMethod.log(e.toString(), colorCode: 1);
      return false;
    }
  }

  static Future<bool> stepInstallationUpdateNextActive({
    required String? qmsInstallationStepId,
    required int? revisionId,
    String? activeStatus,
  }) async {
    try {
      var uri = Uri.parse('$_baseURL/installation-step-record/update');
      var request = http.MultipartRequest('POST', uri);

      // Add headers
      request.headers.addAll({
        'Accept': 'application/json',
      });

      // Add text fields
      request.fields['qms_installation_step_id'] = qmsInstallationStepId ?? '';
      request.fields['revision_id'] = revisionId?.toString() ?? '';
      request.fields['active_status'] = activeStatus ?? '';

      // Send the request
      var response = await request.send();

      // Log the response and return success/failure
      var responseData = await http.Response.fromStream(response);
      DMethod.logResponse(responseData);

      var jsonResponse = json.decode(responseData.body);

      // Check if the message indicates success
      return jsonResponse['message'] == 'Record updated successfully';
    } catch (e) {
      DMethod.log(e.toString(), colorCode: 1);
      return false;
    }
  }

  static Future<Map<String, dynamic>?> installationRecords({
    String? username,
    String? dmsId,
    String? servicePoint,
    String? project,
    String? segment,
    String? sectionName,
    String? area,
    String? latitude,
    String? longitude,
    int? idTypeOfInstallation,
    String? typeOfInstallation,
    String? imsId,
    String? imsCloseDate,
    List<String>? materialNames,
    List<int>? materialQuantities,
    String? emailUser,
    String? phoneUser,
    String? approvalOps,
    String? emailOps,
    String? phoneOps,
    String? fullNameJointers,
    String? emailJointers,
    String? phoneJointers,
  }) async {
    try {
      var uri = Uri.parse('$_baseURL/installation-records');
      var request = http.MultipartRequest('POST', uri);

      // Add headers
      request.headers.addAll({
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      });

      // Add text fields
      request.fields['username'] = username ?? '';
      request.fields['dms_id'] = dmsId ?? '';
      request.fields['service_point'] = servicePoint ?? '';
      request.fields['project'] = project ?? '';
      request.fields['segment'] = segment ?? '';
      request.fields['section_name'] = sectionName ?? '';
      request.fields['area'] = area ?? '';
      request.fields['latitude'] = latitude ?? '';
      request.fields['longitude'] = longitude ?? '';
      request.fields['id_type_of_installation'] =
          idTypeOfInstallation?.toString() ?? '';
      request.fields['type_of_installation'] = typeOfInstallation ?? '';
      request.fields['ims_id'] = imsId ?? '';
      request.fields['ims_close_date'] = imsCloseDate ?? '';
      request.fields['status'] = 'Created';
      request.fields['email_user'] = emailUser ?? '';
      request.fields['phone_user'] = phoneUser ?? '';
      request.fields['approval_ops'] = approvalOps ?? '';
      request.fields['email_ops'] = emailOps ?? '';
      request.fields['phone_ops'] = phoneOps ?? '';
      request.fields['fullname_jointers'] = fullNameJointers ?? '';
      request.fields['email_jointers'] = emailJointers ?? '';
      request.fields['phone_jointers'] = phoneJointers ?? '';

      // Add multiple material names and quantities
      if (materialNames != null && materialQuantities != null) {
        for (int i = 0; i < materialNames.length; i++) {
          request.fields['material_name[$i]'] = materialNames[i];
          request.fields['material_quantity[$i]'] =
              materialQuantities[i].toString();
        }
      }

      // Send the request
      var response = await request.send();

      // Get response and log it
      var responseData = await http.Response.fromStream(response);
      DMethod.logResponse(responseData);

      if (response.statusCode == 201) {
        return jsonDecode(responseData.body);
      } else {
        return null;
      }
    } catch (e) {
      DMethod.log(e.toString(), colorCode: 1);
      return null;
    }
  }

  static Future<Map<String, dynamic>?> generateQMSInstallationStepId(
      {String? qmsId}) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseURL/generate-step-installation-id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({"qms_id": qmsId}),
      );

      DMethod.logResponse(response);

      if (response.statusCode == 201) {
        return jsonDecode(response.body); // Kembalikan map dari respons
      } else {
        return null; // Gagal
      }
    } catch (e) {
      DMethod.log(e.toString(), colorCode: 1);
      return null; // Gagal
    }
  }

  Future<InstallationRecords?> getInstallationRecord(String qmsId) async {
    try {
      final response = await http.get(
          Uri.parse('$_baseURL/installation-records/get-qms?qms_id=$qmsId'));
      DMethod.logResponse(response);

      if (response.statusCode == 200) {
        final resBody = jsonDecode(response.body) as Map<String, dynamic>;
        final installationRecordData =
            resBody['installation_record'] as Map<String, dynamic>;

        // Buat instance dari InstallationRecords menggunakan fromJson
        return InstallationRecords.fromJson(installationRecordData);
      } else {
        DMethod.log(
            'Failed to load installation record get qms: ${response.statusCode}',
            colorCode: 1);
        return null;
      }
    } catch (e) {
      if (e is http.ClientException) {
        DMethod.log('Network error: ${e.message}', colorCode: 1);
      } else {
        DMethod.log('Error: ${e.toString()}', colorCode: 1);
      }
      return null;
    }
  }

  Future<List<InstallationStepRecords>?> getInstallationStepRecords(
      String qmsId) async {
    try {
      final response = await http.get(Uri.parse(
          '$_baseURL/getInstallationStepRecordsByQmsId?qms_id=$qmsId'));

      DMethod.logResponse(response);

      if (response.statusCode == 200) {
        final List<dynamic> resBody = jsonDecode(response.body);
        return resBody
            .map((e) =>
                InstallationStepRecords.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      } else {
        DMethod.log(
            'Failed to load Installation Step Records : ${response.statusCode}',
            colorCode: 1);
        return null;
      }
    } catch (e) {
      if (e is http.ClientException) {
        DMethod.log('Network error: ${e.message}', colorCode: 1);
      } else {
        DMethod.log('Error: ${e.toString()}', colorCode: 1);
      }
      return null;
    }
  }

  static Future<bool> onprogressInstallationRecord({
    required String? qmsId,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseURL/installation-records/status/onprogress/$qmsId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          "onprogress_date": DateTime.now().toIso8601String(),
          "status_date": DateTime.now().toIso8601String(),
        }),
      );

      DMethod.logResponse(response);

      return response.statusCode == 200;
    } catch (e) {
      DMethod.log(e.toString(), colorCode: 1);
      return false;
    }
  }

  static Future<bool> submitInstallationRecord({
    required String qmsId,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseURL/installation-records/status/submitted/$qmsId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          "submitted_date": DateTime.now().toIso8601String(),
          "status_date": DateTime.now().toIso8601String(),
        }),
      );

      DMethod.logResponse(response);

      return response.statusCode == 200; // Check for a successful status code
    } catch (e) {
      DMethod.log(e.toString(), colorCode: 1);
      return false; // Return false if there is an exception
    }
  }

  static Future<bool> onprogressInstallationStepRecord({
    required String? qmsId,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse(
            '$_baseURL/installation-step-records/status/onprogress/$qmsId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          "onprogress_date": DateTime.now().toIso8601String(),
          "status_date": DateTime.now().toIso8601String(),
        }),
      );

      DMethod.logResponse(response);

      return response.statusCode == 200; // Check for a successful status code
    } catch (e) {
      DMethod.log(e.toString(), colorCode: 1);
      return false; // Return false if there is an exception
    }
  }

  static Future<bool> resubmitInstallationRecord({
    required String qmsId,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseURL/installation-records/status/resubmitted/$qmsId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          "resubmitted_date": DateTime.now().toIso8601String(),
          "status_date": DateTime.now().toIso8601String(),
        }),
      );

      DMethod.logResponse(response);

      return response.statusCode == 200; // Check for a successful status code
    } catch (e) {
      DMethod.log(e.toString(), colorCode: 1);
      return false; // Return false if there is an exception
    }
  }

  static Future<bool> submitInstallationStepRecord({
    required String qmsId,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse(
            '$_baseURL/installation-step-records/status/submitted/$qmsId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          "submitted_date": DateTime.now().toIso8601String(),
          "status_date": DateTime.now().toIso8601String(),
        }),
      );

      DMethod.logResponse(response);

      return response.statusCode == 200; // Check for a successful status code
    } catch (e) {
      DMethod.log(e.toString(), colorCode: 1);
      return false; // Return false if there is an exception
    }
  }

  static Future<bool> resubmitInstallationStepRecord({
    required String qmsId,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse(
            '$_baseURL/installation-step-records/status/resubmitted/$qmsId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          "resubmitted_date": DateTime.now().toIso8601String(),
          "status_date": DateTime.now().toIso8601String(),
        }),
      );

      DMethod.logResponse(response);

      return response.statusCode == 200;
    } catch (e) {
      DMethod.log(e.toString(), colorCode: 1);
      return false;
    }
  }

  Future<List<InstallationRecords>?> getInstallationRecordByUsername(
      String username) async {
    try {
      final response = await http.get(Uri.parse(
          '$_baseURL/installation-records/username?username=$username'));

      DMethod.logResponse(response);

      if (response.statusCode == 200) {
        final List<dynamic> resBody = jsonDecode(response.body);
        return resBody
            .map((e) =>
                InstallationRecords.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      } else if (response.statusCode == 404) {
        throw Exception("Installation History Empty");
      } else {
        DMethod.log(
            'Failed to load Installation Step Records : ${response.statusCode}',
            colorCode: 1);
        return null;
      }
    } catch (e) {
      if (e is http.ClientException) {
        DMethod.log('Network error: ${e.message}', colorCode: 1);
      } else {
        DMethod.log('Error: ${e.toString()}', colorCode: 1);
      }
      return null;
    }
  }
}
