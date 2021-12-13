import 'dart:io';

import 'package:derek/custom_widgets/custom_textfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:derek/locale_provider.dart';
import 'package:derek/models/statement_type_model.dart';
import 'package:file_picker/file_picker.dart';

class NewStatementScreen extends StatefulWidget {
  @override
  _NewStatementScreenState createState() => _NewStatementScreenState();
}

class _NewStatementScreenState extends State<NewStatementScreen> {
  List<StatementTypeModel> allStatementTypes = [];
  Map<String, String> locations = {};
  List<StatementTypeModel> allOrganizationTypes = [];
  Map<String, String> organizations = {};
  bool isLoading = true;
  List<String> filesBase64 = [];
  List<File> allFiles = [];
  List<String> allExtensions = [];
  List<int> allSizes = [];
  String messageTypeId = '';
  String locationId = '';
  String organizationTypeId = '';
  String organizationId = '';

  int currentStep = 0;

  String statementTopic = '';
  String statementContent = '';

  void incrementStep() {
    if (currentStep < 4) {
      setState(() {
        currentStep++;
      });
    }
  }

  void bottomAction() {
    showModalBottomSheet(context: context, builder: (context){
      return Container(
        height: MediaQuery.of(context).size.height/2.5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ListTile(
              leading: Icon(Icons.photo),
              title: Text('Photo'),
            ),
            ListTile(
              leading: Icon(Icons.videocam_rounded),
              title: Text('Video'),
            ),
            ListTile(
              leading: Icon(Icons.audiotrack),
              title: Text('Audio'),
            ),
            ListTile(
              leading: Icon(Icons.insert_drive_file),
              title: Text('File'),
            ),
          ],
        ),
      );
    });
  }

  void loadToggle() {
    setState(() {
      if(isLoading) {
        isLoading = false;
      } else {
        isLoading = true;
      }
    });
  }

  void getAllStatementTypes() async {
    String currentLanguage =
    Provider.of<LocaleProvider>(context, listen: false).locale.toString();
    String requestLang = currentLanguage == 'kk' ? 'kz' : currentLanguage;
    final response = await http
        .post(Uri.https('derek.edus.kz', 'slim/index.php/api/getAllMessageTypes'));
    if (response.statusCode == 200) {
      List sources = json.decode(response.body);
      sources.forEach((element) {
        StatementTypeModel statementTypeModel = StatementTypeModel(id: element['message_type_id'], title: element['message_type_name_' + requestLang], subtitle: element['message_type_text_' + requestLang]);
        allStatementTypes.add(statementTypeModel);
      });
      loadToggle();
    } else {
      throw Exception('Failed to load source list');
    }
  }

  void getRegions() async {
    loadToggle();
    String defineLanguage = Provider.of<LocaleProvider>(context, listen: false).locale.toString();
    String currentLanguage = defineLanguage == 'kk' ? 'kz' : defineLanguage;
    String pathToLocation = 'punkt_name_' + currentLanguage;
    final response = await http.post(Uri.https('derek.edus.kz', 'slim/index.php/api/getAllpunkt'), body: {'punkt_region_id': '1'});
    if (response.statusCode == 200) {
      List sources = json.decode(response.body);
      print(sources);
      sources.forEach((element) {
        locations[element[pathToLocation]] = element['punkt_id'];
      });
      loadToggle();
    } else {
      throw Exception('Failed to load source list');
    }
  }

  void getOrganizationTypes() async {
    loadToggle();
    String defineLanguage = Provider.of<LocaleProvider>(context, listen: false).locale.toString();
    String currentLanguage = defineLanguage == 'kk' ? 'kz' : defineLanguage;
    final response = await http.post(Uri.https('derek.edus.kz', 'slim/index.php/api/getAllOrgTypes'));
    if (response.statusCode == 200) {
      List sources = json.decode(response.body);
      sources.forEach((element) {
        StatementTypeModel statementTypeModel = StatementTypeModel(id: element['org_type_id'], title: element['org_type_name_' + currentLanguage], subtitle: element['org_type_text_' + currentLanguage]);
        allOrganizationTypes.add(statementTypeModel);
      });
      loadToggle();
    } else {
      throw Exception('Failed to load source list');
    }
  }

  void getAllOrganizations() async {
    loadToggle();
    String defineLanguage = Provider.of<LocaleProvider>(context, listen: false).locale.toString();
    String currentLanguage = defineLanguage == 'kk' ? 'kz' : defineLanguage;
    String pathToOrganization = 'org_name_' + currentLanguage;
    final response = await http.post(Uri.https('derek.edus.kz', 'slim/index.php/api/getAllOrgNames'), body: {
      'org_punkt_id': locationId,
      'org_org_type_id': organizationTypeId
    });
    if (response.statusCode == 200) {
      List sources = json.decode(response.body);
      print(sources);
      sources.forEach((element) {
        setState(() {
          // locations.add(element[pathToLocation]);
          organizations[element[pathToOrganization]] = element['org_id'];
          print(organizations);
        });
      });
      loadToggle();
    } else {
      throw Exception('Failed to load source list');
    }
  }

  void sendNewStatement() async {
    loadToggle();
    final provider = Provider.of<LocaleProvider>(context, listen: false);
    final response = await http.post(Uri.https('derek.edus.kz', 'slim/index.php/api/newMessage'), body: {
      'message_user_id': provider.getCurrentUser.id,
      'message_punkt_id': locationId,
      'message_type_org_id': organizationTypeId,
      'message_org_id': organizationId,
      'message_message_type_id': messageTypeId,
      'message_title': statementTopic,
      'message_text': statementContent,
      'message_file_1': filesBase64.isNotEmpty ? '${allExtensions[0]}:${allSizes[0]}:${filesBase64[0]}' : '',
      'message_file_2': filesBase64.length >= 2 ? '${allExtensions[1]}:${allSizes[1]}:${filesBase64[1]}' : '',
      'message_file_3': filesBase64.length >= 3 ? '${allExtensions[2]}:${allSizes[2]}:${filesBase64[2]}' : ''
    });
    print('this is response code!!');
    print(response.statusCode);
    print(response.body);
    if (response.statusCode == 200) {
      print(response.body);
      loadToggle();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.successSent)));
      Navigator.pop(context);
    } else if(response.statusCode == 500) {
      loadToggle();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error uploading files')));
    } else {
      throw Exception('Failed to load source list');
    }
  }

  void addFiles() async {
    if(filesBase64.length < 3) {
      List<File> tempFiles = [];
      FilePickerResult? result = await FilePicker.platform.pickFiles(
          allowMultiple: true,
          type: FileType.custom,
          allowedExtensions: ['png', 'jpg', 'jpeg', 'xlsx', 'xls', 'doc', 'docx', 'ppt', 'pptx', 'pdf']
      );
      if (result == null) return;

      if((result.paths.length + allFiles.length) <= 3) {
        tempFiles = result.paths.map((path) => File(path!)).toList();

        if(tempFiles.isNotEmpty) {
          setState(() {
            tempFiles.forEach((element) {
              allFiles.add(element);
              filesBase64.add(base64Encode(element.readAsBytesSync()));
            });
          });
          result.files.forEach((element) {
            allExtensions.add(element.extension!);
            allSizes.add(element.size);
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.maximumFilesCount)));
        return;
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.maximumFilesCount)));
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAllStatementTypes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.newStatement),
      ),
      body: Theme(
        data: Theme.of(context).copyWith(
            colorScheme:
                ColorScheme.light(primary: Theme.of(context).primaryColor)),
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
    );
  }

  List<Step> getSteps() => [
        Step(
          state: currentStep > 0 ? StepState.complete : StepState.indexed,
          isActive: currentStep >= 0,
          title: currentStep == 0 ? Icon(Icons.description_outlined) : Text(''),
          content: isLoading ? Center(child: CircularProgressIndicator(),) : ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: EdgeInsets.all(MediaQuery.of(context).size.width / 35),
              itemCount: allStatementTypes.length,
              itemBuilder: (BuildContext context, int index) {
                if (index == 0) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).size.height / 30),
                        child: Text('${AppLocalizations.of(context)!.selectStatementType}:',
                          style: TextStyle(
                            fontSize: 22,),
                        ),
                      ),
                      _statementTypeContainer(
                          allStatementTypes[index].title, allStatementTypes[index].subtitle, allStatementTypes[index].id),
                    ],
                  );
                } else {
                  return _statementTypeContainer(
                      allStatementTypes[index].title, allStatementTypes[index].subtitle, allStatementTypes[index].id);
                }
              }),
        ),
        Step(
            state: currentStep > 1 ? StepState.complete : StepState.indexed,
            isActive: currentStep >= 1,
            title: currentStep == 1 ? Icon(Icons.add_location_alt_rounded) : Text(''),
            content: isLoading ? Center(child: CircularProgressIndicator(),) : SingleChildScrollView(
              physics: ScrollPhysics(),
              child: _locationsList(context, locations),
            )),
        Step(
          state: currentStep > 2 ? StepState.complete : StepState.indexed,
          isActive: currentStep >= 2,
          title: currentStep == 2 ? Icon(Icons.school) : Text(''),
          content: isLoading ? Center(child: CircularProgressIndicator(),) : ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: EdgeInsets.all(MediaQuery.of(context).size.width / 35),
              itemCount: allOrganizationTypes.length,
              itemBuilder: (BuildContext context, int index) {
                if (index == 0) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).size.height / 30),
                        child: Text('${AppLocalizations.of(context)!.selectOrgType}',
                          style: TextStyle(
                            fontSize: 22,),
                        ),
                      ),
                      _statementTypeContainer(allOrganizationTypes[index].title,
                          allOrganizationTypes[index].subtitle, allOrganizationTypes[index].id),
                    ],
                  );
                } else {
                  return _statementTypeContainer(allOrganizationTypes[index].title,
                      allOrganizationTypes[index].subtitle, allOrganizationTypes[index].id);
                }
              }),
        ),
        Step(
            state: currentStep > 3 ? StepState.complete : StepState.indexed,
            isActive: currentStep >= 3,
            title: currentStep == 3 ? Icon(Icons.location_city) : Text(''),
            content: isLoading ? Center(child: CircularProgressIndicator(),) : SingleChildScrollView(
              physics: ScrollPhysics(),
              child: _locationsList(context, organizations),
            )),
        Step(
            state: currentStep > 4 ? StepState.complete : StepState.indexed,
            isActive: currentStep >= 4,
            title: currentStep == 4 ? Icon(Icons.last_page) : Text(''),
            content: SingleChildScrollView(
              physics: ScrollPhysics(),
              child: Column(
                children: [
                  Text(AppLocalizations.of(context)!.fillStatementData,
                    style: TextStyle(
                        fontSize: 18,),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 15,
                  ),
                  CustomTF(
                      securePassword: false, hintText: AppLocalizations.of(context)!.topic, onChanged: (value) {
                        statementTopic = value.trim();
                  },),
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 20,
                  ),

                  TextField(
                    autocorrect: false,
                    onChanged: (value) {

                      statementContent = value.trim();
                    },
                    keyboardType: TextInputType.visiblePassword,
                    minLines: 5,
                    maxLines: 100,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.statementText,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide(
                          color: Colors.grey,
                          width: 1.0,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide(
                          color: Theme.of(context).primaryColor,
                          width: 2.0,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(
                    height: MediaQuery.of(context).size.height / 20,
                  ),
                  filesBase64.isEmpty ? Text('') : Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _filesContainer(context, 0),
                        allFiles.length >= 2 ? _filesContainer(context, 1) : Text(''),
                        allFiles.length >= 3 ? _filesContainer(context, 2) : Text(''),
                      ],
                    ),
                  ),


                  SizedBox(
                    height: MediaQuery.of(context).size.height / 20,
                  ),

                  isLoading ? LinearProgressIndicator() : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FloatingActionButton(child: Icon(Icons.attach_file, color: Colors.white,), heroTag: null, backgroundColor: Theme.of(context).accentColor, onPressed: () {
                        addFiles();
                      }),
                      FloatingActionButton(child: Icon(Icons.send, color: Colors.white,),heroTag: null, backgroundColor: Theme.of(context).accentColor, onPressed: () {
                        if(statementTopic.length > 5 && statementContent.length > 10) {
                          sendNewStatement();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.fillAllLines)));
                        }
                      }
                      ),
                    ],
                  ),

                ],
              ),
            )),
      ];

  GestureDetector _statementTypeContainer(String title, String subtitle, String id) {
    return GestureDetector(
      onTap: () {
        if (currentStep == 0) {
          messageTypeId = id;
          incrementStep();
          getRegions();
        } else {
          organizationTypeId = id;
          incrementStep();
          getAllOrganizations();
        }
      },
      child: Container(
          margin:
              EdgeInsets.only(bottom: MediaQuery.of(context).size.height / 30),
          padding: EdgeInsets.all(MediaQuery.of(context).size.width / 40),
          height: MediaQuery.of(context).size.height / 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Theme.of(context).accentColor,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Icon(Icons.description_outlined),
              Expanded(
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      Container(
                        child: Flexible(
                          child: Text(
                            subtitle,
                            style: TextStyle(color: Colors.white54),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          )),
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
                if(currentStep == 1) {
                  locationId = locations[locations.keys.elementAt(index)]!;
                  getOrganizationTypes();
                } else {
                  organizationId = locations[locations.keys.elementAt(index)]!;
                }
                incrementStep();
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Theme.of(context).accentColor,
                ),
                margin: EdgeInsets.symmetric(vertical: 5),
                padding: EdgeInsets.all(20),
                child: Text(locations.keys.elementAt(index), style: TextStyle(
                    color: Colors.white,
                    fontSize: 18
                ),),
              )
          );
        });
  }

  GestureDetector _filesContainer(BuildContext context, int index) {
    bool isImage = false;
    if(allExtensions[index] == 'jpg' || allExtensions[index] == 'png' || allExtensions[index] == 'jpeg') {
      isImage = true;
    }
    return GestureDetector(
      onLongPress: () {
        setState(() {
          allFiles.removeAt(index);
          filesBase64.removeAt(index);
          allExtensions.removeAt(index);
          allSizes.removeAt(index);
        });
      },
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.holdToDelete), duration: Duration(milliseconds: 500),));
      },
      child: Container(
        width: MediaQuery.of(context).size.width/4,
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: isImage ? Colors.white12 : Colors.grey,
        ),
        child: isImage ? Image.memory(base64Decode(filesBase64[index])) : Icon(Icons.file_copy),
      ),
    );
  }
}
