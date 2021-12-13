import 'package:derek/custom_widgets/custom_outlined_button.dart';
import 'package:derek/custom_widgets/custom_textformfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:derek/locale_provider.dart';
import 'package:provider/provider.dart';

class ChangePasswordScreen extends StatefulWidget {
  final String userId;

  ChangePasswordScreen({required this.userId});

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final myKey = GlobalKey<
      FormState>(); //Key for changing state of view when user enters incorrect password or login

  bool onceError = false;
  String currentPassword = '';
  String newPassword = '';
  bool isLoading = false;

  bool checkValid() {
    final isValid = myKey.currentState!.validate();
    if(isValid) {
      myKey.currentState!.save();
      setState(() {
        onceError = false;
      });
      return true;
    } else {
      if(!onceError) {
        setState(() {
          onceError = true;
        });
      }
      return false;
    }
  }

  void changePassword() async {
    final provider = Provider.of<LocaleProvider>(context, listen: false);
    String defineLanguage = provider.locale.toString();
    String currentLanguage = defineLanguage == 'kk' ? 'kz' : defineLanguage;

    setState(() {
      isLoading = true;
    });
    final response = await http.post(Uri.https('derek.edus.kz', '/slim/index.php/api/changePassword'), body: {
      'user_id': widget.userId,
      'tekuwi_password': currentPassword,
      'new_password': newPassword
    });
    if (response.statusCode == 200) {
      setState(() {
        isLoading = false;
      });
      List sources = json.decode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(sources[0]['answer_name_'+currentLanguage])));
      if(sources[0]['answer_id'] == '6' || sources[0]['answer_type'] == 'success_change_password') {
        Navigator.pop(context);
      }
    } else {
      throw Exception('Failed to load source list');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.changePassword),
      ),
      body: Form(
        key: myKey,
        autovalidateMode:
        onceError ? AutovalidateMode.onUserInteraction : null,
        child: ListView(
          padding: EdgeInsets.all(20),
          children: [
            SizedBox(
              height: 30,
            ),
            CustomTextFieldForm(securePassword: true, hintText: AppLocalizations.of(context)!.currentPassword,
              validator: (val) {
                if (val == '') {
                  return AppLocalizations.of(context)!.fillPassword;
                } else if (val!.isNotEmpty && val.length < 8) {
                  return AppLocalizations.of(context)!
                      .minPassCharacter;
                } else {
                  return null;
                }
              },
              onSaved: (value) {
                currentPassword = value!;
              },),
            SizedBox(
              height: 50,
            ),
            CustomTextFieldForm(securePassword: false, hintText: AppLocalizations.of(context)!.newPassword, validator: (val) {
              if (val == '') {
                return AppLocalizations.of(context)!.fillPassword;
              } else if (val!.isNotEmpty && val.length < 8) {
                return AppLocalizations.of(context)!
                    .minPassCharacter;
              } else {
                return null;
              }
            },
              onSaved: (value) {
                newPassword = value!;
              },),
            SizedBox(
              height: 100,
            ),
            isLoading ? LinearProgressIndicator() : CustomButton(title: AppLocalizations.of(context)!.changeButton, onPressed: () {
              if(checkValid()) {
                changePassword();
              }
            })
          ],
        ),
      )
    );
  }
}
