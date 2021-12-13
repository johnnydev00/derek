import 'package:derek/change_password_screen.dart';
import 'package:derek/custom_widgets/custom_outlined_button.dart';
import 'package:derek/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:derek/locale_provider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isLoading = true;

  String regDate = '';
  String cityName = '';

  void getUserInfo() async {
    final provider = Provider.of<LocaleProvider>(context, listen: false);
    String defineLanguage = provider.locale.toString();
    String currentLanguage = defineLanguage == 'kk' ? 'kz' : defineLanguage;
    final response = await http.post(
        Uri.https('derek.edus.kz', '/slim/index.php/api/user_account'),
        body: {'user_id': provider.getCurrentUser.id});
    if (response.statusCode == 200) {
      List sources = json.decode(response.body);
      regDate = sources[0]['user_date_reg'];
      cityName = sources[0]['punkt_name_' + currentLanguage];
      setState(() {
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load source list');
    }
  }

  void deleteUser() async {
    final provider = Provider.of<LocaleProvider>(context, listen: false);
    String defineLanguage = provider.locale.toString();
    String currentLanguage = defineLanguage == 'kk' ? 'kz' : defineLanguage;
    final response = await http.post(
        Uri.https('derek.edus.kz', '/slim/index.php/api/user_account_delete'),
        body: {'user_id': provider.getCurrentUser.id});
    if (response.statusCode == 200) {
      provider.exitUser();
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => WelcomeScreen()),
          (Route<dynamic> route) => false);
    } else {
      throw Exception('Failed to load source list');
    }
  }

  showAlertDialog(BuildContext context) {
    Widget cancelButton = TextButton(
      child: Text(AppLocalizations.of(context)!.cancelButton),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child: Text(
        AppLocalizations.of(context)!.confirmDelete,
        style: TextStyle(color: Colors.red),
      ),
      onPressed: () {
        Navigator.pop(context);
        deleteUser();
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text(AppLocalizations.of(context)!.warningAlert),
      content: Text(AppLocalizations.of(context)!.deleteUserAlert),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LocaleProvider>(context, listen: false);
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height -
        AppBar().preferredSize.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.personalInformation),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              padding: EdgeInsets.all(10),
              width: width,
              height: height,
              child: Column(
                children: [
                  Card(
                      child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 30),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CircleAvatar(
                                child: Text(
                                  provider.getCurrentUser.name.toString()[0],
                                  style: TextStyle(fontSize: 25),
                                ),
                                radius: 30,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: width/2,
                                    child: Text('${provider.getCurrentUser.name.toString()} ${provider.getCurrentUser.surname.toString()}',textAlign: TextAlign.left, style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold
                                    ),),
                                  ),

                                  Text(''),
                                  Text(
                                      provider.getCurrentUser.email.toString()),
                                ],
                              ),
                            ],
                          ))),
                  ListTile(
                    title: Text(AppLocalizations.of(context)!.creationDate),
                    subtitle: Text(regDate),
                  ),
                  ListTile(
                    title: Text(AppLocalizations.of(context)!.location),
                    subtitle: Text(cityName),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      CustomButton(
                          title: AppLocalizations.of(context)!.changePassword,
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ChangePasswordScreen(
                                          userId: provider.getCurrentUser.id!,
                                        )));
                          }),
                      CustomButton(
                          title: AppLocalizations.of(context)!.deleteAccount,
                          onPressed: () {
                            showAlertDialog(context);
                          }),
                    ],
                  )
                ],
              )),
    );
  }
}
