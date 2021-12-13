import 'package:derek/custom_widgets/custom_outlined_button.dart';
import 'package:derek/locale_provider.dart';
import 'package:derek/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:derek/l10n/l10n.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:derek/information_screen.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LocaleProvider(),
      builder: (context, child) {
        final provider = Provider.of<LocaleProvider>(context);

        return MaterialApp(
            debugShowCheckedModeBanner: false,
            supportedLocales: L10n.all,
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate
            ],
            locale: provider.locale,
            theme: ThemeData(primaryColor: Colors.orange[800], accentColor: Colors.blueGrey, appBarTheme: AppBarTheme(
              color: Colors.orange[800]
            )),
            home: FutureBuilder<bool>(
              future: getUser(),
              builder: (context, snapshot) {
                if(snapshot.hasData) {
                  if(snapshot.data == true) {
                    return WelcomeScreen();
                  } else {
                    return InformationScreen();
                  }
                } else {
                  return Container(color: Colors.white,);
                }
              },
            ));
      },
    );
  }

  Future<bool> getUser() async {
    var sharedPreferences = await SharedPreferences.getInstance();
    String? user = sharedPreferences.getString('email');
    return user == null;
  }
}


class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  void changeLanguage(int index) async {
    final provider = Provider.of<LocaleProvider>(context, listen: false);
    provider.setLocale(L10n.all[index]);
  }

  @override
  Widget build(BuildContext context) {
    List<String> allLanguages =
        Provider.of<LocaleProvider>(context, listen: false).getAllLanguages;
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height -
        AppBar().preferredSize.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;
    return Scaffold(
        appBar: AppBar(
          title: Text('DEREK'),
          actions: [
            Padding(
              padding: EdgeInsets.only(right: width*0.05),
              child: DropdownButtonHideUnderline(
                child: DropdownButton(
                  icon: Icon(
                    Icons.language,
                    color: Colors.white,
                  ),
                  items: allLanguages.map((String items) {
                    return DropdownMenuItem(value: items, child: Text(items));
                  }).toList(),
                  onChanged: (newValue) {
                    changeLanguage(allLanguages.indexOf(newValue.toString()));
                  },
                ),
              ),
            )
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              width: width,
              height: height,
              padding: EdgeInsets.symmetric(horizontal: width/10),
              child: Column(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(AppLocalizations.of(context)!.welcomeTitle, style: TextStyle(
                          fontSize: 30
                        ),),
                        Text(AppLocalizations.of(context)!.welcomeSubtitle1, textAlign: TextAlign.center, style: TextStyle(
                          fontSize: 18
                        ),),
                        Text(AppLocalizations.of(context)!.welcomeSubtitle2, textAlign: TextAlign.center, style: TextStyle(
                          fontSize: 18
                        ),),
                      ],
                    ),
                  ),
                  Container(
                    height: height*0.3,
                    width: width,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        CustomButton(title: AppLocalizations.of(context)!.joinButton, onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()))),
                        Text(AppLocalizations.of(context)!.orDivider),
                        TextButton(onPressed: () {
                          Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (context) => InformationScreen()),
                                  (Route<dynamic> route) => false);
                        }, child: Text(AppLocalizations.of(context)!.withoutSignIn, style: TextStyle(
                          decoration: TextDecoration.underline,
                        ),)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
