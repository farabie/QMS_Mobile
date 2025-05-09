part of '../pages.dart';

class AuditHistory extends StatefulWidget {
  const AuditHistory({super.key});

  @override
  State<AuditHistory> createState() => _AuditHistoryState();
}

class _AuditHistoryState extends State<AuditHistory> {
  late Future<List<Audit>> _auditHistoryFuture;
  late User user;

  @override
  void initState() {
    user = context.read<UserCubit>().state;
    super.initState();
    _auditHistoryFuture = _fetchAuditHistory();
  }

  Future<List<Audit>> _fetchAuditHistory() async {
    // String username = 'Patroli';
    return await ApiService().fetchAllAudits(user.username!);
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
                  'Quality Audit History',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              Expanded(
                child: FutureBuilder<List<Audit>>(
                  future: _auditHistoryFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return const Center(
                          child: Text('Quality Audit History is Empty.'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No audits found.'));
                    }

                    List<Audit> audits = snapshot.data!;

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      physics: const BouncingScrollPhysics(),
                      itemCount: audits.length,
                      itemBuilder: (context, index) {
                        final audit = audits[index];

                        return Column(
                          children: [
                            ItemHistory.inspection(
                              idTicket: audit.qmsTicket,
                              status: audit.statusTicket,
                              textColor:
                                  _getTextStatusColor(audit.statusTicket),
                              statusColor: _getStatusColor(audit.statusTicket),
                              widthStatus: _getWidthStatus(audit.statusTicket),
                              onTap: () async {
                                if (audit.statusTicket == 'On Progress') {
                                  print('QMS Ticket: ${audit.qmsTicket}');
                                  try {
                                    final auditResponse = await ApiService()
                                        .fetchAuditByTicket2(audit.qmsTicket);

                                    if (auditResponse.assetTagging.isNotEmpty) {
                                      Navigator.pushReplacementNamed(
                                        context,
                                        AppRoute.detailPausedAudit,
                                        arguments: {
                                          'qms_ticket': audit.qmsTicket,
                                          'assetTaggingData':
                                              auditResponse.assetTagging,
                                        },
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
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
                                } else if (audit.statusTicket == 'Created') {
                                  Navigator.pushReplacementNamed(
                                    context,
                                    AppRoute.detailAuditStatus,
                                    arguments: {
                                      'qms_ticket': audit.qmsTicket,
                                      'dms_ticket': audit.dmsTicket,
                                    },
                                  );
                                } else {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoute.detailHistoryAudit,
                                    arguments: {
                                      'qms_ticket': audit.qmsTicket,
                                    },
                                  );
                                }
                              },
                              date: audit.updatedAt,
                              createdBy: audit.worker,
                              ttDms: 'TT-${audit.dmsTicket}',
                              servicePoint: audit.servicePoint,
                              sectionName: audit.sectionName,
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
        ));
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
