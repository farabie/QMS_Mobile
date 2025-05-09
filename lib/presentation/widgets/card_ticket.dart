part of 'widgets.dart';

enum TicketType { installation, inspection, audit }

Widget cardTicket(
    {DateTime? createdAt,
    String? ttNumber,
    String? section,
    String? servicePoint,
    dynamic Function()? onClick,
    BuildContext? context}) {
  return Container(
    decoration: BoxDecoration(
      color: AppColor.whiteColor,
      borderRadius: BorderRadius.circular(10),
    ),
    margin: const EdgeInsets.only(bottom: 20),
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.event,
              color: Colors.grey,
              size: 18,
            ),
            const Gap(8),
            Text(
              DateFormat('dd MMMM yyyy').format(createdAt!),
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const Gap(12),
        Text(
          ttNumber!,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: AppColor.defaultText,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Gap(6),
        Text(
          section!,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: AppColor.textBody,
            fontSize: 14,
          ),
        ),
        const Gap(6),
        Text(
          "Service Point: $servicePoint",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: AppColor.textBody,
            fontSize: 14,
          ),
        ),
        const Gap(10),
        DButtonBorder(
          onClick: onClick,
          mainColor: Colors.white,
          radius: 10,
          borderColor: AppColor.scaffold,
          child: const Text(
            'Installation Ticket Form',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget cardTicket2({
  required DateTime createdAt,
  required String ttNumber,
  required String section,
  required String servicePoint,
  dynamic Function()? onClick,
  required BuildContext context,
}) {
  return Container(
    decoration: BoxDecoration(
      color: AppColor.whiteColor,
      borderRadius: BorderRadius.circular(10),
    ),
    margin: const EdgeInsets.only(bottom: 20),
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.event,
              color: Colors.grey,
              size: 18,
            ),
            const Gap(8),
            Text(
              DateFormat('dd MMMM yyyy').format(createdAt),
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const Gap(12),
        Text(
          ttNumber,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: AppColor.defaultText,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Gap(6),
        Text(
          section,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: AppColor.textBody,
            fontSize: 14,
          ),
        ),
        const Gap(6),
        Text(
          "Service Point: $servicePoint",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: AppColor.textBody,
            fontSize: 14,
          ),
        ),
        const Gap(10),
        DButtonBorder(
          onClick: onClick,
          mainColor: Colors.white,
          radius: 10,
          borderColor: AppColor.scaffold,
          child: const Text(
            'Inspection Ticket Form',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget cardTicket3({
  required DateTime createdAt,
  required String ttNumber,
  required String section,
  required String servicePoint,
  dynamic Function()? onClick,
  required BuildContext context,
}) {
  return Container(
    decoration: BoxDecoration(
      color: AppColor.whiteColor,
      borderRadius: BorderRadius.circular(10),
    ),
    margin: const EdgeInsets.only(bottom: 20),
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.event,
              color: Colors.grey,
              size: 18,
            ),
            const Gap(8),
            Text(
              DateFormat('dd MMMM yyyy').format(createdAt),
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const Gap(12),
        Text(
          ttNumber,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: AppColor.defaultText,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Gap(6),
        Text(
          section,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: AppColor.textBody,
            fontSize: 14,
          ),
        ),
        const Gap(6),
        Text(
          "Service Point: $servicePoint",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: AppColor.textBody,
            fontSize: 14,
          ),
        ),
        const Gap(10),
        DButtonBorder(
          onClick: onClick,
          mainColor: Colors.white,
          radius: 10,
          borderColor: AppColor.scaffold,
          child: const Text(
            'Quality Audit Ticket Form',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
      ],
    ),
  );
}
