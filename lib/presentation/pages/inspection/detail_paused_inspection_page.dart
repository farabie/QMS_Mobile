part of '../pages.dart';

class DetailPausedInspectionPage extends StatefulWidget {
  final String ticketNumber;
  final String idInspection;
  final bool isReversed;

  const DetailPausedInspectionPage({
    super.key,
    required this.ticketNumber,
    required this.idInspection,
    required this.isReversed,
  });

  @override
  _DetailPausedInspectionPageState createState() =>
      _DetailPausedInspectionPageState();
}

class _DetailPausedInspectionPageState
    extends State<DetailPausedInspectionPage> {
  List<AssetTaggingInspection> assetTaggingData = [];
  AssetTaggingInspection? selectedAssetTagging;

  late final TextEditingController edtQmsInspectionTicketNumber;
  final TextEditingController edtProject = TextEditingController();

  @override
  void initState() {
    super.initState();
    edtQmsInspectionTicketNumber =
        TextEditingController(text: widget.idInspection);
    _refreshAssetTaggings(widget.idInspection); // Load data initially
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _refreshAssetTaggings(widget.idInspection);
  }

  Future<String?> _updateAssetTaggingStatus(
      String defectId, int status, int findingCount,
      {bool createDefectId = true}) async {
    try {
      String? createdDefectId;

      // Create defect ID only if the parameter is true
      if (createDefectId) {
        createdDefectId = await ApiService().createDefectId(
          idInspection: widget.idInspection,
          defectId: defectId,
        );
      }

      await ApiService().updateAssetTaggingInspectionStatus(
        nama: defectId,
        idInspection: widget.idInspection,
        status: status,
        findingCount: findingCount,
      );

      print(
          'Updated Asset Tagging: $defectId, Status: $status, Finding Count: $findingCount');

      return createdDefectId;
    } catch (e) {
      print('Error updating asset tagging status: $e');
      return null;
    }
  }

  void _refreshAssetTaggings(String idInspection) async {
    try {
      List<AssetTaggingInspection> refreshedTaggings =
          await ApiService().getAssetTaggingInspection(idInspection);

      if (refreshedTaggings.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('No asset taggings found for this inspection')),
        );
        return;
      }

      setState(() {
        assetTaggingData = refreshedTaggings;
      });
    } catch (e) {
      print('Error refreshing asset taggings: $e');
    }
  }

  bool isLastAssetTagging() {
    return assetTaggingData.every((tag) => tag.status == 2);
  }

  Future<void> _onWillPop(bool didPop) async {
    if (didPop) return;

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
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoute.dashboard,
        arguments: 1,
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args == null || args['assetTaggingData'] == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Detail Paused Inspection'),
        ),
        body: const Center(child: Text('No data available')),
      );
    }

    // Assuming that the assetTaggingData is provided in the args
    final List<AssetTaggingInspection> assetTaggingData =
        args['assetTaggingData'];

    return PopScope(
      onPopInvoked: _onWillPop,
      canPop: false,
      child: Scaffold(
        appBar: AppBarWidget.cantBack(
          'Detail Ticket',
          context,
          onBackPressed: () => _onWillPop(false),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
          child: contentTicketDMS3(assetTaggingData),
        ),
      ),
    );
  }

  Widget contentTicketDMS3(List<AssetTaggingInspection> assetTaggingData) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      // child: Column(
      //   crossAxisAlignment: CrossAxisAlignment.start,
      //   children: [
      //     Expanded(
      //       child: ListView(
      //         children: [
      //           InputWidget.disable(
      //             'QMS Inspection Ticket Number',
      //             edtQmsInspectionTicketNumber,
      //           ),
      //           const Gap(12),
      //           const Text(
      //             'Span Route',
      //             style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      //           ),
      //           const Gap(6),
      //           ListView.builder(
      //             shrinkWrap: true,
      //             physics: const NeverScrollableScrollPhysics(),
      //             itemCount: assetTaggingData.length,
      //             itemBuilder: (context, index) {
      //               final currentTag = assetTaggingData[index];

      //               final isActive = (index == 0 && currentTag.status != 2) ||
      //                   (index > 0 && assetTaggingData[index - 1].status == 2);

      //               print('Current Tag at index $index: ${currentTag.nama}');
      //               print(
      //                   'Current Tag: ${currentTag.nama}, Finding Count: ${currentTag.findingCount}');

      //               return GestureDetector(
      //                   onTap: isActive && currentTag.status != 2
      //                       ? () {
      //                           setState(() {
      //                             selectedAssetTagging = currentTag;
      //                           });
      //                         }
      //                       : null,
      //                   child: Container(
      //                     width: double.infinity,
      //                     padding: const EdgeInsets.all(12),
      //                     margin: const EdgeInsets.only(bottom: 8),
      //                     decoration: BoxDecoration(
      //                       border: Border.all(color: Colors.black),
      //                       borderRadius: BorderRadius.circular(8),
      //                       color: currentTag.status == 2
      //                           ? Colors.white
      //                           : isActive
      //                               ? AppColor.qualityAudit
      //                               : AppColor.greyColor3,
      //                     ),
      //                     child: Row(
      //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //                       children: [
      //                         Column(
      //                           crossAxisAlignment: CrossAxisAlignment.start,
      //                           children: [
      //                             Row(
      //                               children: [
      //                                 if (currentTag.findingCount > 0)
      //                                   Container(
      //                                     width: 22,
      //                                     height: 22,
      //                                     margin:
      //                                         const EdgeInsets.only(right: 8),
      //                                     alignment: Alignment.center,
      //                                     decoration: const BoxDecoration(
      //                                       color: Colors.red,
      //                                       shape: BoxShape.circle,
      //                                     ),
      //                                     child: Text(
      //                                       '${currentTag.findingCount}',
      //                                       style: const TextStyle(
      //                                         color: Colors.white,
      //                                         fontSize: 12,
      //                                         fontWeight: FontWeight.bold,
      //                                       ),
      //                                     ),
      //                                   ),
      //                                 Text(
      //                                   '${currentTag.nama}',
      //                                   style: TextStyle(
      //                                     fontSize: 12,
      //                                     color: currentTag.status == 2
      //                                         ? Colors.black
      //                                         : isActive
      //                                             ? Colors.white
      //                                             : Colors.black,
      //                                   ),
      //                                 ),
      //                               ],
      //                             ),
      //                           ],
      //                         ),
      //                         const Spacer(),
      //                         if (isActive && currentTag.status != 2)
      //                           GestureDetector(
      //                             onTap: () {
      //                               showDialog(
      //                                 context: context,
      //                                 builder: (context) {
      //                                   return AlertDialog(
      //                                     title: Text(
      //                                         'Apakah ada temuan di ${currentTag.nama} ?'),
      //                                     actions: [
      //                                       TextButton(
      //                                         onPressed: () async {
      //                                           int newFindingCount =
      //                                               currentTag.findingCount + 1;
      //                                           String? newDefectId =
      //                                               await _updateAssetTaggingStatus(
      //                                             currentTag.nama,
      //                                             1, // Status
      //                                             newFindingCount,
      //                                             createDefectId: true,
      //                                           );

      //                                           // Navigator.pop(context);
      //                                           // if (mounted) {
      //                                           Navigator.pushReplacementNamed(
      //                                             context,
      //                                             AppRoute.formInspectionPause,
      //                                             arguments: {
      //                                               'ticketNumber':
      //                                                   widget.ticketNumber,
      //                                               'formattedIdInspection':
      //                                                   widget.idInspection,
      //                                               'selectedAssetTagging':
      //                                                   currentTag,
      //                                               'defectId': newDefectId,
      //                                             },
      //                                           ).then((_) {
      //                                             setState(() {
      //                                               _refreshAssetTaggings(
      //                                                   widget.idInspection);
      //                                             });
      //                                           });
      //                                           // }
      //                                         },
      //                                         child: const Text('Yes'),
      //                                       ),
      //                                       TextButton(
      //                                         onPressed: () async {
      //                                           Navigator.pop(context);

      //                                           await Future.delayed(
      //                                               const Duration(seconds: 1));

      //                                           await _updateAssetTaggingStatus(
      //                                             currentTag.nama,
      //                                             2,
      //                                             currentTag.findingCount,
      //                                             createDefectId: false,
      //                                           );

      //                                           await ApiService()
      //                                               .updateInspectionTicketStatusOnProgress(
      //                                                   widget.idInspection,
      //                                                   'On Progress');

      //                                           setState(() {
      //                                             currentTag.status = 2;
      //                                           });

      //                                           // Cek jika ada asset tagging berikutnya
      //                                           int currentIndex =
      //                                               assetTaggingData
      //                                                   .indexOf(currentTag);
      //                                           if (currentIndex + 1 <
      //                                               assetTaggingData.length) {
      //                                             await _updateAssetTaggingStatus(
      //                                               assetTaggingData[
      //                                                       currentIndex + 1]
      //                                                   .nama,
      //                                               1, // Status
      //                                               assetTaggingData[
      //                                                       currentIndex + 1]
      //                                                   .findingCount,
      //                                               createDefectId: false,
      //                                             );

      //                                             setState(() {
      //                                               assetTaggingData[
      //                                                       currentIndex + 1]
      //                                                   .status = 1;
      //                                             });
      //                                           } else {
      //                                             setState(() {
      //                                               _refreshAssetTaggings(
      //                                                   widget.idInspection);
      //                                             });
      //                                           }
      //                                         },
      //                                         child: const Text('No'),
      //                                       ),
      //                                     ],
      //                                   );
      //                                 },
      //                               );
      //                             },
      //                             child: const Icon(
      //                               Icons.arrow_forward,
      //                               color: Colors.white,
      //                             ),
      //                           ),
      //                       ],
      //                     ),
      //                   ));
      //             },
      //           ),
      //           const Gap(24),
      //           SizedBox(
      //             width: double.infinity,
      //             child: DButtonBorder(
      //               onClick: isLastAssetTagging()
      //                   ? () async {
      //                       Navigator.pushReplacementNamed(
      //                         context,
      //                         AppRoute.summaryInspection,
      //                         arguments: {
      //                           'idInspection': widget.idInspection,
      //                           'assetTaggings': assetTaggingData,
      //                         },
      //                       );
      //                     }
      //                   : null,
      //               mainColor: AppColor.inspection,
      //               radius: 10,
      //               borderColor: isLastAssetTagging()
      //                   ? AppColor.inspection
      //                   : AppColor.greyColor2,
      //               child: const Text(
      //                 'Finish',
      //                 style: TextStyle(
      //                   color: Colors.white,
      //                   fontSize: 16,
      //                   fontWeight: FontWeight.w600,
      //                 ),
      //               ),
      //             ),
      //           ),
      //           const Gap(24),
      //         ],
      //       ),
      //     ),
      //   ],
      // ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ListView(
              children: [
                InputWidget.disable(
                  'QMS Inspection Ticket Number',
                  edtQmsInspectionTicketNumber,
                ),
                const Gap(12),
                const Text(
                  'Span Route',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const Gap(6),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: assetTaggingData.length,
                  itemBuilder: (context, index) {
                    final currentTag = assetTaggingData[index];
                    final isActive = (index == 0 && currentTag.status != 2) ||
                        (index > 0 && assetTaggingData[index - 1].status == 2);

                    return GestureDetector(
                      onTap: isActive && currentTag.status != 2
                          ? () {
                              setState(() {
                                selectedAssetTagging = currentTag;
                              });
                            }
                          : null,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(8),
                          color: currentTag.status == 2
                              ? Colors.white
                              : isActive
                                  ? AppColor.qualityAudit
                                  : AppColor.greyColor3,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              // Gunakan Expanded di sini agar teks dapat membungkus dengan benar.
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (currentTag.findingCount > 0)
                                        Container(
                                          width: 22,
                                          height: 22,
                                          margin:
                                              const EdgeInsets.only(right: 8),
                                          alignment: Alignment.center,
                                          decoration: const BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Text(
                                            '${currentTag.findingCount}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      Expanded(
                                        // Pastikan teks panjang dapat terbungkus
                                        child: Text(
                                          currentTag.nama,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: currentTag.status == 2
                                                ? Colors.black
                                                : isActive
                                                    ? Colors.white
                                                    : Colors.black,
                                          ),
                                          overflow: TextOverflow.visible,
                                          softWrap: true,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            if (isActive && currentTag.status != 2)
                              GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text(
                                          'Apakah ada temuan di ${currentTag.nama} ?',
                                        ),
                                        actions: [
                                          // Dialog Buttons
                                          TextButton(
                                            onPressed: () async {
                                              int newFindingCount =
                                                  currentTag.findingCount + 1;
                                              String? newDefectId =
                                                  await _updateAssetTaggingStatus(
                                                currentTag.nama,
                                                1, // Status
                                                newFindingCount,
                                                createDefectId: true,
                                              );

                                              // Navigator.pop(context);
                                              // if (mounted) {
                                              Navigator.pushReplacementNamed(
                                                context,
                                                AppRoute.formInspectionPause,
                                                arguments: {
                                                  'ticketNumber':
                                                      widget.ticketNumber,
                                                  'formattedIdInspection':
                                                      widget.idInspection,
                                                  'selectedAssetTagging':
                                                      currentTag,
                                                  'defectId': newDefectId,
                                                },
                                              ).then((_) {
                                                setState(() {
                                                  _refreshAssetTaggings(
                                                      widget.idInspection);
                                                });
                                              });
                                              // }
                                            },
                                            child: const Text('Yes'),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              Navigator.pop(context);

                                              await Future.delayed(
                                                  const Duration(seconds: 1));

                                              await _updateAssetTaggingStatus(
                                                currentTag.nama,
                                                2,
                                                currentTag.findingCount,
                                                createDefectId: false,
                                              );

                                              await ApiService()
                                                  .updateInspectionTicketStatusOnProgress(
                                                      widget.idInspection,
                                                      'On Progress');

                                              setState(() {
                                                currentTag.status = 2;
                                              });

                                              // Cek jika ada asset tagging berikutnya
                                              int currentIndex =
                                                  assetTaggingData
                                                      .indexOf(currentTag);
                                              if (currentIndex + 1 <
                                                  assetTaggingData.length) {
                                                await _updateAssetTaggingStatus(
                                                  assetTaggingData[
                                                          currentIndex + 1]
                                                      .nama,
                                                  1, // Status
                                                  assetTaggingData[
                                                          currentIndex + 1]
                                                      .findingCount,
                                                  createDefectId: false,
                                                );

                                                setState(() {
                                                  assetTaggingData[
                                                          currentIndex + 1]
                                                      .status = 1;
                                                });
                                              } else {
                                                setState(() {
                                                  _refreshAssetTaggings(
                                                      widget.idInspection);
                                                });
                                              }
                                            },
                                            child: const Text('No'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                child: const Icon(
                                  Icons.arrow_forward,
                                  color: Colors.white,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const Gap(24),
                SizedBox(
                  width: double.infinity,
                  child: DButtonBorder(
                    onClick: isLastAssetTagging()
                        ? () {
                            Navigator.pushReplacementNamed(
                              context,
                              AppRoute.summaryInspection,
                              arguments: {
                                'idInspection': widget.idInspection,
                                'assetTaggings': assetTaggingData,
                              },
                            );
                          }
                        : null,
                    mainColor: AppColor.inspection,
                    radius: 10,
                    borderColor: isLastAssetTagging()
                        ? AppColor.inspection
                        : AppColor.greyColor2,
                    child: const Text(
                      'Finish',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const Gap(24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
