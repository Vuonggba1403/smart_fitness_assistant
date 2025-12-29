import 'package:dotted_dashed_line/dotted_dashed_line.dart';
import 'package:flutter/material.dart';
import '../../../../../core/functions/color_extension.dart';

/// Widget hiển thị từng bước hướng dẫn với timeline indicator
class StepDetailRow extends StatelessWidget {
  final Map sObj;
  final bool isLast;

  const StepDetailRow({super.key, required this.sObj, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepNumber(),
        _buildTimelineIndicator(),
        const SizedBox(width: 10),
        _buildStepContent(textColor),
      ],
    );
  }

  /// Build số thứ tự bước
  Widget _buildStepNumber() {
    return SizedBox(
      width: 25,
      child: Text(
        sObj["no"].toString(),
        style: TextStyle(color: TColor.secondaryColor1, fontSize: 14),
      ),
    );
  }

  /// Build timeline indicator với chấm tròn và đường nối
  Widget _buildTimelineIndicator() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: TColor.secondaryColor1,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              border: Border.all(color: TColor.white, width: 3),
              borderRadius: BorderRadius.circular(9),
            ),
          ),
        ),
        if (!isLast)
          DottedDashedLine(
            height: 80,
            width: 0,
            dashColor: TColor.secondaryColor1,
            axis: Axis.vertical,
          ),
      ],
    );
  }

  /// Build nội dung bước (tiêu đề và chi tiết)
  Widget _buildStepContent(Color? textColor) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            sObj["title"].toString(),
            style: TextStyle(color: textColor, fontSize: 14),
          ),
          Text(
            sObj["detail"].toString(),
            style: TextStyle(color: textColor?.withOpacity(0.7), fontSize: 12),
          ),
        ],
      ),
    );
  }
}
