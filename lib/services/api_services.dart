import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:qms_application/data/models/models.dart';

Future<List<String>> fetchCableTypes() async {
  final response = await http
      .get(Uri.parse('https://stagingapiqms.triasmitra.com/public/api/cable-types'));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return (data['data'] as List)
        .map((item) => item['cable_type'].toString())
        .toList();
  } else {
    print('Error: ${response.statusCode}, ${response.body}');
    throw Exception('Failed to load cable types');
  }
}

Future<List<String>> fetchCategoryItems(String cableType) async {
  final response = await http.get(Uri.parse(
      'https://stagingapiqms.triasmitra.com/public/api/category-items/$cableType'));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return (data['data'] as List)
        .map((item) => item['category_item'].toString())
        .toList();
  } else {
    print('Error: ${response.statusCode}, ${response.body}');
    throw Exception('Failed to load category item');
  }
}

Future<List<String>> fetchItems(String categoryItem, String cableType) async {
  final response = await http.get(Uri.parse(
      'https://stagingapiqms.triasmitra.com/public/api/items/$categoryItem/$cableType'));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return (data['data'] as List)
        .map((item) => item['item'].toString())
        .toList();
  } else {
    print('Error: ${response.statusCode}, ${response.body}');
    throw Exception('Failed to load Category of Inspection details');
  }
}

Future<List<String>> fetchCategoryItemCode(
    String item, String categoryItem) async {
  final response = await http.get(Uri.parse(
      'https://stagingapiqms.triasmitra.com/public/api/category-item-code/$item/$categoryItem'));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return (data['data'] as List)
        .map((item) => item['category_item_code'].toString())
        .toList();
  } else {
    print('Error: ${response.statusCode}, ${response.body}');
    throw Exception('Failed to load Category Item Code');
  }
}

class ApiService {
  // --------------------------- START DMS DATABASE ---------------------------

  final String baseUrl = 'http://35.219.106.161:8080';

  Future<List<dynamic>> getTickets(String username) async {
    print("Fetching tickets with param1: $username, param2: 1");

    final response = await http.get(
        Uri.parse(
            '$baseUrl/PatroliApi/getTicketByUser?param1=$username&param2=1'),
        headers: {
          'Authorization': 'Bearer xzvOowuH6nFdXJH2dz8ZxHX2hWSR7skvbnVzdQ==',
          'Cache-Control': 'no-cache',
          'Pragma': 'no-cache',
        });

    print("HTTP status code: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      print('Response body: ${response.body}');

      if (data['result'] == 'ok' && data['data'] != null) {
        print("Tickets data fetched successfully");

        List<dynamic> tickets = data['data'];
        List<dynamic> openedTickets = tickets.where((ticket) {
          return ticket['ticket_status'] == 'opened';
        }).toList();

        return openedTickets;
      } else {
        print("Error fetching tickets: ${data['message']}");
        throw Exception('Failed to load tickets: ${data['message']}');
      }
    } else {
      print("Failed to load tickets with status code: ${response.statusCode}");
      throw Exception('Failed to load tickets: ${response.statusCode}');
    }
  }

  Future<List<dynamic>?> getTicketDetail(String ticketNumber) async {
    final response = await http.get(
      Uri.parse('$baseUrl/PatroliApi/getTicketDetail?param1=$ticketNumber'),
      headers: {
        'Authorization': 'Bearer xzvOowuH6nFdXJH2dz8ZxHX2hWSR7skvbnVzdQ=='
      },
    );

    print("Response body: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'] ?? []; // Return as a list
    } else {
      throw Exception('Failed to load ticket details');
    }
  }

