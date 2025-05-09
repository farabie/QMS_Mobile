part of '../pages.dart';

class InstallationHistory extends StatefulWidget {
  const InstallationHistory({super.key});

  @override
  State<InstallationHistory> createState() => _InstallationHistoryState();
}

class _InstallationHistoryState extends State<InstallationHistory> {
  late User user;

  refresh() {
    context
        .read<InstallationRecordsUsernameBloc>()
        .add(FetchInstallationRecordsUsername(user.username ?? ''));
  }

  @override
  void initState() {
    user = context.read<UserCubit>().state;
    refresh();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(
              left: 16,
              top: 16,
              // vertical: 16,
            ),
            child: Text(
              'Installation History',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<InstallationRecordsUsernameBloc,
                InstallationRecordsUsernameState>(
              builder: (context, state) {
                if (state is InstallationRecordsUsernameLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is InstallationRecordsUsernameLoaded) {
                  final records = state.records;
                  return RefreshIndicator(
                    onRefresh: () async => refresh(),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      physics: const BouncingScrollPhysics(),
                      itemCount: records.length,
                      itemBuilder: (context, index) {
                        final record = records[index];
                        String? status = record.status;

                        return Column(
                          children: [
                            ItemHistory.installation(
                              idTicket: record.qmsId,
                              status: status,
                              textColor: _getTextStatusColor(record.status),
                              statusColor: _getStatusColor(record.status),
                              widthStatus: _getWidthStatus(record.status),
                              onTap: () {
                                if ((status == 'Created') ||
                                    (status == 'On Progress')) {
                                  Navigator.pushNamed(
                                      context, AppRoute.formAllStepInstallation,
                                      arguments: {
                                        'ticketNumber': record.dmsId,
                                        'qms_id': record.qmsId,
                                        'typeOfInstallationName':
                                            record.typeOfInstallation,
                                        'typeOfInstallationId':
                                            record.idTypeOfInstallation,
                                      });
                                } else if (status == 'Rejected') {
                                  Navigator.pushNamed(context,
                                      AppRoute.rejetedAllStepInstallation,
                                      arguments: {
                                        'ticketNumber': record.dmsId,
                                        'qms_id': record.qmsId,
                                        'email_ops': record.emailOps,
                                        'phone_ops': record.phoneOps,
                                        'approval_ops': record.approvalOps,
                                        'typeOfInstallationName':
                                            record.typeOfInstallation,
                                        'typeOfInstallationId':
                                            record.idTypeOfInstallation,
                                      });
                                } else {
                                  Navigator.pushNamed(context,
                                      AppRoute.detailHistoryInstallation,
                                      arguments: {
                                        'qms_id': record.qmsId,
                                        'typeOfInstallationName':
                                            record.typeOfInstallation,
                                      });
                                }
                              },
                              date: record
                                  .createdAt, // Assuming `record.date` is a DateTime
                              createdBy: record.username,
                              ttDms: "TT-${record.dmsId}",
                              servicePoint: record.servicePoint,
                              sectionName: record.sectionName,
                            ),
                            const SizedBox(height: 12),
                          ],
                        );
                      },
                    ),
                  );
                } else if (state is InstallationRecordsUsernameError) {
                  return Center(child: Text(state.message));
                } else {
                  return const Center(child: Text('No data available.'));
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'Created':
        return AppColor.saveButton;
      case 'On Progress':
        return AppColor.onProgressColor;
      case 'Submitted':
        return AppColor.blueColor1;
      case 'Resubmitted':
        return AppColor.blueColor1;
      case 'On Review':
        return AppColor.installation;
      case 'Rejected':
        return AppColor.rectification;
      case 'Closed':
        return AppColor.greyColor1;
      case 'Closed to be rectified':
        return AppColor.closedToBeRectifiedColor;
      case 'Canceled':
        return AppColor.canceledColor;
      default:
        return AppColor.greyColor1;
    }
  }

  Color _getTextStatusColor(String? status) {
    switch (status) {
      case 'Created':
      case 'Submitted':
      case 'Resubmitted':
      case 'On Review':
      case 'Rejected':
      case 'Closed':
      case 'Canceled':
        return AppColor.whiteColor;
      case 'On Progress':
        return AppColor.defaultText;
      case 'Closed to be rectified':
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
      case 'Resubmitted':
      case 'On Review':
      case 'Rejected':
      case 'Closed':
      case 'Canceled':
        return 70;
      case 'Closed to be rectified':
        return 120;
      default:
        return 0;
    }
  }
}
