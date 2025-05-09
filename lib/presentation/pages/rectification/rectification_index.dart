part of '../pages.dart';

class RectificationIndex extends StatefulWidget {
  final String indexType;
  final String inspectionTicketNumber;

  const RectificationIndex(
      {super.key,
      required this.indexType,
      required this.inspectionTicketNumber});

  @override
  State<RectificationIndex> createState() => _RectificationIndexState();
}

class _RectificationIndexState extends State<RectificationIndex>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late User user;

  List<Rectification> rectificationTicket = [];
  Map<String, List<Rectification>> groupedRectificationTickets =
      {}; // Grouped tickets
  bool loading = true; // Add this loading state

  final List<String> statuses = [
    'All', // Default option to show all child rectifications
    'Created',
    'Acknowledge',
    'Opened',
    'On Progress',
    'Approval SPV',
    'On Review',
    'Rejected',
    'Submited',
    'Closed',
  ];

  // Variable to hold the selected status
  String selectedStatus = 'All';

  @override
  void initState() {
    super.initState();

    // Safely attempt to fetch the user state
    final currentState = context.read<UserCubit>().state;
    if (currentState != null) {
      user = currentState;
    } else {
      // Handle the case where the user state is not available
      throw Exception("UserCubit state is not initialized.");
    }

    // Initialize TabController
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        // Load data for the selected tab
        RectificationType type;
        switch (_tabController.index) {
          case 0:
            type = RectificationType.inspection;
            break;
          case 1:
            type = RectificationType.installation;
            break;
          case 2:
            type = RectificationType.quality_audit;
            break;
          default:
            type = RectificationType.inspection;
        }
        loadData();
      }
    });

    // Initial data load
    loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Call loadData each time dependencies change, such as when navigating back
    print("didChangeDependencies triggered");
    loadData();
  }

  Future<void> loadData() async {
    setState(() {
      loading = true; // Start loading
    });

    String apiUrl =
        'https://apiqms.triasmitra.com/public/api/rectification/index/ticket/${user.serpo}';
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        // Parse and store the rectification tickets
        List<Rectification> rectifications =
            data.map((json) => Rectification.fromJson(json)).toList();

        // Group by related_ticket
        Map<String, List<Rectification>> groupedTickets = {};
        for (var ticket in rectifications) {
          String relatedTicket = ticket.relatedTicket; // Field in Rectification
          if (!groupedTickets.containsKey(relatedTicket)) {
            groupedTickets[relatedTicket] = [];
          }
          groupedTickets[relatedTicket]!.add(ticket);
        }

        // Update state with the fetched data
        setState(() {
          rectificationTicket = rectifications;
          groupedRectificationTickets = groupedTickets;
          loading = false; // Stop loading
        });
      } else {
        throw Exception(
            'Failed to load rectifications: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        loading = false; // Stop loading even in case of error
      });
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.indexType) {
      case 'created':
        return Scaffold(
          body: Column(
            children: [
              header(context, 'Site Rectification'),
              TabBar(
                controller: _tabController,
                indicator: const BoxDecoration(),
                dividerColor: Colors.transparent,
                tabs: [
                  Tab(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () {
                          setState(() {
                            _tabController.index = 0;
                          });
                        },
                        child: Container(
                          width: 200,
                          height: 50,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _tabController.index == 0
                                ? AppColor.blueColor1
                                : AppColor.greyColor1,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: const Text(
                            'Inspection',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Tab(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () {
                          setState(() {
                            _tabController.index = 1;
                          });
                        },
                        child: Container(
                          width: 200,
                          height: 50,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _tabController.index == 1
                                ? AppColor.blueColor1
                                : AppColor.greyColor1,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: const Text(
                            'Installation',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Tab(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () {
                          setState(() {
                            _tabController.index = 2;
                          });
                        },
                        child: Container(
                          width: 200,
                          height: 50,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _tabController.index == 2
                                ? AppColor.blueColor1
                                : AppColor.greyColor1,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: const Text(
                            'Quality Audit',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Add other tabs...
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTabContent("inspection"), // First tab content
                    _buildTabContent("installation"), // Second tab content
                    _buildTabContent("quality_audit"), // Third tab content
                  ],
                ),
              ),
            ],
          ),
        );
      case 'inspection_tickets':
        final inspectionRectifications = rectificationTicket
            .where((rectification) => rectification.type == 'inspection')
            .where((rectification) => rectification.status == 'Created')
            .where((rectification) =>
                rectification.relatedTicket == widget.inspectionTicketNumber)
            .toList();

        if (inspectionRectifications.isEmpty) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBarWidget.secondary('List rectification ticket', context),
          body: SafeArea(
            child: Container(
              color: AppColor.scaffold, // Ensure a background color is set
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Add your text outside the loop here (above the list)
                  Text(
                    widget.inspectionTicketNumber, // Example text
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20), // Add some spacing

                  // The ListView.builder inside an Expanded widget for scrollable content
                  Expanded(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: inspectionRectifications.length,
                      itemBuilder: (context, index) {
                        final rectificationItem =
                            inspectionRectifications[index];

                        return Container(
                          decoration: BoxDecoration(
                            color: AppColor.whiteColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.event,
                                    color: Colors.grey,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    rectificationItem.createdAt ??
                                        'Unknown Date',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                      decoration: TextDecoration
                                          .none, // No yellow underline
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                rectificationItem.ticketNumber ??
                                    'No related ticket',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration
                                      .none, // No yellow underline
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                rectificationItem.section ??
                                    'No section specified',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 14,
                                  decoration: TextDecoration
                                      .none, // No yellow underline
                                ),
                              ),
                              Text(
                                rectificationItem.servicePoint ??
                                    'No service point specified',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 14,
                                  decoration: TextDecoration
                                      .none, // No yellow underline
                                ),
                              ),
                              const SizedBox(height: 10),
                              DButtonBorder(
                                onClick: () {
                                  Navigator.pushReplacementNamed(
                                    context,
                                    AppRoute.rectificationShow,
                                    arguments: {
                                      'ticketNumber':
                                          rectificationItem.ticketNumber,
                                      'showType': 'acknowledge',
                                      'step': '-',
                                    },
                                  );
                                },
                                mainColor: Colors.white,
                                radius: 10,
                                borderColor: AppColor.scaffold,
                                child: const Text(
                                  'Rectification Ticket Form',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      case 'quality_tickets':
        final inspectionRectifications = rectificationTicket
            .where((rectification) => rectification.type == 'quality_audit')
            .where((rectification) => rectification.status == 'Created')
            .where((rectification) =>
                rectification.relatedTicket == widget.inspectionTicketNumber)
            .toList();

        if (inspectionRectifications.isEmpty) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBarWidget.secondary('List rectification ticket', context),
          body: SafeArea(
            child: Container(
              color: AppColor.scaffold, // Ensure a background color is set
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Add your text outside the loop here (above the list)
                  Text(
                    widget.inspectionTicketNumber, // Example text
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20), // Add some spacing

                  // The ListView.builder inside an Expanded widget for scrollable content
                  Expanded(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: inspectionRectifications.length,
                      itemBuilder: (context, index) {
                        final rectificationItem =
                            inspectionRectifications[index];

                        return Container(
                          decoration: BoxDecoration(
                            color: AppColor.whiteColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.event,
                                    color: Colors.grey,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    rectificationItem.createdAt ??
                                        'Unknown Date',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                      decoration: TextDecoration
                                          .none, // No yellow underline
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                rectificationItem.ticketNumber ??
                                    'No related ticket',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration
                                      .none, // No yellow underline
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                rectificationItem.section ??
                                    'No section specified',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 14,
                                  decoration: TextDecoration
                                      .none, // No yellow underline
                                ),
                              ),
                              Text(
                                rectificationItem.servicePoint ??
                                    'No service point specified',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 14,
                                  decoration: TextDecoration
                                      .none, // No yellow underline
                                ),
                              ),
                              const SizedBox(height: 10),
                              DButtonBorder(
                                onClick: () {
                                  Navigator.pushReplacementNamed(
                                    context,
                                    AppRoute.rectificationShow,
                                    arguments: {
                                      'ticketNumber':
                                          rectificationItem.ticketNumber,
                                      'showType': 'acknowledge',
                                      'step': '-',
                                    },
                                  );
                                },
                                mainColor: Colors.white,
                                radius: 10,
                                borderColor: AppColor.scaffold,
                                child: const Text(
                                  'Rectification Ticket Form',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      case 'history':
        return Scaffold(
          body: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Align(
                  alignment:
                      Alignment.centerLeft, // Aligns the title to the left
                  child: Text(
                    'Rectification History ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 10), // Add top margin here
                child: TabBar(
                  controller: _tabController,
                  indicator: const BoxDecoration(),
                  dividerColor: Colors.transparent,
                  tabs: [
                    Tab(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () {
                            setState(() {
                              _tabController.index = 0;
                            });
                          },
                          child: Container(
                            width: 200,
                            height: 50,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _tabController.index == 0
                                  ? AppColor.blueColor1
                                  : AppColor.greyColor1,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: const Text(
                              'Inspection',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Tab(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () {
                            setState(() {
                              _tabController.index = 1;
                            });
                          },
                          child: Container(
                            width: 200,
                            height: 50,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _tabController.index == 1
                                  ? AppColor.blueColor1
                                  : AppColor.greyColor1,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: const Text(
                              'Installation',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Tab(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () {
                            setState(() {
                              _tabController.index = 2;
                            });
                          },
                          child: Container(
                            width: 200,
                            height: 50,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _tabController.index == 2
                                  ? AppColor.blueColor1
                                  : AppColor.greyColor1,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: const Text(
                              'Quality Audit',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Add other tabs...
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTabHistoryContent("inspection"), // First tab content
                    _buildTabHistoryContent(
                        "installation"), // Second tab content
                    _buildTabHistoryContent(
                        "quality_audit"), // Third tab content
                  ],
                ),
              ),
            ],
          ),
        );
      default:
        return const Text(
          'Ticket type is not found',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        );
    }
  }

  Widget _buildTabContent(type) {
    final rawInspection = rectificationTicket
        .where((rectification) => rectification.type == type)
        .where((rectification) => rectification.status == 'Created')
        .toList();

    final Map<String, int> relatedTicketCounts = {};
    final List<Rectification> inspection = [];

    for (var rectification in rawInspection) {
      String relatedTicket = rectification.relatedTicket;

      // If it's a new relatedTicket, add to uniqueInspection
      if (!relatedTicketCounts.containsKey(relatedTicket)) {
        inspection.add(rectification);
        relatedTicketCounts[relatedTicket] = 1; // Initialize count
      } else {
        relatedTicketCounts[relatedTicket] =
            relatedTicketCounts[relatedTicket]! + 1; // Increment count
      }
    }

    final installation = rectificationTicket
        .where((rectification) => rectification.type == type)
        .where((rectification) => rectification.status == 'Created')
        .toList();

    switch (type) {
      case 'inspection':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: inspection.isNotEmpty
                  ? ListView.builder(
                      padding: const EdgeInsets.all(20),
                      physics: const BouncingScrollPhysics(),
                      itemCount: inspection.length,
                      itemBuilder: (context, index) {
                        final rectificationItem = inspection[index];
                        // Use `relatedTicketCount` with a fallback value of 0
                        final relatedTicketCount = relatedTicketCounts[
                                rectificationItem.relatedTicket] ??
                            0;

                        return Container(
                          decoration: BoxDecoration(
                            color: AppColor.whiteColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.event,
                                    color: Colors.grey,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    rectificationItem.createdAt,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                rectificationItem.relatedTicket,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "Defect found: $relatedTicketCount",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                rectificationItem.section,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                rectificationItem.servicePoint,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 10),
                              DButtonBorder(
                                onClick: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => RectificationIndex(
                                        indexType: 'inspection_tickets',
                                        inspectionTicketNumber:
                                            rectificationItem.relatedTicket,
                                      ),
                                    ),
                                  );
                                },
                                mainColor: Colors.white,
                                radius: 10,
                                borderColor: AppColor.scaffold,
                                child: const Text(
                                  'Rectification Tickets',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Text(
                        'Data is empty!',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
            ),
          ],
        );
      case 'installation':
        return installation.isNotEmpty
            ? ListView.builder(
                padding: const EdgeInsets.all(20),
                physics: const BouncingScrollPhysics(),
                itemCount: installation.length,
                itemBuilder: (context, index) {
                  final rectificationItem = installation[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: AppColor.whiteColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.event,
                              color: Colors.grey,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              rectificationItem.createdAt,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          rectificationItem.ticketNumber,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Installation Ticket: ${rectificationItem.relatedTicket}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          rectificationItem.section,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          rectificationItem.servicePoint,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 10),
                        DButtonBorder(
                          // here
                          onClick: () {
                            switch (rectificationItem.status) {
                              case 'Created':
                                Navigator.pushReplacementNamed(
                                  context,
                                  AppRoute.rectificationShow,
                                  arguments: {
                                    'ticketNumber':
                                        rectificationItem.ticketNumber,
                                    'showType': 'acknowledge',
                                    'step': '-',
                                  },
                                );
                              case 'Opened':
                                Navigator.pushReplacementNamed(
                                  context,
                                  AppRoute.rectificationCreate,
                                  arguments: {
                                    'ticketNumber':
                                        rectificationItem.ticketNumber,
                                    'createType': 'record',
                                  },
                                );
                              case 'On Progress':
                                Navigator.pushReplacementNamed(
                                  context,
                                  AppRoute.rectificationCreate,
                                  arguments: {
                                    'ticketNumber':
                                        rectificationItem.ticketNumber,
                                    'createType': 'record',
                                  },
                                );
                              default:
                            }
                          },
                          mainColor: Colors.white,
                          radius: 10,
                          borderColor: AppColor.scaffold,
                          child: const Text(
                            'Rectification Ticket Form',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              )
            : Center(
                child: Text(
                  'Data is empty!',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              );
      case 'quality_audit':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: inspection.isNotEmpty
                  ? ListView.builder(
                      padding: const EdgeInsets.all(20),
                      physics: const BouncingScrollPhysics(),
                      itemCount: inspection.length,
                      itemBuilder: (context, index) {
                        final rectificationItem = inspection[index];
                        // Use `relatedTicketCount` with a fallback value of 0
                        final relatedTicketCount = relatedTicketCounts[
                                rectificationItem.relatedTicket] ??
                            0;

                        return Container(
                          decoration: BoxDecoration(
                            color: AppColor.whiteColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.event,
                                    color: Colors.grey,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    rectificationItem.createdAt,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                rectificationItem.relatedTicket,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "Defect found: $relatedTicketCount",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                rectificationItem.section,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                rectificationItem.servicePoint,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 10),
                              DButtonBorder(
                                onClick: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => RectificationIndex(
                                        indexType: 'quality_tickets',
                                        inspectionTicketNumber:
                                            rectificationItem.relatedTicket,
                                      ),
                                    ),
                                  );
                                },
                                mainColor: Colors.white,
                                radius: 10,
                                borderColor: AppColor.scaffold,
                                child: const Text(
                                  'Rectification Tickets',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Text(
                        'Data is empty!',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
            ),
          ],
        );
      default:
        return const Text(
          'Ticket type is not found',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        );
    }
  }

  Widget _buildTabHistoryContent(type) {
    final String jabatan = user.jabatan ?? '';

    if (loading) {
      return Center(child: CircularProgressIndicator());
    }

    if (jabatan != 'Jointer') {
      return const Center(child: Text('Rectification History is Empty'));
    }
    final rawInspection = rectificationTicket
        .where((rectification) => rectification.type == type)
        .toList();

    final Map<String, int> relatedTicketCounts = {};
    final List<Rectification> inspection = [];

    for (var rectification in rawInspection) {
      String relatedTicket = rectification.relatedTicket;

      // If it's a new relatedTicket, add to uniqueInspection
      if (!relatedTicketCounts.containsKey(relatedTicket)) {
        inspection.add(rectification);
        relatedTicketCounts[relatedTicket] = 1; // Initialize count
      } else {
        relatedTicketCounts[relatedTicket] =
            relatedTicketCounts[relatedTicket]! + 1; // Increment count
      }
    }

    final installation = rectificationTicket
        .where((rectification) => rectification.type == type)
        .toList();

    switch (type) {
      case 'inspection':
        Color _getStatusColor(String status) {
          switch (status) {
            case 'Acknowledge':
              return const Color(0xFF239FDB);
            case 'Created':
              return const Color(0xFF008B6B);
            case 'Submited':
              return const Color.fromARGB(255, 25, 110, 153);
            case 'Opened':
              return const Color(0xFF1CC900);
            case 'On Progress':
              return const Color(0xFFEDFF23);
            case 'Paused':
              return const Color(0xFFFA4D75);
            case 'Approved by OPS':
              return const Color(0xFFFA4D75);
            case 'Approved by SPV':
              return const Color(0xFFAB07F9);
            case 'Approved By SPV':
              return const Color(0xFFAB07F9);
            case 'On Review':
              return const Color(0xFFFF9C40);
            case 'Rejected':
              return const Color(0xFFEB4D4B);
            case 'closed':
              return const Color(0xFF757575);
            default:
              return Colors.black; // Default color if no status matches
          }
        }

        Color _getStatusTextColor(String status) {
          switch (status) {
            case 'On Progress':
              return AppColor.defaultText;
            default:
              return AppColor.whiteColor; // Default color if no status matches
          }
        }
        return Column(
          children: [
            // Dropdown for status filter
            Card(
              color: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              margin: const EdgeInsets.only(
                left: 16.0, // Custom margin for the left side
                top: 20.0, // Custom margin for the top side
                right: 100.0, // Custom margin for the right side
                bottom: 10.0, // Custom margin for the bottom side
              ), // Adjust margin as needed
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 12.0, // Custom margin for the left side
                  top: 5.0, // Custom margin for the top side
                  right: 12.0, // Custom margin for the right side
                  bottom: 5.0, // Custom margin for the bottom side
                ),
                // Adjust padding as needed
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Text(
                      'Filter by Status: ',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 10),
                    DropdownButton<String>(
                      value: selectedStatus,
                      icon: const Icon(Icons.arrow_downward),
                      iconSize:
                          18, // Set arrow button size to be slightly smaller
                      elevation: 16,
                      style: const TextStyle(
                          color:
                              Colors.black), // Text style for the selected item
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedStatus = newValue!;
                        });
                      },
                      items: statuses
                          .map<DropdownMenuItem<String>>((String status) {
                        return DropdownMenuItem<String>(
                          value: status,
                          child: Text(
                            status,
                            style: const TextStyle(
                                fontSize:
                                    12.0), // Set your desired text size here
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                physics: const BouncingScrollPhysics(),
                // Only count parent rectifications with matching child cards
                itemCount: inspection.where((parentRectification) {
                  final childInspectionTickets = rectificationTicket
                      .where((rectification) =>
                          rectification.relatedTicket ==
                          parentRectification.relatedTicket)
                      .toList();

                  // Filter child rectifications based on status
                  final filteredChildTickets = selectedStatus == 'All'
                      ? childInspectionTickets
                      : childInspectionTickets
                          .where((rectification) =>
                              rectification.status == selectedStatus)
                          .toList();

                  // Only show parent if it has child cards with the selected status
                  return filteredChildTickets.isNotEmpty;
                }).length,
                itemBuilder: (context, index) {
                  // Access each parent rectification item
                  final parentRectification =
                      inspection.where((parentRectification) {
                    final childInspectionTickets = rectificationTicket
                        .where((rectification) =>
                            rectification.relatedTicket ==
                            parentRectification.relatedTicket)
                        .toList();

                    // Filter child rectifications based on status
                    final filteredChildTickets = selectedStatus == 'All'
                        ? childInspectionTickets
                        : childInspectionTickets
                            .where((rectification) =>
                                rectification.status == selectedStatus)
                            .toList();

                    // Only show parent if it has child cards with the selected status
                    return filteredChildTickets.isNotEmpty;
                  }).toList()[index];

                  // Filter the child rectifications where related_ticket matches the parent
                  final List<Rectification> childInspectionTickets =
                      rectificationTicket
                          .where((rectification) =>
                              rectification.relatedTicket ==
                              parentRectification.relatedTicket)
                          .toList();

                  // Apply status filter if necessary
                  final filteredChildTickets = selectedStatus == 'All'
                      ? childInspectionTickets
                      : childInspectionTickets
                          .where((rectification) =>
                              rectification.status == selectedStatus)
                          .toList();

                  return Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: 8), // Space between cards
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 5,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Parent Card Content
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                parentRectification.relatedTicket,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                              const Gap(10),

                              // Loop over filtered child rectifications (child cards)
                              for (var childRectification
                                  in filteredChildTickets)
                                GestureDetector(
                                  onTap: () {
                                    switch (childRectification.status) {
                                      case 'Created':
                                        Navigator.pushReplacementNamed(
                                          context,
                                          AppRoute.rectificationShow,
                                          arguments: {
                                            'ticketNumber':
                                                childRectification.ticketNumber,
                                            'showType': 'acknowledge',
                                            'step': '-',
                                          },
                                        );
                                      case 'Rejected':
                                        Navigator.pushReplacementNamed(
                                          context,
                                          AppRoute.rectificationShow,
                                          arguments: {
                                            'ticketNumber':
                                                childRectification.ticketNumber,
                                            'showType': 'acknowledge',
                                            'step': '-',
                                          },
                                        );
                                      case 'Opened':
                                        Navigator.pushReplacementNamed(
                                          context,
                                          AppRoute.rectificationCreate,
                                          arguments: {
                                            'ticketNumber':
                                                childRectification.ticketNumber,
                                            'createType': 'record',
                                          },
                                        );
                                      case 'On Progress':
                                        Navigator.pushReplacementNamed(
                                          context,
                                          AppRoute.rectificationCreate,
                                          arguments: {
                                            'ticketNumber':
                                                childRectification.ticketNumber,
                                            'createType': 'record',
                                          },
                                        );
                                      default:
                                    }
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(top: 12),
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: Colors
                                          .grey[100], // Child card background
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.2),
                                          blurRadius: 3,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 6,
                                            left: 6,
                                            right: 6,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                childRectification.ticketNumber,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 10,
                                                ),
                                              ),
                                              const Gap(3),
                                              const Spacer(),
                                              Container(
                                                height: 15,
                                                width: 70,
                                                decoration: BoxDecoration(
                                                  color: _getStatusColor(
                                                      childRectification
                                                          .status),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    childRectification.status ==
                                                            'Submited'
                                                        ? 'Submitted'
                                                        : childRectification
                                                                        .status ==
                                                                    'Approved by SPV' ||
                                                                childRectification
                                                                        .status ==
                                                                    'Approved By SPV'
                                                            ? 'Approved SPV'
                                                            : childRectification
                                                                        .status ==
                                                                    'Approved by OPS'
                                                                ? 'Approved OPS'
                                                                : childRectification
                                                                    .status,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 8,
                                                      color:
                                                          _getStatusTextColor(
                                                              childRectification
                                                                  .status),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Gap(6),
                                        Text(
                                          'Service Point: ${childRectification.servicePoint}',
                                          style: const TextStyle(fontSize: 11),
                                        ),
                                        Text(
                                          'Section Patrol: ${childRectification.sectionPatrol}',
                                          style: const TextStyle(fontSize: 11),
                                        ),
                                        const Gap(6),
                                        // here
                                        Text(
                                          '${childRectification.reasonRejectedSpv}',
                                          style: const TextStyle(fontSize: 11),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      case 'installation':
        Color _getStatusColor(String status) {
          switch (status) {
            case 'Acknowledge':
              return const Color(0xFF239FDB);
            case 'Submited':
              return const Color.fromARGB(255, 25, 110, 153);
            case 'Created':
              return const Color(0xFF008B6B);
            case 'Opened':
              return const Color(0xFF1CC900);
            case 'On Progress':
              return const Color(0xFFEDFF23);
            case 'Paused':
              return const Color(0xFFFA4D75);
            case 'Approval SPV':
              return const Color(0xFFAB07F9);
            case 'On Review':
              return const Color(0xFFFF9C40);
            case 'Rejected':
              return const Color(0xFFEB4D4B);
            case 'closed':
              return const Color(0xFF757575);
            default:
              return Colors.black; // Default color if no status matches
          }
        }

        Color _getStatusTextColor(String status) {
          switch (status) {
            case 'On Progress':
              return AppColor.defaultText;
            default:
              return AppColor.whiteColor; // Default color if no status matches
          }
        }

        return Column(
          children: [
            // Dropdown for status filter
            Card(
              color: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              margin: const EdgeInsets.only(
                left: 16.0,
                top: 20.0,
                right: 100.0,
                bottom: 10.0,
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Text(
                      'Filter by Status: ',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 10),
                    DropdownButton<String>(
                      value: selectedStatus,
                      icon: const Icon(Icons.arrow_downward),
                      iconSize: 18,
                      elevation: 16,
                      style: const TextStyle(color: Colors.black),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedStatus = newValue!;
                        });
                      },
                      items: statuses
                          .map<DropdownMenuItem<String>>((String status) {
                        return DropdownMenuItem<String>(
                          value: status,
                          child: Text(
                            status,
                            style: const TextStyle(fontSize: 12.0),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                physics: const BouncingScrollPhysics(),
                // Filter installations based on selected status
                itemCount: installation.where((rectification) {
                  return selectedStatus == 'All' ||
                      rectification.status == selectedStatus;
                }).length,
                itemBuilder: (context, index) {
                  // Access each filtered installation item
                  final filteredInstallations =
                      installation.where((rectification) {
                    return selectedStatus == 'All' ||
                        rectification.status == selectedStatus;
                  }).toList();

                  final installationItem = filteredInstallations[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0), // Add vertical margin
                    child: GestureDetector(
                      onTap: () {
                        switch (installationItem.status) {
                          case 'Created':
                            Navigator.pushReplacementNamed(
                              context,
                              AppRoute.rectificationShow,
                              arguments: {
                                'ticketNumber': installationItem.ticketNumber,
                                'showType': 'acknowledge',
                                'step': '-',
                              },
                            );
                            break;
                          case 'Rejected':
                            Navigator.pushReplacementNamed(
                              context,
                              AppRoute.rectificationShow,
                              arguments: {
                                'ticketNumber': installationItem.ticketNumber,
                                'showType': 'acknowledge',
                                'step': '-',
                              },
                            );
                            break;
                          case 'Opened':
                            Navigator.pushReplacementNamed(
                              context,
                              AppRoute.rectificationCreate,
                              arguments: {
                                'ticketNumber': installationItem.ticketNumber,
                                'createType': 'record',
                              },
                            );
                            break;
                          case 'On Progress':
                            Navigator.pushReplacementNamed(
                              context,
                              AppRoute.rectificationCreate,
                              arguments: {
                                'ticketNumber': installationItem.ticketNumber,
                                'createType': 'record',
                              },
                            );
                            break;
                          default:
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 6, left: 6, right: 6),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    installationItem.ticketNumber,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const Gap(3),
                                  Container(
                                    height: 15,
                                    width: 70,
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(
                                          installationItem.status),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: Text(
                                        installationItem.status == 'Submited'
                                            ? 'Submitted'
                                            : installationItem.status,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 8,
                                          color: _getStatusTextColor(
                                              installationItem.status),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    'Details >',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 10,
                                      color: AppColor.defaultText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Divider(color: AppColor.divider),
                            ItemTextHistory.primary(
                                "Date", installationItem.createdAt ?? '-', 1),
                            ItemTextHistory.primary("Acknowledged By",
                                installationItem.acknowledged_by ?? '-', 1),
                            ItemTextHistory.primary("QMS Related TT",
                                installationItem.relatedTicket ?? '-', 1),
                            ItemTextHistory.primary(
                                "Section", installationItem.section ?? '-', 1),
                            ItemTextHistory.primary("Longitude",
                                installationItem.longitude ?? '-', 1),
                            ItemTextHistory.primary("Latitude",
                                installationItem.latitude ?? '-', 1),
                            ItemTextHistory.primary("",
                                installationItem.reasonRejectedSpv ?? '-', 1),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      case 'quality_audit':
        return const Text(
          'Quality Audit',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        );

      default:
        return const Text(
          'Ticket type is not found',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        );
    }
  }
}

class rectificationInstallationHistory extends StatelessWidget {
  final String date;
  final String ticketNumber;
  final String? relatedTicket;
  final String? servicePoint;
  final String? longitude;
  final String? latitude;
  final String? acknowledgeBy;
  final String status;
  final VoidCallback? onTap;

  const rectificationInstallationHistory({
    required this.date,
    required this.ticketNumber,
    required this.relatedTicket,
    required this.servicePoint,
    required this.longitude,
    required this.latitude,
    required this.acknowledgeBy,
    required this.status,
    this.onTap,
  });

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Acknowledge':
        return const Color(0xFF239FDB);
      case 'Created':
        return const Color(0xFF008B6B);
      case 'Opened':
        return const Color(0xFF1CC900);
      case 'On Progress':
        return const Color(0xFFEDFF23);
      case 'Paused':
        return const Color(0xFFFA4D75);
      case 'Approval SPV':
        return const Color(0xFFAB07F9);
      case 'On Review':
        return const Color(0xFFFF9C40);
      case 'Rejected':
        return const Color(0xFFEB4D4B);
      case 'closed':
        return const Color(0xFF757575);
      default:
        return Colors.black; // Default color if no status matches
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status) {
      case 'On Progress':
        return AppColor.defaultText;
      default:
        return AppColor.whiteColor; // Default color if no status matches
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          switch (status) {
            case 'Opened':
              Navigator.pushReplacementNamed(
                context,
                AppRoute.rectificationCreate,
                arguments: {
                  'ticketNumber': ticketNumber,
                  'createType': 'record',
                },
              );
            case 'On Progress':
              Navigator.pushReplacementNamed(
                context,
                AppRoute.rectificationCreate,
                arguments: {
                  'ticketNumber': ticketNumber,
                  'createType': 'record',
                },
              );
            default:
          }
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  top: 6,
                  left: 6,
                  right: 6,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      ticketNumber,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    const Gap(3),
                    Container(
                      height: 15,
                      width: 70,
                      decoration: BoxDecoration(
                          color: _getStatusColor(status),
                          borderRadius: BorderRadius.circular(10)),
                      child: Center(
                        child: Text(
                          status,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 8,
                            color: _getStatusTextColor(status),
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Details >',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                        color: AppColor.defaultText,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                color: AppColor.divider,
              ),
              ItemTextHistory.primary("Date", date ?? '-', 1),
              ItemTextHistory.primary(
                  "Acknowledged By", acknowledgeBy ?? '-', 1),
              ItemTextHistory.primary(
                  "QMS Related TT", relatedTicket ?? '-', 1),
              ItemTextHistory.primary("Service Point", servicePoint ?? '-', 1),
              ItemTextHistory.primary("Longitude", longitude ?? '-', 1),
              ItemTextHistory.primary("Latitude", latitude ?? '-', 1),
              const Gap(12)
            ],
          ),
        ));
  }
}
