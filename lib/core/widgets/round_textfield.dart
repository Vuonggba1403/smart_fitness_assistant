import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_fitness_assistant/core/theme/ui/app_theme.dart';
import 'package:smart_fitness_assistant/locale/locale_key.dart';
import '../functions/colo_extension.dart';

class RoundTextField extends StatefulWidget {
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final String hintText;
  final String iconPath; // đường dẫn icon prefix
  final bool isPassword;
  final Widget? rightIcon;
  final EdgeInsets? margin;

  const RoundTextField({
    super.key,
    required this.hintText,
    required this.iconPath,
    this.controller,
    this.margin,
    this.keyboardType,
    this.isPassword = false,
    this.rightIcon,
  });

  @override
  State<RoundTextField> createState() => _RoundTextFieldState();
}

class _RoundTextFieldState extends State<RoundTextField> {
  bool _obscure = false;

  @override
  void initState() {
    super.initState();
    _obscure = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color;
    return Container(
      margin: widget.margin,
      decoration: BoxDecoration(
        color: theme.textFieldDecoration.color,
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextFormField(
        controller: widget.controller,
        keyboardType: widget.keyboardType,
        obscureText: _obscure,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "${LocaleKey.permissionMessage.tr}";
          }
          return null;
        },
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            vertical: 15,
            horizontal: 15,
          ),
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          hintText: widget.hintText,
          hintStyle: TextStyle(
            color: textColor?.withOpacity(0.7),
            fontSize: 12,
          ),
          prefixIcon: Container(
            alignment: Alignment.center,
            width: 20,
            height: 20,
            child: Image.asset(
              widget.iconPath,
              width: 20,
              height: 20,
              fit: BoxFit.contain,
              color: textColor?.withOpacity(0.7),
            ),
          ),
          suffixIcon: widget.isPassword
              ? IconButton(
                  icon: Icon(
                    _obscure ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscure = !_obscure;
                    });
                  },
                )
              : widget.rightIcon,
        ),
      ),
    );
  }
}
