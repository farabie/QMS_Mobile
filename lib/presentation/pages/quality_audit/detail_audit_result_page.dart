part of '../pages.dart';

class DetailAuditResultPage extends StatefulWidget {
  final String assetTagging;
  final String idAudit;

  const DetailAuditResultPage({
    super.key,
    required this.assetTagging,
    required this.idAudit,
  });

  @override
  _DetailAuditResultPageState createState() => _DetailAuditResultPageState();
}

class _DetailAuditResultPageState extends State<DetailAuditResultPage> {
  Future<List<Map<String, dynamic>>>? _auditResults;

  @override
  void initState() {
    super.initState();

    // Fetch data dari API menggunakan parameter yang diterima melalui konstruktor
    _auditResults = ApiService()
        .getAuditResultsByTagging(widget.idAudit, widget.assetTagging);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarWidget.secondary('Detail Quality Audit Result', context),
        body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: _auditResults,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                            child: Text('No Results Available'));
                      }

                      final auditResults = snapshot.data!;

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        itemCount: auditResults.length,
                        itemBuilder: (context, index) {
                          final result = auditResults[index];

                          return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: _buildAuditResultCard(result, index));
                        },
                      );
                    },
                  ),
                )
              ],
            )));
  }

  Widget _buildAuditResultCard(Map<String, dynamic> result, int index) {
    List<String> allImages = [
      if (result['panoramic'] != null) result['panoramic'],
      if (result['far'] != null) result['far'],
      if (result['near_1'] != null) result['near_1'],
      if (result['near_2'] != null) result['near_2'],
      if (result['near_3'] != null) result['near_3'],
    ]
        .map((path) => 'https://apiqms.triasmitra.com/storage/app/public/$path')
        .toList();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Colors.white,
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Audit Result ${index + 1}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColor.greyColor2,
            ),
          ),
          const Gap(6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ItemDescriptionDetail.primary(
                    'QMS Defect ID', result['id_asset_tagging']),
                const Gap(12),
                ItemDescriptionDetail.primary('Asset Tagging', result['nama']),
                const Gap(12),
                ItemDescriptionDetail.primary('Latitude', result['latitude']),
                const Gap(12),
                ItemDescriptionDetail.primary('Longitude', result['longitude']),
                const Gap(12),
                ItemDescriptionDetail.primary('Category of Audit Detail',
                    result['category_audit_detail']),
                const Gap(12),
              ],
            ),
          ),
          const Gap(12),
          ElevatedButton(
            onPressed: () {
              // Navigasi ke halaman baru dengan semua gambar
              _showAllImagesPage(context, allImages);
            },
            child: Text('View Photos'),
          ),
        ],
      ),
    );
  }

  void _showAllImagesPage(BuildContext context, List<String> allImages) {
    List<String> imageTitles = [
      if (allImages.length > 0) 'Panoramic',
      if (allImages.length > 1) 'Far',
      if (allImages.length > 2) 'Near 1',
      if (allImages.length > 3) 'Near 2',
      if (allImages.length > 4) 'Near 3',
    ];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBarWidget.secondary('All Documentation/Photos', context),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ListView.builder(
              itemCount: allImages.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    _showFullScreenImagePage(context, allImages[index]);
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        imageTitles[
                            index], // Display the title before the image
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8), // Add some spacing
                      _buildImageDescriptionFull(allImages[index], context),
                      const SizedBox(height: 12), // Add spacing between images
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _showFullScreenImagePage(BuildContext context, String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Center(
            child: InteractiveViewer(
              maxScale: 5.0,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageDescriptionFull(String imageUrl, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          height: 200,
          width: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Text(
                'Error loading image',
                style: TextStyle(color: Colors.white),
              ),
            );
          },
        ),
      ),
    );
  }
}
