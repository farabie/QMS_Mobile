part of '../pages.dart';

class RectificationShow extends StatefulWidget {
  final String showType;
  final String ticketNumber;
  final String step;

  const RectificationShow({
    required this.showType,
    required this.ticketNumber,
    required this.step,
    Key? key,
  }) : super(key: key);

  @override
  _RectificationShowState createState() => _RectificationShowState();
}

class _RectificationShowState extends State<RectificationShow> {
  late User user;
  Map<String, dynamic>? recordData;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController _startDateController = TextEditingController();
  TextEditingController _endDateController = TextEditingController();

  void _updateStartDateText() {
    if (startDate != null) {
      _startDateController.text = "${startDate!.toLocal()}".split('.')[0];
    }
  }

  void _updateEndDateText() {
    if (endDate != null) {
      _endDateController.text = "${endDate!.toLocal()}".split('.')[0];
    }
  }

  bool isLoading = true;
  Timer? _debounce;
  Map<String, dynamic>? rectificationData;
  Map<String, dynamic>? rectificationDetailData;
  Map<String, dynamic>? auditAdditionalData;
  Map<String, dynamic>? inspectionAdditionalData;
  List<dynamic>? installationAdditionalData;
  List<dynamic>? revisionData;
  String? selectedOption = 'Non Service Affected';
  String? activityDetails;
  String? activityLocation;
  DateTime? startDate;
  DateTime? endDate;
  List<String> selectedWorkers = [];
  List<String> selectedOptions = [];
  List<dynamic> customers = [];
  List<String> workers = [];
  // Initialize a map to hold the dropdown selections for each customer
  final Map<String, String?> dropdownSelections = {
    // Default values can be null or any initial value
    'first_Customer 1': null,
    'second_Customer 1': null,
    'first_Customer 2': null,
    'second_Customer 2': null,
    'first_Customer 3': null,
    'second_Customer 3': null,
  };

  Map<String, bool> dropdownVisibility = {}; // Tracks visibility of dropdowns

  @override
  void initState() {
    user = context.read<UserCubit>().state;
    super.initState();
    retryFetch(fetchRectificationData);
    retryFetch(fetchRecordData);
    retryFetch(fetchWorkerData);
    retryFetch(fetchCustomerData);
    retryFetch(fetchInspectionDetail);
  }

  Future<void> retryFetch(Future<void> Function() fetchMethod,
      {int maxRetries = 3}) async {
    int retryCount = 0;

    while (retryCount < maxRetries) {
      try {
        await fetchMethod(); // Call the fetch method
        return; // If successful, exit the function
      } catch (e) {
        retryCount++;
        if (e.toString().contains('429')) {
          // Handle 429 rate limiting
          final waitTime =
              Duration(seconds: 2 ^ retryCount); // Exponential backoff
          print(
              'Rate limit exceeded. Retrying in ${waitTime.inSeconds} seconds...');
          await Future.delayed(waitTime); // Wait before retrying
        } else {
          print('Error occurred: $e');
          rethrow; // If the error is not 429, rethrow it
        }
      }
    }

    // If max retries reached, throw an exception
    throw Exception('Failed to fetch data after $maxRetries attempts.');
  }

