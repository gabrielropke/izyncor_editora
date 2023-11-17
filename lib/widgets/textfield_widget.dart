import 'package:flutter/material.dart';

class textfield_widget extends StatelessWidget {
  const textfield_widget(
      {super.key,
      required this.controller,
      this.prefixIcon,
      this.suffixIcon,
      required this.obscureText,
      required this.keyboardType,
      required this.hintText, this.maxLength, this.maxLines});

  final TextEditingController controller;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final String hintText;
  final int? maxLength;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLength: maxLength,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 17,
      ),
      obscureText: obscureText,
      decoration: InputDecoration(
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color.fromARGB(255, 243, 243, 243),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(13)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.white)),
        contentPadding: const EdgeInsets.fromLTRB(20, 10, 10, 10),
        hintText: hintText,
        hintStyle: const TextStyle(
            color: Color.fromARGB(255, 189, 185, 185),
            fontWeight: FontWeight.w400),
      ),
    );
  }
}
