import 'package:flutter/material.dart';
import 'package:smart_fitness_assistant/core/functions/colo_extension.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    required this.title,
    this.onMoreTap,
    this.showBackButton = true, // 🔹 Mặc định có nút back
  });

  final String title;
  final Function()? onMoreTap;
  final bool showBackButton; // 🔹 Dùng để ẩn/hiện nút back

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: TColor.white,
      centerTitle: true,
      elevation: 0,
      leading: showBackButton
          ? InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                margin: const EdgeInsets.all(8),
                height: 40,
                width: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: TColor.lightGray,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Image.asset(
                  "assets/img/black_btn.png",
                  width: 15,
                  height: 15,
                  fit: BoxFit.contain,
                ),
              ),
            )
          : const SizedBox(), // 🔹 Không hiển thị nếu false
      title: Text(
        title,
        style: TextStyle(
          color: TColor.black,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        InkWell(
          onTap: onMoreTap, // 🔹 Cho phép xử lý tuỳ chọn
          child: Container(
            margin: const EdgeInsets.all(8),
            height: 40,
            width: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: TColor.lightGray,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Image.asset(
              "assets/img/more_btn.png",
              width: 15,
              height: 15,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
