import 'dart:convert';

import 'package:derek/custom_widgets/custom_drawer.dart';
import 'package:derek/information_detail_screen.dart';
import 'package:derek/locale_provider.dart';
import 'package:derek/new_statement_screen.dart';
import 'package:derek/user_agreement_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'models/information_model.dart';
import 'package:provider/provider.dart';

class InformationScreen extends StatefulWidget {
  @override
  _InformationScreenState createState() => _InformationScreenState();
}

class _InformationScreenState extends State<InformationScreen> {
  var _allEvents = [];

  bool snackEnable = true;

  void showSnack(String str) {
    if(snackEnable) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(str), duration: Duration(seconds: 1),));
      snackEnable = false;
    }

    Future.delayed(const Duration(seconds: 2), () {
      snackEnable = true;
    });
  }

  void getInfo() async {
    String defineLanguage = Provider.of<LocaleProvider>(context, listen: false).locale.toString();
    String currentLanguage = defineLanguage == 'en' ? 'ru' : defineLanguage;
    final response = await http.post(Uri.https('derek.edus.kz', 'slim/index.php/api/getNews'), body: {'lang': currentLanguage});
    if (response.statusCode == 200) {
      List sources = json.decode(response.body);
      setState(() {
        _allEvents.addAll(sources.map((source) => new InformationModel.fromJson(source)).toList());
      });
    } else {
      throw Exception('Failed to load source list');
    }
  }

  void addStatement() {
    final provider = Provider.of<LocaleProvider>(context, listen: false);
    if(provider.getCurrentUser.email == null) {
        showSnack(AppLocalizations.of(context)!.signInToWrite);
    } else {
      if(provider.getCurrentUser.userAgreement == '0000-00-00 00:00:00') {
        _awaitReturnValueFromSecondScreen(context);
      } else {
        Navigator.push(context, MaterialPageRoute(builder: (context)=>NewStatementScreen()));
      }
    }
  }

  void _awaitReturnValueFromSecondScreen(BuildContext context) async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (context)=>UserAgreementScreen()));
    if(result != null && result != '0000-00-00 00:00:00') {
      Navigator.push(context, MaterialPageRoute(builder: (context)=>NewStatementScreen()));
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getInfo();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.informationTitle),
      ),
      drawer: CustomDrawer(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.edit_rounded),
        onPressed: () {
          addStatement();
        },
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: _allEvents.isEmpty ? Center(child: CircularProgressIndicator()) : ListView.builder(
        padding: EdgeInsets.all(width/20),
          itemCount: _allEvents.length,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => InformationDetail(infoItem: _allEvents[index])));
              },
              child: _customContainer(context, _allEvents[index].newsTitle, _allEvents[index].newsDate, _allEvents[index].newsImage),
            );
          }
      ),
    );
  }

  Container _customContainer(BuildContext context, String newsTitle, String newsDate, String imageUrl) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    var containerHeight = MediaQuery.of(context).size.height/7;

    return Container(
      margin: EdgeInsets.symmetric(vertical: height/100),
      height: containerHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).accentColor,
        borderRadius: BorderRadius.circular(5)
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: width/3,
            height: containerHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
                image: imageUrl != 'http://derek.edus.kz/images/default.jpg' ? DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover
                ) : null
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Container(
                    child: Padding(
                      padding: EdgeInsets.all(width/40),
                      child: Text(newsTitle, textAlign: TextAlign.left, style: TextStyle(
                          color: Colors.white
                      ),),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(width/100),
                  child: Text(newsDate, style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12
                  ),),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
