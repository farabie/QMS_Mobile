part of '../pages.dart';

class DMSDetailTicket extends StatefulWidget {
  const DMSDetailTicket({super.key});

  @override
  State<DMSDetailTicket> createState() => _DMSDetailTicketState();
}

class _DMSDetailTicketState extends State<DMSDetailTicket> {
  String? ticketNumber;
  String? servicePointName;

  List<InstallationType> installationType = [];
  InstallationType? selectedInstallationType;
  bool isLoading = true;
  bool _isSubmitting = false;
  String? errorMessage;
  String? username;
  String? clusterName;
  String? emailUser;
  String? phoneUser;
  late User user;

  refresh() {
    context
        .read<InstallationRecordsUsernameBloc>()
        .add(FetchInstallationRecordsUsername(user.username!));
  }

  @override
  void initState() {
    user = context.read<UserCubit>().state;
    username = user.username;
    clusterName = user.clusterName;
    emailUser = user.email;
    phoneUser = user.phone;

    refresh();
    fetchInstallationTypes();
    super.initState();
  }

  Future<void> fetchInstallationTypes() async {
    try {
      final types = await InstallationSource().listInstallationTypes();
      if (types != null) {
        setState(() {
          installationType = types;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = "Failed to load installation types";
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "An error occurred: $e";
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments as Map?;

    if (args != null) {
      ticketNumber = args['ticketNumber'] as String?;
      servicePointName = args['servicePointName'] as String?;
    }

    if (ticketNumber != null) {
      context.read<TicketDetailBloc>().add(FetchTicketDetail(ticketNumber!));
      context
          .read<TicketImsDetailBloc>()
          // .add(FetchTicketImsTicketDetail('240913PMHQJBY.IDLE4896'));
          .add(FetchTicketImsTicketDetail(ticketNumber!));
      context.read<OpsApprovalBloc>().add(FetchOpsApproval(clusterName!));
      context
          .read<InformationJointerBloc>()
          .add(FetchInformationJointer(servicePointName!));
      //Ticket Joint Closure 1
      // .add(FetchTicketImsTicketDetail('241001PMINTHQPRB.SPCP0293'));
    }
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

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: _onWillPop,
      canPop: false,
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBarWidget.cantBack('Detail', context,
                onBackPressed: () => _onWillPop(false)),
            body: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 24),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      contentTicketDMS(),
                    ],
                  ),
                )
              ],
            ),
          ),
          if (_isSubmitting)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  String? _getIsOptional(List<String> materialNames,
      List<int> materialQuantities, bool isTicketImsNotFound) {
    bool hasJointClosureMoreThanOne = false;

    // Check for Joint Closure material and its quantity
    for (int i = 0; i < materialNames.length; i++) {
      if (materialNames[i].contains('Joint Closure') &&
          materialQuantities[i] > 1) {
        hasJointClosureMoreThanOne = true;
        break;
      }
    }

    if (isTicketImsNotFound || hasJointClosureMoreThanOne == false) {
      return 'No';
    }

    return 'Yes';
  }

  Widget contentTicketDMS() {
    return BlocBuilder<TicketDetailBloc, TicketDetailState>(
        builder: (context, state) {
      if (state is TicketDetailLoading) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      } else if (state is TicketDetailLoaded) {
        final ticketDetails = state.ticketDetail;

        return BlocBuilder<OpsApprovalBloc, OpsApprovalState>(
            builder: (context, opsApprovalState) {
          if (opsApprovalState is OpsApprovalLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (opsApprovalState is OpsApprovalLoaded) {
            final opsApproval = opsApprovalState.records;

            return BlocBuilder<InformationJointerBloc, InformationJointerState>(
              builder: (context, informationJointerState) {
                if (informationJointerState is InformationJointerLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (informationJointerState
                    is InformationJointerLoaded) {
                  final informationJointer = informationJointerState.records;

                  // FullName Dengan Array
                  final fullNameJointers = informationJointer
                      .where((jointer) =>
                          jointer.userServiceRole ==
                          "Jointer") // Filter by userServiceRole
                      .map((jointer) => jointer.fullName)
                      .where((name) => name != null)
                      .join(',');

                  final emailJointers = informationJointer
                      .where((jointer) =>
                          jointer.userServiceRole ==
                          "Jointer") // Filter by userServiceRole
                      .map((jointer) => jointer.email)
                      .where((email) => email != null)
                      .join(',');

                  final phoneJointers = informationJointer
                      .where((jointer) =>
                          jointer.userServiceRole ==
                          "Jointer") // Filter by userServiceRole
                      .map((jointer) => jointer.phone)
                      .where((phone) => phone != null)
                      .join(',');

                  return Container(
                    decoration: BoxDecoration(
                      color: AppColor.whiteColor,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'TT-$ticketNumber',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColor.defaultText,
                          ),
                        ),
                        Divider(
                          color: AppColor.greyColor2,
                        ),
                        InputWidget.disable(
                          'Service Point',
                          TextEditingController(text: servicePointName),
                        ),
                        const Gap(6),
                        InputWidget.disable(
                          'Project',
                          TextEditingController(
                              text: ticketDetails.projectName),
                        ),
                        const Gap(6),
                        InputWidget.disable(
                          'Segment',
                          TextEditingController(text: ticketDetails.spanName),
                        ),
                        const Gap(6),
                        InputWidget.disable(
                          'Section Name',
                          TextEditingController(
                              text: ticketDetails.sectionName),
                        ),
                        const Gap(6),
                        InputWidget.disable(
                          'Area',
                          TextEditingController(
                              text: ticketDetails
                                  .ticketAssignees?[0].serviceAreaName),
                        ),
                        const Gap(6),
                        InputWidget.disable(
                          'Latitude',
                          TextEditingController(
                              text: ticketDetails.latitude.toString()),
                        ),
                        const Gap(6),
                        InputWidget.disable(
                          'Longitude',
                          TextEditingController(
                              text: ticketDetails.longitude.toString()),
                        ),
                        const Gap(6),
                        imsInformation(),
                        const Gap(6),
                        InputWidget.dropDown2(
                          title: 'Type of installation',
                          hintText: 'Select Type Of Installation',
                          value: selectedInstallationType?.typeName ?? '',
                          items: installationType.isEmpty
                              ? [
                                  'Loading...'
                                ] // Temporary message while fetching data
                              : installationType
                                  .map((type) => type.typeName ?? '')
                                  .toList(),
                          hintTextSearch: 'Search type of installation',
                          onChanged: (newValue) {
                            setState(() {
                              selectedInstallationType =
                                  installationType.firstWhere(
                                (type) => type.typeName == newValue,
                              );
                            });
                          },
                        ),
                        const Gap(24),
                        DButtonBorder(
                          onClick: () async {
                            if (selectedInstallationType == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Please select a Type of Installation'),
                                ),
                              );
                              return;
                            }

                            setState(() {
                              _isSubmitting = false;
                            });

                            final ticketImsState =
                                context.read<TicketImsDetailBloc>().state;

                            if (ticketImsState is TicketImsDetailNotFound) {
                              final response =
                                  await InstallationSource.installationRecords(
                                username: username,
                                dmsId: ticketNumber,
                                servicePoint: servicePointName,
                                project: ticketDetails.projectName,
                                segment: ticketDetails.segmentName,
                                sectionName: ticketDetails.sectionName,
                                area: ticketDetails
                                        .ticketAssignees?[0].serviceAreaName ??
                                    '',
                                latitude: ticketDetails.latitude.toString(),
                                longitude: ticketDetails.longitude.toString(),
                                typeOfInstallation:
                                    selectedInstallationType?.typeName ?? '',
                                idTypeOfInstallation:
                                    selectedInstallationType?.id ?? 0,
                                emailUser: emailUser,
                                phoneUser: phoneUser,
                                approvalOps: opsApproval[0].opsName,
                                emailOps: opsApproval[0].emailOps,
                                phoneOps: opsApproval[0].phoneOps,
                                fullNameJointers: "[$fullNameJointers]",
                                emailJointers: "[$emailJointers]",
                                phoneJointers: "[$phoneJointers]",
                              );

                              if (response != null &&
                                  response['data'] != null) {
                                final qmsId = response['data']['qms_id'];

                                _getIsOptional([], [], true);

                                await _submitInstallationSteps(
                                    context: context,
                                    qmsId: qmsId,
                                    isOptional: 'No',
                                    typeOfInstallationName:
                                        selectedInstallationType?.typeName ??
                                            'Unknown',
                                    typeOfInstallationId:
                                        selectedInstallationType?.id ?? 0);

                                Navigator.pushReplacementNamed(
                                  context,
                                  AppRoute.formAllStepInstallation,
                                  arguments: {
                                    'ticketNumber': ticketNumber!,
                                    'qms_id': qmsId,
                                    'typeOfInstallationId':
                                        selectedInstallationType?.id ?? 0,
                                    'typeOfInstallationName':
                                        selectedInstallationType?.typeName ?? ''
                                  },
                                );
                              } else {
                                // Tampilkan pesan error jika gagal submit installation records
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Failed to submit installation records'),
                                  ),
                                );
                                return; // Hentikan eksekusi jika terjadi error
                              }
                            } else if (ticketImsState
                                is TicketImsDetailLoaded) {
                              final ticketImsDetails = ticketImsState.ticketIms;

                              final imsId = ticketImsDetails.ticketIms ?? '';
                              final imsCloseDate =
                                  ticketImsDetails.receivedDate ?? '';

                              // Menggabungkan materialName dan materialQuantity ke dalam format list yang sesuai
                              final materialList =
                                  ticketImsDetails.details?.map((detail) {
                                        return {
                                          'name': detail.name ??
                                              '', // Mengambil nama material
                                          'quantity': detail.qty?.toString() ??
                                              '0', // Mengambil jumlah material
                                        };
                                      }).toList() ??
                                      [];

                              // Pisahkan materialName dan materialQuantity menjadi dua list
                              final materialNames = materialList
                                  .map((material) => material['name'] as String)
                                  .toList();
                              final materialQuantities = materialList
                                  .map((material) =>
                                      int.parse(material['quantity'] as String))
                                  .toList();

                              final response =
                                  await InstallationSource.installationRecords(
                                username: username,
                                dmsId: ticketNumber,
                                servicePoint: servicePointName,
                                project: ticketDetails.projectName,
                                segment: ticketDetails.segmentName,
                                sectionName: ticketDetails.sectionName,
                                area: ticketDetails
                                        .ticketAssignees?[0].serviceAreaName ??
                                    '',
                                latitude: ticketDetails.latitude.toString(),
                                longitude: ticketDetails.longitude.toString(),
                                typeOfInstallation:
                                    selectedInstallationType?.typeName ?? '',
                                idTypeOfInstallation:
                                    selectedInstallationType?.id ?? 0,
                                imsId: imsId,
                                imsCloseDate: imsCloseDate,
                                materialNames: materialNames,
                                materialQuantities: materialQuantities,
                                emailUser: emailUser,
                                phoneUser: phoneUser,
                                approvalOps: opsApproval[0].opsName,
                                emailOps: opsApproval[0].emailOps,
                                phoneOps: opsApproval[0].phoneOps,
                                fullNameJointers: "[$fullNameJointers]",
                                emailJointers: "[$emailJointers]",
                                phoneJointers: "[$phoneJointers]",
                              );

                              if (response != null &&
                                  response['data'] != null) {
                                final qmsId = response['data']['qms_id'];

                                String? isOptional = _getIsOptional(
                                    materialNames, materialQuantities, false);

                                // Handle fetching steps asynchronously
                                await _submitInstallationSteps(
                                    context: context,
                                    isOptional: isOptional,
                                    qmsId: qmsId,
                                    typeOfInstallationName:
                                        selectedInstallationType?.typeName ??
                                            'Unknown',
                                    typeOfInstallationId:
                                        selectedInstallationType?.id ?? 0);

                                Navigator.pushReplacementNamed(
                                  context,
                                  AppRoute.formAllStepInstallation,
                                  arguments: {
                                    'ticketNumber': ticketNumber!,
                                    'qms_id': qmsId,
                                    'typeOfInstallationId':
                                        selectedInstallationType?.id ?? 0,
                                    'typeOfInstallationName':
                                        selectedInstallationType?.typeName ?? ''
                                  },
                                );
                              } else {
                                // Tampilkan pesan error jika gagal submit installation records
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Failed to submit installation records'),
                                  ),
                                );
                                return; // Hentikan eksekusi jika terjadi error
                              }
                            } else if (ticketImsState is TicketImsDetailError) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Failed to fetch Ticket IMS due to network error'),
                                ),
                              );
                            } else {
                              // Handle kondisi error lain (misal jika state tidak dikenali)
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'An unexpected error occurred while fetching Ticket IMS'),
                                ),
                              );
                            }

                            setState(() {
                              _isSubmitting = false;
                            });
                          },
                          mainColor: Colors.white,
                          radius: 10,
                          borderColor: AppColor.scaffold,
                          child: const Text(
                            'Installation Ticket Form',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const Gap(24),
                      ],
                    ),
                  );
                } else if (informationJointerState is InformationJointerError) {
                  return Center(
                    child: Text(
                        'Information Jointer Error: ${informationJointerState.toString()}'),
                  );
                } else {
                  return const Center(
                    child: Text('Information Jointer not available'),
                  );
                }
              },
            );
          } else if (opsApprovalState is OpsApprovalError) {
            return Center(
              child: Text('Ops Approval Error: ${opsApprovalState.message}'),
            );
          } else {
            return const Center(
              child: Text('Ops Approval not available'),
            );
          }
        });
      } else if (state is TicketDetailError) {
        return Center(
          child: Text('Error: ${state.message}'),
        );
      } else {
        return const Center(
          child: Text('No Detail Available'),
        );
      }
    });
  }

  Future<void> _submitInstallationSteps({
    BuildContext? context,
    String? qmsId,
    String? isOptional,
    String? typeOfInstallationName,
    int? typeOfInstallationId,
  }) async {
    final scaffoldContext = context;

    setState(() {
      _isSubmitting = true;
    });

    final installationGenerateSteps =
        await InstallationSource.installationGenerateSteps(
            qmsId: qmsId,
            isOptional: isOptional,
            typeOfInstallationId: typeOfInstallationId,
            typeOfInstallationName: typeOfInstallationName);

    if (installationGenerateSteps != null) {
      ScaffoldMessenger.of(scaffoldContext!).showSnackBar(
        const SnackBar(
          content: Text("Create Installation Step Success"),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      print('Failed to generate step installation');
    }
    setState(() {
      _isSubmitting = false;
    });
  }

  Widget imsInformation() {
    return BlocBuilder<TicketImsDetailBloc, TicketImsDetailState>(
      builder: (context, state) {
        if (state is TicketImsDetailLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is TicketImsDetailLoaded) {
          final ticketImsDetails = state.ticketIms;

          final materialList = ticketImsDetails.details
                  ?.map((detail) => {
                        'name': detail.name ??
                            '', // Memberikan nilai default jika null
                        'quantity': detail.qty?.toString() ??
                            '0', // Memberikan nilai default jika null
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
                      ticketImsDetails.ticketIms ?? '',
                    ),
                    const Gap(6),
                    ItemDescriptionDetail.primary(
                      'IMS Close Date',
                      ticketImsDetails.receivedDate ?? '',
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
        } else if (state is TicketImsDetailNotFound) {
          return Container(
            height: 100,
            decoration: BoxDecoration(
                border: Border.all(color: AppColor.defaultText),
                borderRadius: BorderRadius.circular(10)),
            child: Container(
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
          );
        } else if (state is TicketImsDetailError) {
          return Center(
            child: Text('Error: ${state.message}'),
          );
        } else {
          return const Center(
            child: Text('No Detail Ims Available'),
          );
        }
      },
    );
  }
}
