import 'package:derek/custom_widgets/custom_outlined_button.dart';
import 'package:derek/custom_widgets/custom_textformfield.dart';
import 'package:derek/forget_password_screen.dart';
import 'package:derek/information_screen.dart';
import 'package:derek/registration_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'custom_widgets/custom_textfield.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:derek/locale_provider.dart';


class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final myKey = GlobalKey<
      FormState>(); //Key for changing state of view when user enters incorrect password or login

  bool onceError =
      false; //bool for defining when user entered incorrect minimum one time
  bool securePassword = true;
  bool isLoading = false;
  bool snackEnable = true;
  String email = '';
  String password = '';

  void showSnack(String str) {
    if(snackEnable) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(str), duration: Duration(seconds: 1),));
      snackEnable = false;
    }

    Future.delayed(const Duration(seconds: 2), () {
      snackEnable = true;
    });
  }

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

  void loadingToggle() {
    setState(() {
      if(isLoading) {
        isLoading = false;
      } else {
        isLoading = true;
      }
    });
  }

  void loginFunc(String email, String password) async {
    loadingToggle();
    final provider = Provider.of<LocaleProvider>(context, listen: false);
    String defineLanguage = provider.locale.toString();
    String currentLanguage = defineLanguage == 'kk' ? 'kz' : defineLanguage;
    final response = await http.post(Uri.https('derek.edus.kz', '/slim/index.php/api/login'), body: {
      'user_email': email,
      'user_password': password,
      'user_browser': 'smartphone',
      'user_imei': 'token',
      'user_lang': currentLanguage,
      'user_os': 'android'
    });

    if (response.statusCode == 200) {
      loadingToggle();
      List sources = json.decode(response.body);
      print(sources[0]);
      if(sources[0]['user_email'] == email) {
        provider.setUser(sources[0]['user_id'], sources[0]['user_email'], sources[0]['user_name'], sources[0]['user_surname'], sources[0]['user_date_agreement']);

        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => InformationScreen()),
                (Route<dynamic> route) => false);
      } else if(sources[0]['answer_type'] == 'error_login' || sources[0]['answer_id'] == '2'){
        showSnack(sources[0]['answer_name_'+currentLanguage]);
      } else {
        showSnack(AppLocalizations.of(context)!.unknownError);
      }
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
          title: Text(AppLocalizations.of(context)!.loginTitle),
        ),
        body: Form(
          key: myKey,
          autovalidateMode:
              onceError ? AutovalidateMode.onUserInteraction : null,
          child: SafeArea(
            child: SingleChildScrollView(
              child: Container(
                width: width,
                height: height,
                padding: EdgeInsets.symmetric(
                    horizontal: width / 10, vertical: height / 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.loginTitle,
                      style: TextStyle(fontSize: 30),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                        Text(''),
                        CustomTextFieldForm(
                          suffixButton: _suffixButton(context),
                          securePassword: securePassword,
                          hintText: AppLocalizations.of(context)!.passwordHint,
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
                            password = value!;
                          },
                        ),
                        Text(''),
                        TextButton(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => ForgetPasswordScreen()));
                            },
                            child: Text(
                                AppLocalizations.of(context)!.forgotPassword)),
                      ],
                    ),
                    isLoading ? LinearProgressIndicator() : CustomButton(
                        title: AppLocalizations.of(context)!.loginButton,
                        onPressed: () {
                          if(checkValid()) {
                            loginFunc(email, password);
                          }
                        }),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(AppLocalizations.of(context)!.haveAcc),
                        TextButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          RegistrationScreen()));
                            },
                            child: Text(AppLocalizations.of(context)!
                                .registrationButton))
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  IconButton _suffixButton(BuildContext context) {
    return IconButton(
      padding: EdgeInsets.zero,
      constraints: BoxConstraints(),
      onPressed: () {
        setState(() {
          if (securePassword) {
            securePassword = false;
          } else {
            securePassword = true;
          }
        });
      },
      icon: securePassword ? Icon(Icons.remove_red_eye) : Icon(Icons.security),
    );
  }
}
