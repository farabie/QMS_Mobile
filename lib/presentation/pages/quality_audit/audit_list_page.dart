part of '../pages.dart';

class ListAuditPage extends StatefulWidget {
  final List<dynamic>? tickets;

  const ListAuditPage({super.key, this.tickets});
  // const ListAuditPage({super.key});

  @override
  State<ListAuditPage> createState() => _ListAuditPageState();
}

class _ListAuditPageState extends State<ListAuditPage> {
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

  // Fungsi untuk mengambil data dari API
  void fetchTickets() async {
    setState(() {
      tickets = null; // Clear data sebelum fetch baru
      isLoading = true;
    });
    try {
      // Panggil API yang mengembalikan data tiket
      List<dynamic> data = await apiService.getTickets(user.username!);
      print('Data fetched: $data');

      setState(() {
        tickets = data; // Simpan data tiket yang diterima
        isLoading = false; // Data telah diambil, loader berhenti
      });
    } catch (e) {
      print("Error fetching tickets: $e");
      setState(() {
        isLoading = false; // Error terjadi, loader berhenti
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          header(context, 'Site Quality Audit'),
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
                        itemCount: tickets?.length ?? 0, // Jumlah tiket
                        itemBuilder: (context, index) {
                          // Data tiap tiket
                          var ticket = tickets?[index];
                          return cardTicket3(
                            createdAt:
                                DateTime.parse(ticket["ticket_status_date"]),
                            ttNumber: 'TT-${ticket['ticket_number']}',
                            section: ticket['section_name'],
                            servicePoint: ticket['service_point_name'],
                            onClick: () {
                              Navigator.pushReplacementNamed(
                                context,
                                AppRoute.detailDmsTicketAudit,
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
