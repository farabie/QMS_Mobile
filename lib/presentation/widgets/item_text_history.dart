part of 'widgets.dart';

class ItemTextHistory {
  static Widget primary(String title, String subTitle, int maxLines,
      {double? width}) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: AppColor.greyColor2,
            ),
          ),
          SizedBox(
            width: width,
            child: Text(
              subTitle,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColor.defaultText,
              ),
              textAlign: TextAlign.right,
            ),
          )
        ],
      ),
    );
  }

  static Widget date({String? title, DateTime? subTitle, double? width}) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title ?? '',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: AppColor.greyColor2,
            ),
          ),
          Text(
            DateFormat('dd MMMM yyyy').format(subTitle!),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColor.defaultText,
            ),
            textAlign: TextAlign.right,
          )
        ],
      ),
    );
  }
}
