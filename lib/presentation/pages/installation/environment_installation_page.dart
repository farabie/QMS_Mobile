part of '../pages.dart';

class EnvironmentInstallationPage extends StatefulWidget {
  const EnvironmentInstallationPage({super.key});

  @override
  State<EnvironmentInstallationPage> createState() =>
      _EnvironmentInstallationPageState();
}

class _EnvironmentInstallationPageState
    extends State<EnvironmentInstallationPage> {
  final ScrollController _scrollController = ScrollController();
  bool isLoading = false;

  final edtDescription = TextEditingController();
  final FocusNode _descriptionFocusNode = FocusNode();

  String? ticketNumber;
  String? qmsInstallationStepId;
  String? qmsId;
  int? imageLength;
  String? stepDescription;
  String? typeOfInstallationName;
  int? typeOfInstallationId;
  int? revisionId;

  final documentations = <XFile>[].obs;

  List<String> environmentalCategories = [
    'Terdapat tanaman merambat / alang-alang',
    'Cabang/Ranting Pohon Menghalangi Kabel',
    'Tanah berpotensi longsor',
    'Atribut Kegiatan Masyarakat',
    'Government / Non Government Activity',
    'Ditumpangi Kabel Operator Lain',
    'Others'
  ];

  List<bool> selectedCategories = [
    false,
    false,
    false,
    false,
    false,
    false,
    false,
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments as Map?;

    if (args != null) {
      ticketNumber = args['ticketNumber'] as String?;
      imageLength = args['imageLength'] as int?;
      qmsId = args['qmsId'] as String?;
      qmsInstallationStepId = args['qmsInstallationStepId'] as String?;
      stepDescription = args['stepDescription'] as String?;
      typeOfInstallationName = args['typeOfInstallationName'] as String?;
      typeOfInstallationId = args['typeOfInstallationId'] as int?;
      revisionId = args['revisionId'] as int?;
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _descriptionFocusNode.dispose();
    super.dispose();
  }

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
          String increment =
              (documentations.length + i + 1).toString().padLeft(3, '0');
          String newFileName =
              '$qmsInstallationStepId-$increment$fileExtension';

          Directory appDocDir =
              await path_provider.getApplicationDocumentsDirectory();
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
                      formEnvironmentInstallations(),
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
                  blurStyle: BlurStyle.outer,
                )
              ]),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 50,
                vertical: 5,
              ),
              child: DButtonFlat(
                onClick: () async {
                  // if (documentations.isEmpty) {
                  //   // Jika gambar kurang, tampilkan snackbar dan hentikan eksekusi
                  //   ScaffoldMessenger.of(context).showSnackBar(
                  //     const SnackBar(
                  //       content: Text(
                  //         'Please upload at least 1 images for this step',
                  //       ),
                  //     ),
                  //   );
                  //   return; // Hentikan eksekusi jika gambar kurang
                  // }

                  if (edtDescription.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('Please fill in the description to continue.'),
                      ),
                    );
                    return; // Jangan lanjutkan jika deskripsi kosong
                  }

                  showConfirmationDialog(context);
                },
                radius: 10,
                mainColor: AppColor.blueColor1,
                child: Text(
                  'Next',
                  style: TextStyle(
                      color: AppColor.whiteColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600),
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
          title: const Text('Environmental  Information'),
          content: const Text('Apakah data yang anda input sudah sesuai?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog without action
              },
              child: const Text('Tidak'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _handleInstallationSubmission();
              },
              child: const Text('Iya'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleInstallationSubmission() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    String categoryOfEnvironment =
        getSelectedCategories(environmentalCategories, selectedCategories);

    try {
      bool result = await InstallationSource.stepInstallationUpdate(
        qmsInstallationStepId: qmsInstallationStepId,
        revisionId: revisionId,
        description: edtDescription.text,
        categoryOfEnvironment: categoryOfEnvironment,
        photos: documentations,
        activeStatus: 'Created',
      );

      if (!result) {
        if (mounted) {
          showErrorSnackBar();
        }
        return;
      }

      if (mounted) {
        await Navigator.pushReplacementNamed(
          context,
          AppRoute.formAllStepInstallation,
          arguments: {
            'ticketNumber': ticketNumber!,
            'qms_id': qmsId,
            'typeOfInstallationName': typeOfInstallationName,
            'typeOfInstallationId': typeOfInstallationId,
          },
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void showErrorSnackBar([String message = 'Failed to submit step.']) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String getSelectedCategories(List<String> items, List<bool> selectedItems) {
    List<String> selectedCategories = [];
    for (int i = 0; i < items.length; i++) {
      if (selectedItems[i]) {
        selectedCategories.add(items[i]);
      }
    }
    return selectedCategories
        .join(', '); // Menggabungkan pilihan menjadi satu string
  }

  Widget formEnvironmentInstallations() {
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
                'Environmental Information',
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
              text: qmsInstallationStepId, // Step selanjutnya: ID dari generate
            ),
          ),
          const Gap(6),
          InputWidget.dropDown2(
            title: 'Type of installation',
            hintText: 'Select Type Of Installation',
            value: typeOfInstallationName ?? '', // Tampilkan typeName
            onChanged:
                null, // Dropdown disable karena sudah ada typeOfInstallation
            isEnabled: false, // Set dropdown sebagai disable
            hintTextSearch: 'Search type of installation',
          ),
          const Gap(6),
          InputWidget.checkboxList(
              title: 'Category Of Environment',
              items: environmentalCategories,
              selectedItems: selectedCategories,
              onChanged: (int index) {
                setState(() {
                  // Ubah nilai checkbox yang dipilih
                  selectedCategories[index] = !selectedCategories[index];
                });
              }),
          const Gap(6),
          uploadFile(
            stepDescription ?? 'No Image Uploaded',
            'Upload',
            'No Image Uploaded',
            imageLength ??
                0, // Asumsikan ini adalah jumlah gambar yang diupload
          ),
          const Gap(6),
          InputWidget.textArea(
            title: 'Description',
            hintText: 'Description',
            controller: edtDescription,
            focusNode: _descriptionFocusNode,
          ),
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
                            pickImagesFromGallery(imageLength);
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
                            documentations.length < imageLength) {
                          return GestureDetector(
                            onTap: () {
                              pickImagesFromGallery(imageLength);
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
