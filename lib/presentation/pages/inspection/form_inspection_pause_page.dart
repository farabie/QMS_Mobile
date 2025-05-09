part of '../pages.dart';

class FormInspectionPausePage extends StatefulWidget {
  final String ticketNumber;
  final String formattedIdInspection;
  final String idInspection;
  final String? defectId;
  final AssetTaggingInspection? selectedAssetTagging;

  const FormInspectionPausePage({
    super.key,
    required this.ticketNumber,
    required this.formattedIdInspection,
    required this.idInspection,
    required this.defectId,
    required this.selectedAssetTagging,
  });

  @override
  State<FormInspectionPausePage> createState() =>
      _FormInspectionPausePageState();
}

class _FormInspectionPausePageState extends State<FormInspectionPausePage> {
  List<String> cableTypes = [];
  List<String> categoryItems = [];
  List<String> inspectionDetails = [];
  List<String> categoryItemCode = [];

  String? selectedCableType;
  String? selectedCategoryItem;
  String? selectedInspectionDetail;
  String? selectedCategoryItemCode;

  final panoramicImages = <XFile>[].obs;
  final nearViewImages = <XFile>[].obs;
  final farViewImages = <XFile>[].obs;

  late final TextEditingController edtQmsInspectionTicketNumber;
  late final TextEditingController edtQmsInspectionDefectId;
  late final TextEditingController edtAssetTagging;
  late final TextEditingController edtcategoryItemCode;

  final edtRemark = TextEditingController();
  final edtLatitudeInstall = TextEditingController(text: '');
  final edtLongitudeInstall = TextEditingController(text: '');

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

