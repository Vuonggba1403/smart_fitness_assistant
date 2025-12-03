import 'package:flutter/material.dart';

typedef DialogCallback = Future<void> Function();

class CustomDialog extends StatelessWidget {
  final String title;
  final String content;
  final String okText;
  final DialogCallback? onOk;
  final Color? okColor;

  const CustomDialog({
    super.key,
    required this.title,
    required this.content,
    this.okText = "OK",
    this.onOk,
    this.okColor,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(),
      title: Text(title),
      content: Text(content),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "Huỷ",
                style: TextStyle(
                  color: Colors.red,
                  fontFamily: "OpenSans",
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                if (onOk != null) await onOk!();
                Navigator.pop(context, true);
              },
              child: Text(
                okText,
                style: TextStyle(
                  color: okColor ?? Colors.blue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
