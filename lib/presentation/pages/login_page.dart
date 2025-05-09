part of 'pages.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  login(String username, String password, BuildContext context) {
    UserSource.login(username, password).then((result) {
      if (result == null) {
        AppInfo.failed(context, 'Login Failed');
      } else {
        AppInfo.sucess(context, 'Login Success');
        DSession.setUser(result.toJson());
        Navigator.pushReplacementNamed(
          context,
          AppRoute.dashboard,
          arguments: 0,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final edtUsername = TextEditingController();
    final edtPassword = TextEditingController();
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(0),
        children: [
          buildHeader(),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                DInput(
                  controller: edtUsername,
                  fillColor: Colors.white,
                  radius: BorderRadius.circular(10),
                  hint: 'Username',
                ),
                const SizedBox(height: 20),
                DInputPassword(
                  controller: edtPassword,
                  fillColor: Colors.white,
                  radius: BorderRadius.circular(10),
                  hint: 'Password',
                ),
                const SizedBox(
                  height: 20,
                ),
                AppButton.primary(
                  title: 'LOGIN',
                  onClick: () {
                    login(edtUsername.text, edtPassword.text, context);
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  AspectRatio buildHeader() {
    return AspectRatio(
      aspectRatio: 0.8,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/login_images.png',
            ),
          ),
          Positioned.fill(
            top: 300,
            bottom: 45,
            child: DecoratedBox(
              decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                AppColor.scaffold,
                Colors.transparent,
              ])),
            ),
          ),
          Positioned.fill(
            left: 20,
            right: 30,
            bottom: 0,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Image.asset(
                  'assets/logos/logo_login.png',
                  height: 120,
                  width: 120,
                ),
                const SizedBox(
                  width: 20,
                ),
                RichText(
                  text: TextSpan(
                    text: 'Quality Monitoring\n',
                    style: TextStyle(
                      color: AppColor.defaultText,
                      fontSize: 20,
                      height: 1.4,
                      fontWeight: FontWeight.w400,
                    ),
                    children: const [
                      TextSpan(
                        text: 'Sistem ',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.w400),
                      ),
                      TextSpan(
                        text: '(QMS)',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
