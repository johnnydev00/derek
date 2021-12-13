import 'package:flutter/material.dart';

class CustomTextFieldForm extends StatelessWidget {
  final bool securePassword;
  final String hintText;
  final IconButton? suffixButton;
  final void Function(String?)? onSaved;
  final String? Function(String?)? validator;

  CustomTextFieldForm({required this.securePassword,
    required this.hintText,
    this.suffixButton,
    this.onSaved, this.validator});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autocorrect: false,
      onSaved: onSaved,
      validator: validator,
      maxLines: 1,
      keyboardType: TextInputType.visiblePassword,
      obscureText: securePassword,
      decoration: InputDecoration(
        hintText: hintText,
        suffix: suffixButton,
        errorStyle: TextStyle(color: Colors.red),
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

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide(
            color: Colors.red,
            width: 2.0,
          ),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide(
            color: Colors.red,
            width: 2.0,
          ),
        ),
      ),
    );
  }
}
