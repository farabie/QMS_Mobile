part of '../pages.dart';

class FormAllStepInstallation extends StatefulWidget {
  const FormAllStepInstallation({super.key});

  @override
  State<FormAllStepInstallation> createState() =>
      _FormAllStepInstallationState();
}

class _FormAllStepInstallationState extends State<FormAllStepInstallation> {
  final ScrollController _scrollController = ScrollController();
  String? qmsId;
  String? typeOfInstallationName;
  int? typeOfInstallationId;
  String? ticketNumber;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments as Map?;

    if (args != null) {
      ticketNumber = args['ticketNumber'] as String?;
      qmsId = args['qms_id'] as String?;
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget.cantBack(
        'Detail Tickets',
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
                  formStepInstallation(),
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

  Widget formStepInstallation() {
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
          InputWidget.disable(
            'QMS Installation Ticket Number',
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
                String? lastStepStatus = state.records.isNotEmpty
                    ? state.records.last.activeStatus
                    : null;

                return Column(
                  children: [
                    listStepInstallationRecords(state.records),
                    const Gap(24),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                      ),
                      child: DButtonFlat(
                        onClick: () {
                          if (lastStepStatus == 'Created') {
                            Navigator.pushReplacementNamed(
                              context,
                              AppRoute.summaryInstallation,
                              arguments: {
                                'qms_id': qmsId,
                                'typeOfInstallationName':
                                    typeOfInstallationName,
                              },
                            );
                            // showEnvironmentDialog(context);
                          } else {
                            Navigator.pushReplacementNamed(
                              context,
                              AppRoute.dashboard,
                              arguments: 2,
                            );
                          }
                        },
                        radius: 10,
                        mainColor: (lastStepStatus == 'Created')
                            ? AppColor.blueColor1
                            : AppColor.rectification,
                        child: Text(
                          lastStepStatus == 'Created' ? 'Finish' : 'Pause',
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
    int totalSteps = installationStepRecors.length;

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
          int currentIndex = installationStepRecors.indexOf(record);

          // Inisialisasi nextQmsInstallationStepId sebagai null
          String? nextQmsInstallationStepId;

          // Cek apakah ada step berikutnya
          if (currentIndex + 1 < installationStepRecors.length) {
            nextQmsInstallationStepId =
                installationStepRecors[currentIndex + 1].qmsInstallationStepId;
          }

          String qmsId = record.qmsId ?? '';
          int installationStepId = record.installationStepId ?? 0;
          int stepNumber = record.stepNumber ?? 0;
          int imageLength = record.imageLength ?? 0;
          String stepDescription = record.stepDescription ?? 'Unknown Step';
          String qmsInstallationStepId = record.qmsInstallationStepId ?? '';
          String activeStatus = record.activeStatus ?? '';
          int revisionId = record.revisionId ?? 0;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ItemStepInstallation.inactive(stepNumber: stepNumber, title: stepDescription),
              if (activeStatus == 'Created')
                if (stepNumber == 99)
                  ItemStepInstallation.createdStep(
                    title: 'Environmental Information',
                  )
                else
                  ItemStepInstallation.createdStep(
                    stepNumber: stepNumber,
                    title: stepDescription,
                  )
              else if (activeStatus == 'Active')
                if (stepNumber == 99)
                  ItemStepInstallation.active(
                    title: 'Environmental Information',
                    onClick: () {
                      Map<String, dynamic> arguments = {
                        'ticketNumber': ticketNumber!,
                        'qmsInstallationStepId': qmsInstallationStepId,
                        'qmsId': qmsId,
                        "imageLength": imageLength,
                        'stepDescription': stepDescription,
                        'typeOfInstallationName': typeOfInstallationName,
                        'typeOfInstallationId': typeOfInstallationId,
                        'revisionId': revisionId,
                      };

                      // Hanya tambahkan nextQmsInstallationStepId jika ada step berikutnya
                      if (nextQmsInstallationStepId != null) {
                        arguments['nextQmsInstallationStepId'] =
                            nextQmsInstallationStepId;
                      }

                      Navigator.pushReplacementNamed(
                          context, AppRoute.formEnvironemntInstallation,
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
                        'installationStepId': installationStepId,
                        'qmsId': qmsId,
                        'qmsInstallationStepId': qmsInstallationStepId,
                        'revisionId': revisionId,
                        'stepNumber': stepNumber,
                        "imageLength": imageLength,
                        'stepDescription': stepDescription,
                        'typeOfInstallationName': typeOfInstallationName,
                        'typeOfInstallationId': typeOfInstallationId,
                        'totalSteps': totalSteps,
                      };

                      if (nextQmsInstallationStepId != null) {
                        arguments['nextQmsInstallationStepId'] =
                            nextQmsInstallationStepId;
                      }

                      Navigator.pushReplacementNamed(
                          context, AppRoute.formInstallation,
                          arguments: arguments);
                    },
                  )
              else if (activeStatus == 'Inactive')
                if (stepNumber == 99)
                  ItemStepInstallation.inactive(
                      title: 'Environmental Information')
                else
                  ItemStepInstallation.inactive(
                    stepNumber: stepNumber,
                    title: stepDescription,
                  ),
              const Gap(6),
            ],
          );
        })
      ],
    );
  }
}
