part of 'pages.dart';

class LogOutPage extends StatefulWidget {
  const LogOutPage({super.key});

  @override
  State<LogOutPage> createState() => _LogOutPageState();
}

class _LogOutPageState extends State<LogOutPage> {
  late User user;
  late int? userId;

  @override
  void initState() {
    user = context.read<UserCubit>().state;
    // userId = user.userId;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: buildItemMenu(Icons.logout, 'Logout', () {
          DInfo.dialogConfirmation(context, 'Logout', 'Yes to confirm Logout')
              .then((yes) {
            if (yes ?? false) {
              DSession.removeUser();
              context.read<UserCubit>().update(User());
              // context.read<UserDataCubit>().clearUserData();
              // context.read<LogoutCubit>().fetchUserLogout(userId!);
              // Navigator.pushNamedAndRemoveUntil(context, AppRoute.login, (route) => route.settings.name == AppRoute.dashboard);
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoute.login,
                (route) => false, // This clears all previous routes
              );
            }
          });
        }),
      ),
    );
  }

  Widget buildItemMenu(IconData icon, String title, [VoidCallback? onTap]) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 30),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColor.whiteColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: AppColor.defaultText,
              ),
            ),
            const Gap(16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: AppColor.defaultText,
                  fontSize: 16,
                ),
              ),
            ),
            Icon(
              Icons.navigate_next,
              color: AppColor.defaultText,
            ),
          ],
        ),
      ),
    );
  }
}
