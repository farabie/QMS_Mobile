part of 'common.dart';

//Mengatur Config atau host
class URLs {
  static const host = 'https://stagingapiqms.triasmitra.com/public';

  static const hostStorage = 'https://stagingapiqms.triasmitra.com/storage';
  static String installationImage(String fileName) =>
      '$hostStorage/app/public/$fileName';
}

class UrlsDms {
  static const host = 'http://35.219.106.161:8080';
}

class UrlsIMS {
  static const host = 'https://ims.triasmitra.com';
}

class UrlsWaGateway {
  static const host =
      'https://service-chat.qontak.com/api/open/v1/broadcasts/whatsapp';
}
