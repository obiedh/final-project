import 'package:flutter/material.dart';

class CheckboxItem extends StatefulWidget {
  const CheckboxItem(
      {Key? key,
      required this.title,
      required this.initialState,
      required this.onChanged})
      : super(key: key);

  final String title;
  final bool initialState;
  final ValueChanged<bool> onChanged;

  @override
  _CheckboxItemState createState() => _CheckboxItemState();
}

class _CheckboxItemState extends State<CheckboxItem> {
  late bool isChecked;

  @override
  void initState() {
    super.initState();
    isChecked = widget.initialState;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: isChecked,
          onChanged: (bool? value) {
            setState(() {
              isChecked = value!;
              widget.onChanged(isChecked);
            });
          },
        ),
        Text(widget.title),
      ],
    );
  }
}
