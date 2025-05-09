part of 'widgets.dart';

Widget header(BuildContext context, String title) {
  return Container(
    height: 50,
    margin: const EdgeInsets.fromLTRB(20, 50, 20, 4),
    decoration: BoxDecoration(
      color: AppColor.blueColor1,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Stack(
      children: [
        Center(
          child: Text(
            title,
            style: TextStyle(
              color: AppColor.whiteColor,
              fontWeight: FontWeight.w600,
              fontSize: 16,
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
              onClick: () => Navigator.pushReplacementNamed(context, AppRoute.dashboard),
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
              onClick: () => Navigator.pop,
              child: const Icon(Icons.search),
            ),
          ),
        ),
      ],
    ),
  );
}
