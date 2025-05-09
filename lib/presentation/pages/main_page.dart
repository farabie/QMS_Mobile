part of 'pages.dart';

class MainPage extends StatefulWidget {
  final int initialIndex;
  const MainPage({super.key, this.initialIndex = 0});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  final List<Widget> _tabs = [
    const DashboardPage(),
    const InspectionHistory(),
    const InstallationHistory(),
    RectificationIndex(
      key: UniqueKey(),
      indexType: 'history',
      inspectionTicketNumber: '-',
    ), // Rectification History
    const AuditHistory()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget.primary(context),
      body: _tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: Colors.white,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          _buildBottomNavigationBarItem(
            index: 0,
            label: 'Home',
            activeIconPath: 'assets/icons/ic_home_active.png',
            inactiveIconPath: 'assets/icons/ic_home_inactive.png',
          ),
          _buildBottomNavigationBarItem(
            index: 1,
            label: 'Inspection History',
            activeIconPath: 'assets/icons/ic_inspection_active.png',
            inactiveIconPath: 'assets/icons/ic_inspection_inactive.png',
          ),
          _buildBottomNavigationBarItem(
            index: 2,
            label: 'Installation History',
            activeIconPath: 'assets/icons/ic_installation_active.png',
            inactiveIconPath: 'assets/icons/ic_installation_inactive.png',
          ),
          _buildBottomNavigationBarItem(
            index: 3,
            label: 'Rectification History',
            activeIconPath: 'assets/icons/ic_rectification_active.png',
            inactiveIconPath: 'assets/icons/ic_rectification_inactive.png',
          ),
          _buildBottomNavigationBarItem(
            index: 4,
            label: 'Quality Audit History',
            activeIconPath: 'assets/icons/ic_qualityaudit_active.png',
            inactiveIconPath: 'assets/icons/ic_qualityaudit_inactive.png',
          ),
        ],
      ),
    );
  }

  BottomNavigationBarItem _buildBottomNavigationBarItem({
    required int index,
    required String label,
    required String activeIconPath,
    required String inactiveIconPath,
  }) {
    return BottomNavigationBarItem(
      icon: SizedBox(
        width: 60,
        height: 50,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              _currentIndex == index ? activeIconPath : inactiveIconPath,
              width: 24,
              height: 24,
            ),
            Text(
              label,
              maxLines: 2,
              style: TextStyle(
                fontSize: 8,
                color: _currentIndex == index
                    ? AppColor.blueColor1
                    : AppColor.greyColor1,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      label: '',
    );
  }
}
