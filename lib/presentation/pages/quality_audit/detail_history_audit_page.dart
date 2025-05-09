part of '../pages.dart';

class DetailHistoryAuditPage extends StatefulWidget {
  final String idAudit;

  const DetailHistoryAuditPage({
    super.key,
    required this.idAudit,
  });

  @override
  State<DetailHistoryAuditPage> createState() => _DetailHistoryAuditPageState();
}

class _DetailHistoryAuditPageState extends State<DetailHistoryAuditPage> {
  late Future<List<Audit>> _auditsFuture;
  late Future<List<AssetTaggingAudit>> _assetTaggingsFuture;
  late final TextEditingController edtQmsAuditTicketNumber;

  @override
  void initState() {
    super.initState();
    _auditsFuture = ApiService().fetchAuditByTicket(widget.idAudit);
    _assetTaggingsFuture = ApiService().getAssetTaggingAudit(widget.idAudit);
    edtQmsAuditTicketNumber = TextEditingController(text: widget.idAudit);
  }

  @override
  void dispose() {
    edtQmsAuditTicketNumber.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget.secondary('Detail History Audit', context),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: FutureBuilder<List<Audit>>(
                future: _auditsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No Audits Available'));
                  }

                  final audits = snapshot.data!;
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    itemCount: audits.length,
                    itemBuilder: (context, index) {
                      final audit = audits[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildAuditCard(audit),
                            const Gap(24),
                            FutureBuilder<List<AssetTaggingAudit>>(
                              future: _assetTaggingsFuture,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                } else if (snapshot.hasError) {
                                  return Center(
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: Colors.redAccent.withOpacity(
                                            0.1), // Latar belakang merah transparan
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: Colors
                                              .redAccent, // Warna border merah
                                          width: 1,
                                        ),
                                      ),
                                      child: const Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.error_outline, // Ikon error
                                            color: Colors.redAccent,
                                            size: 40,
                                          ),
                                          SizedBox(height: 10),
                                          Text(
                                            'Error: Asset Tagging belum pernah dibuat untuk Tiket QMS ini',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.redAccent,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                } else if (!snapshot.hasData ||
                                    snapshot.data!.isEmpty) {
                                  return const Center(
                                      child:
                                          Text('No Asset Taggings Available'));
                                }

                                final assetTaggings = snapshot.data!;
                                return _buildAssetTaggingSummary(assetTaggings);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuditCard(Audit audit) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Colors.white,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detail Ticket DMS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColor.defaultText,
            ),
          ),
          Divider(
            color: AppColor.greyColor2,
          ),
          ItemDescriptionDetail.primary('Project', audit.project),
          const Gap(12),
          ItemDescriptionDetail.primary('Segment', audit.segment),
          const Gap(12),
          ItemDescriptionDetail.primary('Section Name', audit.sectionName),
          const Gap(12),
          ItemDescriptionDetail.primary('Section Patrol', audit.sectionPatrol),
          const Gap(12),
          ItemDescriptionDetail.primary('Service Point', audit.servicePoint),
          const Gap(12),
          ItemDescriptionDetail.primary('Worker', audit.worker),
          const Gap(12),
        ],
      ),
    );
  }

  Widget _buildAssetTaggingSummary(List<AssetTaggingAudit> assetTaggings) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InputWidget.disable(
            'QMS Audit Ticket Number',
            edtQmsAuditTicketNumber,
          ),
          const Gap(12),
          const Text(
            'Summary Asset Tagging List:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(6),
          ...assetTaggings.map((tagging) {
            return GestureDetector(
              onTap: (tagging.findingCount > 0)
                  ? () {
                      Navigator.pushNamed(
                        context,
                        AppRoute.detailAuditResult,
                        arguments: {
                          'idAudit': widget.idAudit,
                          'assetTagging': tagging.nama,
                        },
                      );
                    }
                  : null,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        tagging.nama,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Container(
                      width: 26,
                      height: 26,
                      alignment: Alignment.center,
                      margin: const EdgeInsets.only(left: 8),
                      decoration: BoxDecoration(
                        color: tagging.findingCount > 0
                            ? Colors.red
                            : Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${tagging.findingCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
