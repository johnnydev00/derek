import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:derek/locale_provider.dart';

class AgreementInfo extends StatefulWidget {

  @override
  _AgreementInfoState createState() => _AgreementInfoState();
}

class _AgreementInfoState extends State<AgreementInfo> {
  String agreement = '';

  void getAgreement() async {
    String currentLanguage =
    Provider.of<LocaleProvider>(context, listen: false).locale.toString();
    String requestLang = currentLanguage == 'kk' ? 'kz' : currentLanguage;
    final response = await http
        .get(Uri.https('derek.edus.kz', 'slim/index.php/api/getAttachment'));

    if (response.statusCode == 200) {
      List sources = json.decode(response.body);
      setState(() {
        agreement = sources[0]['answer_name_' + requestLang];
      });
    } else {
      throw Exception('Failed to load source list');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAgreement();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.agreement),
      ),
      body: agreement == '' ? Center(child: CircularProgressIndicator()) : SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width/15, vertical: MediaQuery.of(context).size.height/40),
          child: Html(data: agreement),
        ),
      ),
    );
  }
}