    fetchCableTypes().then((cableTypeResults) {
      setState(() {
        cableTypes = cableTypeResults;
      });
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch cable types: $error')),
      );
    });

    edtQmsInspectionTicketNumber =
        TextEditingController(text: widget.formattedIdInspection);
    edtQmsInspectionDefectId = TextEditingController(text: widget.defectId);
    edtAssetTagging =
        TextEditingController(text: widget.selectedAssetTagging?.nama);
    edtcategoryItemCode = TextEditingController();
  }

  @override
  void dispose() {
    edtQmsInspectionTicketNumber.dispose();
    edtQmsInspectionDefectId.dispose();
    edtAssetTagging.dispose();
    edtcategoryItemCode.dispose();
    super.dispose();
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
          builder: (context) => CameraWithLocationOverlay(
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

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  void _hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  Future<void> _onWillPop(bool didPop) async {
    if (didPop) {
      return;
    }
    final bool shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Oops'),
            content: const Text('You must complete this form'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('OK'),
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
          appBar: AppBarWidget.cantBack('Form Site Inspection', context,
              onBackPressed: () => _onWillPop(false)),
          body: Column(
            children: [
              Expanded(
                child: ListView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    formInspection(),
                  ],
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
                    _showLoadingDialog(context);
                    if (selectedCableType != null &&
                        selectedCategoryItem != null &&
                        selectedInspectionDetail != null &&
                        panoramicImages.isNotEmpty &&
                        farViewImages.isNotEmpty &&
                        nearViewImages.length <= 3) {
                      try {
                        int currentFindingCount =
                            widget.selectedAssetTagging?.findingCount ?? 0;
                        int newFindingCount = currentFindingCount + 1;
                        // Panggil fungsi untuk mengirim data ke backend
                        await ApiService().postInspectionResult(
                          idAssetTagging: edtQmsInspectionDefectId.text,
                          idInspection: edtQmsInspectionTicketNumber.text,
                          nama: edtAssetTagging.text,
                          categoryItemCode: selectedCategoryItemCode!,
                          typeCable: selectedCableType!,
                          categoryInspection: selectedCategoryItem!,
                          categoryInspectionDetail: selectedInspectionDetail!,
                          panoramicImage: panoramicImages.first,
                          farImage: farViewImages.first,
                          nearImages: nearViewImages,
                          latitude: edtLatitudeInstall.text,
                          longitude: edtLongitudeInstall.text,
                          description: edtRemark.text,
                        );

                        await ApiService().updateAssetTaggingInspectionStatus(
                          nama: edtAssetTagging.text,
                          idInspection: edtQmsInspectionTicketNumber.text,
                          status: 1,
                          findingCount: newFindingCount,
                        );

                        await ApiService()
                            .updateInspectionTicketStatusOnProgress(
                                widget.formattedIdInspection, 'On Progress');

                        final response = await ApiService()
                            .fetchInspectionByTicket2(
                                widget.formattedIdInspection);

                        _hideLoadingDialog(context);

                        await Future.delayed(const Duration(milliseconds: 100));

                        Navigator.pushReplacementNamed(
                          context,
                          AppRoute.detailPausedInspection,
                          arguments: {
                            'ticketNumber': widget.ticketNumber,
                            'formattedIdInspection':
                                widget.formattedIdInspection,
                            'qms_ticket': widget.formattedIdInspection,
                            'assetTaggingData': response.assetTagging,
                            'defectId': widget.defectId,
                          },
                        );
                      } catch (error) {
                        _hideLoadingDialog(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Failed to submit data: $error')),
                        );
                      }
                    } else {
                      _hideLoadingDialog(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Please fill all the fields and upload required images')),
                      );
                    }
                  },
                  radius: 10,
                  mainColor: AppColor.saveButton,
                  child: const Text(
                    'Next Inspection',
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
        ));
  }

  Widget formInspection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Inspection Result 1',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColor.defaultText,
            ),
          ),
          Divider(
            color: AppColor.greyColor2,
          ),
          InputWidget.disable(
            'QMS Inspection Ticket Number',
            edtQmsInspectionTicketNumber,
          ),
          const Gap(6),
          InputWidget.disable(
            'QMS Inspecion Defect ID',
            edtQmsInspectionDefectId,
          ),
          const Gap(6),
          InputWidget.disable(
            'Span Route',
            edtAssetTagging,
          ),
          const Gap(6),
          InputWidget.dropDown(
            'Type of cable/enviroment Inspection',
            "Select Type Of Cable",
            selectedCableType,
            cableTypes,
            (newValue) {
              if (newValue != selectedCableType) {
                setState(() {
                  selectedCableType = newValue;
                  selectedCategoryItem = null; // Reset dependent dropdown
                  selectedInspectionDetail = null; // Reset further dropdown
                  selectedCategoryItemCode = null; // Reset further dropdown
                  categoryItems = []; // Clear category items
                  inspectionDetails = []; // Clear inspection details
                  categoryItemCode = []; // Clear inspection details

                  fetchCategoryItems(newValue!).then((categoryItemResults) {
                    setState(() {
                      categoryItems = categoryItemResults;
                    });
                  }).catchError((error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text('Failed to fetch category items: $error')),
                    );
                  });
                });
              }
            },
            'Search type cable/environment Inspection',
          ),
          const Gap(6),
          InputWidget.dropDown(
            'Category of Inspection',
            "Select Category of Inspection",
            selectedCategoryItem,
            categoryItems,
            (newValue) {
              if (newValue != selectedCategoryItem) {
                setState(() {
                  selectedCategoryItem = newValue;
                  selectedInspectionDetail = null;
                  selectedCategoryItemCode = null;
                  inspectionDetails = [];
                  categoryItemCode = [];
                });

                if (selectedCableType != null) {
                  fetchItems(newValue!, selectedCableType!).then((itemResults) {
                    setState(() {
                      inspectionDetails = itemResults;
                    });
                  }).catchError((error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              'Failed to fetch inspection details: $error')),
                    );
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('Please select Cable Type before Category')),
                  );
                }
              }
            },
            'Search category of Inspection',
          ),
          const Gap(6),
          InputWidget.dropDown(
            'Category of Inspection Details',
            "Select Category of Inspection Details",
            selectedInspectionDetail,
            inspectionDetails,
            (newValue) {
              if (newValue != selectedInspectionDetail) {
                setState(() {
                  selectedInspectionDetail = newValue;
                  selectedCategoryItemCode = null;
                  categoryItemCode = [];

                  final categoryItems = selectedCategoryItem;

                  if (categoryItems != null) {
                    fetchCategoryItemCode(newValue!, categoryItems)
                        .then((categoryItemCodeResults) {
                      setState(() {
                        if (categoryItemCodeResults.isNotEmpty) {
                          selectedCategoryItemCode =
                              categoryItemCodeResults.first;
                          edtcategoryItemCode.text = selectedCategoryItemCode!;
                        }
                      });
                    }).catchError((error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'Failed to fetch category item code: $error')),
                      );
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select a cable type first'),
                      ),
                    );
                  }
                });
              }
            },
            'Search category of Inspection Details',
          ),
          const Gap(6),
          InputWidget.disable(
            'Category Item Code',
            edtcategoryItemCode,
          ),
          const Gap(6),
          uploadFile('Take Picture Panoramic View (5 - 10 meter)',
              'Take Picture', panoramicImages, 1),
          const Gap(6),
          uploadFile('Take Picture Far View (2 - 5 meter)', 'Take Picture',
              farViewImages, 1),
          const Gap(6),
          uploadFile('Take Picture Near View (< 0.8 meter)', 'Take Picture',
              nearViewImages, 3),
          const Gap(6),
          InputWidget.disable('Latitude', edtLatitudeInstall),
          const Gap(6),
          InputWidget.disable('Longitude', edtLongitudeInstall),
          const Gap(6),
          InputWidget.textArea2(
            'Description (wajib diisi)',
            'Description',
            edtRemark,
          ),
          const Gap(12),
        ],
      ),
    );
  }

  Widget uploadFile(
      String title, String textButton, RxList<XFile> images, int maxImages) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
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
