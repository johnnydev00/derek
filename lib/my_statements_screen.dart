import 'package:derek/statement_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:derek/locale_provider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:derek/models/statement_model.dart';

class MyStatementsScreen extends StatefulWidget {

  @override
  _MyStatementsScreenState createState() => _MyStatementsScreenState();
}

class _MyStatementsScreenState extends State<MyStatementsScreen> {
  List<StatementModel> myStatements = [];
  bool isLoading = true;

  void getStatements() async{

    final provider = Provider.of<LocaleProvider>(context, listen: false);

    String defineLanguage = provider.locale.toString();
    String currentLanguage = defineLanguage == 'kk' ? 'kz' : defineLanguage;

    if(provider.getCurrentUser.id != null) {
      String userId = provider.getCurrentUser.id.toString();

      final response = await http.post(Uri.https('derek.edus.kz', '/slim/index.php/api/getMymessages'), body: {
        'message_user_id': userId,
        'all': 'true'
      });

      if (response.statusCode == 200) {
        List sources = json.decode(response.body);
        print(sources);
        sources.forEach((element) {
          if(element['message_title'] != 'null' && element['message_title'] != null) {
            StatementModel temp = StatementModel(id: element['message_id'], title: element['message_title'], date: element['message_date_reg'], status: element['message_status_name_'+currentLanguage], location: element['punkt_name_'+currentLanguage], organization: element['org_name_'+currentLanguage]);
            myStatements.add(temp);
          }
        });
        setState(() {
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load source list');
      }
    }
  }

  void _awaitReturnValueFromSecondScreen(BuildContext context, StatementModel statementModel) async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StatementDetailScreen(selectedStatement: statementModel),
        ));

    if(result != null) {
      var deletedItem = result;
      setState(() {
        myStatements.removeWhere((element) => element.id == deletedItem);
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getStatements();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.personalStatements),
      ),
      body: isLoading ? Center(child: CircularProgressIndicator(),) : SafeArea(
        child: myStatements.isEmpty ? Center(child: Text(AppLocalizations.of(context)!.emptyStatements),) : ListView.builder(
            itemCount: myStatements.length,
            padding: EdgeInsets.all(MediaQuery.of(context).size.width/10),
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: () {
                  _awaitReturnValueFromSecondScreen(context, myStatements[index]);
                },
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).accentColor,
                          borderRadius: BorderRadius.circular(5)
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            padding: EdgeInsets.all(MediaQuery.of(context).size.width/20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(myStatements[index].title.toString(), textAlign: TextAlign.left, style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20
                                ),),
                                SizedBox(
                                  height: MediaQuery.of(context).size.width/10,
                                ),
                                Text('${myStatements[index].location}, ${myStatements[index].organization}', textAlign: TextAlign.left, style: TextStyle(
                                    color: Colors.white
                                ),),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.width/10,
                          ),

                          Container(
                            padding: EdgeInsets.all(MediaQuery.of(context).size.width/30),
                            decoration: BoxDecoration(
                                color: Colors.white54,
                                borderRadius: BorderRadius.circular(5)
                            ),
                            child:
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(myStatements[index].status.toString(), style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor
                                ),),
                                Text(myStatements[index].date.toString(), style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 12
                                ),)
                              ],),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.width/10,
                    ),
                  ],
                ),
              );
            }
        ),
      ),
    );
  }
}
