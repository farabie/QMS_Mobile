part of '../pages.dart';

class DetailStepInstallationPage extends StatefulWidget {
  const DetailStepInstallationPage({super.key});

  @override
  State<DetailStepInstallationPage> createState() =>
      _DetailStepInstallationPageState();
}

class _DetailStepInstallationPageState
    extends State<DetailStepInstallationPage> {
  late String qmsInstallationStepId;
  late String stepDescription;
  late String typeOfInstallation;
  late String categoryOfEnvironment;
  late String description;
  late List<String> photoUrls;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    qmsInstallationStepId = arguments['qmsInstallationStepId'];
    stepDescription = arguments['stepDescription'];
    typeOfInstallation = arguments['typeOfInstallation'];
    categoryOfEnvironment = arguments['categoryOfEnvironment'];
    description = arguments['description'];
    List<String> filenames = List<String>.from(arguments['photos'] ?? []);
    photoUrls = filenames
        .map((filename) => URLs.installationImage(filename))
        .toList(); // Membangun URL gambar
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget.secondary('Detail Step Installation', context),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
              physics: const BouncingScrollPhysics(),
              children: [
                Container(
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
                          qmsInstallationStepId,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Divider(
                          color: AppColor.divider,
                        ),
                        const Gap(6),
                        ItemDescriptionDetail.primary(
                          'Type of installation',
                          typeOfInstallation,
                        ),
                        const Gap(12),
                        ItemDescriptionDetail.secondary(
                          stepDescription,
                          photoUrls,
                          context,
                        ),
                        const Gap(12),
                        if (categoryOfEnvironment.isNotEmpty) ...[
                          ItemDescriptionDetail.primary(
                            'Category Of Environment',
                            categoryOfEnvironment,
                          ),
                          const Gap(12),
                        ],
                        // Only display description if it's not null or empty
                        if (description.isNotEmpty) ...[
                          ItemDescriptionDetail.primary(
                            'Description',
                            description,
                          ),
                          const Gap(12),
                        ],
                      ],
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
