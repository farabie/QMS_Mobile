part of '../pages.dart';

class RectificationCreate extends StatefulWidget {
  final String ticketNumber;
  final String createType;

  const RectificationCreate(
      {super.key, required this.ticketNumber, required this.createType});

  @override
  State<RectificationCreate> createState() => _RectificationCreateState();
}

class _RectificationCreateState extends State<RectificationCreate> {
  Map<String, dynamic>? rectificationData;
  Map<String, dynamic>? rectificationDetailData;
  List<Map<String, dynamic>> records = [];
  Timer? _debounce;
  bool isLoading = true;
  bool _isSubmitting = false;
  int nextStep = 1; // Declare nextStep at the class level
  String? description;
  final rectification_images = <XFile>[].obs;

  final edtLatitudeInstall = TextEditingController(text: '');
  final edtLongitudeInstall = TextEditingController(text: '');

  // Find the highest step value

  final List<String> rectification_steps = [
    'Panoramic View Before  (5 - 10 M)',
    'Far View Before (2 - 5 M)',
    'Near View Before (< 0.8 M)',
    'Progress Far View (2 - 5 M)',
    'Progress Near View (< 0.8 M)',
    'Panoramic View After (5 - 10 M)',
    'Far View After (2 - 5 M)',
    'Near View After (< 0.8 M)',
  ];

  // Boolean list to track the state of each checkbox
  List<bool> _isCheckedList = [];

  Future<bool> _requestPermission(Permission permission) async {
    var status = await permission.status;
    if (status.isGranted) {
      return true;
    } else {
      var result = await permission.request();
      return result.isGranted;
    }
  }

  @override
  void initState() {
    super.initState();
    fetchRecordData();
    fetchRectificationData();
  }

