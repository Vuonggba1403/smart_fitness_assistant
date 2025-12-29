import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_fitness_assistant/locale/locale_key.dart';

typedef DialogCallback = Future<void> Function();

/// Custom dialog với style nhất quán
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
          children: [_buildCancelButton(context), _buildConfirmButton(context)],
        ),
      ],
    );
  }

  /// Build nút Hủy
  Widget _buildCancelButton(BuildContext context) {
    return TextButton(
      onPressed: () => Navigator.of(context).pop(),
      child: Text(
        LocaleKey.cancel.tr,
        style: TextStyle(
          color: Colors.red,
          fontFamily: "Poppins",
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Build nút Xác nhận
  Widget _buildConfirmButton(BuildContext context) {
    return TextButton(
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
    );
  }
}
