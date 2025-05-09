part of '../pages.dart';

class DetailHistoryInstallationPage extends StatefulWidget {
  const DetailHistoryInstallationPage({super.key});

  @override
  State<DetailHistoryInstallationPage> createState() =>
      _DetailHistoryInstallationPageState();
}

class _DetailHistoryInstallationPageState
    extends State<DetailHistoryInstallationPage> {
  String? qmsId;
  String? typeOfInstallationName;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget.secondary('Installation', context),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
              physics: const BouncingScrollPhysics(),
              children: [
                ticketDMS(context),
                const Gap(24),
                summaryInstallation('Installation'),
                const Gap(24),
                // opsTeamReview('Ops Team Review'),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget ticketDMS(BuildContext context) {
    return BlocBuilder<InstallationRecordsBloc, InstallationRecordsState>(
        builder: (context, state) {
      if (state is InstallationRecordsLoading) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      } else if (state is InstallationRecordsLoaded) {
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
          int stepNumber = record.stepNumber ?? 0;
          String stepDescription = record.stepDescription ?? 'Unknown Step';
          String qmsInstallationStepId = record.qmsInstallationStepId ?? '';
          String description = record.description ?? '';
          String typeOfInstallation = record.typeOfInstallation ?? '';
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
                descriptionStep: descriptionStep,
                qmsInstallationStepId: qmsInstallationStepId,
                description: description,
                typeOfInstallation: typeOfInstallation,
                photos: photoUrls,
                categoryOfEnvironment: categoryOfEnvironment,
                borderColor: borderColor,
                stepDescription: stepDescription,
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
    String? typeOfInstallation,
    String? categoryOfEnvironment,
    List<String>? photos,
    Color? borderColor,
    String? stepDescription,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoute.detailStepInstallation,
          arguments: {
            'qmsInstallationStepId': qmsInstallationStepId,
            'stepDescription': stepDescription,
            'descriptionStep': descriptionStep,
            'typeOfInstallation': typeOfInstallation,
            'categoryOfEnvironment': categoryOfEnvironment,
            'description': description,
            'photos': photos,
          },
        );
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

  static Widget opsTeamReview(String title) {
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
            ItemDescriptionDetail.primary(
                'Installation Report Status', 'Rejected'),
            const Gap(12),
            ItemDescriptionDetail.primary(
                'Installation Report Remark', 'Foto Panoramtik Tidak Ada'),
            const Gap(12),
            ItemDescriptionDetail.primary(
                'Installation Review Result', 'Improper'),
            const Gap(12),
          ],
        ),
      ),
    );
  }
}
