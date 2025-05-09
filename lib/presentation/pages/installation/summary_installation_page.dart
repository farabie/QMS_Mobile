part of '../pages.dart';

class SummaryInstallationPage extends StatefulWidget {
  const SummaryInstallationPage({super.key});

  @override
  State<SummaryInstallationPage> createState() =>
      _SummaryInstallationPageState();
}

class _SummaryInstallationPageState extends State<SummaryInstallationPage> {
  String? qmsId;
  String? typeOfInstallationName;
  String? emailOps;
  String? phoneOps;
  String? approvalOps;

  late User user;
  String? userEmail;
  String? passEmail;

    @override
  void initState() {
    user = context.read<UserCubit>().state;
    userEmail = user.userEmail;
    passEmail = user.passEmail;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      qmsId = args['qms_id'] as String?;
      typeOfInstallationName = args['typeOfInstallationName'] as String?;
    }

    if (qmsId != null) {
      context
          .read<InstallationRecordsBloc>()
          .add(FetchInstallationRecords(qmsId!));

      context
          .read<InstallationStepRecordsBloc>()
          .add(FetchInstallationStepRecords(qmsId!));
    }
  }

  Future<void> _onWillPop(bool didPop) async {
    if (didPop) {
      return;
    }

    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notice'),
        content: const Text('You cannot go back from this summary page.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: _onWillPop,
      canPop: false,
      child: Scaffold(
        appBar: AppBarWidget.cantBack('Summary Installation', context,
            onBackPressed: () => _onWillPop(false)),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
                physics: const BouncingScrollPhysics(),
                children: [
                  ticketDMS(
                    context,
                    'Detail Ticket DMS',
                  ),
                  const Gap(24),
                  summaryInstallation('Summary Installation'),
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
                    blurStyle: BlurStyle.outer)
              ]),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 50,
                vertical: 5,
              ),
              child: DButtonFlat(
                onClick: () {
                  showConfirmationDialog(
                      context, qmsId!, emailOps, phoneOps, approvalOps);
                },
                radius: 10,
                mainColor: AppColor.blueColor1,
                child: Text(
                  'Submit',
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

  Widget ticketDMS(BuildContext context, String title) {
    return BlocBuilder<InstallationRecordsBloc, InstallationRecordsState>(
        builder: (context, state) {
      if (state is InstallationRecordsLoading) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      } else if (state is InstallationRecordsLoaded) {
        emailOps = state.record.emailOps;
        phoneOps = state.record.phoneOps;
        approvalOps = state.record.approvalOps;
        return _buildTicketDMSContent(state.record);
      } else if (state is InstallationRecordsError) {
        return Center(
          child: Text(state.message),
        );
      }

      return const Center(
        child: Text('No Data Available'),
      );
    });
  }

  Widget _buildTicketDMSContent(InstallationRecords record) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 5,
          horizontal: 12,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Detail Ticket DMS',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            Divider(
              color: AppColor.divider,
            ),
            ItemDescriptionDetail.primary2(
              title: 'TT Number',
              data: "TT-${record.dmsId}",
            ),
            const Gap(12),
            ItemDescriptionDetail.primary2(
              title: 'Service Point',
              data: record.servicePoint,
            ),
            const Gap(12),
            ItemDescriptionDetail.primary2(
              title: 'Project',
              data: record.project,
            ),
            const Gap(12),
            ItemDescriptionDetail.primary2(
              title: 'Segment',
              data: record.segment,
            ),
            const Gap(12),
            ItemDescriptionDetail.primary2(
              title: 'Section Name',
              data: record.sectionName,
            ),
            const Gap(12),
            ItemDescriptionDetail.primary2(
              title: 'Area',
              data: record.area,
            ),
            const Gap(12),
            ItemDescriptionDetail.primary2(
              title: 'Latitude',
              data: record.latitude.toString(),
            ),
            const Gap(12),
            ItemDescriptionDetail.primary2(
              title: 'Longitude',
              data: record.longitude.toString(),
            ),
            const Gap(12),
            if (record.imsId != null)
              imsInformation(record)
            else
              Container(
                height: 100,
                decoration: BoxDecoration(
                    border: Border.all(color: AppColor.defaultText),
                    borderRadius: BorderRadius.circular(10)),
                child: Center(
                  child: Text(
                    'No Ticket IMS',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColor.defaultText,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            const Gap(12),
          ],
        ),
      ),
    );
  }

  Widget imsInformation(InstallationRecords record) {
    final materialList = record.materials
            ?.map((material) => {
                  'name': material.materialName ??
                      '', // Use a default empty string if null
                  'quantity': material.materialQuantity?.toString() ??
                      '0', // Use a default "0" if null
                })
            .toList() ??
        [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Text(
          'IMS Information',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 6,
            vertical: 16,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ItemDescriptionDetail.primary(
                'IMS Ticket Number',
                record.imsId ?? '',
              ),
              const Gap(6),
              ItemDescriptionDetail.primary(
                'IMS Close Date',
                record.imsCloseDate ?? '',
              ),
              const Gap(6),
              ItemDescriptionDetail.imsMaterialName(
                title: 'Material Name & Quantity',
                materials: materialList, // Menggunakan daftar material
              ),
            ],
          ),
        )
      ],
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
        ..subject = 'Ticket Installation Waiting for Approval'
        ..headers = {'Reply-To': username}
        ..html = '''
        <p>Ticket Installation dengan nomor ticket <b>$qmsId</b> berhasil diajukan dan menunggu proses persetujuan anda!</p>
        <p><b>Login QMS</b> untuk melakukan proses persetujuan.</p>
      '''
        ..headers = {
          'Reply-To':
              'Notif Triasmitra <$username>' // Mengatur Reply-To di header
        };
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

  void showConfirmationDialog(BuildContext context, String qmsId,
      String? emailOps, String? phoneOps, String? approvalOps) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Form Installation'),
          content: const Text(
              'Apakah Anda yakin summary installation form yang diisi sudah benar?'),
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

                try {
                  // Call the submission functions
                  final installationSuccess =
                      await InstallationSource.submitInstallationRecord(
                          qmsId: qmsId);
                  final stepSuccess =
                      await InstallationSource.submitInstallationStepRecord(
                          qmsId: qmsId);

                  if (installationSuccess && stepSuccess) {
                    _sendEmailInBackground(qmsId, emailOps, scaffoldMessenger);

                    SendWhatsAppSource.notifSubmitted(
                        phone: phoneOps,
                        typeTicket: 'Installation',
                        toName: approvalOps,
                        qmsId: qmsId);

                    if (navigator.mounted) {
                      navigator.pushReplacementNamed(
                        AppRoute.dashboard,
                        arguments: 2,
                      );
                    }
                  } else {
                    if (navigator.mounted) {
                      navigator.pop(); // Close loading dialog
                      scaffoldMessenger.showSnackBar(
                        const SnackBar(
                            content: Text('Submit gagal, silakan coba lagi.')),
                      );
                    }
                  }
                } catch (e) {
                  if (navigator.mounted) {
                    navigator.pop(); // Close loading dialog
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                          content: Text('Terjadi kesalahan: ${e.toString()}')),
                    );
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

  Widget summaryInstallation(String title) {
    final edtQMSTicket = TextEditingController(text: qmsId);
    final typeOfInstallation =
        TextEditingController(text: typeOfInstallationName);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 5,
          horizontal: 12,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            Divider(
              color: AppColor.divider,
            ),
            InputWidget.disable(
              'QMS Installation Ticket Number',
              edtQMSTicket,
            ),
            const Gap(6),
            InputWidget.disable(
              'Type of installation',
              typeOfInstallation,
            ),
            const Gap(6),
            BlocBuilder<InstallationStepRecordsBloc,
                InstallationStepRecordsState>(builder: (context, state) {
              if (state is InstallationStepRecordsLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (state is InstallationStepRecordsLoaded) {
                return installationStepRecords(state.records);
              } else if (state is InstallationStepRecordsError) {
                return Center(
                  child: Text('Error : ${state.message}'),
                );
              }

              return const Center(
                child: Text('No Data Available'),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget installationStepRecords(
      List<InstallationStepRecords> installationStepRecors) {
    int totalSteps = installationStepRecors.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Step Installation',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: AppColor.greyColor3,
            fontSize: 10,
          ),
        ),
        const Gap(12),
        ...installationStepRecors.map((record) {
          int installationStepId = record.installationStepId ?? 0;
          int stepNumber = record.stepNumber ?? 0;
          int imageLength = record.imageLength ?? 0;
          String qmsId = record.qmsId ?? '';
          String qmsInstallationStepId = record.qmsInstallationStepId ?? '';
          int revisionId = record.revisionId ?? 0;
          String stepDescription = record.stepDescription ?? 'Unknown Step';
          String typeOfInstallationName = record.typeOfInstallation ?? '';
          String description = record.description ?? '';
          String categoryOfEnvironment = record.categoryOfEnvironment ?? '';

          Color borderColor = Colors.black;
          String descriptionStep = '$stepNumber. $stepDescription';

          // If stepNumber is 99, modify the descriptionStep and borderColor
          if (stepNumber == 99) {
            // borderColor = Colors.red; // Change border color to red
            descriptionStep =
                'Environmental Information'; // Set custom description
          }

          List<String> photoUrls = [];
          if (record.photos != null) {
            photoUrls = record.photos!
                .map((photo) =>
                    photo.photoUrl ?? '') // Mengganti null dengan string kosong
                .where((url) =>
                    url.isNotEmpty) // Menghapus string kosong jika perlu
                .toList();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              itemStepInstallation(
                installationStepId: installationStepId,
                qmsId: qmsId,
                qmsInstallationStepId: qmsInstallationStepId,
                revisionId: revisionId,
                stepNumber: stepNumber,
                imageLength: imageLength,
                stepDescription: stepDescription,
                descriptionStep: descriptionStep,
                typeOfInstallationName: typeOfInstallationName,
                description: description,
                photos: photoUrls,
                categoryOfEnvironment: categoryOfEnvironment,
                totalSteps: totalSteps,
                borderColor: borderColor,
              ),
              const Gap(6),
            ],
          );
        })
      ],
    );
  }

  Widget itemStepInstallation({
    String? descriptionStep,
    String? qmsInstallationStepId,
    String? description,
    String? typeOfInstallationName,
    String? categoryOfEnvironment,
    List<String>? photos,
    Color? borderColor,
    String? stepDescription,
    int? installationStepId,
    String? qmsId,
    int? stepNumber,
    int? imageLength,
    int? totalSteps,
    int? revisionId,
  }) {
    return GestureDetector(
      onTap: () {
        if (stepNumber == 99) {
          Navigator.pushNamed(
            context,
            AppRoute.formEditEnvironmentInstallation,
            arguments: {
              'installationStepId': installationStepId,
              'qmsId': qmsId,
              'qmsInstallationStepId': qmsInstallationStepId,
              'stepNumber': stepNumber,
              'imageLength': imageLength,
              'stepDescription': stepDescription,
              'descriptionStep': descriptionStep,
              'typeOfInstallationName': typeOfInstallationName,
              'categoryOfEnvironment': categoryOfEnvironment,
              'description': description,
              'photos': photos,
              'totalSteps': totalSteps,
              'revisionId': revisionId,
            },
          );
        } else {
          Navigator.pushNamed(
            context,
            AppRoute.formEditInstallation,
            arguments: {
              'installationStepId': installationStepId,
              'qmsId': qmsId,
              'qmsInstallationStepId': qmsInstallationStepId,
              'revisionId': revisionId,
              'stepNumber': stepNumber,
              'imageLength': imageLength,
              'stepDescription': stepDescription,
              'descriptionStep': descriptionStep,
              'typeOfInstallationName': typeOfInstallationName,
              'categoryOfEnvironment': categoryOfEnvironment,
              'description': description,
              'photos': photos,
              'totalSteps': totalSteps,
            },
          );
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(12, 10, 0, 10),
        decoration: BoxDecoration(
            border: Border.all(color: borderColor!),
            borderRadius: BorderRadius.circular(10)),
        child: Text(
          descriptionStep ?? '',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColor.defaultText,
          ),
        ),
      ),
    );
  }
}
