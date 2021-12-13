import 'package:derek/custom_widgets/custom_outlined_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:derek/custom_widgets/custom_textformfield.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:derek/locale_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final myKey = GlobalKey<FormState>();
  bool onceError = false; //bool for defining when user entered incorrect minimum one time

  int currentStep = 0;
  // List<String> locations = [];
  Map<String, String> locations = {};
  bool isLoading = true;
  bool snackEnable = true;

  String locationId = '';
  String name = '';
  String surname = '';
  String email = '';
  String password = '';
  String smsCode = '';
  String regAnswer = '';

  void loadingToggle() {
    setState(() {
      if(isLoading) {
        isLoading = false;
      } else {
        isLoading = true;
      }
    });
  }

  void showSnack(String str) {
    if(snackEnable) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(str), duration: Duration(milliseconds: 700),));
      snackEnable = false;
    }

    Future.delayed(const Duration(seconds: 1), () {
      snackEnable = true;
    });
  }

  void getRegions() async {
    String defineLanguage = Provider.of<LocaleProvider>(context, listen: false).locale.toString();
    String currentLanguage = defineLanguage == 'kk' ? 'kz' : defineLanguage;
    String pathToLocation = 'punkt_name_' + currentLanguage;
    final response = await http.post(Uri.https('derek.edus.kz', 'slim/index.php/api/getAllpunkt'), body: {'punkt_region_id': '1'});
    if (response.statusCode == 200) {
      List sources = json.decode(response.body);
      print(sources);
      sources.forEach((element) {
        setState(() {
          // locations.add(element[pathToLocation]);
          locations[element[pathToLocation]] = element['punkt_id'];
        });
      });
      loadingToggle();
    } else {
      throw Exception('Failed to load source list');
    }
  }
  void register(String name, String surname, String email) async {
    loadingToggle();
    String currentLang = Provider.of<LocaleProvider>(context, listen: false).locale.toString();
    final response = await http.post(Uri.https('derek.edus.kz', 'slim/index.php/api/register_new_user_to_temp'), body: {
      'user_temp_punkt_id': locationId,
      'user_temp_name': name,
      'user_temp_device_info': 'smartphone',
      'user_temp_token': 'token',
      'user_temp_surname': surname,
      'user_email': email,
      'user_temp_lang': currentLang,
      'user_temp_os': 'android'
    });
    if (response.statusCode == 200) {
      List sources = json.decode(response.body);
      if(currentLang == 'kk') {
        regAnswer = sources[0]['answer_name_kz'];
      } else {
        regAnswer = sources[0]['answer_name_' + currentLang];
      }

      loadingToggle();
      if(sources[0]['answer_id'] == '9' || sources[0]['answer_type'] == 'success_sended_pincode' || sources[0]['answer_id'] == '10') {
        incrementStep();
      } else {
        showSnack(regAnswer);
      }
    } else {
      throw Exception('Failed to load source list');
    }
  }

  void checkPinCode(String pinCode) async {
    loadingToggle();
    final response = await http.post(Uri.https('derek.edus.kz', '/slim/index.php/api/register_check_pincode'), body: {
      'user_email': email,
      'user_pincode': pinCode
    });
    if (response.statusCode == 200) {
      loadingToggle();
      List sources = json.decode(response.body);

      if(sources[0]['result'] == 'true') {
        incrementStep();
      } else {
        showSnack(AppLocalizations.of(context)!.incorrectPin);
      }
    } else {
      throw Exception('Failed to load source list');
    }
  }

  void setPassword() async {
    loadingToggle();
    final response = await http.post(Uri.https('derek.edus.kz', '/slim/index.php/api/register_set_new_password'), body: {
      'user_email': email,
      'user_password': password
    });
    if (response.statusCode == 200) {
      loadingToggle();
      List sources = json.decode(response.body);

      if(sources[0]['result'] == 'true') {
        incrementStep();
      } else {
        showSnack(AppLocalizations.of(context)!.unknownError);
      }
    } else {
      throw Exception('Failed to load source list');
    }
  }

  bool checkValid() {
    final isValid = myKey.currentState!.validate();
    if(isValid) {
      myKey.currentState!.save();
      setState(() {
        onceError = false;
      });
      return true;
    } else {
      if(!onceError) {
        setState(() {
          onceError = true;
        });
      }
      return false;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getRegions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.registrationButton),
      ),
      body: Form(
        key: myKey,
        autovalidateMode: onceError ? AutovalidateMode.onUserInteraction : null,
        child: Theme(
          data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(primary: Theme.of(context).primaryColor)
          ),
          child: Stepper(
            type: StepperType.horizontal,
            steps: getSteps(),
            currentStep: currentStep,
            controlsBuilder: (context, {onStepContinue, onStepCancel}) {
              return Row(
                children: [
                  if (currentStep > 100)
                    ElevatedButton(
                      child: Text('Next'),
                      onPressed: onStepContinue,
                    ),
                  if (currentStep > 100)
                    ElevatedButton(
                      child: Text('Cancel'),
                      onPressed: onStepCancel,
                    ),
                ],
              );
            },
          ),
        ),
      )
    );
  }

  void incrementStep() {
    if(currentStep < 4) {
      setState(() {
        currentStep++;
      });
    }
  }

  List<Step> getSteps() => [
    Step(
      state: currentStep > 0 ? StepState.complete : StepState.indexed,
      isActive: currentStep >= 0,
      title: currentStep == 0 ? Icon(Icons.location_city) : Text(''),
      content: isLoading ? LinearProgressIndicator() : SingleChildScrollView (
        physics: ScrollPhysics(),
        child: Column(
          children: [
            Text(AppLocalizations.of(context)!.enterAddress, style: TextStyle(fontSize: 22),),
            SizedBox(height: MediaQuery.of(context).size.height/30,),
            _locationsList(context, locations),
            IconButton(onPressed: () {
              if(locationId != '') {
                incrementStep();
              } else {
                showSnack(AppLocalizations.of(context)!.enterAddress);
              }
            }, icon: Icon(Icons.arrow_forward_ios))
          ],
        ),
      )
    ),

    mainStep(1, Icon(Icons.article_outlined), Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text(AppLocalizations.of(context)!.enterUserInfo, style: TextStyle(
            fontSize: 22
        ),),

        CustomTextFieldForm(securePassword: false, hintText: AppLocalizations.of(context)!.nameHint, validator: (val) {
          if(val == '') {
            return AppLocalizations.of(context)!.fillName;
          } else if(val!.length > 30) {
            return AppLocalizations.of(context)!.longName;
          } else {
            return null;
          }
        }, onSaved: (value) {
          name = value!;
        },),

        CustomTextFieldForm(securePassword: false, hintText: AppLocalizations.of(context)!.surnameHint, validator: (val) {
          if(val == '') {
            return AppLocalizations.of(context)!.fillSurname;
          } else if(val!.length > 50) {
            return AppLocalizations.of(context)!.longSurname;
          } else {
            return null;
          }
        }, onSaved: (value) {
          surname = value!;
        },),

        CustomTextFieldForm(securePassword: false, hintText: AppLocalizations.of(context)!.loginHint, validator: (val) {
          bool emailValid = RegExp(
              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
              .hasMatch(val!);
          if(val.length == 0) {
            return AppLocalizations.of(context)!.fillEmail;
          } else if(!emailValid) {
            return AppLocalizations.of(context)!.incorrectEmail;
          } else {
            return null;
          }
        }, onSaved: (value) {
          email = value!;
        },),

        isLoading ? LinearProgressIndicator() : IconButton(onPressed: () {
          if(checkValid()) {
            register(name, surname, email);
            // incrementStep();
          }
        }, icon: Icon(Icons.arrow_forward_ios))
      ],
    )),

    mainStep(2, Icon(Icons.message), Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text(AppLocalizations.of(context)!.codeSent, style: TextStyle(
            fontSize: 22
        ),),

        PinCodeTextField(appContext: context, length: 4, onChanged: (value) {
          smsCode = value;
        }, pinTheme: PinTheme(
          shape: PinCodeFieldShape.box,
          borderRadius: BorderRadius.circular(5),
          inactiveColor: Colors.grey,
          activeColor: Theme.of(context).primaryColor,
          selectedColor: Theme.of(context).accentColor,
        ), onCompleted: (value) {
          checkPinCode(value.toString());
        },),

        // CustomButton(title: AppLocalizations.of(context)!.verifyButton, onPressed: incrementStep),
        isLoading ? LinearProgressIndicator() : Text(regAnswer)
      ],
    )),

    mainStep(3, Icon(Icons.password), Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text(AppLocalizations.of(context)!.createPasswordTitle, style: TextStyle(
            fontSize: 22
        ),),
        CustomTextFieldForm(securePassword: false, hintText: AppLocalizations.of(context)!.passwordHint, validator: (val) {
          if(val == '') {
            return AppLocalizations.of(context)!.fillPassword;
          } else if(val!.isNotEmpty && val.length < 8) {
            return AppLocalizations.of(context)!.minPassCharacter;
          } else {
            return null;
          }
        }, onSaved: (value) {
          password = value!;
        },),

        isLoading ? LinearProgressIndicator() : CustomButton(title: AppLocalizations.of(context)!.verifyButton, onPressed: () {
          if(checkValid()) {
            setPassword();
          }
        })
      ],
    )),

    mainStep(4, Icon(Icons.last_page), Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text(AppLocalizations.of(context)!.successRegTitle, style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold
        ),),
        Icon(Icons.check, size: 100, color: Colors.green,),

        CustomButton(title: AppLocalizations.of(context)!.loginButton, onPressed: () => Navigator.pop(context)),
      ],
    ), customHeight: 2),
  ];

  //default values for multiple steps
  Step mainStep(int index, Icon icon, Column childColumn, {double customHeight = 1.5}) {
    return Step(
        state: currentStep > index ? StepState.complete : StepState.indexed,
        isActive: currentStep >= index,
        title: currentStep == index ? icon : Text(''),
        content: Container(
          height: MediaQuery.of(context).size.height/customHeight,
          child: childColumn
        )
    );
  }
  ListView _locationsList(BuildContext context, Map<String, String> locations) {
    return ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: locations.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                locationId = locations[locations.keys.elementAt(index)]!;
                print(locationId);
              });
            },
            child: ListTile(
              title: Text(locations.keys.elementAt(index), style: TextStyle(
                color: locationId == locations[locations.keys.elementAt(index)] ? Colors.white : Colors.black,
              ),),
              tileColor: locationId == locations[locations.keys.elementAt(index)] ? Theme.of(context).accentColor : Colors.white38,
              trailing: locationId == locations[locations.keys.elementAt(index)] ? Icon(Icons.check, color: Colors.green,) : null,
            ),
          );
        }
    );
  }
}

