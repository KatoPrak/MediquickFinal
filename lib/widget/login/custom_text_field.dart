// widget/login/custom_text_field.dart
import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String hintText;
  final bool isPassword;
  final String? Function(String?)? validator;
  final IconData? prefixIcon;
  final VoidCallback? onPrefixTap;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final Color borderColor;
  final Color iconColor;

  const CustomTextField({
    super.key,
    this.controller,
    required this.hintText,
    required this.isPassword,
    this.validator,
    this.prefixIcon,
    this.onPrefixTap,
    this.suffixIcon,
    this.onSuffixTap,
    this.borderColor = Colors.grey,
    this.iconColor = Colors.black,
  });

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _isObscured = true;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.isPassword ? _isObscured : false,
      validator: widget.validator,
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: TextStyle(color: Colors.grey[600]),

        // Kustomisasi border
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: widget.borderColor, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: widget.borderColor, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),

        // Ikon prefix (bisa untuk ikon mata atau ikon lain)
        prefixIcon:
            widget.isPassword
                ? GestureDetector(
                  onTap: () {
                    setState(() {
                      _isObscured = !_isObscured;
                    });
                  },
                  child: Icon(
                    _isObscured ? Icons.visibility : Icons.visibility_off,
                    color: widget.iconColor, // Warna ikon
                  ),
                )
                : widget.prefixIcon != null
                ? Icon(widget.prefixIcon, color: widget.iconColor)
                : null,

        // Ikon suffix (opsional, bisa digunakan untuk ikon tambahan)
        suffixIcon:
            widget.suffixIcon != null
                ? GestureDetector(
                  onTap: widget.onSuffixTap,
                  child: Icon(widget.suffixIcon, color: widget.iconColor),
                )
                : null,
      ),
    );
  }
}
