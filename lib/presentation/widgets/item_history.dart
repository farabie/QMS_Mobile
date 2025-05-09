part of 'widgets.dart';

class ItemHistory {
  static Widget installation({
    String? idTicket,
    String? status,
    Color? statusColor,
    Color? textColor,
    void Function()? onTap,
    DateTime? date,
    String? createdBy,
    String? ttDms,
    String? servicePoint,
    String? sectionName,
    double? widthStatus,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 6,
                left: 6,
                right: 6,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    idTicket ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  const Gap(3),
                  Container(
                    height: 15,
                    width: widthStatus,
                    decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(10)),
                    child: Center(
                      child: Text(
                        status ?? '',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 8,
                          color: textColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              color: AppColor.divider,
            ),
            ItemTextHistory.date(title: "Date", subTitle: date),
            ItemTextHistory.primary("Created By", createdBy ?? '-', 1),
            ItemTextHistory.primary("TT DMS", ttDms ?? '-', 1),
            ItemTextHistory.primary("Service Point", servicePoint ?? '-', 1),
            ItemTextHistory.primary("Section Name", sectionName ?? '-', 2,
                width: 150),
            const Gap(12)
          ],
        ),
      ),
    );
  }

  static Widget inspection({
    String? idTicket,
    String? status,
    Color? statusColor,
    Color? textColor,
    void Function()? onTap,
    DateTime? date,
    String? createdBy,
    String? ttDms,
    String? servicePoint,
    String? sectionName,
    double? widthStatus,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 6,
                left: 6,
                right: 6,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    idTicket ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  const Gap(3),
                  Container(
                    height: 15,
                    width: widthStatus,
                    decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(10)),
                    child: Center(
                      child: Text(
                        status ?? '',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 8,
                          color: textColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              color: AppColor.divider,
            ),
            ItemTextHistory.date(title: "Date", subTitle: date),
            ItemTextHistory.primary("Created By", createdBy ?? '-', 1),
            ItemTextHistory.primary("TT DMS", ttDms ?? '-', 1),
            ItemTextHistory.primary("Service Point", servicePoint ?? '-', 1),
            ItemTextHistory.primary("Section Name", sectionName ?? '-', 2,
                width: 150),
            const Gap(12)
          ],
        ),
      ),
    );
  }

  static Widget qualityAudit({
    String? idTicket,
    String? status,
    Color? statusColor,
    Color? textColor,
    void Function()? onTap,
    DateTime? date,
    String? createdBy,
    String? ttDms,
    String? servicePoint,
    String? sectionName,
    double? widthStatus,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 6,
                left: 6,
                right: 6,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    idTicket ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  const Gap(3),
                  Container(
                    height: 15,
                    width: widthStatus,
                    decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(10)),
                    child: Center(
                      child: Text(
                        status ?? '',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 8,
                          color: textColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              color: AppColor.divider,
            ),
            ItemTextHistory.date(title: "Date", subTitle: date),
            ItemTextHistory.primary("Created By", createdBy ?? '-', 1),
            ItemTextHistory.primary("TT DMS", ttDms ?? '-', 1),
            ItemTextHistory.primary("Service Point", servicePoint ?? '-', 1),
            ItemTextHistory.primary("Section Name", sectionName ?? '-', 2,
                width: 150),
            const Gap(12)
          ],
        ),
      ),
    );
  }
}
