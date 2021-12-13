import 'package:flutter/material.dart';
import 'package:derek/l10n/l10n.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:derek/models/user_model.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = Locale('ru');
  List<String> _allLanguages = ['English', 'Қазақша', 'Русский'];
  UserModel _currentUser = UserModel();
  bool _allInformationLoaded = false;

  Locale get locale => _locale;
  List<String> get getAllLanguages => _allLanguages;
  UserModel get getCurrentUser => _currentUser;
  bool get allLoaded => _allInformationLoaded;

  LocaleProvider() {
    getSavedLang();
  }

  void setLocale(Locale locale) async {
    if (!L10n.all.contains(locale)) return;

    if(_locale != locale) {
      _locale = locale;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('language', L10n.all.indexOf(locale));
      notifyListeners();
    }
  }

  void setUser(String id, String email, String name, String surname, String agreement) async{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('id', id);
      await prefs.setString('email', email);
      await prefs.setString('name', name);
      await prefs.setString('surname', surname);
      await prefs.setString('agreement', agreement);
      _currentUser.id = id;
      _currentUser.email = email;
      _currentUser.name = name;
      _currentUser.surname = surname;
      _currentUser.userAgreement = agreement;
  }

  void exitUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('id');
    await prefs.remove('email');
    await prefs.remove('name');
    await prefs.remove('surname');
    await prefs.remove('agreement');
    _currentUser.id = null;
    _currentUser.email = null;
    _currentUser.name = null;
    _currentUser.surname = null;
    _currentUser.userAgreement = null;
  }

  void getSavedLang() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int savedLang = prefs.getInt('language') ?? 2;
    _currentUser.id = prefs.getString('id');
    _currentUser.email = prefs.getString('email');
    _currentUser.name = prefs.getString('name');
    _currentUser.surname = prefs.getString('surname');
    _currentUser.userAgreement = prefs.getString('agreement');
    setLocale(L10n.all[savedLang]);
  }
}
