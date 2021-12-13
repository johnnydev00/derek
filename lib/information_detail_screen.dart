import 'package:flutter/material.dart';
import 'package:derek/models/information_model.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class InformationDetail extends StatelessWidget {
  final InformationModel infoItem;

  InformationDetail({required this.infoItem});

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.informationTitle),
      ),
      body: ListView(
        padding: EdgeInsets.only(bottom: height/20),
        children: [
          infoItem.newsImage != 'http://derek.edus.kz/images/default.jpg' ? Image(image: NetworkImage(infoItem.newsImage!),) : Text(''),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: width/10, vertical: height/40),
            child: Text(infoItem.newsTitle!, textAlign: TextAlign.center, style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold
            ),),
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: width/20, vertical: height/40),
            child: Html(
              data: infoItem.newsText,
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: width/10),
            child: Row(
              children: [
                Icon(Icons.calendar_today),
                Text(' '),
                Text(infoItem.newsDate!)
              ],
            ),
          ),
        ],
      ),
    );
  }
}
