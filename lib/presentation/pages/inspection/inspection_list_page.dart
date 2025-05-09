part of '../pages.dart';

class ListInspectionPage extends StatefulWidget {
  final List<dynamic>? tickets;

  const ListInspectionPage({super.key, this.tickets});

  @override
  State<ListInspectionPage> createState() => _ListInspectionPageState();
}

class _ListInspectionPageState extends State<ListInspectionPage> {
  List<dynamic>? tickets;
  late User user;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    tickets = widget.tickets; // Ambil tiket dari widget
    if (tickets == null) {
      print('Memanggil fetchData');
      fetchTickets(); // Ambil tiket jika tidak ada data dari widget
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void fetchTickets() async {
    setState(() {
      tickets = null; // Clear data sebelum fetch baru
      isLoading = true;
    });
    try {
      List<dynamic> data = await apiService.getTickets(user.username!);
      print('Data fetched: $data');

      setState(() {
        tickets = data; // Simpan data tiket yang diterima
        isLoading = false; // Data telah diambil, loader berhenti
      });
    } catch (e) {
      print("Error fetching tickets: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          header(context, 'Site Inspection'),
          const Gap(12),
          Container(
            width: 200,
            height: 50,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColor.blueColor1,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              'DMS TT Patroll (${tickets?.length ?? 0})',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : tickets?.isEmpty ?? true
                    ? const Center(
                        child: Text('No tickets available'),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(20),
                        physics: const BouncingScrollPhysics(),
                        itemCount: tickets?.length ?? 0,
                        itemBuilder: (context, index) {
                          // Data tiap tiket
                          var ticket = tickets?[index];
                          return cardTicket2(
                            createdAt:
                                DateTime.parse(ticket["ticket_status_date"]),
                            ttNumber: 'TT-${ticket['ticket_number']}',
                            section: ticket['section_name'],
                            servicePoint: ticket['service_point_name'],
                            onClick: () {
                              Navigator.pushReplacementNamed(
                                context,
                                AppRoute.detailDmsTicketInspection,
                                arguments: {
                                  'ticketNumber': ticket['ticket_number'],
                                },
                              );
                            },
                            context: context,
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