  Future<List<AssetTagging>> fetchAssetTagging(String ticketNumber) async {
    final response = await http.get(
      Uri.parse('$baseUrl/PatroliApi/getTicketDetail?param1=$ticketNumber'),
      headers: {
        'Authorization': 'Bearer xzvOowuH6nFdXJH2dz8ZxHX2hWSR7skvbnVzdQ=='
      },
    );

    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<dynamic> ticketSteps = [];

      if (data['data'] != null) {
        ticketSteps = (data['data'] as List<dynamic>)
            .expand((item) => item['ticket_steps'] as List<dynamic>)
            .toList();
      }

      List<AssetTagging> assetTaggings = ticketSteps
          .where((step) => step['asset_name'] != null && step['urutan'] != null)
          .map((step) => AssetTagging(
                assetName: step['asset_name'] as String,
                urutan: step['urutan'] as int,
              ))
          .toList();

      if (assetTaggings.isEmpty) {
        return [
          AssetTagging(assetName: 'Data null, tapi fungsi berhasil', urutan: 0)
        ];
      }

      return assetTaggings;
    } else {
      throw Exception('Failed to load asset tagging');
    }
  }

  /// Get Service Points by Cluster Name
  Future<List<String>> getServicePoints(String clusterName) async {
    final String url =
        '$baseUrl/PatroliApi/getServicePoints?param2=$clusterName';
    print('Request URL: $url'); // Debugging: menampilkan URL yang digunakan

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer xzvOowuH6nFdXJH2dz8ZxHX2hWSR7skvbnVzdQ==',
          'Accept': 'application/json',
        },
      );

      print('Response Status Code: ${response.statusCode}');
      print(
          'Response Body: ${response.body}'); // Debugging: menampilkan respons

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['result'] == 'ok' && data['data'] is List) {
          List<String> servicePoints = [];
          for (var region in data['data']) {
            for (var cluster in region['clusters']) {
              for (var serviceArea in cluster['service_area']) {
                for (var servicePoint in serviceArea['service_point']) {
                  servicePoints.add(servicePoint['service_point_name']);
                }
              }
            }
          }
          return servicePoints;
        } else {
          throw Exception('Unexpected response format: ${response.body}');
        }
      } else {
        throw Exception(
            'Failed to fetch service points: ${response.reasonPhrase}');
      }
    } catch (e) {
      print(
          'Error occurred while fetching service points: $e'); // Debugging: tampilkan error
      throw Exception('Error occurred while fetching service points: $e');
    }
  }

  // --------------------------- END OF DMS DATABASE ---------------------------

  // --------------------------- START QMS DATABASE ----------------------------

  // Fungsi untuk mendapatkan cluster_name berdasarkan username
  Future<String?> getClusterName(String username) async {
    // Print untuk memastikan username sudah benar
    print('Username yang digunakan: $username');

    final Uri url = Uri.parse(
        'https://stagingapiqms.triasmitra.com/public/api/getClusterName/$username');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data.containsKey('cluster_name')) {
          return data['cluster_name'];
        } else {
          print('cluster_name tidak ditemukan di response');
          return null; // Username tidak memiliki cluster_name
        }
      } else {
        print('Status code: ${response.statusCode}');
        throw Exception(
            'Gagal mendapatkan cluster_name. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching cluster name: $e');
      throw Exception('Error: $e');
    }
  }

  // END Fungsi Cluster Name

  Future<String> createInspectionTicket(
    String username,
    String ticketNumber,
    String project,
    String segment,
    String sectionName,
    String sectionPatrol,
    String worker,
    String servicePoint,
    String? emailUser,
    String? phoneUser,
    String? approvalOps,
    String? emailOps,
    String? phoneOps,
  ) async {
    const String url =
        'https://stagingapiqms.triasmitra.com/public/api/create-inspection';

    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'dms_ticket': ticketNumber,
        'project': project,
        'segment': segment,
        'section_name': sectionName,
        'section_patrol': sectionPatrol,
        'worker': worker,
        'service_point': servicePoint,
        'status_ticket': 'Created',
        'email_user': emailUser!,
        'phone_user': phoneUser!,
        'approval_ops': approvalOps!,
        'email_ops': emailOps!,
        'phone_ops': phoneOps!,
      }),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData.containsKey('id_inspection')) {
        return responseData['id_inspection'];
      } else {
        throw Exception('Formatted QMS Ticket Number not found in response');
      }
    } else {
      throw Exception('Failed to create inspection ticket');
    }
  }

  Future<String> createAuditTicket(
    String username,
    String ticketNumber,
    String project,
    String segment,
    String sectionName,
    String sectionPatrol,
    String worker,
    String servicePoint,
    String servicePointAudit,
    String? emailUser,
    String? phoneUser,
    String? approvalOps,
    String? emailOps,
    String? phoneOps,
  ) async {
    const String url = 'https://stagingapiqms.triasmitra.com/public/api/create-audit';

    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'dms_ticket': ticketNumber,
        'project': project,
        'segment': segment,
        'section_name': sectionName,
        'section_patrol': sectionPatrol,
        'worker': worker,
        'service_point': servicePoint,
        'service_point_audit': servicePointAudit,
        'status_ticket': 'Created',
        'email_user': emailUser!,
        'phone_user': phoneUser!,
        'approval_ops': approvalOps!,
        'email_ops': emailOps!,
        'phone_ops': phoneOps!,
      }),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData.containsKey('id_audit')) {
        return responseData['id_audit'];
      } else {
        throw Exception('Formatted QMS Ticket Number not found in response');
      }
    } else {
      throw Exception('Failed to create audit ticket');
    }
  }

  Future<void> updateInspectionTicketStatusOnProgress(
      String idInspection, String newStatus) async {
    const String url =
        'https://stagingapiqms.triasmitra.com/public/api/inspection/update-status-progress';

    String onProgressDate =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'qms_ticket': idInspection,
          'status_ticket': newStatus,
          'onprogress_date': onProgressDate,
        }),
      );

      if (response.statusCode == 200) {
        print('Ticket status updated successfully');
      } else {
        print('Failed to update ticket status: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to update inspection ticket status');
      }
    } catch (e) {
      print('Error during updating ticket status: $e');
      rethrow;
    }
  }

  Future<void> updateAuditTicketStatusOnProgress(
      String idAudit, String newStatus) async {
    const String url =
        'https://stagingapiqms.triasmitra.com/public/api/audit/update-status-progress';

    String onProgressDate =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'qms_ticket': idAudit,
          'status_ticket': newStatus,
          'onprogress_date': onProgressDate,
        }),
      );

      if (response.statusCode == 200) {
        print('Ticket status updated successfully');
      } else {
        print('Failed to update ticket status: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to update audit ticket status');
      }
    } catch (e) {
      print('Error during updating ticket status: $e');
      rethrow;
    }
  }

  Future<void> updateInspectionTicketStatusSubmitted(
      String idInspection, String newStatus) async {
    const String url =
        'https://stagingapiqms.triasmitra.com/public/api/inspection/update-status-submitted';

    String submittedDate =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'qms_ticket': idInspection,
          'status_ticket': newStatus,
          'submitted_date': submittedDate,
        }),
      );

      if (response.statusCode == 200) {
        print('Ticket status updated successfully');
      } else {
        print('Failed to update ticket status: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to update inspection ticket status');
      }
    } catch (e) {
      print('Error during updating ticket status: $e');
      rethrow;
    }
  }

  Future<void> updateAuditTicketStatusSubmitted(
      String idAudit, String newStatus) async {
    const String url =
        'https://stagingapiqms.triasmitra.com/public/api/audit/update-status-submitted';

    String submittedDate =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'qms_ticket': idAudit,
          'status_ticket': newStatus,
          'submitted_date': submittedDate,
        }),
      );

      if (response.statusCode == 200) {
        print('Ticket status updated successfully');
      } else {
        print('Failed to update ticket status: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to update audit ticket status');
      }
    } catch (e) {
      print('Error during updating ticket status: $e');
      rethrow;
    }
  }

  Future<List<Inspection>> fetchAllInspections(String username) async {
    final response = await http.get(Uri.parse(
        'https://stagingapiqms.triasmitra.com/public/api/inspection/$username'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<Inspection> inspections = (data['data'] as List)
          .map((item) => Inspection.fromJson(item))
          .toList();
      return inspections;
    } else {
      throw Exception('Failed to load inspection history');
    }
  }

  Future<List<Audit>> fetchAllAudits(String username) async {
    final response = await http.get(
        Uri.parse('https://stagingapiqms.triasmitra.com/public/api/audit/$username'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<Audit> inspections =
          (data['data'] as List).map((item) => Audit.fromJson(item)).toList();
      return inspections;
    } else {
      throw Exception('Failed to load audit history');
    }
  }

  Future<List<Inspection>> fetchInspectionByTicket(String idInspection) async {
    print('Fetching inspections for ID: $idInspection');
    final response = await http.get(Uri.parse(
        'https://stagingapiqms.triasmitra.com/public/api/inspection/id/$idInspection'));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      if (jsonData['success']) {
        List<dynamic> data = jsonData['data'];
        return data.map((item) => Inspection.fromJson(item)).toList();
      } else {
        throw Exception(jsonData['message']);
      }
    } else {
      print(
          'Failed to update status: ${response.statusCode}, ${response.body}');
      throw Exception('Failed to fetch inspections');
    }
  }

  Future<List<Audit>> fetchAuditByTicket(String idAudit) async {
    print('Fetching audits for ID: $idAudit');
    final response = await http.get(Uri.parse(
        'https://stagingapiqms.triasmitra.com/public/api/audit/id/$idAudit'));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      if (jsonData['success']) {
        List<dynamic> data = jsonData['data'];
        return data.map((item) => Audit.fromJson(item)).toList();
      } else {
        throw Exception(jsonData['message']);
      }
    } else {
      print(
          'Failed to update status: ${response.statusCode}, ${response.body}');
      throw Exception('Failed to fetch audits');
    }
  }

  Future<InspectionResponse> fetchInspectionByTicket2(String qmsTicket) async {
    print('Fetching inspections for QMS Ticket: $qmsTicket');
    final response = await http.get(Uri.parse(
        'https://stagingapiqms.triasmitra.com/public/api/inspection/asset/$qmsTicket'));

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      if (jsonData['success']) {
        return InspectionResponse.fromJson(jsonData['data']);
      } else {
        throw Exception(jsonData['message']);
      }
    } else {
      print(
          'Failed to fetch inspections: ${response.statusCode}, ${response.body}');
      throw Exception('Failed to fetch inspections');
    }
  }

  Future<AuditResponse> fetchAuditByTicket2(String qmsTicket) async {
    print('Fetching audits for QMS Ticket: $qmsTicket');
    final response = await http.get(Uri.parse(
        'https://stagingapiqms.triasmitra.com/public/api/audit/asset/$qmsTicket'));

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      if (jsonData['success']) {
        return AuditResponse.fromJson(jsonData['data']);
      } else {
        throw Exception(jsonData['message']);
      }
    } else {
      print('Failed to fetch audits: ${response.statusCode}, ${response.body}');
      throw Exception('Failed to fetch audits');
    }
  }

  Future<Map<String, dynamic>> postAssetTaggingInspection(
      Map<String, dynamic> payload) async {
    const String url =
        'https://stagingapiqms.triasmitra.com/public/api/asset-tagging-inspection';

    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      print('Asset Tagging Inspection created successfully');
      return json.decode(response.body);
    } else {
      final errorResponse = json.decode(response.body);
      print('Failed to create Asset Tagging Inspection');
      print('Error details: $errorResponse');
      throw Exception(
          'Failed to create Asset Tagging Inspection: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> postAssetTaggingAudit(
      Map<String, dynamic> payload) async {
    const String url =
        'https://stagingapiqms.triasmitra.com/public/api/asset-tagging-audit';

    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      print('Asset Tagging Audit created successfully');
      return json.decode(response.body);
    } else {
      final errorResponse = json.decode(response.body);
      print('Failed to create Asset Tagging Audit');
      print('Error details: $errorResponse');
      throw Exception('Failed to create Asset Tagging Audit: ${response.body}');
    }
  }

  Future<List<AssetTaggingInspection>> getAssetTaggingInspection(
      String idInspection) async {
    final response = await http.get(Uri.parse(
        'https://stagingapiqms.triasmitra.com/public/api/asset-tagging-inspection/$idInspection'));

    if (response.statusCode == 200) {
      try {
        final Map<String, dynamic> data = jsonDecode(response.body);
        print('Decoded data: $data');

        if (data['success'] == true && data['data'] is List) {
          return (data['data'] as List).map((item) {
            if (item is Map &&
                item.containsKey('nama') &&
                item.containsKey('id_inspection') &&
                item.containsKey('status') &&
                item.containsKey('finding_count')) {
              return AssetTaggingInspection(
                nama: item['nama'].toString(),
                idInspection: item['id_inspection'].toString(),
                status: int.tryParse(item['status'].toString()) ?? 0,
                findingCount:
                    int.tryParse(item['finding_count'].toString()) ?? 0,
              );
            } else {
              throw Exception('Unexpected item format: $item');
            }
          }).toList();
        } else {
          throw Exception(data['message'] ?? 'No data found');
        }
      } catch (e) {
        print('Error parsing JSON: $e');
        throw Exception('Failed to parse asset tagging inspection data');
      }
    } else {
      print('Error: ${response.statusCode}, ${response.body}');
      throw Exception('Failed to load asset tagging inspection data');
    }
  }

  Future<List<AssetTaggingAudit>> getAssetTaggingAudit(String idAudit) async {
    final response = await http.get(Uri.parse(
        'https://stagingapiqms.triasmitra.com/public/api/asset-tagging-audit/$idAudit'));

    if (response.statusCode == 200) {
      try {
        final Map<String, dynamic> data = jsonDecode(response.body);
        print('Decoded data: $data');

        if (data['success'] == true && data['data'] is List) {
          return (data['data'] as List).map((item) {
            if (item is Map &&
                item.containsKey('nama') &&
                item.containsKey('id_audit') &&
                item.containsKey('status') &&
                item.containsKey('finding_count')) {
              return AssetTaggingAudit(
                nama: item['nama'].toString(),
                idAudit: item['id_audit'].toString(),
                status: int.tryParse(item['status'].toString()) ?? 0,
                findingCount:
                    int.tryParse(item['finding_count'].toString()) ?? 0,
              );
            } else {
              throw Exception('Unexpected item format: $item');
            }
          }).toList();
        } else {
          throw Exception(data['message'] ?? 'No data found');
        }
      } catch (e) {
        print('Error parsing JSON: $e');
        throw Exception('Failed to parse asset tagging audit data');
      }
    } else {
      print('Error: ${response.statusCode}, ${response.body}');
      throw Exception('Failed to load asset tagging audit data');
    }
  }

  Future<void> updateAssetTaggingInspectionStatus({
    required String nama,
    required String idInspection,
    required int status,
    required int findingCount,
  }) async {
    const String url =
        'https://stagingapiqms.triasmitra.com/public/api/asset-tagging-inspection/update';
    final response = await http.put(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'nama': nama,
        'id_inspection': idInspection,
        'status': status,
        'finding_count': findingCount,
      }),
    );

    if (response.statusCode == 200) {
      print('Status updated successfully');
    } else {
      print('Failed to update status: ${response.body}');
      throw Exception('Failed to update status: ${response.body}');
    }
  }

  Future<void> updateAssetTaggingAuditStatus({
    required String nama,
    required String idAudit,
    required int status,
    required int findingCount,
  }) async {
    const String url =
        'https://stagingapiqms.triasmitra.com/public/api/asset-tagging-audit/update';
    final response = await http.put(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'nama': nama,
        'id_audit': idAudit,
        'status': status,
        'finding_count': findingCount,
      }),
    );

    if (response.statusCode == 200) {
      print('Status updated successfully');
    } else {
      print('Failed to update status: ${response.body}');
      throw Exception('Failed to update status: ${response.body}');
    }
  }

  Future<String> createDefectId({
    required String idInspection,
    required String defectId,
  }) async {
    const String url =
        'https://stagingapiqms.triasmitra.com/public/api/create-defect-id';

    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'qms_ticket': idInspection,
        'defect_id': defectId,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['defect_id'];
    } else {
      final errorResponse = json.decode(response.body);
      print('Failed to create Defect ID');
      print('Error details: $errorResponse');
      throw Exception('Failed to create Defect ID: ${response.body}');
    }
  }

  Future<void> postInspectionResult({
    required String idAssetTagging,
    required String idInspection,
    required String nama,
    required String categoryItemCode,
    required String typeCable,
    required String categoryInspection,
    required String categoryInspectionDetail,
    required XFile panoramicImage,
    required XFile farImage,
    required List<XFile> nearImages,
    required String latitude,
    required String longitude,
    required String description,
  }) async {
    var uri =
        Uri.parse('https://stagingapiqms.triasmitra.com/public/api/inspection-result');
    var request = http.MultipartRequest('POST', uri);

    request.fields['id_asset_tagging'] = idAssetTagging;
    request.fields['id_inspection'] = idInspection;
    request.fields['nama'] = nama;
    request.fields['category_item_code'] = categoryItemCode;
    request.fields['type_cable'] = typeCable;
    request.fields['category_inspection'] = categoryInspection;
    request.fields['category_inspection_detail'] = categoryInspectionDetail;
    request.fields['latitude'] = latitude;
    request.fields['longitude'] = longitude;
    request.fields['description'] = description;
    request.fields['status_ticket'] = 'Created';

    request.files.add(
        await http.MultipartFile.fromPath('panoramic', panoramicImage.path));

    request.files.add(await http.MultipartFile.fromPath('far', farImage.path));

    for (int i = 0; i < nearImages.length; i++) {
      request.files.add(await http.MultipartFile.fromPath(
          'near_${i + 1}', nearImages[i].path));
    }

    var response = await request.send();

    if (response.statusCode == 200) {
      print('Inspection result uploaded successfully');
    } else {
      print('Failed to upload inspection result: ${response.statusCode}');
      throw Exception('Failed to upload inspection result');
    }
  }

  Future<void> postAuditResult({
    required String idAssetTagging,
    required String idAudit,
    required String nama,
    required String categoryItemCode,
    required String typeCable,
    required String categoryAudit,
    required String categoryAuditDetail,
    required XFile panoramicImage,
    required XFile farImage,
    required List<XFile> nearImages,
    required String latitude,
    required String longitude,
    required String description,
  }) async {
    var uri =
        Uri.parse('https://stagingapiqms.triasmitra.com/public/api/audit-result');
    var request = http.MultipartRequest('POST', uri);

    request.fields['id_asset_tagging'] = idAssetTagging;
    request.fields['id_audit'] = idAudit;
    request.fields['nama'] = nama;
    request.fields['category_item_code'] = categoryItemCode;
    request.fields['type_cable'] = typeCable;
    request.fields['category_audit'] = categoryAudit;
    request.fields['category_audit_detail'] = categoryAuditDetail;
    request.fields['latitude'] = latitude;
    request.fields['longitude'] = longitude;
    request.fields['description'] = description;
    request.fields['status_ticket'] = 'Created';

    request.files.add(
        await http.MultipartFile.fromPath('panoramic', panoramicImage.path));

    request.files.add(await http.MultipartFile.fromPath('far', farImage.path));

    for (int i = 0; i < nearImages.length; i++) {
      request.files.add(await http.MultipartFile.fromPath(
          'near_${i + 1}', nearImages[i].path));
    }

    var response = await request.send();

    if (response.statusCode == 200) {
      print('Audit result uploaded successfully');
    } else {
      print('Failed to upload audit result: ${response.statusCode}');
      throw Exception('Failed to upload audit result');
    }
  }

  Future<void> updateTicketStatusInspectionResult(
      String? idInspection, String newStatus) async {
    if (idInspection == null || idInspection.isEmpty) {
      print('No idInspection provided, skipping updateTicketStatusResult');
      return;
    }
    const String url =
        'https://stagingapiqms.triasmitra.com/public/api/inspection-result/update-status';

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'id_inspection': idInspection,
          'status_ticket': newStatus,
        }),
      );

      if (response.statusCode == 200) {
        print('Ticket status updated successfully');
      } else {
        print('Failed to update ticket status: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to update inspection ticket status Result');
      }
    } catch (e) {
      print('Error during updating ticket status: $e');
      rethrow;
    }
  }

  Future<void> updateTicketStatusAuditResult(
      String? idAudit, String newStatus) async {
    if (idAudit == null || idAudit.isEmpty) {
      print('No id Audit provided, skipping updateTicketStatusResult');
      return;
    }
    const String url =
        'https://stagingapiqms.triasmitra.com/public/api/audit-result/update-status';

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'id_audit': idAudit,
          'status_ticket': newStatus,
        }),
      );

      if (response.statusCode == 200) {
        print('Ticket status updated successfully');
      } else {
        print('Failed to update ticket status: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to update audit ticket status Result');
      }
    } catch (e) {
      print('Error during updating ticket status: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getInspectionResultsByTagging(
      String idInspection, String nama) async {
    final response = await http.get(Uri.parse(
        'https://stagingapiqms.triasmitra.com/public/api/inspection-result/$idInspection/$nama'));

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);

      final List<dynamic> data = jsonResponse['data'];

      return data.map((item) => item as Map<String, dynamic>).toList();
    } else {
      throw Exception('Gagal mengambil hasil inspeksi');
    }
  }

  Future<List<Map<String, dynamic>>> getAuditResultsByTagging(
      String idAudit, String nama) async {
    final response = await http.get(Uri.parse(
        'https://stagingapiqms.triasmitra.com/public/api/audit-result/$idAudit/$nama'));

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);

      final List<dynamic> data = jsonResponse['data'];

      return data.map((item) => item as Map<String, dynamic>).toList();
    } else {
      throw Exception('Gagal mengambil hasil audit');
    }
  }
}

final apiService = ApiService(); // Membuat instance dari ApiService