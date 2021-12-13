import 'package:derek/about_project_screen.dart';
import 'package:derek/agreement_info_screen.dart';
import 'package:derek/hotlines_screen.dart';
import 'package:derek/information_screen.dart';
import 'package:derek/main.dart';
import 'package:derek/profile_screen.dart';
import 'package:derek/my_statements_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:derek/locale_provider.dart';
import 'package:derek/l10n/l10n.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:derek/models/user_model.dart';

class CustomDrawer extends StatelessWidget {

  void changeLanguage(int index, BuildContext context) async {
    final provider = Provider.of<LocaleProvider>(context, listen: false);
    provider.setLocale(L10n.all[index]);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LocaleProvider>(context, listen: false);
    List<String> allLanguages =
        provider.getAllLanguages;
    final currentUser = provider.getCurrentUser;

    if (currentUser.email != '' && currentUser.email != null) {
      return _drawerPattern(context, Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ListView(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            children: [
              ListTile(
                leading: Icon(Icons.list_alt_outlined),
                title: Text(AppLocalizations.of(context)!.personalStatements),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => MyStatementsScreen()));
                },
              ),

              ListTile(
                leading: Icon(Icons.person),
                title: Text(AppLocalizations.of(context)!.personalInformation),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen()));
                },
              ),

              ListTile(
                leading: Icon(Icons.article_outlined),
                title: Text(AppLocalizations.of(context)!.informationTitle),
                  onTap: () {
                    Navigator.pop(context);
                  },
              ),
              ListTile(
                leading: Icon(Icons.call_rounded),
                title: Text(AppLocalizations.of(context)!.hotlines),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => HotlinesScreen()));
                },
              ),
              ListTile(
                leading: Icon(Icons.info_outline),
                title: Text(AppLocalizations.of(context)!.aboutProject),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AboutProjectScreen()));
                },
              ),
              ListTile(
                leading: Icon(Icons.description_outlined),
                title: Text(AppLocalizations.of(context)!.agreement),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AgreementInfo()));
                },
              ),

            ],
          ),
          Divider(),

          DropdownButton(
            icon: Icon(
              Icons.language,
              color: Colors.black12,
            ),
            hint: Text(AppLocalizations.of(context)!.changeLanguageHint),
            items: allLanguages.map((String items) {
              return DropdownMenuItem(value: items, child: Text(items));
            }).toList(),
            onChanged: (newValue) {
              changeLanguage(allLanguages.indexOf(newValue.toString()), context);
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => InformationScreen()),
                      (Route<dynamic> route) => false);
            },
          ),

          ListTile(
            leading: Icon(Icons.exit_to_app, color: Colors.red,),
            title: Text(AppLocalizations.of(context)!.exitButton),
            onTap: () {
              provider.exitUser();
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => WelcomeScreen()),
                      (Route<dynamic> route) => false);
            },
          ),

        ],
      ), currentUser);
    } else {
      return _drawerPattern(context, Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ListView(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            children: [
              ListTile(
                leading: Icon(Icons.article_outlined),
                title: Text(AppLocalizations.of(context)!.informationTitle),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.call_rounded),
                title: Text(AppLocalizations.of(context)!.hotlines),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => HotlinesScreen()));
                },
              ),
              ListTile(
                leading: Icon(Icons.info_outline),
                title: Text(AppLocalizations.of(context)!.aboutProject),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AboutProjectScreen()));
                },
              ),
              ListTile(
                leading: Icon(Icons.description_outlined),
                title: Text(AppLocalizations.of(context)!.agreement),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AgreementInfo()));
                },
              ),
            ],
          ),

          Divider(),

          DropdownButton(
            icon: Icon(
              Icons.language,
              color: Colors.black12,
            ),
            hint: Text(AppLocalizations.of(context)!.changeLanguageHint),
            items: allLanguages.map((String items) {
              return DropdownMenuItem(value: items, child: Text(items));
            }).toList(),
            onChanged: (newValue) {
              changeLanguage(allLanguages.indexOf(newValue.toString()), context);
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => InformationScreen()),
                      (Route<dynamic> route) => false);
            },
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text(AppLocalizations.of(context)!.loginButton),
            onTap: () {
              provider.exitUser();
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => WelcomeScreen()),
                      (Route<dynamic> route) => false);
            },
          ),

        ],
      ), currentUser);
    }
  }

  Drawer _drawerPattern(BuildContext context, Column column, UserModel currentUser) {
    final height = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;

    return Drawer(
        child: SafeArea(
            child: SingleChildScrollView(
                physics: ScrollPhysics(),
                child: currentUser.email == null ? Container(height: height, child: column,) : Container(
                    height: height,
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          color: Theme.of(context).primaryColor,
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(''),
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: Theme.of(context).accentColor,
                                child: Text('${currentUser.name.toString()[0]}', style: TextStyle(
                                  fontSize: 30
                                ),),
                              ),
                              Text(''),
                              Text('${currentUser.name} ${currentUser.surname}', style: TextStyle(
                                color: Colors.white
                              ),),
                              Text(''),
                              Text(currentUser.email.toString(), style: TextStyle(
                                  color: Colors.white
                              ),),
                              Text(''),
                            ],
                          ),
                        ),
                        Expanded(
                          child: column
                        )
                      ],
                    )
                )
            )
        )
    );
  }
}
