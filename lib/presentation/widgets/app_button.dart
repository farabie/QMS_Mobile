part of 'widgets.dart';

class AppButton {
  static Widget primary({String? title, void Function()? onClick}) {
    return DButtonFlat(
      onClick: onClick,
      height: 40,
      mainColor: AppColor.blueColor1,
      radius: 10,
      child: Text(
        title ?? '',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600
        ),
      ),
    );
  }
}
