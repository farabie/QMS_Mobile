part of 'widgets.dart';

Widget buildItemProgressTickets(
  String asset,
  String title,
  String dateByStatus,
  void Function()? onTap,
) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      height: 80,
      child: Row(
        children: [
          Container(
            height: 50,
            width: 6,
            decoration: BoxDecoration(
              color: AppColor.blueColor1,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
          ),
          const Gap(24),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColor.defaultText,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const Gap(6),
                Text(
                  dateByStatus,
                  style: TextStyle(
                    color: AppColor.textBody,
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),
          Image.asset(
            asset,
            height: 40,
            width: 40,
            fit: BoxFit.cover,
          ),
          const Gap(20),
        ],
      ),
    ),
  );
}
