part of 'pages.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<TicketByUser> ticketByUserCM = [];
  List<TicketByUser> ticketByUserPM = [];
  List<dynamic> dmsTickets = [];
  List<Inspection> qmsInspections = [];
  List<Audit> qmsAudits = [];

  late User user;
  late Future<void> _ticketsFuture;
  late Future<void> _ticketsFuture2;
  int rectificationTicketCount = 0;
  // late Future<List<dynamic>> _tickets;

  bool navigateToInstallation = false;
  DateTime? lastBackPressTime;

  @override
  void initState() {
    super.initState();
    user = context.read<UserCubit>().state;
    refresh();
    // _tickets = ApiService().getTickets(user.username!);
    _ticketsFuture = fetchTickets();
    _ticketsFuture2 = fetchTickets2();
    _initializeRectificationCount(); // Call the async helper function
  }

  Future<void> _initializeRectificationCount() async {
    rectificationTicketCount = await fetchRectification();
    setState(() {}); // Update the UI after fetching the count
  }

  Future<int> fetchRectification() async {
    String apiUrl =
        'https://stagingapiqms.triasmitra.com/public/api/rectification/index/ticket/${user.serpo}';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        // Parse the rectification tickets
        List<Rectification> rectifications =
            data.map((json) => Rectification.fromJson(json)).toList();

        // Filter tickets where status is 'created'
        List<Rectification> createdTickets = rectifications
            .where((ticket) => ticket.status == 'Created')
            .toList();

        // Return the count of tickets with status 'created'
        return createdTickets.length;
      } else {
        throw Exception(
            'Failed to load rectifications: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
      return 0; // Return 0 in case of an error
    }
  }

  Future<void> fetchTickets() async {
    final List<dynamic> dmsData = await ApiService().getTickets(user.username!);
    dmsTickets = dmsData;

    final List<Inspection> inspectionData =
        await ApiService().fetchAllInspections(user.username!);
    qmsInspections = inspectionData;
  }

  Future<void> fetchTickets2() async {
    final List<dynamic> dmsData = await ApiService().getTickets(user.username!);
    dmsTickets = dmsData;

    final List<Audit> auditData =
        await ApiService().fetchAllAudits(user.username!);
    qmsAudits = auditData;
  }

  refresh() async {
    context
        .read<InstallationRecordsUsernameBloc>()
        .add(FetchInstallationRecordsUsername(user.username!));
    context.read<TicketByUserBloc>().add(FetchTicketByUserCM(user.username!));
    context.read<TicketByUserBloc>().add(FetchTicketByUserPM(user.username!));
  }

  Future<bool> _onWillPop() async {
    final now = DateTime.now();

    if (lastBackPressTime == null ||
        now.difference(lastBackPressTime!) > const Duration(seconds: 2)) {
      lastBackPressTime = now;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tekan sekali lagi untuk keluar'),
          duration: Duration(seconds: 2),
        ),
      );
      return false; // Cegah aplikasi keluar dengan sekali tekan
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('EEEE \nd MMMM yyyy').format(now);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: RefreshIndicator(
          onRefresh: () async => refresh(),
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24),
            children: [
              welcomeCard(formattedDate: formattedDate),
              const Gap(36),
              buildQmsModule(),
              // const Gap(36),
              // buildProgressQmsTicket(),
            ],
          ),
        ),
      ),
    );
  }

  Widget welcomeCard({String? formattedDate}) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 6),
            child: Text(
              'Welcome To QMS Mobile Apps',
              style: TextStyle(fontSize: 14),
            ),
          ),
          Divider(
            color: AppColor.scaffold,
            height: 4,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          'assets/icons/ic_nama.png',
                          width: 16,
                          height: 16,
                        ),
                        const SizedBox(width: 6),
                        BlocBuilder<UserCubit, User>(
                          builder: (context, state) {
                            return Text(
                              state.nama ?? '',
                              style: const TextStyle(
                                overflow: TextOverflow.ellipsis,
                                fontSize: 10,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const Gap(6),
                    Row(
                      children: [
                        Image.asset(
                          'assets/icons/ic_position.png',
                          width: 16,
                          height: 16,
                        ),
                        const SizedBox(width: 6),
                        BlocBuilder<UserCubit, User>(
                          builder: (context, state) {
                            return Text(
                              state.jabatan.toString(),
                              style: const TextStyle(
                                overflow: TextOverflow.ellipsis,
                                fontSize: 10,
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 12),
                      ],
                    ),
                    const Gap(6),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Text(
                    formattedDate ?? '',
                    style: const TextStyle(fontSize: 10),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildQmsModule() {
    return BlocBuilder<UserCubit, User?>(
      builder: (context, user) {
        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }
        final String jabatan = user.jabatan ?? '';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Module',
              style: TextStyle(
                fontSize: 20,
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Gap(20),
            GridView.count(
              padding: const EdgeInsets.all(0),
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                FutureBuilder<void>(
                  future: _ticketsFuture,
                  builder: (context, snapshot) {
                    List<dynamic> filteredInspectionTickets;

                    if (qmsInspections.isEmpty) {
                      filteredInspectionTickets = dmsTickets;
                    } else {
                      final existingQmsTicketNumbers = qmsInspections
                          .map((inspection) => inspection.dmsTicket)
                          .toSet();

                      filteredInspectionTickets = dmsTickets.where((ticket) {
                        final ticketNumber = ticket['ticket_number'];

                        bool shouldInclude =
                            !existingQmsTicketNumbers.contains(ticketNumber);

                        return shouldInclude;
                      }).toList();
                    }

                    int ticketCount = filteredInspectionTickets.length;

                    return buildItemModuleMenu(
                      asset: 'assets/images/inspection_bg.png',
                      status: 'Inspection',
                      total: ticketCount,
                      onTap: () {
                        if (jabatan == 'Patroli SIM A' ||
                            jabatan == 'Patroli SIM C') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ListInspectionPage(
                                tickets: filteredInspectionTickets,
                              ),
                            ),
                          );
                        } else {
                          _showAccessDeniedDialog(context, 'Inspection');
                        }
                      },
                    );
                  },
                ),
                if (jabatan == 'SPV')
                  BlocBuilder<TicketByUserBloc, TicketByUserState>(
                    builder: (context, ticketState) {
                      return BlocBuilder<InstallationRecordsUsernameBloc,
                          InstallationRecordsUsernameState>(
                        builder: (context, installationState) {
                          int cmCount = 0;
                          int pmCount = 0;
                          int totalTicketsInstallation = 0;

                          List<TicketByUser> filteredCmTickets = [];
                          List<TicketByUser> filteredPmTickets = [];

                          if (ticketState is TicketByUserLoaded) {
                            List<TicketByUser> cmTickets =
                                ticketState.cmTickets;
                            List<TicketByUser> pmTickets =
                                ticketState.pmTickets;

                            if (installationState
                                    is InstallationRecordsUsernameLoaded &&
                                installationState.records.isNotEmpty) {
                              final installedTicketNumbers = installationState
                                  .records
                                  .where(
                                      (record) => record.status != 'Canceled')
                                  .map((record) => record.dmsId)
                                  .toSet();

                              filteredCmTickets = cmTickets
                                  .where((ticket) => !installedTicketNumbers
                                      .contains(ticket.ticketNumber))
                                  .toList();
                              filteredPmTickets = pmTickets
                                  .where((ticket) => !installedTicketNumbers
                                      .contains(ticket.ticketNumber))
                                  .toList();
                            } else {
                              filteredCmTickets = cmTickets;
                              filteredPmTickets = pmTickets;
                            }

                            cmCount = filteredCmTickets.length;
                            pmCount = filteredPmTickets.length;
                            totalTicketsInstallation = cmCount + pmCount;
                          }

                          return buildItemModuleMenu(
                            asset: 'assets/images/installation_bg.png',
                            status: 'Installation',
                            total: totalTicketsInstallation,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ListInstallationPage(
                                    cmCount: filteredCmTickets.length,
                                    pmCount: filteredPmTickets.length,
                                    ticketByUserCM: filteredCmTickets,
                                    ticketByUserPM: filteredPmTickets,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  )
                else
                  buildItemModuleMenu(
                    asset: 'assets/images/installation_bg.png',
                    status: 'Installation',
                    total: 0,
                    onTap: () {
                      _showAccessDeniedDialog(context, 'Installation');
                    },
                  ),
                buildItemModuleMenu(
                  asset: 'assets/images/rectification_bg.png',
                  status: 'Rectification',
                  total: rectificationTicketCount,
                  onTap: () {
                    if (jabatan == 'Jointer') {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const RectificationIndex(
                                  indexType: 'created',
                                  inspectionTicketNumber: '-')));
                    } else {
                      _showAccessDeniedDialog(context, 'Rectification');
                    }
                  },
                ),
                FutureBuilder<void>(
                  future: _ticketsFuture2,
                  builder: (context, snapshot) {
                    List<dynamic> filteredAuditTickets;

                    if (qmsAudits.isEmpty) {
                      filteredAuditTickets = dmsTickets;
                    } else {
                      final existingQmsTicketNumbers =
                          qmsAudits.map((audit) => audit.dmsTicket).toSet();

                      filteredAuditTickets = dmsTickets.where((ticket) {
                        final ticketNumber = ticket['ticket_number'];

                        bool shouldInclude =
                            !existingQmsTicketNumbers.contains(ticketNumber);

                        return shouldInclude;
                      }).toList();
                    }

                    int ticketCount = filteredAuditTickets.length;

                    return buildItemModuleMenu(
                      asset: 'assets/images/qualityaudit_bg.png',
                      status: 'Quality Audit',
                      total: ticketCount,
                      onTap: () {
                        if (jabatan == 'Optimation') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ListAuditPage(
                                tickets: filteredAuditTickets,
                              ),
                            ),
                          );
                        } else {
                          _showAccessDeniedDialog(context, 'Quality Audit');
                        }
                      },
                    );
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _showAccessDeniedDialog(BuildContext context, String moduleName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Access Denied'),
          content: Text('You do not have access to the $moduleName module.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget buildProgressQmsTicket() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'QMS Ticket',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Gap(20),
        ListView(
          padding: const EdgeInsets.all(0),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            buildItemProgressTickets(
              'assets/icons/ic_approved.png',
              'TT-24082800S009',
              '14 aug 2024, 12:00',
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DashboardPage(),
                  ),
                );
              },
            ),
            buildItemProgressTickets(
              'assets/icons/ic_process.png',
              'TT-24082800S009',
              '14 aug 2024, 12:00',
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DashboardPage(),
                  ),
                );
              },
            )
          ],
        )
      ],
    );
  }
}
