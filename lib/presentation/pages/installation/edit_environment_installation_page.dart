part of '../pages.dart';

class EditEnvironmentInstallationPage extends StatefulWidget {
  const EditEnvironmentInstallationPage({super.key});

  @override
  State<EditEnvironmentInstallationPage> createState() =>
      _EditEnvironmentInstallationPageState();
}

class _EditEnvironmentInstallationPageState
    extends State<EditEnvironmentInstallationPage> {
  int? installationStepId;
  int? stepNumber;
  int? imageLength;
  String? qmsId;
  String? qmsInstallationStepId;
  String? stepDescription;
  String? typeOfInstallationName;
  int? totalSteps;
  String? categoryOfEnvironment;
  String? description;
  final documentations = <XFile>[].obs;
  bool isPhotoUrlMode = true;
  int? revisionId;

  List<String>? photoUrls;

  bool isLoading = false;

  final FocusNode _descriptionFocusNode = FocusNode();

  late TextEditingController edtDescription;

  List<String> environmentalCategories = [
    'Terdapat tanaman merambat / alang-alang',
    'Cabang/Ranting Pohon Menghalangi Kabel',
    'Tanah berpotensi longsor',
    'Atribut Kegiatan Masyarakat',
    'Government / Non Government Activity',
    'Ditumpangi Kabel Operator Lain',
    'Others'
  ];

  List<bool> selectedCategories = List.filled(7, false);
  List<String>? originalPhotoUrls;

  final List<String> deletedPhotoUrls = [];

  @override
  void initState() {
    super.initState();
    edtDescription = TextEditingController();
    photoUrls = [];
    originalPhotoUrls = [];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments as Map?;

    if (args != null) {
      installationStepId = args['installationStepId'] as int?;
      qmsId = args['qmsId'] as String?;
      qmsInstallationStepId = args['qmsInstallationStepId'] as String?;
      stepNumber = args['stepNumber'] as int?;
      imageLength = args['imageLength'] as int?;
      stepDescription = args['stepDescription'] as String?;
      typeOfInstallationName = args['typeOfInstallationName'] as String?;
      description = args['description'] as String?;
      revisionId = args['revisionId'] as int?;

      // Handle photos if they haven't been changed yet
      if (originalPhotoUrls!.isEmpty &&
          photoUrls!.isEmpty &&
          documentations.isEmpty) {
        List<String> filenames = List<String>.from(args['photos'] ?? []);
        originalPhotoUrls = filenames
            .map((filename) => URLs.installationImage(filename))
            .toList();
        photoUrls = List.from(originalPhotoUrls!);
        isPhotoUrlMode = photoUrls!.isNotEmpty;
      }

      totalSteps = args['totalSteps'] as int?;

      // edtDescription = TextEditingController(text: description ?? '');
      if (edtDescription.text.isEmpty) {
        edtDescription.text = description ?? '';
      }

      if (categoryOfEnvironment == null) {
        categoryOfEnvironment = args['categoryOfEnvironment'] as String?;

        if (categoryOfEnvironment != null) {
          List<String> selectedCategoriesFromArgs =
              categoryOfEnvironment!.split(',').map((e) => e.trim()).toList();

          for (int i = 0; i < environmentalCategories.length; i++) {
            selectedCategories[i] =
                selectedCategoriesFromArgs.contains(environmentalCategories[i]);
          }
        }
      }
    }
  }

  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    _descriptionFocusNode.dispose();
    super.dispose();
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
                      formEditEnvironmentInstallation(),
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
                onClick: () async {
                  if (edtDescription.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('Please fill in the description to continue.'),
                      ),
                    );
                    return;
                  }

                  final updatedDescription = edtDescription.text;
                  final List<XFile> photosToUpload = isPhotoUrlMode
                      ? [] // If in photoUrl mode with no changes, send empty list
                      : documentations;

                  final String updatedCategoryOfEnvironment =
                      getSelectedCategories(
                    environmentalCategories,
                    selectedCategories,
                  );

                  showConfirmationDialog(
                    context,
                    updateDescription: updatedDescription,
                    photosToUpload: photosToUpload,
                    categoryOfEnvironment: updatedCategoryOfEnvironment,
                  );
                },
                radius: 10,
                mainColor: AppColor.saveButton,
                child: Text(
                  'Edit',
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

  String getSelectedCategories(List<String> items, List<bool> selectedItems) {
    List<String> selectedCategories = [];
    for (int i = 0; i < items.length; i++) {
      if (selectedItems[i]) {
        selectedCategories.add(items[i]); // Hanya tambahkan yang dipilih
      }
    }
    return selectedCategories.join(', '); // Gabungkan pilihan yang dipilih saja
  }

  void showConfirmationDialog(BuildContext context,
      {String? updateDescription,
      List<XFile>? photosToUpload,
      String? categoryOfEnvironment}) {
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
                  bool hasDescriptionChanged = description != updateDescription;

                  bool hasPhotosChanged = false;
                  if (isPhotoUrlMode) {
                    // Compare current photoUrls with original photoUrls
                    hasPhotosChanged =
                        !listEquals(photoUrls, originalPhotoUrls);
                  } else {
                    // If we switched to documentation mode, there are changes
                    hasPhotosChanged = true;
                  }

                  bool hasCategoryChanged =
                      categoryOfEnvironment != this.categoryOfEnvironment;

                  if (!hasDescriptionChanged &&
                      !hasPhotosChanged &&
                      !hasCategoryChanged) {
                    if (!mounted) return;
                    Navigator.pushReplacementNamed(
                      scaffoldContext,
                      AppRoute.summaryInstallation,
                      arguments: {
                        'qms_id': qmsId,
                        'typeOfInstallationName': typeOfInstallationName,
                      },
                    );
                    return;
                  }

                  final finalDescription = edtDescription.text.isEmpty
                      ? 'no environment'
                      : updateDescription;

                  List<XFile> finalPhotos = [];
                  if (isPhotoUrlMode) {
                    // Convert existing photoUrls to XFile
                    for (String url in photoUrls!) {
                      String filename = url.split('/').last;
                      String tempPath =
                          await _downloadAndSaveImage(url, filename);
                      finalPhotos.add(XFile(tempPath));
                    }
                  } else {
                    finalPhotos = documentations;
                  }

                  print('Sending update with ${finalPhotos.length} photos');

                  final finalCategory = (categoryOfEnvironment?.isEmpty ?? true)
                      ? ''
                      : categoryOfEnvironment;

                  bool response =
                      await InstallationSource.environmentalInformationUpdate(
                    qmsInstallationStepId: qmsInstallationStepId,
                    revisionId: revisionId,
                    description: finalDescription,
                    photos: finalPhotos,
                    categoryOfEnvironment: finalCategory,
                    activeStatus: 'Created',
                  );

                  if (!mounted) return;

                  if (response) {
                    print("Final Photos : $finalPhotos");
                    Navigator.pushReplacementNamed(
                      scaffoldContext,
                      AppRoute.summaryInstallation,
                      arguments: {
                        'qms_id': qmsId,
                        'typeOfInstallationName': typeOfInstallationName,
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

  Future<String> _downloadAndSaveImage(String url, String filename) async {
    try {
      final response = await http.get(Uri.parse(url));
      final bytes = response.bodyBytes;

      // Get temporary directory
      final tempDir = await getTemporaryDirectory();
      final tempPath = path.join(tempDir.path, filename);

      // Save file
      await File(tempPath).writeAsBytes(bytes);
      return tempPath;
    } catch (e) {
      print('Error downloading image: $e');
      throw e;
    }
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

  void showErrorSnackBar([String message = 'Failed to submit step.']) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget formEditEnvironmentInstallation() {
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
          InputWidget.checkboxEditList(
            title: 'Category Of Environment',
            items: environmentalCategories,
            selectedItems: selectedCategories,
            onChanged: (int index) {
              setState(() {
                selectedCategories[index] = !selectedCategories[index];
              });
            },
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
              // Kondisi ketika tidak ada gambar sama sekali
              if ((isPhotoUrlMode && photoUrls!.isEmpty) ||
                  (!isPhotoUrlMode && documentations.isEmpty))
                Column(
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
                          // Ketika menambah foto baru, pastikan mode photoUrl dimatikan
                          setState(() {
                            isPhotoUrlMode = false;
                            photoUrls!
                                .clear(); // Clear photoUrls when switching to documentation mode
                          });
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
                )
              else
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 12, 24, 12),
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                    ),
                    itemCount: (isPhotoUrlMode
                            ? photoUrls!.length
                            : documentations.length) +
                        ((isPhotoUrlMode
                                    ? photoUrls!.length
                                    : documentations.length) <
                                imageLength
                            ? 1
                            : 0),
                    itemBuilder: (context, index) {
                      if ((isPhotoUrlMode &&
                              index == photoUrls!.length &&
                              photoUrls!.length < imageLength) ||
                          (!isPhotoUrlMode &&
                              index == documentations.length &&
                              documentations.length < imageLength)) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              isPhotoUrlMode = false;
                              photoUrls!
                                  .clear(); // Clear photoUrls when adding new images
                            });
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

                      // Tampilkan gambar sesuai mode yang aktif
                      if (!isPhotoUrlMode) {
                        String path = documentations[index].path;
                        return buildImageWidget(
                          imageUrl: path,
                          onRemove: () => removeImage(index),
                          isNetworkImage: false,
                        );
                      } else {
                        String imageUrl = photoUrls![index];
                        return buildImageWidget(
                          imageUrl: imageUrl,
                          onRemove: () {
                            setState(() {
                              removePhotoUrl(index);
                              if (photoUrls!.isEmpty) {
                                isPhotoUrlMode = false;
                              }
                            });
                          },
                          isNetworkImage: true,
                        );
                      }
                    },
                  ),
                ),
            ],
          ),
        ),
        const Gap(12),
        Text(
          "Uploaded: ${isPhotoUrlMode ? photoUrls!.length : documentations.length}/$imageLength",
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget buildImageWidget({
    required String imageUrl,
    required VoidCallback onRemove,
    required bool isNetworkImage,
  }) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (_) => Dialog(
                child: isNetworkImage
                    ? Image.network(imageUrl, fit: BoxFit.contain)
                    : Image.file(File(imageUrl), fit: BoxFit.contain),
              ),
            );
          },
          child: SizedBox(
            width: 79,
            height: 68,
            child: isNetworkImage
                ? Image.network(imageUrl, fit: BoxFit.cover)
                : Image.file(File(imageUrl), fit: BoxFit.cover),
          ),
        ),
        Positioned(
          left: 0,
          top: 0,
          child: GestureDetector(
            onTap: onRemove,
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
  }

  //Fungsi Untuk Mengahapus Gambar
  void removeImage(int index) {
    setState(() {
      documentations.removeAt(index);
      if (documentations.isEmpty) {
        isPhotoUrlMode = false;
      }
    });
  }

  void removePhotoUrl(int index) {
    setState(() {
      if (index < photoUrls!.length) {
        String removedUrl = photoUrls![index];
        String filename = removedUrl.split('/').last;

        // Add to deleted photos list
        deletedPhotoUrls.add(filename);

        // Remove from photoUrls
        photoUrls!.removeAt(index);

        if (photoUrls!.isEmpty) {
          isPhotoUrlMode = false;
        }
        // Print untuk debugging
        print('Current photos after removal: ${photoUrls!.length}');
        print('Deleted photos: $deletedPhotoUrls');
      }
    });
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
        setState(() {
          isPhotoUrlMode = false; // Pastikan mode photoUrl dimatikan
          photoUrls!.clear(); // Clear photoUrls ketika menambah foto baru

          // Calculate remaining slots
          int remainingSlots = imageLength! - documentations.length;

          if (results!.length > remainingSlots) {
            results = results?.take(remainingSlots).toList();
          }
        });

        List<XFile> processedFiles = [];
        int increment = documentations.length + 1;

        for (XFile file in results!) {
          String newFileName =
              '$qmsInstallationStepId-${increment.toString().padLeft(3, '0')}';
          increment++;
          Directory appDocDir =
              await path_provider.getApplicationDocumentsDirectory();
          String newPath = path.join(
              appDocDir.path, '$newFileName${path.extension(file.path)}');
          File newFile = await File(file.path).copy(newPath);
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
}
