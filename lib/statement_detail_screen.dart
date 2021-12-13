import 'package:flutter/material.dart';
import 'package:derek/locale_provider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:derek/models/statement_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class StatementDetailScreen extends StatefulWidget {
  StatementModel selectedStatement;
  StatementDetailScreen({required this.selectedStatement});

  @override
  _StatementDetailScreenState createState() => _StatementDetailScreenState();
}

class _StatementDetailScreenState extends State<StatementDetailScreen> {
  bool isLoading = true;
  String? deletedId;

  void getMessageDetail() async {
    String defineLanguage = Provider.of<LocaleProvider>(context, listen: false).locale.toString();
    String currentLanguage = defineLanguage == 'kk' ? 'kz' : defineLanguage;

    final response = await http.post(Uri.https('derek.edus.kz', '/slim/index.php/api/getDetailMessage'), body: {
      'message_id': widget.selectedStatement.id,
    });

    if (response.statusCode == 200) {
      List sources = json.decode(response.body);
      widget.selectedStatement.text = sources[0]['message_text'];
      widget.selectedStatement.type = sources[0]['message_type_name_'+currentLanguage];
      setState(() {
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load source list');
    }
  }

  void deleteMessage() async {
    setState(() {
      isLoading = true;
    });
    String defineLanguage = Provider.of<LocaleProvider>(context, listen: false).locale.toString();
    String currentLanguage = defineLanguage == 'kk' ? 'kz' : defineLanguage;

    final response = await http.post(Uri.https('derek.edus.kz', '/slim/index.php/api/user_message_delete'), body: {
      'message_id': widget.selectedStatement.id,
    });

    if (response.statusCode == 200) {
      setState(() {
        isLoading = false;
      });
      List sources = json.decode(response.body);

      if(sources[0]['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.successfulDeleted)));
        deletedId = widget.selectedStatement.id;
        Navigator.pop(context, deletedId);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.unknownError)));
      }

    } else {
      throw Exception('Failed to load source list');

    }
  }

  showAlertDialog(BuildContext context) {
    Widget cancelButton = TextButton(
      child: Text(AppLocalizations.of(context)!.cancelButton),
      onPressed:  () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child: Text(AppLocalizations.of(context)!.confirmDelete, style: TextStyle(
        color: Colors.red
      ),),
      onPressed:  () {
        Navigator.pop(context);
        deleteMessage();
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text(AppLocalizations.of(context)!.warningAlert),
      content: Text(AppLocalizations.of(context)!.deleteAlertContent),
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
    getMessageDetail();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: EdgeInsets.only(right: MediaQuery.of(context).size.width*0.05),
            child: IconButton(onPressed: () {
              showAlertDialog(context);
            }, icon: Icon(Icons.delete)),
          )
        ],
      ),
      body: isLoading ? Center(child: CircularProgressIndicator(),) : ListView(
        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width/10),
        children: [
          ListTile(
            title: Text('${AppLocalizations.of(context)!.creationDate}:'),
            trailing: Text(widget.selectedStatement.date.toString(), style: TextStyle(
              fontWeight: FontWeight.bold
            ),),
          ),

          ListTile(
            title: Text('${AppLocalizations.of(context)!.statementType}:'),
            subtitle: Text(widget.selectedStatement.type.toString(), style: TextStyle(
                fontWeight: FontWeight.bold,
              color: Colors.black
            ),),
          ),

          ListTile(
            title: Text('${AppLocalizations.of(context)!.organization}:'),
            subtitle: Text('${widget.selectedStatement.organization.toString()} ${widget.selectedStatement.location.toString()}', style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black
            ),),
          ),

          ListTile(
            title: Text('${AppLocalizations.of(context)!.status}:'),
            trailing: Text(widget.selectedStatement.status.toString(), style: TextStyle(
                fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor
            ),),
          ),

          Card(
            child: Column(
              children: [
                Padding(padding: EdgeInsets.all(10), child: Text(widget.selectedStatement.title.toString(), style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22
                ),),),
                Padding(padding: EdgeInsets.all(10), child: Text(widget.selectedStatement.text.toString()),)
              ],
            ),
          )
        ],
      ),
    );
  }
}
