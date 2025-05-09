part of 'widgets.dart';

class InputWidget {
  static Widget disable(String title, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const Gap(3),
        TextFormField(
          readOnly: true,
          controller: controller,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColor.greyColor2,
          ),
          minLines: 1,
          maxLines: null,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColor.disable,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide(color: AppColor.disable)),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColor.disable)),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColor.disable)),
          ),
        ),
      ],
    );
  }

  static Widget available(
      String title, String hintText, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const Gap(3),
        SizedBox(
          height: 45,
          child: TextFormField(
            controller: controller,
            maxLines: 2,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColor.defaultText,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              filled: true,
              fillColor: AppColor.whiteColor,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide(color: AppColor.defaultText)),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColor.defaultText)),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColor.defaultText)),
            ),
          ),
        ),
      ],
    );
  }

  static Widget textArea(
      {String? title,
      String? hintText,
      TextEditingController? controller,
      FocusNode? focusNode,
      void Function(String)? onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Text(
              '* ',
              style: TextStyle(
                color: Colors.red,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              title ?? '',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const Gap(3),
        SizedBox(
          height: 100,
          child: TextFormField(
            controller: controller,
            focusNode: focusNode!,
            maxLines: 4,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColor.defaultText,
            ),
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hintText,
              filled: true,
              fillColor: AppColor.whiteColor,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide(color: AppColor.defaultText)),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColor.defaultText)),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColor.defaultText)),
            ),
          ),
        ),
      ],
    );
  }

  static Widget textAreaDisable(
      {String? title,
      String? hintText,
      TextEditingController? controller,
      FocusNode? focusNode,
      void Function(String)? onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title ?? '',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const Gap(3),
        SizedBox(
          height: 100,
          child: TextFormField(
            readOnly: true,
            controller: controller,
            focusNode: focusNode!,
            maxLines: 4,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColor.greyColor2,
            ),
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hintText,
              filled: true,
              fillColor: AppColor.disable,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide(color: AppColor.disable)),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColor.disable)),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColor.disable)),
            ),
          ),
        ),
      ],
    );
  }

  static Widget textArea2(
      String title, String hintText, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const Gap(3),
        SizedBox(
          height: 100,
          child: TextFormField(
            controller: controller,
            maxLines: 4,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColor.defaultText,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              filled: true,
              fillColor: AppColor.whiteColor,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide(color: AppColor.defaultText)),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColor.defaultText)),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColor.defaultText)),
            ),
          ),
        ),
      ],
    );
  }

  static Widget dropDown(
    String title,
    String hintText,
    String? value,
    List<String> items,
    void Function(String?)? onChanged,
    String hintTextSearch,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const Gap(3),
        SizedBox(
          height: 50,
          child: DropdownSearch<String>(
            selectedItem: value,
            items: items,
            dropdownDecoratorProps: DropDownDecoratorProps(
              dropdownSearchDecoration: InputDecoration(
                filled: true,
                fillColor: AppColor.whiteColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide(color: AppColor.defaultText),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColor.defaultText),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColor.defaultText),
                ),
              ),
            ),
            onChanged: onChanged,
            popupProps: PopupProps.dialog(
              dialogProps: DialogProps(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 8,
              ),
              showSearchBox: true,
              searchFieldProps: TextFieldProps(
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: hintTextSearch,
                  filled: true,
                  fillColor: AppColor.disable,
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColor.defaultText),
                  ),
                ),
              ),
              itemBuilder: (context, item, isSelected) {
                return Column(
                  children: [
                    ListTile(
                      title: Text(item),
                      onTap: () {
                        onChanged?.call(item);
                        Navigator.pop(context);
                      },
                    ),
                    if (item != items.last)
                      Divider(
                        color: AppColor.greyColor1,
                      ),
                  ],
                );
              },
            ),
            dropdownBuilder: (context, selectedItem) => Text(
              selectedItem ?? hintText,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColor.defaultText,
              ),
            ),
          ),
        ),
      ],
    );
  }

  static Widget dropDown2({
    String title = '',
    String hintText = '',
    String value = '',
    List<String>? items,
    void Function(String?)? onChanged,
    bool isEnabled = true,
    String hintTextSearch = '',
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const Gap(3),
        SizedBox(
          height: 50,
          child: DropdownSearch<String>(
            selectedItem: value.isEmpty ? null : value,
            items: items ?? [], // Handle null for items
            dropdownDecoratorProps: DropDownDecoratorProps(
              dropdownSearchDecoration: InputDecoration(
                filled: true,
                fillColor: AppColor.whiteColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide(color: AppColor.defaultText),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColor.defaultText),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColor.defaultText),
                ),
              ),
            ),
            onChanged: (newValue) {
              if (onChanged != null) {
                onChanged(newValue);
              }
            },
            popupProps: PopupProps.dialog(
              dialogProps: DialogProps(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 8,
              ),
              showSearchBox: true,
              searchFieldProps: TextFieldProps(
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: hintTextSearch,
                  filled: true,
                  fillColor: AppColor.disable,
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColor.defaultText),
                  ),
                ),
              ),
            ),
            dropdownBuilder: (context, selectedItem) => Container(
              alignment: Alignment.centerLeft,
              child: Text(
                selectedItem?.isNotEmpty == true ? selectedItem! : hintText,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColor.defaultText,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            enabled: isEnabled,
          ),
        ),
      ],
    );
  }

  static Widget checkboxList({
    String? title,
    List<String>? items,
    List<bool>? selectedItems,
    ValueChanged<int>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title ?? '',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Gap(3),
        for (int i = 0; i < items!.length; i++) ...[
          Transform.translate(
            offset: const Offset(-12, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Checkbox(
                  value: selectedItems![i],
                  onChanged: (bool? value) {
                    if (value != null) {
                      onChanged!(i); // Mengubah nilai checkbox yang dipilih
                    }
                  },
                  activeColor: AppColor.blueColor1,
                  checkColor: Colors.white,
                ),
                Expanded(
                  child: Text(
                    items[i],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColor.defaultText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ]
      ],
    );
  }

  static Widget checkboxEditList({
    String? title,
    required List<String>
        items, // Making items required, assuming it's always passed
    required List<bool>
        selectedItems, // Making selectedItems required, for better null-safety
    required ValueChanged<int> onChanged, // Making onChanged required
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) // Check if title is not null
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        const Gap(3),
        for (int i = 0; i < items.length; i++) ...[
          Transform.translate(
            offset: const Offset(-12, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Checkbox(
                  value: selectedItems[i],
                  onChanged: (bool? value) {
                    if (value != null) {
                      onChanged(i); // Pass index to onChanged callback
                    }
                  },
                  activeColor: AppColor.blueColor1,
                  checkColor: Colors.white,
                ),
                Expanded(
                  child: Text(
                    items[i],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColor.defaultText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ]
      ],
    );
  }

  Widget uploadFile(String title, String textButton) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const Gap(3),
        Container(
          height: 160,
          decoration: BoxDecoration(
            color: AppColor.whiteColor,
            border: Border.all(color: AppColor.defaultText),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 36,
              ),
              child: DButtonFlat(
                onClick: () {},
                height: 40,
                mainColor: AppColor.blueColor1,
                radius: 10,
                child: Text(
                  textButton,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
