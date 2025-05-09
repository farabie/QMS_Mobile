part of '../pages.dart';

class ListInstallationPage extends StatefulWidget {
  final int cmCount;
  final int pmCount;
  final List<TicketByUser>? ticketByUserCM;
  final List<TicketByUser>? ticketByUserPM;

  const ListInstallationPage({
    super.key,
    this.cmCount = 0,
    this.pmCount = 0,
    this.ticketByUserCM,
    this.ticketByUserPM,
  });

  @override
  State<ListInstallationPage> createState() => _ListInstallationPageState();
}

class _ListInstallationPageState extends State<ListInstallationPage>
    with TickerProviderStateMixin {
  late TabController tabController;
  bool isSearching = false;
  String searchQuery = '';
  List<TicketByUser> filteredCmTickets = [];
  List<TicketByUser> filteredPmTickets = [];
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(() {
      setState(() {});
    });

    // Initialize filtered lists
    filteredCmTickets = widget.ticketByUserCM ?? [];
    filteredPmTickets = widget.ticketByUserPM ?? [];
  }

  @override
  void dispose() {
    tabController.dispose();
    searchController.dispose();
    super.dispose();
  }

  void filterTickets(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
      if (searchQuery.isEmpty) {
        filteredCmTickets = widget.ticketByUserCM ?? [];
        filteredPmTickets = widget.ticketByUserPM ?? [];
      } else {
        filteredCmTickets = (widget.ticketByUserCM ?? []).where((ticket) {
          final formattedTicketNumber = 'TT-${ticket.ticketNumber}';
          return formattedTicketNumber.toLowerCase().contains(searchQuery) ||
              ticket.ticketNumber?.toLowerCase().contains(searchQuery) ==
                  true ||
              ticket.servicePointName?.toLowerCase().contains(searchQuery) ==
                  true ||
              ticket.sectionName?.toLowerCase().contains(searchQuery) == true;
        }).toList();

        filteredPmTickets = (widget.ticketByUserPM ?? []).where((ticket) {
          final formattedTicketNumber = 'TT-${ticket.ticketNumber}';
          return formattedTicketNumber.toLowerCase().contains(searchQuery) ||
              ticket.ticketNumber?.toLowerCase().contains(searchQuery) ==
                  true ||
              ticket.servicePointName?.toLowerCase().contains(searchQuery) ==
                  true ||
              ticket.sectionName?.toLowerCase().contains(searchQuery) == true;
        }).toList();
      }
    });
  }

  // void filterTickets(String query) {
  //   setState(() {
  //     searchQuery = query.toLowerCase();
  //     if (searchQuery.isEmpty) {
  //       filteredCmTickets = widget.ticketByUserCM ?? [];
  //       filteredPmTickets = widget.ticketByUserPM ?? [];
  //     } else {
  //       filteredCmTickets = (widget.ticketByUserCM ?? []).where((ticket) {
  //         return ticket.ticketNumber?.toLowerCase().contains(searchQuery) ==
  //                 true ||
  //             ticket.servicePointName?.toLowerCase().contains(searchQuery) ==
  //                 true ||
  //             ticket.sectionName?.toLowerCase().contains(searchQuery) == true;
  //       }).toList();

  //       filteredPmTickets = (widget.ticketByUserPM ?? []).where((ticket) {
  //         return ticket.ticketNumber?.toLowerCase().contains(searchQuery) ==
  //                 true ||
  //             ticket.servicePointName?.toLowerCase().contains(searchQuery) ==
  //                 true ||
  //             ticket.sectionName?.toLowerCase().contains(searchQuery) == true;
  //       }).toList();
  //     }
  //   });
  // }

  Widget buildSearchHeader(BuildContext context, String title) {
    return Container(
      height: 50,
      margin: const EdgeInsets.fromLTRB(20, 50, 20, 4),
      decoration: BoxDecoration(
        color: AppColor.blueColor1,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          if (!isSearching)
            Center(
              child: Text(
                title,
                style: TextStyle(
                  color: AppColor.whiteColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            )
          else
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 50),
                child: TextField(
                  controller: searchController,
                  style: TextStyle(color: AppColor.whiteColor),
                  decoration: InputDecoration(
                    hintText: 'Search tickets...',
                    hintStyle:
                        TextStyle(color: AppColor.whiteColor.withOpacity(0.7)),
                    border: InputBorder.none,
                  ),
                  onChanged: filterTickets,
                ),
              ),
            ),
          Positioned(
            left: 8,
            bottom: 0,
            top: 0,
            child: UnconstrainedBox(
              child: DButtonFlat(
                width: 36,
                height: 36,
                radius: 10,
                mainColor: Colors.white,
                onClick: () =>
                    Navigator.pushReplacementNamed(context, AppRoute.dashboard),
                child: const Icon(Icons.arrow_back),
              ),
            ),
          ),
          Positioned(
            right: 8,
            bottom: 0,
            top: 0,
            child: UnconstrainedBox(
              child: DButtonFlat(
                width: 36,
                height: 36,
                radius: 10,
                mainColor: Colors.white,
                onClick: () {
                  setState(() {
                    if (isSearching) {
                      searchController.clear();
                      filterTickets('');
                    }
                    isSearching = !isSearching;
                  });
                },
                child: Icon(isSearching ? Icons.close : Icons.search),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          buildSearchHeader(context, 'Site Installation'),
          const Gap(12),
          TabBar(
            controller: tabController,
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
                        tabController.index = 0;
                      });
                    },
                    child: Container(
                      width: 200,
                      height: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: tabController.index == 0
                            ? AppColor.blueColor1
                            : AppColor.greyColor1,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        'DMS TT CM (${filteredCmTickets.length})',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: tabController.index == 0
                              ? Colors.white
                              : Colors.white,
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
                        tabController.index = 1;
                      });
                    },
                    child: Container(
                      width: 200,
                      height: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: tabController.index == 1
                              ? Colors.blue
                              : Colors.grey,
                          borderRadius: BorderRadius.circular(5)),
                      child: Text(
                        'DMS TT PM (${filteredPmTickets.length})',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: tabController.index == 1
                              ? Colors.white
                              : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: [
                filteredCmTickets.isEmpty
                    ? const Center(
                        child: Text('Ticket DMS TT CM Empty'),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(
                            top: 16, bottom: 24, left: 24, right: 24),
                        physics: const BouncingScrollPhysics(),
                        itemCount: filteredCmTickets.length,
                        itemBuilder: (context, index) {
                          final ticket = filteredCmTickets[index];
                          return cardTicket(
                            createdAt: ticket.ticketStatusDate!,
                            ttNumber: 'TT-${ticket.ticketNumber}',
                            section: ticket.sectionName!,
                            servicePoint: ticket.servicePointName!,
                            onClick: () {
                              if (ticket.ticketNumber != null) {
                                Navigator.pushReplacementNamed(
                                  context,
                                  AppRoute.detailDMSTicket,
                                  arguments: {
                                    'ticketNumber': ticket.ticketNumber!,
                                    'servicePointName':
                                        ticket.servicePointName!,
                                  },
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Error: Ticket number is missing'),
                                  ),
                                );
                              }
                            },
                            context: context,
                          );
                        },
                      ),
                filteredPmTickets.isEmpty
                    ? const Center(
                        child: Text('Ticket DMS TT PM Empty'),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(20),
                        physics: const BouncingScrollPhysics(),
                        itemCount: filteredPmTickets.length,
                        itemBuilder: (context, index) {
                          final ticket = filteredPmTickets[index];
                          return cardTicket(
                            createdAt: ticket.ticketStatusDate!,
                            ttNumber: 'TT-${ticket.ticketNumber}',
                            section: ticket.sectionName!,
                            servicePoint: ticket.servicePointName!,
                            onClick: () {
                              if (ticket.ticketNumber != null) {
                                Navigator.pushReplacementNamed(
                                  context,
                                  AppRoute.detailDMSTicket,
                                  arguments: {
                                    'ticketNumber': ticket.ticketNumber!,
                                    'servicePointName':
                                        ticket.servicePointName!,
                                  },
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Error: Ticket number is missing'),
                                  ),
                                );
                              }
                            },
                            context: context,
                          );
                        },
                      ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
