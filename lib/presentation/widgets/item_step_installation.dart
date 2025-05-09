part of 'widgets.dart';

class ItemStepInstallation {
  static Widget inactive({int? stepNumber, String? title}) {
    return Container(
      height: 35,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5), color: AppColor.disable),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            stepNumber != null && title != null
                ? "$stepNumber. $title"
                : title ?? "",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColor.greyColor2,
            ),
          ),
        ],
      ),
    );
  }

  static Widget active(
      {String? title, int? stepNumber, void Function()? onClick}) {
    return GestureDetector(
      onTap: onClick,
      child: Container(
        height: 35,
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
            border: Border.all(color: AppColor.defaultText),
            borderRadius: BorderRadius.circular(5),
            color: AppColor.activeStepColor),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              stepNumber != null && title != null
                  ? "$stepNumber. $title"
                  : title ?? "",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColor.defaultText,
              ),
            ),
            const Icon(
              size: 20,
              Icons.arrow_forward,
              color: Colors.black,
            ),
          ],
        ),
      ),
    );
  }

  static Widget createdStep(
      {int? stepNumber, String? title, void Function()? onClick}) {
    return GestureDetector(
      onTap: onClick,
      child: Container(
        height: 35,
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
            border: Border.all(color: AppColor.defaultText),
            borderRadius: BorderRadius.circular(5),
            color: AppColor.whiteColor),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              stepNumber != null && title != null
                  ? "$stepNumber. $title"
                  : title ?? "",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColor.defaultText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
