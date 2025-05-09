part of '../pages.dart';

class DetailDmsTicketInspectionPage extends StatefulWidget {
  final String ticketNumber;

  const DetailDmsTicketInspectionPage({super.key, required this.ticketNumber});

  @override
  _DetailDmsTicketInspectionPageState createState() =>
      _DetailDmsTicketInspectionPageState();
}

class _DetailDmsTicketInspectionPageState
    extends State<DetailDmsTicketInspectionPage> {
  late Future<List<dynamic>?> _ticketDetail;
  String? username;
  String? clusterName;
  String? emailUser;
  String? phoneUser;
  late User user;

  final TextEditingController edtProject = TextEditingController();
  final TextEditingController edtSegment = TextEditingController();
  final TextEditingController edtSectionName = TextEditingController();
  final TextEditingController edtSectionPatrol = TextEditingController();
  final TextEditingController edtWorker = TextEditingController();
  final TextEditingController edtServicePoint = TextEditingController();

  @override
  void initState() {
    super.initState();
    user = context.read<UserCubit>().state;
    username = user.username;
    clusterName = user.clusterName;
    emailUser = user.email;
    phoneUser = user.phone;
    _ticketDetail = ApiService().getTicketDetail(widget.ticketNumber);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget.secondary('Detail Ticket', context),
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
                  edtSegment.text = data['segment_name'] ?? 'N/A';
                  edtSectionName.text = data['section_name'] ?? 'N/A';
                  edtSectionPatrol.text = data['span_name'] ?? 'N/A';

                  if (data['ticket_assignees'] != null &&
                      data['ticket_assignees'].isNotEmpty) {
                    final assignee = data['ticket_assignees'][0];
                    edtWorker.text = assignee['worker'] ?? 'N/A';
                    edtServicePoint.text =
                        assignee['service_point_name'] ?? 'N/A';
                  } else {
                    edtWorker.text = 'N/A';
                    edtServicePoint.text = 'N/A';
                  }

                  return contentTicketDMS(data);
                },
              );
            }
          },
        ),
      ),
    );
  }

  Widget contentTicketDMS(Map<String, dynamic> data) {
    final String ttNumber = widget.ticketNumber;

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
            'TT-$ttNumber',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColor.defaultText,
            ),
          ),
          Divider(
            color: AppColor.greyColor2,
          ),
          InputWidget.disable('Project', edtProject),
          const Gap(6),
          InputWidget.disable('Segment', edtSegment),
          const Gap(6),
          InputWidget.disable('Section Name', edtSectionName),
          const Gap(6),
          InputWidget.disable('Section Patrol', edtSectionPatrol),
          const Gap(6),
          InputWidget.disable('Worker', edtWorker),
          const Gap(6),
          InputWidget.disable('Service Point', edtServicePoint),
          const Gap(6),
          SizedBox(
            width: double.infinity,
            child: DButtonBorder(
              onClick: () async {
                _showLoadingDialog(context);
                try {
                  // final formattedIdInspection =
                  //     await ApiService().createInspectionTicket(
                  //         username!,
                  //         widget.ticketNumber,
                  //         edtProject.text,
                  //         edtSegment.text,
                  //         edtSectionName.text,
                  //         edtSectionPatrol.text,
                  //         edtWorker.text,
                  //         edtServicePoint.text,
                  //         // clusterName!,
                  //         emailUser!,
                  //         phoneUser!,
                  //         approvalOps!,
                  //         emailOps!,
                  //         phoneOps!);

                  // Step 1: Ambil data approval berdasarkan clusterName
                  final opsApprovalSource = OpsApprovalSource();
                  final approvalData =
                      await opsApprovalSource.getApprovalOps(clusterName!);

                  if (approvalData == null || approvalData.isEmpty) {
                    throw Exception(
                        "Approval data is empty or not found for cluster: $clusterName");
                  }

                  final approvalOps =
                      approvalData[0]; // Ambil data pertama dari hasil API

                  // Step 2: Post data dengan API createInspectionTicket
                  final formattedIdInspection =
                      await ApiService().createInspectionTicket(
                    username!,
                    widget.ticketNumber,
                    edtProject.text,
                    edtSegment.text,
                    edtSectionName.text,
                    edtSectionPatrol.text,
                    edtWorker.text,
                    edtServicePoint.text,
                    emailUser!,
                    phoneUser!,
                    approvalOps.opsName, // Gunakan data approval dari API
                    approvalOps.emailOps,
                    approvalOps.phoneOps,
                  );

                  if (formattedIdInspection.isNotEmpty) {
                    _hideLoadingDialog(context);
                    Navigator.pushReplacementNamed(
                      context,
                      AppRoute.detailInspection,
                      arguments: {
                        'ticketNumber': widget.ticketNumber,
                        'formattedIdInspection': formattedIdInspection,
                        'sectionPatrol': edtSectionPatrol.text,
                      },
                    );
                  } else {
                    throw Exception("Formatted ID Inspection is null or empty");
                  }
                } catch (e) {
                  print('Error: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to create inspection ticket: $e'),
                    ),
                  );
                  _hideLoadingDialog(context);
                }
              },
              mainColor: Colors.white,
              radius: 10,
              borderColor: AppColor.scaffold,
              child: const Text(
                'Create Inspection Ticket',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const Gap(6),
        ],
      ),
    );
  }
}
