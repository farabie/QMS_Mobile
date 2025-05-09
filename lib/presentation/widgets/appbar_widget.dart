part of 'widgets.dart';

class AppBarWidget {
  static PreferredSizeWidget primary(BuildContext context){
    return PreferredSize(
      preferredSize: const Size.fromHeight(56.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5), // Warna bayangan
              offset: const Offset(0, 3), // x = 0, y = 3
              blurRadius: 10, // blur = 10
            ),
          ],
        ),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(
                size: 24,
                Icons.notifications,
                color: Colors.black,
              ),
            ),
            const SizedBox(
              width: 24,
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, AppRoute.logout);
              },
              child: Image.asset(
                'assets/icons/ic_user.png',
                width: 24,
                height: 24,
              ),
            ),
            const SizedBox(
              width: 20,
            ),
          ],
          leading: Padding(
            padding: const EdgeInsets.only(
              left: 10,
            ),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.search,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }

  static PreferredSizeWidget secondary(String title, BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(60.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5), // Warna bayangan
              offset: const Offset(0, 3), // x = 0, y = 3
              blurRadius: 10, // blur = 10
            ),
          ],
        ),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(
              left: 10,
            ),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.black,
              ),
            ),
          ),
          title: Text(
            title,
            style: TextStyle(
              color: AppColor.defaultText,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          centerTitle: true,
        ),
      ),
    );
  }

  static PreferredSizeWidget cantBack(String title, BuildContext context,
      {required VoidCallback onBackPressed}) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(60.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5), // Warna bayangan
              offset: const Offset(0, 3), // x = 0, y = 3
              blurRadius: 10, // blur = 10
            ),
          ],
        ),
        child: AppBar(
          backgroundColor: Colors.transparent,
          // automaticallyImplyLeading: false,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(
              left: 10,
            ),
            child: IconButton(
              onPressed: onBackPressed,
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.black,
              ),
            ),
          ),
          title: Text(
            title,
            style: TextStyle(
              color: AppColor.defaultText,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          centerTitle: true,
        ),
      ),
    );
  }
}
