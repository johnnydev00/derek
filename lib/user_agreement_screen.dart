import 'package:derek/custom_widgets/custom_outlined_button.dart';
import 'package:flutter/material.dart';
import 'package:derek/locale_provider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_html/flutter_html.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UserAgreementScreen extends StatefulWidget {

  @override
  _UserAgreementScreenState createState() => _UserAgreementScreenState();
}

class _UserAgreementScreenState extends State<UserAgreementScreen> {

  String agreementContent = '';
  bool checkedValue = false;
  bool isLoading = false;

  void checkUserAgreement() async {
    final provider = Provider.of<LocaleProvider>(context, listen: false);
    String defineLanguage = provider.locale.toString();
    String currentLanguage = defineLanguage == 'kk' ? 'kz' : defineLanguage;
    final response = await http.post(Uri.https('derek.edus.kz', '/slim/index.php/api/checkUserAgreement'), body: {
      'user_id': provider.getCurrentUser.id
    });
    if (response.statusCode == 200) {
      List sources = json.decode(response.body);
      setState(() {
        agreementContent = sources[0]['answer_name_' + currentLanguage];
      });
    } else {
      throw Exception('Failed to load source list');
    }
  }

  void updateUserAgreement() async {
    setState(() {
      isLoading = true;
    });
    final provider = Provider.of<LocaleProvider>(context, listen: false);
    String defineLanguage = provider.locale.toString();
    String currentLanguage = defineLanguage == 'kk' ? 'kz' : defineLanguage;
    final response = await http.post(Uri.https('derek.edus.kz', '/slim/index.php/api/updateAggrement'), body: {
      'user_id': provider.getCurrentUser.id
    });
    if (response.statusCode == 200) {
      setState(() {
        isLoading = false;
      });
      provider.getCurrentUser.userAgreement = '7777-77-77 77:77:77';
      updateAgreementDate('7777-77-77 77:77:77');
      Navigator.pop(context, provider.getCurrentUser.userAgreement);
    } else {
      throw Exception('Failed to load source list');
    }
  }

  void updateAgreementDate(String agreement) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('agreement', agreement);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkUserAgreement();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.agreement),
      ),
      body: agreementContent == '' ? Center(child: CircularProgressIndicator(),) : SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width/15, vertical: MediaQuery.of(context).size.height/40),
          child: Column(
            children: [
              Html(data: agreementContent),
              SizedBox(
                height: 20,
              ),
              isLoading ? Text('') : CheckboxListTile(
                title: Text(AppLocalizations.of(context)!.agreeCheckbox),
                value: checkedValue,
                onChanged: (newValue) {
                  setState(() {
                    checkedValue = newValue!;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,  //  <-- leading Checkbox
              ),
              SizedBox(
                height: 20,
              ),

              isLoading ? LinearProgressIndicator() : CustomButton(title: AppLocalizations.of(context)!.continueButton, onPressed: () {
                if(checkedValue) {
                  updateUserAgreement();
                }
              }),

              SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
