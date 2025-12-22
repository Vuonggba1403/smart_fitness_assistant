import 'package:flutter/material.dart';
import 'bubble_triangle_painter.dart';

class MessageBubble extends StatelessWidget {
  final String text;

  const MessageBubble({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// 🟣 Avatar (FIXED SIZE)
        const CircleAvatar(
          radius: 20,
          backgroundColor: Color(0xFFBB86FC),
          child: Padding(
            padding: EdgeInsets.all(4),
            child: Image(image: AssetImage("assets/img/kitty.png")),
          ),
        ),

        const SizedBox(width: 8),

        /// 🔵 Bubble (MUST BE FLEXIBLE)
        Expanded(
          child: Stack(
            children: [
              /// Bubble body
              Container(
                margin: const EdgeInsets.only(left: 6),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3494E6), Color(0xFFec6ead)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  text,
                  softWrap: true,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              /// Bubble arrow
              Positioned(
                left: 0,
                top: 14,
                child: CustomPaint(
                  size: const Size(6, 16),
                  painter: BubbleTrianglePainter(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
