import 'package:flutter/material.dart';

class CustomTF extends StatelessWidget {

  final bool securePassword;
  final String hintText;
  final IconButton? suffixButton;
  final void Function(String)? onChanged;

  CustomTF(
      {required this.securePassword,
        required this.hintText,
        this.suffixButton,
        this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      autocorrect: false,
      onChanged: onChanged,
      keyboardType: TextInputType.visiblePassword,
      maxLines: 1,
      obscureText: securePassword,
      decoration: InputDecoration(
        labelText: hintText,
        suffix: suffixButton,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide(
            color: Colors.grey,
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2.0,
          ),
        ),
      ),
    );
  }
}
