part of '../pages.dart';

class InspectionHistory extends StatefulWidget {
  const InspectionHistory({super.key});

  @override
  State<InspectionHistory> createState() => _InspectionHistoryState();
}

class _InspectionHistoryState extends State<InspectionHistory> {
  late Future<List<Inspection>> _inspectionHistoryFuture;
  late User user;

  @override
  void initState() {
    user = context.read<UserCubit>().state;
    super.initState();
    _inspectionHistoryFuture = _fetchInspectionHistory();
  }

  Future<List<Inspection>> _fetchInspectionHistory() async {
    return await ApiService().fetchAllInspections(user.username!);
  }

  Future<bool> _onWillPop() async {
    return true; // Mengembalikan true akan menutup aplikasi

    // Navigator.pushReplacementNamed(context, AppRoute.dashboard);
    // return false; // Mengembalikan false akan mencegah kembali ke halaman sebelumnya
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(
                left: 16,
                top: 16,
              ),
              child: Text(
                'Inspection History',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Inspection>>(
                future: _inspectionHistoryFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(
                        child: Text('Inspection History is Empty'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No inspections found.'));
                  }

                  List<Inspection> inspections = snapshot.data!;

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    physics: const BouncingScrollPhysics(),
                    itemCount: inspections.length,
                    itemBuilder: (context, index) {
                      final inspection = inspections[index];

                      return Column(
                        children: [
                          ItemHistory.inspection(
                            idTicket: inspection.qmsTicket,
                            status: inspection.statusTicket,
                            textColor:
                                _getTextStatusColor(inspection.statusTicket),
                            statusColor:
                                _getStatusColor(inspection.statusTicket),
                            widthStatus:
                                _getWidthStatus(inspection.statusTicket),
                            onTap: () async {
                              if (inspection.statusTicket == 'On Progress') {
                                print('QMS Ticket: ${inspection.qmsTicket}');
                                try {
                                  final inspectionResponse = await ApiService()
                                      .fetchInspectionByTicket2(
                                          inspection.qmsTicket);

                                  if (inspectionResponse
                                      .assetTagging.isNotEmpty) {
                                    Navigator.pushReplacementNamed(
                                      context,
                                      AppRoute.detailPausedInspection,
                                      arguments: {
                                        'qms_ticket': inspection.qmsTicket,
                                        'assetTaggingData':
                                            inspectionResponse.assetTagging,
                                      },
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'No asset tagging data available'),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Error fetching asset tagging data: $e'),
                                    ),
                                  );
                                }
                              } else if (inspection.statusTicket == 'Created') {
                                Navigator.pushReplacementNamed(
                                  context,
                                  AppRoute.detailInspectionStatus,
                                  arguments: {
                                    'qms_ticket': inspection.qmsTicket,
                                    'dms_ticket': inspection.dmsTicket,
                                  },
                                );
                              } else {
                                Navigator.pushNamed(
                                  context,
                                  AppRoute.detailHistoryInspection,
                                  arguments: {
                                    'qms_ticket': inspection.qmsTicket,
                                  },
                                );
                              }
                            },
                            date: inspection.updatedAt,
                            createdBy: inspection.worker,
                            ttDms: 'TT-${inspection.dmsTicket}',
                            servicePoint: inspection.servicePoint,
                            sectionName: inspection.sectionName,
                          ),
                          const SizedBox(height: 12),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Created':
        return AppColor.saveButton;
      case 'Paused':
        return AppColor.rectification;
      case 'On Progress':
        return AppColor.onProgress;
      case 'Submitted':
        return AppColor.blueColor1;
      case 'On Review':
        return AppColor.installation;
      case 'Closed':
        return AppColor.greyColor1;
      case 'Closed To Be Rectified':
        return AppColor.closedToBeRectifiedColor;
      default:
        return AppColor.greyColor1;
    }
  }

  Color _getTextStatusColor(String? status) {
    switch (status) {
      case 'Created':
      case 'Paused':
        return AppColor.whiteColor;
      case 'On Progress':
        return AppColor.defaultText;
      case 'Submitted':
      case 'On Review':
      case 'Closed':
        return AppColor.whiteColor;
      case 'Closed To Be Rectified':
        return AppColor.rejectedColor;
      default:
        return AppColor.greyColor1;
    }
  }

  double _getWidthStatus(String? status) {
    switch (status) {
      case 'Created':
      case 'On Progress':
      case 'Submitted':
      case 'On Review':
      case 'Closed':
        return 70;
      case 'Closed To Be Rectified':
        return 110;
      default:
        return 0;
    }
  }
}
