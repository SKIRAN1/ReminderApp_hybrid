import 'package:flutter/material.dart';

import '../helpers/constants.dart';

class TextFieldContainer extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final String? Function(String?) validator;
  final bool obscureText;

  const TextFieldContainer({
    required this.controller,
    required this.labelText,
    required this.hintText,
    required this.validator,
    this.obscureText = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Text(
            labelText,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          width: double.infinity,
          child: TextFormField(
            obscureText: obscureText,
            controller: controller,
            textInputAction: obscureText? TextInputAction.done:TextInputAction.next,
            decoration: InputDecoration(
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Color(0xFF9CA3AF)),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Color(0xFF9CA3AF)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Color(0xFF9CA3AF)),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Color(0xFF9CA3AF)),
              ),
              fillColor:  Colors.white,
              filled: true,
              hintText: hintText,
              hintStyle: const TextStyle(
                fontFamily: fontFamily1,
                color: Color(0xFF9CA3AF),
              ),
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }
}