  Future<void> fetchRectificationData() async {
    final String url =
        'https://apiqms.triasmitra.com/public/api/rectification/show/${widget.ticketNumber}/ticket';

    try {
      // Perform the GET request
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Decode the JSON response
        final Map<String, dynamic> data = json.decode(response.body);

        // Assuming the API response has rectification and rectification_detail
        final rectification = data['rectification'] ?? {};
        final rectificationDetail = data['rectification_detail'] ?? {};
        final inspectionAdditional = data['inspection_additional'] ?? {};
        final auditAdditional = data['audit_additional'] ?? {};
        final installationAdditional = data['installation_additional'] ?? [];
        final revision = data['revision'] ?? []; // Fetch the revision array

        setState(() {
          // Process rectification data
          rectificationData = {
            'ticketNumber': rectification['ticket_number'] ?? '',
            'relatedTicket': rectification['related_ticket'] ?? '',
            'relatedTicketSequence':
                rectification['related_ticket_sequence'] ?? '',
            'type': rectification['type'] ?? '',
            'ttDms': rectification['tt_dms'] ?? '',
            'project': rectification['project'] ?? '',
            'segment': rectification['segment'] ?? '',
            'section': rectification['section'] ?? '',
            'area': rectification['area'] ?? '',
            'servicePoint': rectification['service_point'] ?? '',
            'spanRoute': rectification['span_route'] ?? '',
            'longitude': rectification['longitude'] ?? '',
            'latitude': rectification['latitude'] ?? '',
            'description': rectification['description'] ?? '',
            'createdAt': rectification['created_at'] ?? '',
            'nocRevisionLoop': rectification['noc_revision_loop'] ?? '',
            'spvRevisionLoop': rectification['spv_revision_loop'] ?? '',
            'opsRevisionLoop': rectification['ops_revision_loop'] ?? '',
            'status': rectification['status'] ?? '',
          };

          // Process rectification detail data
          rectificationDetailData = {
            'scheduleStart': rectificationDetail['schedule_start'] ?? '',
            'scheduleEnd': rectificationDetail['schedule_end'] ?? '',
            'workers': rectificationDetail['workers'] ?? '',
            'activityDetail': rectificationDetail['activity_detail'] ?? '',
            'activityLocation': rectificationDetail['activity_location'] ?? '',
            'impactedCustomer': rectificationDetail['impacted_customer'] ?? '',
            'sectionCustomers': rectificationDetail['section_customers'] ?? '',
            'type': rectificationDetail['type'] ?? '',
            'loopingProcess': rectificationDetail['looping_process'] ?? '',
            'createdAt': rectificationDetail['created_at'] ?? '',
          };

          // Process inspection additional data
          inspectionAdditionalData = {
            'categoryInspectionDetail':
                inspectionAdditional['category_inspection_detail'] ?? '',
            'panoramic': inspectionAdditional['panoramic'] ?? '',
            'far': inspectionAdditional['far'] ?? '',
            'near1': inspectionAdditional['near_1'] ?? '',
            'near2': inspectionAdditional['near_2'] ?? '',
            'near3': inspectionAdditional['near_3'] ?? '',
            'reason_rejected': inspectionAdditional['reason_rejected'] ?? '',
          };

          // Process inspection additional data
          auditAdditionalData = {
            'categoryAuditDetail': auditAdditional['category_audit'] ?? '',
            'panoramic': auditAdditional['panoramic'] ?? '',
            'far': auditAdditional['far'] ?? '',
            'near1': auditAdditional['near_1'] ?? '',
            'near2': auditAdditional['near_2'] ?? '',
            'near3': auditAdditional['near_3'] ?? '',
            'reason_rejected': auditAdditional['rejection_reason'] ?? '',
          };

          // Process installation additional data
          installationAdditionalData = (installationAdditional as List)
              .map((item) => {
                    'stepId': item['qms_installation_step_id'] ??
                        'No Reason Provided',
                    'reasonRejected':
                        item['reason_rejected'] ?? 'No Reason Provided',
                    'stepDescription':
                        item['step_description'] ?? 'No Description',
                    'photo_url': item['photo_url'] ?? [],
                  })
              .toList();

          // Process revision data
          try {
            revisionData = (revision as List).map((item) {
              return {
                'id': item['id'] ?? '',
                'ticketNumber': item['ticket_number'] ?? '',
                'step': item['step'] ?? 0,
                'stepName': item['step_name'] ?? '',
                'description': item['description'] ?? '',
                'longitude': item['longitude'] ?? '',
                'latitude': item['latitude'] ?? '',
                'nocRevisionLoop': item['noc_revision_loop'] ?? 0,
                'spvRevisionLoop': item['spv_revision_loop'] ?? 0,
                'opsRevisionLoop': item['ops_revision_loop'] ?? 0,
                'status': item['status'] ?? '',
                'reasonRejectSpv': item['reason_reject_spv'] ?? '',
                'statusTempSpv': item['status_temp_spv'] ?? '',
                'reasonTempSpv': item['reason_temp_spv'] ?? '',
                'reasonRejectOps': item['reason_reject_ops'],
                'statusTempOps': item['status_temp_ops'],
                'reasonTempOps': item['reason_temp_ops'],
                'executeBy': item['execute_by'] ?? '',
                'photoUrl': item['photo_url'] ?? [],
              };
            }).toList();
          } catch (e) {
            print('Error processing revision data: $e');
          }

          // Find the specific step data where stepId matches widget.step
          final currentStepData = installationAdditionalData?.firstWhere(
                (item) => item['stepId'] == widget.step,
                orElse: () => {}, // Return an empty map if no match is found
              ) ??
              {}; // Default to an empty map if installationAdditionalData is null

          // Handle currentStepData if it is found
          if (currentStepData.isNotEmpty) {
            // Do something with currentStepData (for example, display the data in the UI)
          } else {
            // Handle the case where no matching step is found
            print('No matching step found for stepId: ${widget.step}');
          }

          isLoading = false; // Set loading to false once data is fetched
        });
      } else {
        print('Failed to fetch data: ${response.statusCode}');
        isLoading = false; // Set loading to false on error
      }

      print('Response body: testing');
    } catch (e) {
      print('disini, Error occurred while fetching data: $e');
      isLoading = false; // Set loading to false on error
    }
  }

  Future<void> fetchRecordData() async {
    final url = Uri.parse(
      'https://apiqms.triasmitra.com/public/api/rectification_record/show/${widget.ticketNumber}/${widget.step}',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          recordData = json.decode(response.body);
        });
        print(url);
      } else {
        // Handle error response
        print('Failed to load data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> fetchCustomerData() async {
    final url = Uri.parse(
        'https://apiqms.triasmitra.com/public/api/rectification/show/${widget.ticketNumber}/customer');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          customers = data['customers'];
          // Initialize dropdown visibility and selections for each customer
          for (var customer in customers) {
            dropdownVisibility[customer['company_name']] = false;
            // Set the first section name as the default value for the first dropdown
            dropdownSelections['first_${customer['company_name']}'] =
                customer['additional_data'].isNotEmpty
                    ? customer['additional_data'][0]['customer_section_name']
                    : 'No sections available';
            // Set the default value for the second dropdown to "Empty"
            dropdownSelections['second_${customer['company_name']}'] = 'Empty';
          }
        });
      } else {
        throw Exception('Failed to load customer data');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<void> fetchWorkerData() async {
    String url =
        'https://apiqms.triasmitra.com/public/api/rectification/index/worker/${user.serpo}';

    try {
      // Perform the GET request
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Decode the JSON response as a list of strings
        final List<dynamic> data = json.decode(response.body);

        setState(() {
          workers = List<String>.from(data);
          // Use the 'workers' list as needed, for example, assigning it to a state variable
        });
      } else {
        // Handle the error response
        // print('Failed to load worker data: ${response.statusCode}');
      }
    } catch (e) {
      // print('Error occurred while fetching data: $e');
    }
  }

  Future<void> fetchInspectionDetail() async {}

  Future<void> submitData() async {
    // Show loading indicator

    // Validate form fields
    if (!_formKey.currentState!.validate()) {
      return; // Stop if form validation fails
    }

    // Validate worker selection
    if (selectedWorkers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: const Text('Please select at least one worker'),
          backgroundColor: Colors.red,
        ),
      );
      return; // Stop submission
    }

    setState(() {
      isLoading = true; // Set a loading state variable to true
    });

    // Optionally add a delay to simulate waiting
    await Future.delayed(Duration(seconds: 1)); // Add a delay (e.g., 1 second)

    // Prepare the data to send
    String interruptService = selectedOption ?? 'No'; // 'Yes' or 'No'

    // Convert DateTime to string format
    String? formattedStartDate = startDate?.toIso8601String();
    String? formattedEndDate = endDate?.toIso8601String();

    // Create a list to hold impacted customers with the desired structure
    List<List<String?>> impactedCustomers = [];

    for (var customer in customers) {
      String companyName = customer['company_name']; // Extract company name

      if (selectedOptions.contains(companyName)) {
        // Retrieve section data
        String? firstSection = dropdownSelections['first_$companyName'];
        String? secondSection = dropdownSelections['second_$companyName'];

        // Add customer data in the desired format
        impactedCustomers.add([
          companyName, // Customer name
          firstSection, // First section
          secondSection // Second section
        ]);
      }
    }

    Map<String, dynamic> dataToSend = {
      'acknowledged_by': user.username,
      'spv_approval': user.atasanName,
      'ops_approval': user.clusterName,
      'startDate': formattedStartDate,
      'endDate': formattedEndDate,
      'interruptService': interruptService,
      'selectedWorkers': selectedWorkers,
      'ticketNumber': widget.ticketNumber,
      'activityDetails': activityDetails,
      'activityLocation': activityLocation,
      'storeType': "detail",
    };

    // Conditionally add fields if `interruptService` is 'Yes'
    if (interruptService == 'Service Affected') {
      dataToSend.addAll({
        'impactedCustomers': impactedCustomers,
      });
    }

    try {
      // Send the POST request to the API
      final response = await http.post(
        Uri.parse(
            'https://apiqms.triasmitra.com/public/api/rectification/store'),
        headers: {
          'Content-Type': 'application/json', // Set the request content type
        },
        body: json.encode(dataToSend),
      );

      // Check the response status
      if (response.statusCode == 200) {
        print('Data submitted successfully: ${response}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Ticket Is Successfully Acknowledge'),
            backgroundColor: AppColor.saveButton,
          ),
        );
      } else {
        // Decode the JSON response to extract the error message
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        String errorMessage = responseData['error'] ?? 'Something went wrong';

        print('Failed to submit data: ${response.statusCode}');
        print('Error: $errorMessage');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Acknowledge Ticket Failed: $errorMessage'),
            backgroundColor: AppColor.closeButton,
          ),
        );
      }
    } catch (error) {
      print('Error submitting data: $error');
    } finally {
      // Hide loading indicator
      setState(() {
        isLoading = false; // Set loading state to false when done
      });
    }
  }

  void showStepDetails(BuildContext context, Map<String, dynamic>? stepData) {
    if (stepData == null) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Detail Step Information',
            style: TextStyle(
              color: AppColor.defaultText,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Step: ${stepData['stepId'] ?? 'Step ID'}'),
              Text(
                  'Step Description: ${stepData['stepDescription'] ?? 'No Description'}'),
              SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: (stepData['photoUrl'] ?? []).map<Widget>((photoUrl) {
                  return GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => Dialog(
                          child: InteractiveViewer(
                            child: Image.network(
                              'https://apiqms.triasmitra.com/storage/app/public/${photoUrl}',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.error);
                              },
                            ),
                          ),
                        ),
                      );
                    },
                    child: Image.network(
                      'https://apiqms.triasmitra.com/storage/app/public/${photoUrl}',
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.error);
                      },
                    ),
                  );
                }).toList(),
              ),
              // Add more fields as needed
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Close'),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                8), // Set smaller radius for less rounding
          ),
        );
      },
    );
  }

  void showRejectedRevision(
      BuildContext context, Map<String, dynamic>? stepData) {
    if (stepData == null) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Reject Detail',
            style: TextStyle(
              color: AppColor.defaultText,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  'Step ${stepData['step'] ?? 'Step ID'} : ${stepData['stepName'] ?? 'Step ID'}'),
              Text(
                (rectificationData?['spvRevisionLoop'] ?? 0) == 0
                    ? ' Ops Team ${stepData['reasonRejectOps'] ?? ''}'
                    : ' SPV ${stepData['reasonRejectSpv'] ?? ''}',
              ),

              SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: (stepData['photoUrl'] ?? []).map<Widget>((photoUrl) {
                  if (photoUrl == null || photoUrl.isEmpty) {
                    return const Icon(Icons
                        .error); // Return an error icon if photoUrl is invalid
                  }

                  return GestureDetector(
                    onTap: () {
                      // Construct the URL
                      final String imageUrl =
                          'https://apiqms.triasmitra.com/storage/app/public/rectification/${stepData['ticketNumber']}/${stepData['step']}/${photoUrl}';

                      // Print the URL to the console

                      // Show a dialog with the full-size image
                      showDialog(
                        context: context,
                        builder: (context) => Dialog(
                          child: InteractiveViewer(
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons
                                    .error); // Error icon for invalid image URL
                              },
                            ),
                          ),
                        ),
                      );
                    },
                    child: Image.network(
                      // Thumbnail URL
                      'https://apiqms.triasmitra.com/storage/app/public/rectification/${stepData['ticketNumber']}/${stepData['step']}/${photoUrl}',
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                            Icons.error); // Error icon for thumbnail issues
                      },
                    ),
                  );
                }).toList(),
              ),
              // Add more fields as needed
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Close'),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                8), // Set smaller radius for less rounding
          ),
        );
      },
    );
  }

  void _delay() {
    setState(() {
      isLoading = true; // Show loading indicator immediately
    });

    // Use a microtask to allow the UI to update first
    Future.microtask(() {
      if (_debounce?.isActive ?? false) _debounce?.cancel();

      _debounce = Timer(const Duration(milliseconds: 5000), () {
        setState(() {
          isLoading = false; // Stop loading when done
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RectificationCreate(
              ticketNumber: widget.ticketNumber,
              createType: 'result',
            ),
          ),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (rectificationData == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    switch (widget.showType) {
      case 'form_acknowledge':
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: const ui.Size.fromHeight(60.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    offset: const Offset(0, 3),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: IconButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MainPage(initialIndex: 3),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                    ),
                  ),
                ),
                title: Text(
                  'Form Acknowledge',
                  style: TextStyle(
                    color: AppColor.defaultText,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                centerTitle: true,
              ),
            ),
          ),
          body: isLoading
              ? const Center(
                  child: CircularProgressIndicator(), // Loading indicator
                )
              : SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
                  child: Form(
                    key: _formKey, // Assign the form key
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Gap(20),
                                const Text(
                                  'Rectification Category',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Flexible(
                                      child: RadioListTile<String>(
                                        title: const Text(
                                          'Service Affected',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                        value: 'Service Affected',
                                        groupValue: selectedOption,
                                        contentPadding: EdgeInsets.zero,
                                        onChanged: (value) {
                                          setState(() {
                                            selectedOption = value;
                                            startDate =
                                                null; // Reset start date
                                            endDate = null; // Reset end date
                                            _startDateController
                                                .clear(); // Clear text field
                                            _endDateController
                                                .clear(); // Clear text field
                                          });
                                        },
                                      ),
                                    ),
                                    Flexible(
                                      child: RadioListTile<String>(
                                        title: const Text(
                                          'Non Service Affected',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                        value: 'Non Service Affected',
                                        groupValue: selectedOption,
                                        contentPadding: EdgeInsets.zero,
                                        onChanged: (value) {
                                          setState(() {
                                            selectedOption = value;
                                            startDate =
                                                null; // Reset start date
                                            endDate = null; // Reset end date
                                            _startDateController
                                                .clear(); // Clear text field
                                            _endDateController
                                                .clear(); // Clear text field
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const Gap(10),
                                const Text(
                                  'Activity Details',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                TextFormField(
                                  decoration: const InputDecoration(
                                    border:
                                        OutlineInputBorder(), // Outline for input box
                                  ),
                                  maxLines: 3, // Multiline input
                                  style: const TextStyle(
                                    fontSize:
                                        12, // Decrease font size here as well
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      activityDetails =
                                          value; // Save the value directly
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Activity Details is required';
                                    }
                                    return null;
                                  },
                                ),
                                const Gap(10),
                                const Text(
                                  'Activity Location',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                TextFormField(
                                  decoration: const InputDecoration(
                                    border:
                                        OutlineInputBorder(), // Outline for input box
                                  ),
                                  maxLines: 3, // Multiline input
                                  style: const TextStyle(
                                    fontSize:
                                        12, // Decrease font size here as well
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      activityLocation =
                                          value; // Save the value directly
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Activity Location is required';
                                    }
                                    return null;
                                  },
                                ),
                                if (selectedOption == 'Service Affected') ...[
                                  const SizedBox(height: 8.0),
                                  const Text(
                                    'Impacted Customers',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Column(
                                    children: customers.map((customer) {
                                      return Card(
                                        elevation: 4,
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 8, horizontal: 0),
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius
                                              .zero, // No rounded corners
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(
                                              1.0), // Padding inside each card
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Transform.translate(
                                                offset: const Offset(-16,
                                                    0), // Shift left by 16 pixels
                                                child: CheckboxListTile(
                                                  title: Text(
                                                    customer['company_name'],
                                                    style: const TextStyle(
                                                        fontSize: 12),
                                                  ),
                                                  value: selectedOptions
                                                      .contains(customer[
                                                          'company_name']),
                                                  controlAffinity:
                                                      ListTileControlAffinity
                                                          .leading, // Checkbox on the left
                                                  onChanged: (bool? value) {
                                                    setState(() {
                                                      if (value == true) {
                                                        selectedOptions.add(
                                                            customer[
                                                                'company_name']);
                                                        dropdownVisibility[customer[
                                                                'company_name']] =
                                                            true; // Show dropdowns
                                                      } else {
                                                        selectedOptions.remove(
                                                            customer[
                                                                'company_name']);
                                                        dropdownVisibility[customer[
                                                                'company_name']] =
                                                            false; // Hide dropdowns
                                                      }
                                                    });
                                                  },
                                                ),
                                              ),
                                              if (dropdownVisibility[customer[
                                                      'company_name']] ==
                                                  true) ...[
                                                const Divider(
                                                  color: Colors.grey,
                                                  thickness: .8,
                                                  indent: 16.0,
                                                  endIndent: 16.0,
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 58.0),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const Text(
                                                        'Section Customer',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 12),
                                                      ),
                                                      SizedBox(
                                                        width: 200,
                                                        child: DropdownButton<
                                                            String>(
                                                          isExpanded: true,
                                                          value: dropdownSelections[
                                                              'first_${customer['company_name']}'],
                                                          // Removed hint for the first dropdown; now it directly displays the first section
                                                          items: customer[
                                                                  'additional_data']
                                                              .map<
                                                                  DropdownMenuItem<
                                                                      String>>((section) =>
                                                                  DropdownMenuItem<
                                                                      String>(
                                                                    value: section[
                                                                        'customer_section_name'],
                                                                    child: Text(
                                                                        section[
                                                                            'customer_section_name'],
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                12)),
                                                                  ))
                                                              .toList(),
                                                          onChanged: (value) {
                                                            setState(() {
                                                              dropdownSelections[
                                                                      'first_${customer['company_name']}'] =
                                                                  value;
                                                            });
                                                          },
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 200,
                                                        child: DropdownButton<
                                                            String>(
                                                          isExpanded: true,
                                                          value: dropdownSelections[
                                                              'second_${customer['company_name']}'],
                                                          // Set "Empty" as the default hint for the second dropdown
                                                          items: [
                                                            const DropdownMenuItem<
                                                                String>(
                                                              value: 'Empty',
                                                              child: Text(
                                                                  'Empty',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          12)),
                                                            ),
                                                            ...customer[
                                                                    'additional_data']
                                                                .map<
                                                                        DropdownMenuItem<
                                                                            String>>(
                                                                    (section) {
                                                              return DropdownMenuItem<
                                                                  String>(
                                                                value: section[
                                                                    'customer_section_name'],
                                                                child: Text(
                                                                    section[
                                                                        'customer_section_name'],
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            12)),
                                                              );
                                                            }).toList()
                                                          ],
                                                          onChanged: (value) {
                                                            setState(() {
                                                              dropdownSelections[
                                                                      'second_${customer['company_name']}'] =
                                                                  value;
                                                            });
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                  const Gap(10),
                                ],
                                const Gap(20),
                                const Text(
                                  'Proposed Schedule',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                // Start Date Input
                                // Start Date with Time Input
                                TextFormField(
                                  controller: _startDateController,
                                  readOnly:
                                      true, // Make it read-only to prevent manual input
                                  decoration: InputDecoration(
                                    labelText: 'Start Date & Time',
                                    labelStyle: const TextStyle(
                                        fontSize: 12), // Smaller label size
                                    border: OutlineInputBorder(),
                                    suffixIcon: IconButton(
                                      icon: const Icon(
                                        Icons.calendar_today,
                                        size: 16, // Smaller icon size
                                      ),
                                      onPressed: () async {
                                        // Set initialDate to 4 days after today
                                        final DateTime today = DateTime.now();
                                        final DateTime restrictedDate =
                                            today.add(Duration(days: 4));
                                        final DateTime initialDate =
                                            selectedOption == 'Service Affected'
                                                ? restrictedDate
                                                : today;

                                        final DateTime? pickedDate =
                                            await showDatePicker(
                                          context: context,
                                          initialDate:
                                              initialDate, // Set initial date to 4 days after today
                                          firstDate: selectedOption ==
                                                  'Service Affected'
                                              ? restrictedDate
                                              : today,
                                          lastDate: DateTime(
                                              2101), // Adjust this as needed
                                          selectableDayPredicate:
                                              (DateTime date) {
                                            if (selectedOption ==
                                                'Service Affected') {
                                              return date.isAfter(
                                                      restrictedDate.subtract(
                                                          Duration(days: 1))) ||
                                                  date.isAtSameMomentAs(
                                                      restrictedDate);
                                            }
                                            return true; // No restriction for 'Non Service Affected'
                                          },
                                        );

                                        if (pickedDate != null) {
                                          final TimeOfDay? pickedTime =
                                              await showTimePicker(
                                            context: context,
                                            initialTime: TimeOfDay.now(),
                                          );

                                          if (pickedTime != null) {
                                            setState(() {
                                              startDate = DateTime(
                                                pickedDate.year,
                                                pickedDate.month,
                                                pickedDate.day,
                                                pickedTime.hour,
                                                pickedTime.minute,
                                              );
                                            });
                                            _updateStartDateText();
                                          }
                                        }
                                      },
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Start Date & Time is required';
                                    }
                                    return null;
                                  },
                                  style: const TextStyle(
                                      fontSize:
                                          12), // Smaller font size for input text
                                ),
                                const SizedBox(
                                    height: 10.0), // Space between inputs
                                // End Date with Time Input
                                TextFormField(
                                  controller: _endDateController,
                                  readOnly:
                                      true, // Make it read-only to prevent manual input
                                  decoration: InputDecoration(
                                    labelText: 'End Date & Time',
                                    labelStyle: const TextStyle(
                                        fontSize: 12), // Smaller label size
                                    border: OutlineInputBorder(),
                                    suffixIcon: IconButton(
                                      icon: const Icon(
                                        Icons.calendar_today,
                                        size: 16, // Smaller icon size
                                      ),
                                      onPressed: () async {
                                        // Dynamically set initialDate to 4 days after the selected startDate (if available)
                                        final DateTime today = DateTime.now();
                                        final DateTime restrictedDate =
                                            today.add(Duration(days: 4));
                                        final DateTime initialDate =
                                            selectedOption == 'Service Affected'
                                                ? restrictedDate
                                                : today;

                                        final DateTime? pickedDate =
                                            await showDatePicker(
                                          context: context,
                                          initialDate:
                                              initialDate, // Dynamic initial date
                                          firstDate: selectedOption ==
                                                  'Service Affected'
                                              ? restrictedDate
                                              : today,
                                          lastDate: DateTime(
                                              2101), // Adjust this as needed
                                          selectableDayPredicate:
                                              (DateTime date) {
                                            if (selectedOption ==
                                                'Service Affected') {
                                              return date.isAfter(
                                                      restrictedDate.subtract(
                                                          Duration(days: 1))) ||
                                                  date.isAtSameMomentAs(
                                                      restrictedDate);
                                            }
                                            return true; // No restriction for 'Non Service Affected'
                                          },
                                        );

                                        if (pickedDate != null) {
                                          final TimeOfDay? pickedTime =
                                              await showTimePicker(
                                            context: context,
                                            initialTime: TimeOfDay.now(),
                                          );

                                          if (pickedTime != null) {
                                            setState(() {
                                              endDate = DateTime(
                                                pickedDate.year,
                                                pickedDate.month,
                                                pickedDate.day,
                                                pickedTime.hour,
                                                pickedTime.minute,
                                              );
                                            });
                                            _updateEndDateText();
                                          }
                                        }
                                      },
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'End Date & Time is required';
                                    }
                                    return null;
                                  },
                                  style: const TextStyle(
                                      fontSize:
                                          12), // Smaller font size for input text
                                ),
                                const Gap(20),
                                const Text(
                                  'Worker Assignment',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                Column(
                                  children: workers.map((worker) {
                                    return Card(
                                      elevation: 4,
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 0),
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius
                                            .zero, // No rounded corners
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(
                                            1.0), // Padding inside each card
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Transform.translate(
                                              offset: const Offset(-16,
                                                  0), // Shift left by 16 pixels; adjust as needed
                                              child: CheckboxListTile(
                                                title: Text(
                                                  worker,
                                                  style: const TextStyle(
                                                      fontSize: 12),
                                                ),
                                                value: selectedWorkers.contains(
                                                    worker), // Use selectedWorkers instead of selectedOptions
                                                controlAffinity:
                                                    ListTileControlAffinity
                                                        .leading, // Checkbox on the left
                                                onChanged: (bool? value) {
                                                  setState(() {
                                                    if (value == true) {
                                                      selectedWorkers.add(
                                                          worker); // Add worker if checkbox is checked
                                                    } else {
                                                      selectedWorkers.remove(
                                                          worker); // Remove worker if checkbox is unchecked
                                                    }
                                                  });
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 8.0),
                                const Gap(10),
                                DButtonBorder(
                                  onClick: () async {
                                    if (_formKey.currentState!.validate()) {
                                      if (selectedWorkers.isNotEmpty) {
                                        await submitData(); // Wait for submission to complete

                                        if (mounted && !isLoading) {
                                          // Ensure the widget is still active and loading is finished
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => MainPage(
                                                key: UniqueKey(),
                                                initialIndex: 0,
                                              ),
                                            ),
                                          );
                                        }
                                      }
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Please fill in all required fields'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
                                  mainColor: Colors.white,
                                  radius: 10,
                                  borderColor: AppColor.scaffold,
                                  child: isLoading
                                      ? const CircularProgressIndicator() // Show loading indicator
                                      : const Text(
                                          'Acknowledge',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                        ),
                                ),
                                const Gap(10),
                              ],
                            ),
                          ),
                        ),
                        // here
                      ],
                    ),
                  ),
                ),
        );
      case 'acknowledge':
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: const ui.Size.fromHeight(60.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    offset: const Offset(0, 3),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: IconButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MainPage(initialIndex: 3),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                    ),
                  ),
                ),
                title: Text(
                  'Detail Ticket',
                  style: TextStyle(
                    color: AppColor.defaultText,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                centerTitle: true,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // here
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            rectificationData!['ticketNumber'],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColor.defaultText,
                            ),
                          ),
                          Divider(
                            color: AppColor.greyColor2,
                          ),

                          // Other Fields (QMS Rectification Ticket Number, Project, etc.)
                          InputWidget.disable(
                            'QMS ${rectificationData!['type']} Ticket Number',
                            TextEditingController(
                                text: rectificationData!['relatedTicket']),
                          ),
                          InputWidget.disable(
                            'Cable Project',
                            TextEditingController(
                                text: rectificationData!['project']),
                          ),
                          InputWidget.disable(
                            'Segment',
                            TextEditingController(
                                text: rectificationData!['segment']),
                          ),
                          InputWidget.disable(
                            'Section',
                            TextEditingController(
                                text: rectificationData!['section']),
                          ),
                          if (rectificationData!['type'] == 'installation')
                            InputWidget.disable(
                              'Area',
                              TextEditingController(
                                  text: rectificationData!['area']),
                            ),
                          InputWidget.disable(
                            'Service Point',
                            TextEditingController(
                                text: rectificationData!['servicePoint']),
                          ),
                          InputWidget.disable(
                            'Longitude',
                            TextEditingController(
                                text: rectificationData!['longitude']),
                          ),
                          InputWidget.disable(
                            'Latitude',
                            TextEditingController(
                                text: rectificationData!['latitude']),
                          ),
                          if (rectificationData!['type'] == 'inspection')
                            InputWidget.disable(
                              'Description',
                              TextEditingController(
                                  text: rectificationData!['description']),
                            ),
                          const Gap(20),
                        ],
                      ),
                    ),
                  ),
                  if ((rectificationData?['spvRevisionLoop'] ?? 0) == 0 &&
                      (rectificationData?['opsRevisionLoop'] ?? 0) == 0)
                    (() {
                      switch (rectificationData!['type']) {
                        case 'inspection':
                          return Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Gap(20),
                                  // Other Fields (QMS Rectification Ticket Number, Project, etc.)
                                  InputWidget.disable(
                                    'Span Route',
                                    TextEditingController(
                                        text: rectificationData!['spanRoute']),
                                  ),
                                  InputWidget.disable(
                                    'Description',
                                    TextEditingController(
                                        text: inspectionAdditionalData?[
                                            'categoryInspectionDetail']),
                                  ),
                                  const Gap(20),
                                  const Text(
                                    'Panoramic View',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) => Dialog(
                                              child: InteractiveViewer(
                                                child: Image.network(
                                                  'https://apiqms.triasmitra.com/storage/app/public/${inspectionAdditionalData?['panoramic']}',
                                                  fit: BoxFit.contain,
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return const Icon(
                                                        Icons.error);
                                                  },
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                        child: Image.network(
                                          'https://apiqms.triasmitra.com/storage/app/public/${inspectionAdditionalData?['panoramic']}',
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return const Icon(Icons.error);
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  Gap(20),
                                  const Text(
                                    'Far View',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) => Dialog(
                                              child: InteractiveViewer(
                                                child: Image.network(
                                                  'https://apiqms.triasmitra.com/storage/app/public/${inspectionAdditionalData?['far']}',
                                                  fit: BoxFit.contain,
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return const Icon(
                                                        Icons.error);
                                                  },
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                        child: Image.network(
                                          'https://apiqms.triasmitra.com/storage/app/public/${inspectionAdditionalData?['panoramic']}',
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return const Icon(Icons.error);
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  Gap(20),
                                  const Text(
                                    'Near View',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Gap(20),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      buildImage(context,
                                          inspectionAdditionalData?['near1']),
                                      buildImage(context,
                                          inspectionAdditionalData?['near2']),
                                      buildImage(context,
                                          inspectionAdditionalData?['near3']),
                                    ],
                                  ),
                                  Gap(20),
                                ],
                              ),
                            ),
                          );
                        case 'quality_audit':
                          return Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Gap(20),
                                  // Other Fields (QMS Rectification Ticket Number, Project, etc.)
                                  InputWidget.disable(
                                    'Span Route',
                                    TextEditingController(
                                        text: rectificationData!['spanRoute']),
                                  ),
                                  InputWidget.disable(
                                    'Description',
                                    TextEditingController(
                                        text: auditAdditionalData?[
                                            'categoryAuditDetail']),
                                  ),
                                  const Gap(20),
                                  const Text(
                                    'Panoramic View',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) => Dialog(
                                              child: InteractiveViewer(
                                                child: Image.network(
                                                  'https://apiqms.triasmitra.com/storage/app/public/${auditAdditionalData?['panoramic']}',
                                                  fit: BoxFit.contain,
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return const Icon(
                                                        Icons.error);
                                                  },
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                        child: Image.network(
                                          'https://apiqms.triasmitra.com/storage/app/public/${auditAdditionalData?['panoramic']}',
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return const Icon(Icons.error);
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  Gap(20),
                                  const Text(
                                    'Far View',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) => Dialog(
                                              child: InteractiveViewer(
                                                child: Image.network(
                                                  'https://apiqms.triasmitra.com/storage/app/public/${auditAdditionalData?['far']}',
                                                  fit: BoxFit.contain,
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return const Icon(
                                                        Icons.error);
                                                  },
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                        child: Image.network(
                                          'https://apiqms.triasmitra.com/storage/app/public/${auditAdditionalData?['panoramic']}',
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return const Icon(Icons.error);
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  Gap(20),
                                  const Text(
                                    'Near View',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Gap(20),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      buildImage(context,
                                          auditAdditionalData?['near1']),
                                      buildImage(context,
                                          auditAdditionalData?['near2']),
                                      buildImage(context,
                                          auditAdditionalData?['near3']),
                                    ],
                                  ),
                                  Gap(20),
                                ],
                              ),
                            ),
                          );
                        case 'installation':
                          return Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 16, 16, 80),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Installation Step',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount:
                                        installationAdditionalData?.length ?? 0,
                                    itemBuilder: (context, index) {
                                      // Extract the current step data
                                      final stepData =
                                          installationAdditionalData?[index];

                                      return GestureDetector(
                                        onTap: () {
                                          showStepDetails(context, stepData);
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 12.0),
                                          child: Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16.0,
                                                vertical: 12.0),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              border: Border.all(
                                                  color: Colors.black),
                                            ),
                                            child: Text(
                                              // Extract and display the last two digits of 'stepId'
                                              'Step ${stepData?['stepId'] != null ? stepData!['stepId'].split('.').last.substring(stepData!['stepId'].split('.').last.length - 2) : 'Unknown'}: ${stepData?['stepDescription'] ?? 'No Description'}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        default:
                          // Return an empty widget if no matching type
                          return SizedBox.shrink();
                      }
                    })(),

                  if ((rectificationData?['spvRevisionLoop'] ?? 0) > 0 ||
                      (rectificationData?['opsRevisionLoop'] ?? 0) > 0)
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Rejected Rectification',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: revisionData?.length ?? 0,
                              itemBuilder: (context, index) {
                                final stepData = revisionData?[index];
                                return GestureDetector(
                                  onTap: () {
                                    showRejectedRevision(context, stepData);
                                  },
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 12.0),
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0, vertical: 12.0),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: Colors.black),
                                      ),
                                      child: Text(
                                        'Step ${stepData?['step'] ?? 'No Step : '} : ${stepData?['stepName'] ?? 'No Description'} ',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  // End Condition
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Gap(10),
                          DButtonBorder(
                            onClick: () {
                              Navigator.pushReplacementNamed(
                                context,
                                AppRoute.rectificationShow,
                                arguments: {
                                  'ticketNumber':
                                      rectificationData!['ticketNumber'],
                                  'showType': 'form_acknowledge',
                                  'step': '-',
                                },
                              );
                            },
                            mainColor: Colors.white,
                            radius: 10,
                            borderColor: AppColor.scaffold,
                            child: const Text(
                              'Next',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const Gap(10),
                        ],
                      ),
                    ),
                  ),
                  // here
                ],
              ),
            ),
          ),
        );
      case 'record':
        return Scaffold(
          // appBar: AppBarWidget.secondary('Detail Ticket ${nextStep}', context),
          appBar: PreferredSize(
            preferredSize: const ui.Size.fromHeight(60.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5), // Shadow color
                    offset: const Offset(0, 3), // x = 0, y = 3
                    blurRadius: 10, // blur = 10
                  ),
                ],
              ),
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: Padding(
                  padding: const EdgeInsets.only(
                    left: 10,
                  ),
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        isLoading = true; // Show loading indicator immediately
                      });
                      _delay();
                    },
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                    ),
                  ),
                ),
                title: Text(
                  'Detail Rectification Step Result ',
                  style: TextStyle(
                    color: AppColor.defaultText,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                centerTitle: true,
              ),
            ),
          ),

          body: isLoading
              ? const Center(
                  child: CircularProgressIndicator(), // Loading indicator
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 24),
                        physics: const BouncingScrollPhysics(),
                        children: [
                          Form(
                            key: _formKey,
                            child: formRecordContent(
                              context,
                              widget.ticketNumber,
                              rectificationData?['relatedTicket'] ?? '',
                              widget.step.toString(),
                              recordData?['longitude'] ?? '',
                              recordData?['latitude'] ?? '',
                              recordData?['description'] ?? '',
                              recordData?['step_name'] ?? '',
                              List<String>.from(recordData?['files'] ?? []),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        );

      default:
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: const ui.Size.fromHeight(60.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    offset: const Offset(0, 3),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: IconButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MainPage(initialIndex: 3),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                    ),
                  ),
                ),
                title: Text(
                  'Detail Ticket default',
                  style: TextStyle(
                    color: AppColor.defaultText,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                centerTitle: true,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // here
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            rectificationData!['ticketNumber'],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColor.defaultText,
                            ),
                          ),
                          Divider(
                            color: AppColor.greyColor2,
                          ),

                          // Other Fields (QMS Rectification Ticket Number, Project, etc.)
                          InputWidget.disable(
                            'QMS ${rectificationData!['type']} Ticket Number',
                            TextEditingController(
                                text: rectificationData!['relatedTicket']),
                          ),
                          InputWidget.disable(
                            'Cable Project',
                            TextEditingController(
                                text: rectificationData!['project']),
                          ),
                          InputWidget.disable(
                            'Segment',
                            TextEditingController(
                                text: rectificationData!['segment']),
                          ),
                          InputWidget.disable(
                            'Section',
                            TextEditingController(
                                text: rectificationData!['section']),
                          ),
                          if (rectificationData!['type'] == 'installation')
                            InputWidget.disable(
                              'Area',
                              TextEditingController(
                                  text: rectificationData!['area']),
                            ),
                          InputWidget.disable(
                            'Service Point',
                            TextEditingController(
                                text: rectificationData!['servicePoint']),
                          ),
                          InputWidget.disable(
                            'Longitude',
                            TextEditingController(
                                text: rectificationData!['longitude']),
                          ),
                          InputWidget.disable(
                            'Latitude',
                            TextEditingController(
                                text: rectificationData!['latitude']),
                          ),
                          if (rectificationData!['type'] == 'inspection')
                            InputWidget.disable(
                              'Description',
                              TextEditingController(
                                  text: rectificationData!['description']),
                            ),
                          const Gap(20),
                        ],
                      ),
                    ),
                  ),

                  // Middle Card (conditional based on type)
                  (() {
                    switch (rectificationData!['type']) {
                      case 'inspection':
                        return Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Gap(20),
                                // Other Fields (QMS Rectification Ticket Number, Project, etc.)
                                InputWidget.disable(
                                  'Span Route',
                                  TextEditingController(
                                      text: rectificationData!['spanRoute']),
                                ),
                                InputWidget.disable(
                                  'Description',
                                  TextEditingController(
                                      text: inspectionAdditionalData![
                                          'categoryInspectionDetail']),
                                ),

                                Gap(20),
                                const Text(
                                  'Panoramic View',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600),
                                ),
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => Dialog(
                                            child: InteractiveViewer(
                                              child: Image.network(
                                                'https://apiqms.triasmitra.com/storage/app/public/${inspectionAdditionalData!['panoramic']}',
                                                fit: BoxFit.contain,
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  return const Icon(
                                                      Icons.error);
                                                },
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      child: Image.network(
                                        'https://apiqms.triasmitra.com/storage/app/public/${inspectionAdditionalData!['panoramic']}',
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return const Icon(Icons.error);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                Gap(20),
                                const Text(
                                  'Far View',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600),
                                ),
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => Dialog(
                                            child: InteractiveViewer(
                                              child: Image.network(
                                                'https://apiqms.triasmitra.com/storage/app/public/${inspectionAdditionalData!['far']}',
                                                fit: BoxFit.contain,
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  return const Icon(
                                                      Icons.error);
                                                },
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      child: Image.network(
                                        'https://apiqms.triasmitra.com/storage/app/public/${inspectionAdditionalData!['panoramic']}',
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return const Icon(Icons.error);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                Gap(20),
                                const Text(
                                  'Near View',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600),
                                ),
                                Gap(20),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    buildImage(context,
                                        inspectionAdditionalData!['near1']),
                                    buildImage(context,
                                        inspectionAdditionalData!['near2']),
                                    buildImage(context,
                                        inspectionAdditionalData!['near3']),
                                  ],
                                ),
                                Gap(20),
                              ],
                            ),
                          ),
                        );
                      case 'installation':
                        return Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Gap(20),
                                if (installationAdditionalData != null &&
                                    installationAdditionalData!.isNotEmpty)
                                  ...installationAdditionalData!.map((item) {
                                    return Card(
                                      elevation:
                                          2, // Adjust elevation for shadow effect
                                      margin: const EdgeInsets.only(
                                          bottom: 12), // Spacing between cards
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            8), // Rounded corners
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Step Item (Using dynamic data from each item)
                                            InputWidget.disable(
                                              'Step Item',
                                              TextEditingController(
                                                text: item['stepDescription'] ??
                                                    'No Item', // Convert to string
                                              ),
                                            ),
                                            // Description (Using dynamic data from each item)
                                            InputWidget.disable(
                                              'Review OPS',
                                              TextEditingController(
                                                text: item['reason_rejected'] ??
                                                    'No Review',
                                              ),
                                            ),
                                            // Add more widgets here as necessary
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                              ],
                            ),
                          ),
                        );
                      default:
                        // Return an empty widget if no matching type
                        return SizedBox.shrink();
                    }
                  })(),
                  // End Condition
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Gap(20),
                          const Text(
                            'Rectification Category',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Flexible(
                                child: RadioListTile<String>(
                                  title: const Text(
                                    'Service Affected',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  value: 'Service Affected',
                                  groupValue: selectedOption,
                                  contentPadding: EdgeInsets.zero,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedOption = value;
                                    });
                                  },
                                ),
                              ),
                              Flexible(
                                child: RadioListTile<String>(
                                  title: const Text(
                                    'Non Service Affected',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  value: 'Non Service Affected',
                                  groupValue: selectedOption,
                                  contentPadding: EdgeInsets.zero,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedOption = value;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          if (selectedOption == 'Service Affected') ...[
                            const Gap(10),
                            const Text(
                              'Activity Details',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            TextFormField(
                              decoration: const InputDecoration(
                                border:
                                    OutlineInputBorder(), // Outline for input box
                              ),
                              maxLines: 3, // Multiline input
                              style: const TextStyle(
                                fontSize: 12, // Decrease font size here as well
                              ),
                              onChanged: (value) {
                                setState(() {
                                  activityDetails =
                                      value; // Save the value directly
                                });
                              },
                            ),
                            const Gap(10),
                            const Text(
                              'Activity Location',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            TextFormField(
                              decoration: const InputDecoration(
                                border:
                                    OutlineInputBorder(), // Outline for input box
                              ),
                              maxLines: 3, // Multiline input
                              style: const TextStyle(
                                fontSize: 12, // Decrease font size here as well
                              ),
                              onChanged: (value) {
                                setState(() {
                                  activityLocation =
                                      value; // Save the value directly
                                });
                              },
                            ),
                            const SizedBox(height: 8.0),
                            const Text(
                              'Impacted Customers',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            Column(
                              children: customers.map((customer) {
                                return Card(
                                  elevation: 4,
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 0),
                                  shape: const RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.zero, // No rounded corners
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(
                                        1.0), // Padding inside each card
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Transform.translate(
                                          offset: const Offset(-16,
                                              0), // Shift left by 16 pixels
                                          child: CheckboxListTile(
                                            title: Text(
                                              customer['company_name'],
                                              style:
                                                  const TextStyle(fontSize: 12),
                                            ),
                                            value: selectedOptions.contains(
                                                customer['company_name']),
                                            controlAffinity: ListTileControlAffinity
                                                .leading, // Checkbox on the left
                                            onChanged: (bool? value) {
                                              setState(() {
                                                if (value == true) {
                                                  selectedOptions.add(
                                                      customer['company_name']);
                                                  dropdownVisibility[customer[
                                                          'company_name']] =
                                                      true; // Show dropdowns
                                                } else {
                                                  selectedOptions.remove(
                                                      customer['company_name']);
                                                  dropdownVisibility[customer[
                                                          'company_name']] =
                                                      false; // Hide dropdowns
                                                }
                                              });
                                            },
                                          ),
                                        ),
                                        if (dropdownVisibility[
                                                customer['company_name']] ==
                                            true) ...[
                                          const Divider(
                                            color: Colors.grey,
                                            thickness: .8,
                                            indent: 16.0,
                                            endIndent: 16.0,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 58.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  'Section Customer',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 12),
                                                ),
                                                SizedBox(
                                                  width: 200,
                                                  child: DropdownButton<String>(
                                                    isExpanded: true,
                                                    value: dropdownSelections[
                                                        'first_${customer['company_name']}'],
                                                    // Removed hint for the first dropdown; now it directly displays the first section
                                                    items: customer[
                                                            'additional_data']
                                                        .map<
                                                                DropdownMenuItem<
                                                                    String>>(
                                                            (section) =>
                                                                DropdownMenuItem<
                                                                    String>(
                                                                  value: section[
                                                                      'customer_section_name'],
                                                                  child: Text(
                                                                      section[
                                                                          'customer_section_name'],
                                                                      style: const TextStyle(
                                                                          fontSize:
                                                                              12)),
                                                                ))
                                                        .toList(),
                                                    onChanged: (value) {
                                                      setState(() {
                                                        dropdownSelections[
                                                                'first_${customer['company_name']}'] =
                                                            value;
                                                      });
                                                    },
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 200,
                                                  child: DropdownButton<String>(
                                                    isExpanded: true,
                                                    value: dropdownSelections[
                                                        'second_${customer['company_name']}'],
                                                    // Set "Empty" as the default hint for the second dropdown
                                                    items: [
                                                      const DropdownMenuItem<
                                                          String>(
                                                        value: 'Empty',
                                                        child: Text('Empty',
                                                            style: TextStyle(
                                                                fontSize: 12)),
                                                      ),
                                                      ...customer[
                                                              'additional_data']
                                                          .map<
                                                                  DropdownMenuItem<
                                                                      String>>(
                                                              (section) {
                                                        return DropdownMenuItem<
                                                            String>(
                                                          value: section[
                                                              'customer_section_name'],
                                                          child: Text(
                                                              section[
                                                                  'customer_section_name'],
                                                              style:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          12)),
                                                        );
                                                      }).toList()
                                                    ],
                                                    onChanged: (value) {
                                                      setState(() {
                                                        dropdownSelections[
                                                                'second_${customer['company_name']}'] =
                                                            value;
                                                      });
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const Gap(10),
                          ],
                          const Gap(20),
                          const Text(
                            'Proposed Schedule',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          // Start Date Input
                          // Start Date with Time Input
                          TextFormField(
                            readOnly:
                                true, // Make it read-only to prevent manual input
                            decoration: InputDecoration(
                              labelText: 'Start Date & Time',
                              labelStyle: const TextStyle(
                                  fontSize: 12), // Smaller label size
                              border: OutlineInputBorder(),
                              suffixIcon: IconButton(
                                icon: const Icon(
                                  Icons.calendar_today,
                                  size: 16, // Smaller icon size
                                ),
                                onPressed: () async {
                                  // Set initialDate to 4 days after today
                                  final DateTime initialDate =
                                      (startDate ?? DateTime.now())
                                          .add(Duration(days: 4));

                                  final DateTime? pickedDate =
                                      await showDatePicker(
                                    context: context,
                                    initialDate:
                                        initialDate, // Set initial date to 4 days after today
                                    firstDate:
                                        DateTime(2000), // Adjust this as needed
                                    lastDate:
                                        DateTime(2101), // Adjust this as needed
                                    selectableDayPredicate: (DateTime date) {
                                      // Disable all days before the initialDate
                                      return date.isAfter(initialDate
                                              .subtract(Duration(days: 1))) ||
                                          date.isAtSameMomentAs(initialDate);
                                    },
                                  );

                                  if (pickedDate != null) {
                                    final TimeOfDay? pickedTime =
                                        await showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now(),
                                    );

                                    if (pickedTime != null) {
                                      setState(() {
                                        startDate = DateTime(
                                          pickedDate.year,
                                          pickedDate.month,
                                          pickedDate.day,
                                          pickedTime.hour,
                                          pickedTime.minute,
                                        );
                                      });
                                    }
                                  }
                                },
                              ),
                            ),
                            controller: TextEditingController(
                              text: startDate != null
                                  ? "${startDate!.toLocal()}"
                                      .split('.')[0] // Format date & time
                                  : '',
                            ),
                            style: const TextStyle(
                                fontSize:
                                    12), // Smaller font size for input text
                          ),

                          const SizedBox(height: 10.0), // Space between inputs

                          // End Date with Time Input
                          TextFormField(
                            readOnly:
                                true, // Make it read-only to prevent manual input
                            decoration: InputDecoration(
                              labelText: 'End Date & Time',
                              labelStyle: const TextStyle(
                                  fontSize: 12), // Smaller label size
                              border: OutlineInputBorder(),
                              suffixIcon: IconButton(
                                icon: const Icon(
                                  Icons.calendar_today,
                                  size: 16, // Smaller icon size
                                ),
                                onPressed: () async {
                                  // Set initialDate to 4 days after today
                                  final DateTime initialDate =
                                      (startDate ?? DateTime.now())
                                          .add(Duration(days: 4));

                                  final DateTime? pickedDate =
                                      await showDatePicker(
                                    context: context,
                                    initialDate:
                                        initialDate, // Set initial date to 4 days after today
                                    firstDate:
                                        DateTime(2000), // Adjust this as needed
                                    lastDate:
                                        DateTime(2101), // Adjust this as needed
                                    selectableDayPredicate: (DateTime date) {
                                      // Disable all days before the initialDate
                                      return date.isAfter(initialDate
                                              .subtract(Duration(days: 1))) ||
                                          date.isAtSameMomentAs(initialDate);
                                    },
                                  );

                                  if (pickedDate != null) {
                                    final TimeOfDay? pickedTime =
                                        await showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now(),
                                    );

                                    if (pickedTime != null) {
                                      setState(() {
                                        startDate = DateTime(
                                          pickedDate.year,
                                          pickedDate.month,
                                          pickedDate.day,
                                          pickedTime.hour,
                                          pickedTime.minute,
                                        );
                                      });
                                    }
                                  }
                                },
                              ),
                            ),
                            controller: TextEditingController(
                              text: endDate != null
                                  ? "${endDate!.toLocal()}"
                                      .split('.')[0] // Format date & time
                                  : '',
                            ),
                            style: const TextStyle(
                                fontSize:
                                    12), // Smaller font size for input text
                          ),
                          const Gap(20),
                          const Text(
                            'Worker Assignment',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          Column(
                            children: workers.map((worker) {
                              return Card(
                                elevation: 4,
                                margin: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 0),
                                shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.zero, // No rounded corners
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(
                                      1.0), // Padding inside each card
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Transform.translate(
                                        offset: const Offset(-16,
                                            0), // Shift left by 16 pixels; adjust as needed
                                        child: CheckboxListTile(
                                          title: Text(
                                            worker,
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),
                                          value: selectedWorkers.contains(
                                              worker), // Use selectedWorkers instead of selectedOptions
                                          controlAffinity: ListTileControlAffinity
                                              .leading, // Checkbox on the left
                                          onChanged: (bool? value) {
                                            setState(() {
                                              if (value == true) {
                                                selectedWorkers.add(
                                                    worker); // Add worker if checkbox is checked
                                              } else {
                                                selectedWorkers.remove(
                                                    worker); // Remove worker if checkbox is unchecked
                                              }
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 8.0),
                          const Gap(10),
                          DButtonBorder(
                            onClick: () {
                              submitData();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MainPage(
                                    key: UniqueKey(),
                                    initialIndex: 0,
                                  ), // Navigate with RectificationIndex tab active
                                ),
                              );
                            },
                            mainColor: Colors.white,
                            radius: 10,
                            borderColor: AppColor.scaffold,
                            child: const Text(
                              'Acknowledge',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const Gap(10),
                        ],
                      ),
                    ),
                  ),
                  // here
                ],
              ),
            ),
          ),
        );
    }
  }

  Widget buildImage(BuildContext context, String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      // If there's no image URL, return an empty widget
      return SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => Dialog(
            child: InteractiveViewer(
              child: Image.network(
                'https://apiqms.triasmitra.com/storage/app/public/$imageUrl',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return SizedBox.shrink(); // Show nothing if loading fails
                },
              ),
            ),
          ),
        );
      },
      child: Image.network(
        'https://apiqms.triasmitra.com/storage/app/public/$imageUrl',
        width: 100,
        height: 100,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return SizedBox.shrink(); // Show nothing if loading fails
        },
      ),
    );
  }

  Widget _buildDetailField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label text outside and bold
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600, // Bold text
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 6), // Spacing between label and input

          // Input value inside container
          Container(
            width: double.infinity, // Full width
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4), // Less rounded
            ),
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500, // Medium weight for value
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget formRecordContent(
    BuildContext context, // Add BuildContext as a parameter
    String paramTicketNumber,
    String paramRelatedTicket,
    String paramStep,
    String paramLongitude,
    String paramLatitude,
    String paramDescription,
    String stepName,
    List<String> files,
  ) {
    final ticketNumber = TextEditingController(text: paramTicketNumber);
    final relatedTicket = TextEditingController(text: paramRelatedTicket);
    final description = TextEditingController(text: paramDescription);

    return Container(
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rest of your UI components
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rectification Step $paramStep',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  Gap(20),
                  _buildDetailField(
                      'QMS Rectification Ticket Number', widget.ticketNumber),
                  _buildDetailField(
                      'QMS Related TT', rectificationData?['relatedTicket']),
                  Text(
                    stepName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  Gap(20),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: files.map((file) {
                      return GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => Dialog(
                              child: InteractiveViewer(
                                child: Image.network(
                                  'https://apiqms.triasmitra.com/storage/app/public/rectification/$paramTicketNumber/$paramStep/$file',
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.error);
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                        child: Image.network(
                          'https://apiqms.triasmitra.com/storage/app/public/rectification/$paramTicketNumber/$paramStep/$file',
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.error);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                  Gap(20),
                  _buildDetailField('Longitude', paramLongitude),
                  _buildDetailField('Latitude', paramLatitude),
                  _buildDetailField('Description', paramDescription),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
