part of 'common.dart';

class AppInfo {
  //Menampilkan Info Jika data sukses dikirimkan
  static sucess(BuildContext context, String message) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColor.saveButton,
      ),
    );
  }

  static failed(BuildContext context, String message) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColor.pauseButton,
      ),
    );
  }
  
}
