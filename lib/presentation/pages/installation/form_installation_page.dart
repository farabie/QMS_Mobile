part of '../pages.dart';

class FormInstallationPage extends StatefulWidget {
  const FormInstallationPage({super.key});

  @override
  State<FormInstallationPage> createState() => _FormInstallationPageState();
}

class _FormInstallationPageState extends State<FormInstallationPage> {
  String? ticketNumber;
  int? installationStepId;
  int? stepNumber;
  int? imageLength;
  String? qmsId;
  String? qmsInstallationStepId;
  String? nextQmsInstallationStepId;
  String? stepDescription;
  String? typeOfInstallationName;
  int? typeOfInstallationId;
  int? totalSteps;
  int? revisionId;

  bool isLoading = false;

  final FocusNode _descriptionFocusNode = FocusNode();

  final edtDescription = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments as Map?;

    if (args != null) {
      ticketNumber = args['ticketNumber'] as String?;
      installationStepId = args['installationStepId'] as int?;
      stepNumber = args['stepNumber'] as int?;
      imageLength = args['imageLength'] as int?;
      qmsId = args['qmsId'] as String?;
      qmsInstallationStepId = args['qmsInstallationStepId'] as String?;
      nextQmsInstallationStepId = args['nextQmsInstallationStepId'] as String?;
      stepDescription = args['stepDescription'] as String?;
      typeOfInstallationName = args['typeOfInstallationName'] as String?;
      typeOfInstallationId = args['typeOfInstallationId'] as int?;
      totalSteps = args['totalSteps'] as int?;
      revisionId = args['revisionId'] as int?;
    }
  }

  @override
  void initState() {
    super.initState();
  }

  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    _descriptionFocusNode.dispose();
    super.dispose();
  }

  final documentations = <XFile>[].obs;

  Future<bool> _requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else {
      PermissionStatus status = await permission.request();
      return status == PermissionStatus.granted;
    }
  }

  Future<void> pickImagesFromGallery(int? imageLength) async {
    if (await _requestPermission(
        (Platform.isAndroid && (await _isAndroid13OrAbove()))
            ? Permission.photos
            : Permission.storage)) {
      List<XFile>? results = await ImagePicker().pickMultiImage();
      if (results.isNotEmpty) {
        int remainingSlots = imageLength! - documentations.length;
        if (results.length > remainingSlots) {
          results = results.take(remainingSlots).toList();
        }

        List<XFile> processedFiles = [];
        for (int i = 0; i < results.length; i++) {
          XFile file = results[i];

          // Mendapatkan ekstensi file asli
          String fileExtension = path.extension(file.path);
          
          // Menambahkan ekstensi asli ke nama file baru
          String increment = (documentations.length + i + 1).toString().padLeft(3, '0');
          String newFileName = '$qmsInstallationStepId-$increment$fileExtension';

          Directory appDocDir = await path_provider.getApplicationDocumentsDirectory();
          String newPath = path.join(appDocDir.path, newFileName);

          // Menyalin file dengan nama baru
          File newFile = await File(file.path).copy(newPath);

          // Memastikan XFile dibuat dari path dengan ekstensi yang valid
          processedFiles.add(XFile(newFile.path));
        }

        setState(() {
          documentations.addAll(processedFiles);
        });
      }
    } else {
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Akses Galeri Ditolak'),
              content: const Text(
                  'Akses ke galeri tidak diizinkan. Anda perlu memberikan izin untuk mengakses galeri.'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Tutup'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }

  // Function to check if the Android version is 13 or higher
  Future<bool> _isAndroid13OrAbove() async {
    if (Platform.isAndroid) {
      var androidInfo = await DeviceInfoPlugin().androidInfo;
      return androidInfo.version.sdkInt >= 33; // Android 13+ (API 33)
    }
    return false;
  }

  //Fungsi Untuk Mengahapus Gambar
  void removeImage(int index) {
    setState(() {
      documentations.removeAt(index);
    });
  }

  Future<void> _onWillPop(bool didPop) async {
    if (didPop) {
      return;
    }
    final bool shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Are you sure?'),
            content: const Text('Do you want to close this page?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Yes'),
              ),
            ],
          ),
        ) ??
        false;

    if (shouldPop) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: _onWillPop,
      canPop: false,
      child: Scaffold(
        appBar: AppBarWidget.cantBack(
          'Detail',
          context,
          onBackPressed: () => _onWillPop(false),
        ),
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: ListView(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 24),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      const Gap(6),
                      formInstallation(),
                    ],
                  ),
                )
              ],
            ),
            if (isLoading)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              )
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
                  blurStyle: BlurStyle.outer)
            ],
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 50,
                vertical: 5,
              ),
              child: DButtonFlat(
                onClick: () {
                  setState(() {
                    if (documentations.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please upload at least 1 image to continue.',
                          ),
                        ),
                      );
                      return;
                    }

                    if (edtDescription.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Please fill in the description to continue.'),
                        ),
                      );
                      return; // Jangan lanjutkan jika deskripsi kosong
                    }

                    showConfirmationDialog(context);
                  });
                },
                radius: 10,
                mainColor: AppColor.blueColor1,
                child: Text(
                  'Next',
                  style: TextStyle(
                    color: AppColor.whiteColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Form Installation'),
          content: const Text('Apakah Anda yakin form yang diisi sudah benar?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Tidak'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();

                final scaffoldContext = context;

                if (!mounted) return;
                setState(() {
                  isLoading = true;
                });

                try {
                  bool response =
                      await InstallationSource.stepInstallationUpdate(
                    qmsInstallationStepId: qmsInstallationStepId,
                    revisionId: revisionId,
                    description: edtDescription.text,
                    photos: documentations,
                    activeStatus: 'Created',
                  );

                  if (!mounted) return;

                  if (response) {
                    // Periksa apakah stepNumber == 1
                    if (stepNumber == 1) {
                      bool result = await InstallationSource
                          .stepInstallationUpdateNextActive(
                        qmsInstallationStepId: nextQmsInstallationStepId,
                        revisionId: revisionId,
                        activeStatus: 'Active',
                      );
                      bool recordUpdated =
                          await InstallationSource.onprogressInstallationRecord(
                              qmsId: qmsId);
                      bool stepRecordUpdated = await InstallationSource
                          .onprogressInstallationStepRecord(qmsId: qmsId);

                      //Kondisi untuk jika success merubah status jadi ongoing
                      if (recordUpdated && stepRecordUpdated && result) {
                        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                          const SnackBar(
                            content: Text("Sucess Update Installation Step"),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                          const SnackBar(
                            content:
                                Text("Failed to update one or both records."),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    } else if (stepNumber! < totalSteps!) {
                      // Eksekusi jika stepNumber < totalSteps
                      bool result = await InstallationSource
                          .stepInstallationUpdateNextActive(
                        qmsInstallationStepId: nextQmsInstallationStepId,
                        revisionId: revisionId,
                        activeStatus: 'Active',
                      );

                      if (!mounted) return;

                      if (result) {
                        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                          const SnackBar(
                            content: Text("Sucess Update Installation Step"),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                          const SnackBar(
                            content: Text(
                                "Installation step updated, but failed to activate next step."),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                    } else if (stepNumber == totalSteps) {
                      Navigator.pushReplacementNamed(
                        scaffoldContext,
                        AppRoute.formAllStepInstallation,
                        arguments: {
                          'ticketNumber': ticketNumber!,
                          'qms_id': qmsId,
                          'typeOfInstallationName': typeOfInstallationName,
                          'typeOfInstallationId': typeOfInstallationId,
                        },
                      );
                    }
                    // Navigasi ke formAllStepInstallation
                    Navigator.pushReplacementNamed(
                      scaffoldContext,
                      AppRoute.formAllStepInstallation,
                      arguments: {
                        'ticketNumber': ticketNumber!,
                        'qms_id': qmsId,
                        'typeOfInstallationName': typeOfInstallationName,
                        'typeOfInstallationId': typeOfInstallationId,
                      },
                    );
                  } else {
                    ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                      const SnackBar(
                        content: Text("Failed to update installation step."),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } catch (error) {
                  if (mounted) {
                    ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                      SnackBar(
                        content: Text("An error occurred: $error"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } finally {
                  if (mounted) {
                    setState(() {
                      isLoading = false;
                    });
                  }
                }
              },
              child: const Text('Iya'),
            ),
          ],
        );
      },
    );
  }

  void showLoadingOverlay(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            color: Colors.black.withOpacity(0.3),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );
      },
    );
  }

  void hideLoadingOverlay(BuildContext context) {
    Navigator.of(context).pop(); // Close the loading dialog
  }

  void resetFormAndScroll() {
    setState(() {
      edtDescription.clear();
      _descriptionFocusNode.unfocus();
      documentations.clear();
    });

    // Scroll to the top
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void showErrorSnackBar([String message = 'Failed to submit step.']) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget formInstallation() {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Form Installation',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColor.defaultText,
                ),
              ),
              Text(
                'Step Installation $stepNumber of $totalSteps',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColor.defaultText,
                ),
              ),
            ],
          ),
          Divider(
            color: AppColor.greyColor2,
          ),
          InputWidget.disable(
            'QMS Installation Ticket Number',
            TextEditingController(text: qmsId),
          ),
          const Gap(6),
          InputWidget.disable(
            'QMS Installation Step ID',
            TextEditingController(
              text: qmsInstallationStepId,
            ),
          ),
          const Gap(6),
          InputWidget.dropDown2(
            title: 'Type of installation',
            hintText: 'Select Type Of Installation',
            value: typeOfInstallationName!,
            onChanged: null,
            isEnabled: false,
            hintTextSearch: 'Search type of installation',
          ),
          const Gap(12),
          ...[
            uploadFile(
              stepDescription ?? 'No Image Uploaded',
              'Upload',
              'No Image Uploaded',
              imageLength!,
            ),
            const Gap(12),
            InputWidget.textArea(
              title: 'Description',
              hintText: 'Description',
              controller: edtDescription,
              focusNode: _descriptionFocusNode,
            ),
          ],
          const Gap(24)
        ],
      ),
    );
  }

  Widget uploadFile(
      String title, String textButton, String hintUpload, int imageLength) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const Gap(3),
        Container(
          height: 300,
          decoration: BoxDecoration(
            color: AppColor.whiteColor,
            border: Border.all(color: AppColor.defaultText),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Obx(() {
                // Jika documentations kosong
                if (documentations.isEmpty) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        hintUpload,
                        style: TextStyle(
                          color: AppColor.defaultText,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Gap(20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 36),
                        child: DButtonFlat(
                          onClick: () {
                            pickImagesFromGallery(
                                imageLength); // Kirim currentStep ke sini
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
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                      ),
                      itemCount: documentations.length +
                          (documentations.length < imageLength ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == documentations.length &&
                            documentations.length < (imageLength)) {
                          return GestureDetector(
                            onTap: () {
                              pickImagesFromGallery(
                                  imageLength); // Kirim currentStep ke sini
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

                        String path = documentations[index].path;
                        return Stack(
                          children: [
                            GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => Dialog(
                                    child: Image.file(
                                      File(path),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                );
                              },
                              child: SizedBox(
                                width: 79,
                                height: 68,
                                child: Image.file(
                                  File(path),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              left: 0,
                              top: 0,
                              child: GestureDetector(
                                onTap: () => removeImage(index),
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
                    ),
                  );
                }
              }),
            ],
          ),
        ),
        const Gap(12),
        Text(
          "Uploaded: ${documentations.length}/$imageLength", // Tampilkan jumlah gambar yang diupload
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
