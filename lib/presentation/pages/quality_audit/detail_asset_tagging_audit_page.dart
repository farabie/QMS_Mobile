part of '../pages.dart';

class DetailAssetTaggingAuditPage extends StatefulWidget {
  final String ticketNumber;
  final String formattedIdAudit;
  final bool isReversed;

  const DetailAssetTaggingAuditPage(
      {super.key,
      required this.ticketNumber,
      required this.formattedIdAudit,
      required this.isReversed});

  @override
  _DetailAssetTaggingAuditPageState createState() =>
      _DetailAssetTaggingAuditPageState();
}

class _DetailAssetTaggingAuditPageState
    extends State<DetailAssetTaggingAuditPage> {
  List<AssetTaggingAudit> assetTaggings = [];
  AssetTaggingAudit? selectedAssetTagging;

  late Future<List<dynamic>?> _ticketDetail;

  late final TextEditingController edtQmsAuditTicketNumber;
  final TextEditingController edtProject = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ticketDetail = ApiService().getTicketDetail(widget.ticketNumber);
    _loadAssetTaggingFromLocal(widget.formattedIdAudit);
    edtQmsAuditTicketNumber =
        TextEditingController(text: widget.formattedIdAudit);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadAssetTaggingFromLocal(
        widget.formattedIdAudit); // Refetch data saat kembali
  }

  Future<void> _loadAssetTaggingFromLocal(String idAudit) async {
    try {
      final assetTaggingData = await ApiService().getAssetTaggingAudit(idAudit);

      setState(() {
        assetTaggings = assetTaggingData;

        print(
            'Asset Tagging List: ${assetTaggings.map((e) => e.nama).toList()}');

        if (assetTaggings.isNotEmpty) {
          selectedAssetTagging =
              assetTaggings[0]; // Set the first item as selected
        }
      });
    } catch (e) {
      print('Error fetching asset tagging: $e');
    }
  }

  Future<String?> _updateAssetTaggingStatus(
      String defectId, int status, int findingCount,
      {bool createDefectId = true}) async {
    try {
      String? createdDefectId;

      // Create defect ID only if the parameter is true
      if (createDefectId) {
        createdDefectId = await ApiService().createDefectId(
          idInspection: widget.formattedIdAudit,
          defectId: defectId,
        );
      }

      await ApiService().updateAssetTaggingAuditStatus(
        nama: defectId,
        idAudit: widget.formattedIdAudit,
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

  void _refreshAssetTaggings(String idAudit) async {
    try {
      List<AssetTaggingAudit> refreshedTaggings =
          await ApiService().getAssetTaggingAudit(idAudit);

      setState(() {
        assetTaggings = refreshedTaggings;
      });
    } catch (e) {
      print('Error refreshing asset taggings: $e');
    }
  }

  bool isLastAssetTagging() {
    return assetTaggings.every((tag) => tag.status == 2);
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
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoute.dashboard,
        arguments: 4,
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
            child: FutureBuilder<List<dynamic>?>(
              future: _ticketDetail,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData ||
                    snapshot.data == null ||
                    snapshot.data!.isEmpty) {
                  return const Center(child: Text('No data available'));
                } else {
                  final List<dynamic> dataList = snapshot.data!;
                  return ListView.builder(
                    itemCount: dataList.length,
                    itemBuilder: (context, index) {
                      final data = dataList[index] as Map<String, dynamic>;
                      edtProject.text = data['project_name'] ?? 'N/A';

                      return contentTicketDMS3(data);
                    },
                  );
                }
              },
            ),
          ),
        ));
  }

  Widget contentTicketDMS3(Map<String, dynamic> data) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InputWidget.disable(
            'QMS Audit Ticket Number',
            edtQmsAuditTicketNumber,
          ),
          const Gap(12),
          const Text(
            'Span Route',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const Gap(6),
          Column(
            children: assetTaggings.isNotEmpty
                ? List.generate(assetTaggings.length, (index) {
                    final currentTag = assetTaggings[index];

                    final isActive = (index == 0 && currentTag.status != 2) ||
                        (index > 0 && assetTaggings[index - 1].status == 2);

                    print('Current Tag at index $index: ${currentTag.nama}');
                    print(
                        'Current Tag: ${currentTag.nama}, Finding Count: ${currentTag.findingCount}');

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
                                                fontSize: 14,
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
                                            softWrap: false,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              if (isActive && currentTag.status != 2)
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: Text(
                                              'Apakah ada temuan di ${currentTag.nama} ?'),
                                          actions: [
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

                                                Navigator.pushReplacementNamed(
                                                  context,
                                                  AppRoute.formAudit,
                                                  arguments: {
                                                    'ticketNumber':
                                                        widget.ticketNumber,
                                                    'formattedIdAudit':
                                                        widget.formattedIdAudit,
                                                    'selectedAssetTagging':
                                                        currentTag,
                                                    'defectId': newDefectId,
                                                  },
                                                ).then((_) {
                                                  setState(() {
                                                    _refreshAssetTaggings(widget
                                                        .formattedIdAudit);
                                                  });
                                                });
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
                                                    .updateAuditTicketStatusOnProgress(
                                                        widget.formattedIdAudit,
                                                        'On Progress');

                                                setState(() {
                                                  currentTag.status = 2;
                                                });

                                                int currentIndex = assetTaggings
                                                    .indexOf(currentTag);
                                                if (currentIndex + 1 <
                                                    assetTaggings.length) {
                                                  await _updateAssetTaggingStatus(
                                                    assetTaggings[
                                                            currentIndex + 1]
                                                        .nama,
                                                    1, // Status
                                                    assetTaggings[
                                                            currentIndex + 1]
                                                        .findingCount,
                                                    createDefectId: false,
                                                  );

                                                  setState(() {
                                                    assetTaggings[
                                                            currentIndex + 1]
                                                        .status = 1;
                                                  });
                                                } else {
                                                  setState(() {
                                                    _refreshAssetTaggings(widget
                                                        .formattedIdAudit);
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
                        ));
                  }).toList()
                : [const Center(child: Text('No Asset Taggings Available'))],
          ),
          const Gap(24),
          SizedBox(
            width: double.infinity,
            child: DButtonBorder(
              onClick: isLastAssetTagging()
                  ? () async {
                      Navigator.pushReplacementNamed(
                        context,
                        AppRoute.summaryAudit,
                        arguments: {
                          'idAudit': widget.formattedIdAudit,
                          'assetTaggings': assetTaggings,
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
    );
  }
}
