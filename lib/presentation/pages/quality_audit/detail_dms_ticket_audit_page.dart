part of '../pages.dart';

class DetailDmsTicketAuditPage extends StatefulWidget {
  final String ticketNumber;

  const DetailDmsTicketAuditPage({super.key, required this.ticketNumber});

  @override
  _DetailDmsTicketAuditPageState createState() =>
      _DetailDmsTicketAuditPageState();
}

class _DetailDmsTicketAuditPageState extends State<DetailDmsTicketAuditPage> {
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

  List<String> servicePointAuditList = [];
  String? selectedServicePointAudit;

  @override
  void initState() {
    super.initState();
    user = context.read<UserCubit>().state;
    username = user.username;
    clusterName = user.clusterName;
    emailUser = user.email;
    phoneUser = user.phone;
    _ticketDetail = ApiService().getTicketDetail(widget.ticketNumber);

    _fetchServicePointAudit();
  }

  Future<void> _fetchServicePointAudit() async {
    try {
      // Step 1: Get cluster name from API
      final clusterResponse = await ApiService().getClusterName(username!);
      if (clusterResponse != null && clusterResponse.isNotEmpty) {
        clusterName = clusterResponse; // clusterName adalah String

        // Print untuk memeriksa apakah clusterName benar
        print('Cluster name yang diterima: $clusterName');

        // Step 2: Get service points using the cluster name
        final servicePoints = await ApiService().getServicePoints(
            clusterName!); // Pastikan parameter ini sesuai dengan tipe String

        // Cek apakah servicePoints yang diterima valid
        print('Service Points: $servicePoints');

        setState(() {
          servicePointAuditList = servicePoints ?? [];
        });
      } else {
        throw Exception('Cluster name not found for username: $username');
      }
    } catch (e) {
      print('Error fetching service point audit: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to fetch Service Point Audit: $e'),
        ),
      );
    }
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
          InputWidget.dropDown(
            'Service Point Audit',
            'Select Service Point',
            selectedServicePointAudit,
            servicePointAuditList,
            (newValue) {
              setState(() {
                selectedServicePointAudit = newValue;
              });
            },
            'Search service point',
          ),
          const Gap(6),
          SizedBox(
            width: double.infinity,
            child: DButtonBorder(
              onClick: () async {
                _showLoadingDialog(context);
                try {
                  // final formattedIdAudit = await ApiService().createAuditTicket(
                  //   username!,
                  //   widget.ticketNumber,
                  //   edtProject.text,
                  //   edtSegment.text,
                  //   edtSectionName.text,
                  //   edtSectionPatrol.text,
                  //   edtWorker.text,
                  //   edtServicePoint.text,
                  // );

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

                  // Step 2: Post data dengan API createAuditTicket
                  final formattedIdAudit = await ApiService().createAuditTicket(
                    username!,
                    widget.ticketNumber,
                    edtProject.text,
                    edtSegment.text,
                    edtSectionName.text,
                    edtSectionPatrol.text,
                    edtWorker.text,
                    edtServicePoint.text,
                    selectedServicePointAudit!,
                    emailUser!,
                    phoneUser!,
                    approvalOps.opsName, // Gunakan data approval dari API
                    approvalOps.emailOps,
                    approvalOps.phoneOps,
                  );

                  if (formattedIdAudit.isNotEmpty) {
                    _hideLoadingDialog(context);
                    Navigator.pushReplacementNamed(
                      context,
                      AppRoute.detailAudit,
                      arguments: {
                        'ticketNumber': widget.ticketNumber,
                        'formattedIdAudit': formattedIdAudit,
                        'sectionPatrol': edtSectionPatrol.text,
                      },
                    );
                  } else {
                    throw Exception("Formatted ID Audit is null or empty");
                  }
                } catch (e) {
                  print('Error: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to create audit ticket: $e'),
                    ),
                  );
                  _hideLoadingDialog(context);
                }
              },
              mainColor: Colors.white,
              radius: 10,
              borderColor: AppColor.scaffold,
              child: const Text(
                'Create Quality Audit Ticket',
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
