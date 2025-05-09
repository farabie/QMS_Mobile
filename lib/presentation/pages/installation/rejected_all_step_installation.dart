part of '../pages.dart';

class RejectedAllStepInstallation extends StatefulWidget {
  const RejectedAllStepInstallation({super.key});

  @override
  State<RejectedAllStepInstallation> createState() =>
      _RejectedAllStepInstallationState();
}

class _RejectedAllStepInstallationState
    extends State<RejectedAllStepInstallation> {
  final ScrollController _scrollController = ScrollController();
  String? qmsId;
  String? typeOfInstallationName;
  int? typeOfInstallationId;
  String? ticketNumber;
  String? emailOps;
  String? phoneOps;
  String? approvalOps;

  late User user;
  String? userEmail;
  String? passEmail;

  @override
  void initState() {
    super.initState();
    user = context.read<UserCubit>().state;
    userEmail = user.userEmail;
    passEmail = user.passEmail;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments as Map?;

    if (args != null) {
      ticketNumber = args['ticketNumber'] as String?;
      qmsId = args['qms_id'] as String?;
      emailOps = args['email_ops'] as String?;
      phoneOps = args['phone_ops'] as String?;
      approvalOps = args['approval_ops'] as String?;
      typeOfInstallationName = args['typeOfInstallationName'] as String?;
      typeOfInstallationId = args['typeOfInstallationId'] as int?;
    }

    if (qmsId != null) {
      context
          .read<InstallationStepRecordsBloc>()
          .add(FetchInstallationStepRecords(qmsId!));
    }
  }

  Future<void> _refreshInstallationSteps() async {
    if (qmsId != null) {
      context
          .read<InstallationStepRecordsBloc>()
          .add(FetchInstallationStepRecords(qmsId!));
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget.cantBack(
        'Installation Step Rejected',
        context,
        onBackPressed: () => _onWillPop(false),
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshInstallationSteps,
              child: ListView(
                controller: _scrollController,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
                physics: const BouncingScrollPhysics(),
                children: [
                  const Gap(6),
                  rejectedStepInstallation(),
                ],
              ),
            ),
          )
        ],
      ),
    );
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

  void showConfirmationDialog(BuildContext context, String qmsId) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Installation Step Rejected'),
          content: const Text(
              'Apakah anda yakin installation step reject yang anda revisi sudah benar'),
          actions: [
            TextButton(
              onPressed: () {
                navigator.pop(); // Close dialog
              },
              child: const Text('Tidak'),
            ),
            TextButton(
              onPressed: () async {
                navigator.pop(); // Close dialog

                showLoadingDialog(context);

                // Call the submission functions
                final installationSuccess =
                    await InstallationSource.resubmitInstallationRecord(
                        qmsId: qmsId);
                final stepSuccess =
                    await InstallationSource.resubmitInstallationStepRecord(
                        qmsId: qmsId);

                // Close loading dialog
                if (navigator.canPop()) {
                  navigator.pop(); // Close loading dialog
                }

                if (installationSuccess && stepSuccess) {
                  _sendEmailInBackground(qmsId, emailOps, scaffoldMessenger);

                  SendWhatsAppSource.notifSubmitted(
                      phone: phoneOps,
                      typeTicket: 'Resubmitted Installation',
                      toName: approvalOps,
                      qmsId: qmsId);

                  if (navigator.mounted) {
                    navigator.pushReplacementNamed(
                      AppRoute.dashboard,
                      arguments: 2,
                    );
                  }
                } else {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                        content: Text('Submit gagal, silakan coba lagi.')),
                  );
                }
              },
              child: const Text('Iya'),
            ),
          ],
        );
      },
    );
  }

  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dialog from being dismissed
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  Future<void> _sendEmailInBackground(String qmsId, String? emailOps,
      ScaffoldMessengerState scaffoldMessenger) async {
    try {
      String username = "$userEmail";
      String password = "$passEmail";

      final smtpServer = gmail(username, password);

      final message = Message()
        ..from = Address(username, 'QMS System')
        ..recipients.add(emailOps)
        ..subject = 'Ticket Installation Resubmitted'
        ..headers = {'Reply-To': username}
        ..html = '''
        <p>Ticket Installation dengan nomor ticket <b>$qmsId</b> berhasil diajukan dan menunggu proses persetujuan anda!</p>
        <p><b>Login QMS</b> untuk melakukan proses persetujuan.</p>
      ''';
      await send(message, smtpServer);
    } catch (e) {
      // Show error message without blocking UI
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text(
              'Email notifikasi gagal terkirim, tetapi data telah tersimpan.'),
        ),
      );
    }
  }

  Widget rejectedStepInstallation() {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Gap(6),
          InputWidget.disable(
            "QMS Installation Ticket Number",
            TextEditingController(text: qmsId),
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
          BlocBuilder<InstallationStepRecordsBloc,
              InstallationStepRecordsState>(
            builder: (context, state) {
              if (state is InstallationStepRecordsLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (state is InstallationStepRecordsLoaded) {
                final rejectedRecords = state.records
                    .where((record) => record.status == 'Reject Report')
                    .toList();
                return Column(
                  children: [
                    listStepInstallationRecords(rejectedRecords),
                    const Gap(24),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                      ),
                      child: DButtonFlat(
                        onClick: () {
                          showConfirmationDialog(context, qmsId!);
                        },
                        radius: 10,
                        mainColor: AppColor.blueColor1,
                        child: Text(
                          'Finish',
                          style: TextStyle(
                            color: AppColor.whiteColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const Gap(24),
                  ],
                );
              } else if (state is InstallationStepRecordsError) {
                return Center(
                  child: Text('Error : ${state.message}'),
                );
              }
              return const Center(
                child: Text('No Data Available'),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget listStepInstallationRecords(
      List<InstallationStepRecords> installationStepRecors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'List Step Installation',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColor.defaultText,
          ),
        ),
        const Gap(6),
        ...installationStepRecors.map((record) {
          String qmsId = record.qmsId ?? '';
          // int installationStepId = record.installationStepId ?? 0;
          int stepNumber = record.stepNumber ?? 0;
          int imageLength = record.imageLength ?? 0;
          String stepDescription = record.stepDescription ?? 'Unknown Step';
          String qmsInstallationStepId = record.qmsInstallationStepId ?? '';
          String activeStatus = record.activeStatus ?? '';
          int revisionId = record.revisionId ?? 0;
          String reasonRejected = record.reasonRejected ?? '';
          String description = record.description ?? '';
          String categoryOfEnvironment = record.categoryOfEnvironment ?? '';

          List<String> photoUrls = [];
          if (record.photos != null) {
            photoUrls = record.photos!
                .map((photo) =>
                    photo.photoUrl ?? '') // Mengganti null dengan string kosong
                .where((url) =>
                    url.isNotEmpty) // Menghapus string kosong jika perlu
                .toList();
          }

          // if (stepNumber == 99) return const SizedBox.shrink();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (activeStatus == 'Created')
                if (stepNumber == 99)
                  ItemStepInstallation.createdStep(
                    title: 'Environmental Information',
                    onClick: () {
                      Navigator.pushNamed(
                        context,
                        AppRoute.detailStepInstallation,
                        arguments: {
                          'qmsInstallationStepId': qmsInstallationStepId,
                          'stepDescription': stepDescription,
                          'typeOfInstallation': typeOfInstallationName,
                          'categoryOfEnvironment': categoryOfEnvironment,
                          'description': description,
                          'photos': photoUrls,
                        },
                      );
                    },
                  )
                else
                  ItemStepInstallation.createdStep(
                    stepNumber: stepNumber,
                    title: stepDescription,
                    onClick: () {
                      Navigator.pushNamed(
                        context,
                        AppRoute.detailStepInstallation,
                        arguments: {
                          'qmsInstallationStepId': qmsInstallationStepId,
                          'stepDescription': stepDescription,
                          'typeOfInstallation': typeOfInstallationName,
                          'categoryOfEnvironment': categoryOfEnvironment,
                          'description': description,
                          'photos': photoUrls,
                        },
                      );
                    },
                  )
              else if (activeStatus == 'Active')
                if (stepNumber == 99)
                  ItemStepInstallation.active(
                    title: 'Environmental Information',
                    onClick: () {
                      Map<String, dynamic> arguments = {
                        'ticketNumber': ticketNumber!,
                        'qmsId': qmsId,
                        'qmsInstallationStepId': qmsInstallationStepId,
                        'stepNumber': stepNumber,
                        'imageLength': imageLength,
                        'stepDescription': stepDescription,
                        'typeOfInstallationName': typeOfInstallationName,
                        'typeOfInstallationId': typeOfInstallationId,
                        'categoryOfEnvironment': categoryOfEnvironment,
                        'revisionId': revisionId,
                        'reasonRejected': reasonRejected,
                        'description': description,
                        'photos': photoUrls,
                        'email_ops': emailOps,
                        'phone_ops': phoneOps,
                        'approval_ops': approvalOps,
                      };

                      Navigator.pushReplacementNamed(context,
                          AppRoute.formEditRejectEnvironemntInstallation,
                          arguments: arguments);
                    },
                  )
                else
                  ItemStepInstallation.active(
                    stepNumber: stepNumber,
                    title: stepDescription,
                    onClick: () {
                      Map<String, dynamic> arguments = {
                        'ticketNumber': ticketNumber!,
                        'qmsId': qmsId,
                        'qmsInstallationStepId': qmsInstallationStepId,
                        'stepNumber': stepNumber,
                        "imageLength": imageLength,
                        'stepDescription': stepDescription,
                        'typeOfInstallationName': typeOfInstallationName,
                        'typeOfInstallationId': typeOfInstallationId,
                        'revisionId': revisionId,
                        'reasonRejected': reasonRejected,
                        'description': description,
                        'photos': photoUrls,
                        'email_ops': emailOps,
                        'phone_ops': phoneOps,
                        'approval_ops': approvalOps,
                      };
                      Navigator.pushReplacementNamed(
                          context, AppRoute.formEditRejectInstallation,
                          arguments: arguments);
                    },
                  ),
              const Gap(6),
            ],
          );
        })
      ],
    );
  }
}
