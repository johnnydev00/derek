import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {

  final String title;
  final void Function() onPressed;

  CustomButton({required this.title, required this.onPressed});
  @override
  Widget build(BuildContext context) {
    return OutlinedButton(onPressed: onPressed, child: Text(title),
      style: OutlinedButton.styleFrom(
        primary: Theme.of(context).primaryColor,
        side: BorderSide(width: 1.0, color: Theme.of(context).primaryColor),
      ),
    );
  }
}