  Future<void> pickImagesFromCamera(
      BuildContext context, RxList<XFile> images) async {
    // Meminta izin kamera dan lokasi
    if (await _requestPermission(Permission.camera) &&
        await _requestPermission(Permission.locationWhenInUse)) {
      // Hanya push jika widget masih mounted
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RectificationCamera(
            onImageTaken: (XFile image, Position position) {
              images.add(image);
              edtLatitudeInstall.text = position.latitude.toString();
              edtLongitudeInstall.text = position.longitude.toString();
            },
          ),
        ),
      );
    } else {
      print("Camera or location access not granted");
    }
  }

  void removeImage(RxList<XFile> images, int index) {
    images.removeAt(index);
  }

  Future<void> fetchRectificationData() async {
    setState(() {
      isLoading = true; // Show loading indicator at the start of the fetch
    });

    final String url =
        'https://apiqms.triasmitra.com/public/api/rectification/show/${widget.ticketNumber}/ticket';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        final rectification = data['rectification'] ?? {};
        final rectificationDetail = data['rectification_detail'] ?? {};

        setState(() {
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
            'status': rectification['status'] ?? '',
          };

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
        });
      } else {
        print('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred while fetching data: $e');
    } finally {
      setState(() {
        isLoading = false; // Hide loading indicator after the fetch is complete
      });
    }
  }

  Future<void> fetchRecordData() async {
    setState(() {
      isLoading = true; // Show loading indicator before starting the fetch
    });

    final apiUrl =
        'https://apiqms.triasmitra.com/public/api/rectification_record/index/${widget.ticketNumber}';
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          records = List<Map<String, dynamic>>.from(data);

          // Find the highest step value
          int highestStep = records.isNotEmpty
              ? records
                  .map((record) => record['step'] as int)
                  .reduce((a, b) => a > b ? a : b)
              : 0;

          // Set next step to be one higher than the highest step
          nextStep = highestStep + 1;
          isLoading = false; // Hide loading indicator after data is fetched
        });
      } else {
        setState(() {
          records = [];
          isLoading = false; // Hide loading indicator if fetching failed
        });
      }
    } catch (e) {
      setState(() {
        records = [];
        isLoading = false; // Hide loading indicator in case of an error
      });
    }
  }

  Future<void> submitRecordForm(List<XFile> files) async {
    final url = Uri.parse(
        'https://apiqms.triasmitra.com/public/api/rectification_record/store');
    var request = http.MultipartRequest('POST', url);

    // Add form fields
    request.fields['ticketNumber'] = widget.ticketNumber;
    request.fields['step'] = nextStep.toString();
    request.fields['step_name'] = rectification_steps[nextStep - 1];
    request.fields['description'] = description ?? '';
    request.fields['longitude'] = edtLongitudeInstall.text;
    request.fields['latitude'] = edtLatitudeInstall.text;

    // Add files to the request
    for (var file in files) {
      var mimeType = lookupMimeType(file.path);
      request.files.add(
        await http.MultipartFile.fromPath(
          'file[]', // Use 'file[]' if the API expects a file array
          file.path,
          contentType: mimeType != null ? MediaType.parse(mimeType) : null,
        ),
      );
    }

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        print('Form submitted successfully');

        var responseBody = await response.stream.bytesToString();
        print('Response body: $responseBody');
      } else {
        print('Failed to submit form: ${response.statusCode}');
      }
    } catch (e) {
      print('Error submitting form: $e');
    }
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

  void _onStepTap(int index) {
    setState(() {
      isLoading = true; // Show loading indicator before starting the fetch
    });
    // Cancel the previous timer if it exists
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    // Set a new debounce timer
    _debounce = Timer(const Duration(milliseconds: 3000), () {
      setState(() {
        isLoading = false;
      });

      Navigator.pushReplacementNamed(
        context,
        AppRoute.rectificationShow,
        arguments: {
          'ticketNumber': widget.ticketNumber,
          'showType': 'record',
          'step': (index + 1).toString(),
        },
      );
    });
  }

  void submitTicket() async {
    Map<String, dynamic> dataToSend = {
      'ticketNumber': widget.ticketNumber,
      'type': 'Submited',
    };

    try {
      // Send the POST request to the API
      final response = await http.post(
        Uri.parse(
            'https://apiqms.triasmitra.com/public/api/rectification/update'),
        headers: {
          'Content-Type': 'application/json', // Set the request content type
        },
        body: json.encode(dataToSend),
      );

      // Check the response status
      if (response.statusCode == 200) {
        print('Data submitted successfully: ${response.body}');
        // DInfo.toastSuccess('Ticket Is Successfully Acknowledge');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Ticket Is Successfully Submited'),
            backgroundColor: AppColor.saveButton,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainPage(key: UniqueKey(), initialIndex: 0),
          ),
        );
      } else {
        print('Failed to submit data: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Submit Ticket Is Failed'),
            backgroundColor: AppColor.closeButton,
          ),
        );

        isLoading = false; // Show loading indicator immediately
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainPage(key: UniqueKey(), initialIndex: 0),
          ),
        );
        // DInfo.toastSuccess('Acknowledge Ticket Is Failed');
        print('Error: ${response.body}');
      }
    } catch (error) {
      print('Error submitting data: $error');
    }
  }

  @override
  void dispose() {
    // Clean up the timer when the widget is disposed
    _debounce?.cancel();
    super.dispose();
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    switch (widget.createType) {
      case 'record':
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
          body: isLoading
              ? const Center(
                  child: CircularProgressIndicator(), // Loading indicator
                )
              : Stack(
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 24), // Space for the button
                      child: Column(
                        children: [
                          // Main Input Fields Card
                          Container(
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Gap(10),
                                    InputWidget.disable(
                                      'QMS Rectification Ticket Number',
                                      TextEditingController(
                                          text: widget.ticketNumber),
                                    ),
                                    const Gap(10),
                                    InputWidget.disable(
                                      'Schedule Start Date',
                                      TextEditingController(
                                          text: rectificationDetailData?[
                                                  'scheduleStart'] ??
                                              ''),
                                    ),
                                    const Gap(10),
                                    InputWidget.disable(
                                      'Schedule End Date',
                                      TextEditingController(
                                          text: rectificationDetailData?[
                                                  'scheduleEnd'] ??
                                              ''),
                                    ),
                                    InputWidget.disable(
                                      'Assigned Workers',
                                      TextEditingController(
                                          text: rectificationDetailData?[
                                                  'workers'] ??
                                              ''),
                                    ),
                                    InputWidget.disable(
                                      'Activity Category',
                                      TextEditingController(
                                          text: rectificationDetailData?[
                                                  'type'] ??
                                              ''),
                                    ),
                                    InputWidget.disable(
                                      'Activity Detail',
                                      TextEditingController(
                                          text: rectificationDetailData?[
                                                  'activityDetail'] ??
                                              ''),
                                    ),
                                    InputWidget.disable(
                                      'Activity Location',
                                      TextEditingController(
                                          text: rectificationDetailData?[
                                                  'activityLocation'] ??
                                              ''),
                                    ),
                                    Text(
                                      rectificationData?['reasonRejectedSpv'] ??
                                          '',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Rectification Step Card
                          Container(
                            child: Card(
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
                                      'Rectification Step',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                    // Non-scrollable ListView builder inside the card
                                    ListView.builder(
                                      // here
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: rectification_steps.length,
                                      itemBuilder: (context, index) {
                                        final rectification_step =
                                            rectification_steps[index];
                                        return GestureDetector(
                                          onTap: () {
                                            if ((index + 1) == nextStep) {
                                              Navigator.pushReplacementNamed(
                                                context,
                                                AppRoute.rectificationCreate,
                                                arguments: {
                                                  'ticketNumber':
                                                      widget.ticketNumber,
                                                  'createType': 'insert',
                                                },
                                              );
                                            }
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 12.0),
                                            child: Container(
                                              width: double.infinity,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16.0,
                                                      vertical: 12.0),
                                              decoration: BoxDecoration(
                                                color: (index + 1) == nextStep
                                                    ? Color(0xFF88D66C)
                                                    : (index + 1) < nextStep
                                                        ? Colors.white
                                                        : Colors.grey[200],
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                                border: Border.all(
                                                  color: (index + 1) ==
                                                              nextStep ||
                                                          (index + 1) < nextStep
                                                      ? Colors.black
                                                      : Colors.transparent,
                                                ),
                                              ),
                                              child: Text(
                                                'Step ${index + 1} : $rectification_step',
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
                          ),
                        ],
                      ),
                    ),
                    // Fixed Bottom Button
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        color: Colors.white,
                        padding: const EdgeInsets.all(16.0),
                        child: Center(
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width *
                                0.7, // Shrinks button width
                            child: ElevatedButton(
                              onPressed: () {
                                if (nextStep < 9) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const MainPage(initialIndex: 3),
                                    ),
                                  );
                                } else {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => RectificationCreate(
                                        ticketNumber: widget.ticketNumber,
                                        createType: 'result',
                                      ),
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: nextStep < 9
                                    ? Colors.white
                                    : Colors.lightBlue,
                                foregroundColor:
                                    nextStep < 9 ? Colors.black : Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: BorderSide(
                                    color: nextStep < 9
                                        ? Colors.black
                                        : Colors.black,
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
                              child: Text(
                                nextStep < 9 ? 'Pause' : 'Finish',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: nextStep < 9
                                      ? Colors.black
                                      : Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        );
      case 'insert':
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
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RectificationCreate(
                            ticketNumber: widget.ticketNumber,
                            createType: 'record',
                          ),
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
                            child:
                                formRecordContent(), // Contains TextFormFields
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
          bottomNavigationBar: Container(
            height: 50,
            decoration: BoxDecoration(
              color: AppColor.whiteColor,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  offset: Offset(0, 3),
                  blurRadius: 10,
                  blurStyle: BlurStyle.outer,
                ),
              ],
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 5,
                ),
                child: DButtonFlat(
                  onClick: () async {
                    if (_formKey.currentState!.validate() && !_isSubmitting) {
                      setState(() {
                        _isSubmitting = true; // Disable the button
                      });

                      try {
                        _formKey.currentState!
                            .save(); // Save form state if needed

                        // Check if there are selected images and call submitRecordForm with the list
                        if (rectification_images.isNotEmpty) {
                          await submitRecordForm(
                              rectification_images); // Pass the list of images
                        } else {
                          print("No images selected");
                        }

                        // Re-fetch the updated data after form submission to update the nextStep
                        await fetchRecordData();

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RectificationCreate(
                              ticketNumber: widget.ticketNumber,
                              createType: 'record',
                            ),
                          ),
                        );
                      } finally {
                        setState(() {
                          _isSubmitting =
                              false; // Re-enable the button after the operation completes
                        });
                      }
                    }
                  },
                  radius: 10,
                  mainColor: AppColor.blueColor1,
                  child: _isSubmitting
                      ? const SizedBox(
                          height:
                              20, // Adjust the height and width to make it round
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2, // Makes it thinner and smoother
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Next',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          ),
        );
      case 'result':
        return Scaffold(
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
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MainPage(
                            initialIndex: 3,
                          ), // Navigate with RectificationIndex tab active
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
                  'Rectification Summary',
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
              : Stack(
                  children: [
                    // Main Content Scrollable Area
                    SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0,
                          80.0), // Extra padding at the bottom for button space
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Form Card
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
                                  _buildDetailField(
                                      'QMS Rectification Ticket Number',
                                      widget.ticketNumber ?? 'N/A'),
                                  _buildDetailField('Area',
                                      rectificationData?['area'] ?? 'N/A'),
                                  _buildDetailField(
                                      'Service Point',
                                      rectificationData?['servicePoint'] ??
                                          'N/A'),
                                  _buildDetailField('Longitude',
                                      rectificationData?['longitude'] ?? 'N/A'),
                                  _buildDetailField('Latitude',
                                      rectificationData?['latitude'] ?? 'N/A'),
                                  _buildDetailField(
                                      'Description',
                                      rectificationData?['description'] ??
                                          'N/A'),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16), // Spacing between cards

                          // Rectification Step Card
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
                                  const Text(
                                    'Rectification Step',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: rectification_steps.length,
                                    itemBuilder: (context, index) {
                                      final rectification_step =
                                          rectification_steps[index];
                                      return GestureDetector(
                                        onTap: () {
                                          _onStepTap(index);
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
                                              color: (index + 1) == nextStep
                                                  ? Color(0xFF88D66C)
                                                  : (index + 1) < nextStep
                                                      ? Colors.white
                                                      : Colors.grey[200],
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              border: Border.all(
                                                color: (index + 1) ==
                                                            nextStep ||
                                                        (index + 1) < nextStep
                                                    ? Colors.black
                                                    : Colors.transparent,
                                              ),
                                            ),
                                            child: Text(
                                              'Step ${index + 1} : $rectification_step',
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
                        ],
                      ),
                    ),

                    // Fixed Submit Button at the Bottom
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Card(
                        elevation: 4,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero, // No border radius
                        ),
                        margin:
                            const EdgeInsets.all(0), // No margin for full width
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16.0), // Vertical padding for button
                          child: Center(
                            child: SizedBox(
                              width: 200, // Set a fixed width for the button
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    isLoading =
                                        true; // Show loading indicator immediately
                                  });
                                  _delay();
                                  submitTicket();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        10), // Retain rounded corners for the button itself
                                    side: const BorderSide(color: Colors.black),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 40, vertical: 16),
                                ),
                                child: const Text(
                                  'Submit',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        );
      case 'show':
        List<Map<String, dynamic>> filteredRecords =
            records.where((record) => record['step'] == 1).toList();

        Map<String, dynamic>? firstRecord =
            filteredRecords.isNotEmpty ? filteredRecords.first : null;

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
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RectificationCreate(
                            ticketNumber: widget.ticketNumber,
                            createType: 'result',
                          ),
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
                  'Detail Rectification Step Result',
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
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColor
                                    .whiteColor, // White background color
                                borderRadius:
                                    BorderRadius.circular(5), // Rounded corners
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6), // Padding
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Custom styled label and disabled input field
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment
                                        .spaceBetween, // Align left and right
                                    children: [
                                      const Text(
                                        'Form Rectification',
                                        style: TextStyle(
                                          fontSize:
                                              12, // Decreased font size for the label
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        'Step Rectification ${firstRecord?['step'] ?? 'N/A'} of 8',
                                        style: const TextStyle(
                                          fontSize:
                                              12, // Decreased font size for the label
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(
                                    color: Colors
                                        .black, // Set the color of the line
                                    thickness:
                                        1, // Set the thickness of the line
                                  ),
                                  const Gap(20),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'QMS Rectification Ticket Number',
                                    style: TextStyle(
                                      fontSize:
                                          12, // Decreased font size for the label
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  TextField(
                                    controller: TextEditingController(
                                        text: widget.ticketNumber),
                                    readOnly: true, // Disable editing
                                    decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical:
                                              6), // Similar padding as InputWidget
                                      filled: true, // Enable the fill color
                                      fillColor: Color.fromRGBO(238, 238, 238,
                                          1), // Set the background to grey
                                      border: InputBorder
                                          .none, // Remove the bottom border
                                    ),
                                    style: const TextStyle(
                                      fontSize:
                                          12, // Decreased font size for input field
                                    ),
                                  ),
                                  const Text(
                                    'QMS Related TT',
                                    style: TextStyle(
                                      fontSize:
                                          12, // Decreased font size for the label
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  TextField(
                                    controller: TextEditingController(
                                        text: rectificationData?[
                                                'relatedTicket'] ??
                                            ''),
                                    readOnly: true, // Disable editing
                                    decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical:
                                              6), // Similar padding as InputWidget
                                      filled: true, // Enable the fill color
                                      fillColor: Color.fromRGBO(238, 238, 238,
                                          1), // Set the background to grey
                                      border: InputBorder
                                          .none, // Remove the bottom border
                                    ),
                                    style: const TextStyle(
                                      fontSize:
                                          12, // Decreased font size for input field
                                    ),
                                  ),
                                  const Gap(20),
                                  uploadFile('Take Picture Far View',
                                      'Take Picture', rectification_images, 99),
                                  const Gap(20),
                                  const Text(
                                    "Description",
                                    style: TextStyle(
                                      fontSize:
                                          12, // Same as previous example for description text
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const Gap(6),
                                  TextFormField(
                                    decoration: const InputDecoration(
                                      border:
                                          OutlineInputBorder(), // Outline for input box
                                    ),
                                    maxLines: 5, // Multiline input
                                    style: const TextStyle(
                                      fontSize:
                                          12, // Decrease font size here as well
                                    ),
                                    validator: (value) {
                                      return null; // No validation, so it's optional
                                    },
                                    onSaved: (value) {
                                      description = value; // Save the value
                                    },
                                  ),
                                  const Gap(
                                      6), // Similar spacing as in the other form
                                ],
                              ),
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
          appBar: AppBarWidget.secondary('Cannot find create type', context),
        );
    }
  }

  Widget formRecordContent() {
    final ticketNumber = TextEditingController(text: widget.ticketNumber);
    final relatedTicket =
        TextEditingController(text: rectificationData?['relatedTicket'] ?? '');
    return Container(
      decoration: BoxDecoration(
        color: AppColor.whiteColor, // White background color
        borderRadius: BorderRadius.circular(5), // Rounded corners
      ),
      padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 6), // Padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Custom styled label and disabled input field

          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween, // Align left and right
            children: [
              const Text(
                'Form Rectification',
                style: TextStyle(
                  fontSize: 12, // Decreased font size for the label
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Step Rectification $nextStep of 8',
                style: const TextStyle(
                  fontSize: 12, // Decreased font size for the label
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Divider(
            color: Colors.black, // Set the color of the line
            thickness: 1, // Set the thickness of the line
          ),
          const Gap(20),
          const SizedBox(height: 6),
          const Text(
            'QMS Rectification Ticket Number',
            style: TextStyle(
              fontSize: 12, // Decreased font size for the label
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: ticketNumber,
            readOnly: true, // Disable editing
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6), // Similar padding as InputWidget
              filled: true, // Enable the fill color
              fillColor: Color.fromRGBO(
                  238, 238, 238, 1), // Set the background to grey
              border: InputBorder.none, // Remove the bottom border
            ),
            style: const TextStyle(
              fontSize: 12, // Decreased font size for input field
            ),
          ),
          const Text(
            'QMS Related TT',
            style: TextStyle(
              fontSize: 12, // Decreased font size for the label
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: relatedTicket,
            readOnly: true, // Disable editing
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6), // Similar padding as InputWidget
              filled: true, // Enable the fill color
              fillColor: Color.fromRGBO(
                  238, 238, 238, 1), // Set the background to grey
              border: InputBorder.none, // Remove the bottom border
            ),
            style: const TextStyle(
              fontSize: 12, // Decreased font size for input field
            ),
          ),
          const Gap(20),
          uploadFile('-', 'Take Picture', rectification_images, 99),
          const Gap(20),
          const Text(
            "Description",
            style: TextStyle(
              fontSize: 12, // Same as previous example for description text
              fontWeight: FontWeight.w600,
            ),
          ),
          const Gap(6),
          TextFormField(
            decoration: const InputDecoration(
              border: OutlineInputBorder(), // Outline for input box
            ),
            maxLines: 5, // Multiline input
            style: const TextStyle(
              fontSize: 12, // Decrease font size here as well
            ),
            validator: (value) {
              return null; // No validation, so it's optional
            },
            onSaved: (value) {
              description = value; // Save the value
            },
          ),
          const Gap(6), // Similar spacing as in the other form
        ],
      ),
    );
  }

  // Helper method to create each detail field with label and value
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

  Widget uploadFile(
      String title, String textButton, RxList<XFile> images, int maxImages) {
    if (nextStep < 9) {
      title = rectification_steps[nextStep - 1];
    } else {
      title = 'no step';
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const Gap(3),
        Container(
          height: 240,
          decoration: BoxDecoration(
            color: AppColor.whiteColor,
            border: Border.all(color: AppColor.defaultText),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Obx(() {
                // Jika tidak ada gambar yang dipilih, tampilkan teks 'No Image Selected'
                if (images.isEmpty) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        'No Image Selected',
                        style: TextStyle(
                          color: AppColor.defaultText,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Gap(20),
                      // Tampilkan tombol upload menggunakan showModalBottomSheet
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 36),
                        child: DButtonFlat(
                          onClick: () {
                            pickImagesFromCamera(context, images);
                          },
                          height: 40,
                          mainColor: AppColor.blueColor1,
                          radius: 10,
                          child: Text(
                            textButton,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  return Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 12, 24, 12),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, // Atur jumlah kolom yang diinginkan
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                      ),
                      itemCount:
                          images.length + (images.length < maxImages ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == images.length &&
                            images.length < maxImages) {
                          // Tombol '+' untuk menambahkan gambar jika jumlah belum mencapai maxImages
                          return GestureDetector(
                            onTap: () {
                              pickImagesFromCamera(context, images);
                            },
                            child: Container(
                              width: 79,
                              height: 68,
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColor.defaultText),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Icon(
                                Icons.add,
                                color: AppColor.defaultText,
                              ),
                            ),
                          );
                        }

                        String path = images[index].path;
                        return Stack(
                          children: [
                            SizedBox(
                              width: 79,
                              height: 68,
                              child: Image.file(
                                File(path),
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              left: 0,
                              top: 0,
                              child: GestureDetector(
                                onTap: () => removeImage(images, index),
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColor.closeButton,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                    ),
                  );
                }
              }),
            ],
          ),
        ),
      ],
    );
  }
}
