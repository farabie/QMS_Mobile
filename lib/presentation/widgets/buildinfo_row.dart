part of 'widgets.dart';

Widget buildInfoRow(String iconPath, String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      children: [
        Image.asset(
          iconPath,
          width: 16,
          height: 16,
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            overflow: TextOverflow.ellipsis,
            fontSize: 10,
          ),
        ),
      ],
    ),
  );
}