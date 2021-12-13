import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:derek/locale_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class HotlinesScreen extends StatefulWidget {
  @override
  _HotlinesScreenState createState() => _HotlinesScreenState();
}

class _HotlinesScreenState extends State<HotlinesScreen> {
  Map<String, List> allPhones = {};

  void getPhones() async {
    String currentLanguage =
        Provider.of<LocaleProvider>(context, listen: false).locale.toString();
    final response = await http
        .get(Uri.https('derek.edus.kz', 'slim/index.php/api/getPhones'));
    if (response.statusCode == 200) {
      List sources = json.decode(response.body);
      setState(() {
        sources.forEach((element) {
          List<String> numbers = [];
          String requestLang = currentLanguage == 'kk' ? 'kz' : currentLanguage;
          element['phones'].forEach((element) {
            numbers.add(element['phones_numbers_text']);
          });
          allPhones[element['phones_name_' + requestLang]] = numbers;
        });
      });
    } else {
      throw Exception('Failed to load source list');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPhones();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.hotlines),
        ),
        body: allPhones.isEmpty
            ? Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    Image(
                      image: AssetImage('images/phone_gray.png'),
                    ),
                    ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: allPhones.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Column(
                            children: [
                              Html(data: allPhones.keys.elementAt(index)),
                              _numberElement(allPhones[allPhones.keys.elementAt(index)]!),
                              (allPhones.length-1) == index ? Text('') : Divider(),
                            ],
                          );
                        }),
                  ],
                ),
              ));
    }

  Padding _numberElement(List<dynamic> numbers) {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.width / 20),
      child: ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: numbers.length,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: ListTile(
                title: Text(
                  numbers[index],
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                trailing: FloatingActionButton(
                  heroTag: null,
                  child: Icon(Icons.phone),
                  onPressed: () {
                    launch('tel://${numbers[index]}');
                  },
                ),
              ),
            );
          }),
    );
  }
}

