import 'package:derek/custom_widgets/custom_outlined_button.dart';
import 'package:derek/custom_widgets/custom_textformfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:derek/locale_provider.dart';

class ForgetPasswordScreen extends StatefulWidget {

  @override
  _ForgetPasswordScreenState createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {

  final myKey = GlobalKey<
      FormState>(); //Key for changing state of view when user enters incorrect password or login
  bool onceError = false;
  String email = '';
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

  void passwordRepair() async {
    setState(() {
      isLoading = true;
    });

    final provider = Provider.of<LocaleProvider>(context, listen: false);
    String defineLanguage = provider.locale.toString();
    String currentLanguage = defineLanguage == 'kk' ? 'kz' : defineLanguage;
    final response = await http.post(Uri.https('derek.edus.kz', '/slim/index.php/api/forgetPassword'), body: {
      'user_email': email
    });

    if (response.statusCode == 200) {
      List sources = json.decode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(sources[0]['answer_name_' + currentLanguage]),));

      if(sources[0]['answer_id'] == '3' || sources[0]['answer_type'] == 'forget_password') {
        Navigator.pop(context);
      }
      setState(() {
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load source list');
    }
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height -
        AppBar().preferredSize.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.passwordRecovery),
      ),
      body: Form(
        key: myKey,
        autovalidateMode: onceError ? AutovalidateMode.onUserInteraction : null,
        child: isLoading ? Center(child: CircularProgressIndicator(),) : SafeArea(
          child: SingleChildScrollView(
            child: Container(
              width: width,
              height: height,
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(AppLocalizations.of(context)!.getNewPassToEmail, style: TextStyle(
                    fontSize: 22
                  ),),
                  CustomTextFieldForm(
                    suffixButton: IconButton(
                      icon: Icon(
                        Icons.email_outlined,
                        color: Colors.black,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                      onPressed: null,
                    ),
                    securePassword: false,
                    hintText: AppLocalizations.of(context)!.loginHint,
                    validator: (value) {
                      bool emailValid = RegExp(
                          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                          .hasMatch(value!);
                      if (value.length == 0) {
                        return AppLocalizations.of(context)!.fillEmail;
                      } else if (!emailValid) {
                        return AppLocalizations.of(context)!
                            .incorrectEmail;
                      } else {
                        return null;
                      }
                    },
                    onSaved: (value) {
                      email = value!;
                    },
                  ),

                  CustomButton(title: AppLocalizations.of(context)!.sendButton, onPressed: () {
                    if(checkValid()) {
                      passwordRepair();
                    }
                  })
                ],
              ),
            ),
          ),
        ),
      )
    );
  }
}
