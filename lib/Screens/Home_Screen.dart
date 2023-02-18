import 'dart:io';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:language_picker/language_picker_dialog.dart';
import 'package:language_picker/languages.dart';
import 'package:share_plus/share_plus.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:sqflite/sqflite.dart';
import 'package:toast/toast.dart';
import 'package:translator/translator.dart';
import '../main.dart';
import 'DbHelper.dart';
import 'History_Screen.dart';

class Home_Screen extends StatefulWidget {
  // const Home_Screen({Key? key}) : super(key: key);

  Map? m;

  Home_Screen({this.m});

  @override
  State<Home_Screen> createState() => _Home_ScreenState();
}

Language _selectedDialogLanguage = Languages.english;
Language _selectedDialogLanguage2 = Languages.hindi;

final TextEditingController mycontroller = TextEditingController();
final translator = GoogleTranslator();
String? translated_text;

// Image to TExt --------------//
bool textScanning = false;

XFile? imageFile;

String scannedText = "";

// Image to TExt --------------//

bool _isswitch = false;

class _Home_ScreenState extends State<Home_Screen> {
  bool isSpeaking = false;
  bool isSpeaking1 = false;
  final _flutterTts = FlutterTts();
  final _flutterTts1 = FlutterTts();
  bool firstp = false;
  bool isload = false;

  /////////////////////// SPEECH TO TEXT

  SpeechToText _speechToText = SpeechToText();
  String translated = "";
  bool _speechEnabled = false;

  ///////////////////////

  // Mic To text

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    setState(() {});
    await _speechToText.listen(onResult: _onSpeechResult);
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      mycontroller.text = result.recognizedWords;
    });
  }

  //------------------ language Picker ---------------------//
  Widget _buildDialogItem(Language language) => Row(
        children: <Widget>[
          const SizedBox(
            width: 8.0,
          ),
          Text(language.name),
        ],
      );

  void _openLanguagePickerDialog() => showDialog(
        barrierDismissible: true,
        context: context,
        builder: (context) => Theme(
            data: Theme.of(context).copyWith(
              primaryColor: const Color(0xFF1E62A8),
            ),
            child: LanguagePickerDialog(
                // isDividerEnabled: true,
                titlePadding: const EdgeInsets.all(8.0),
                searchCursorColor: const Color(0xFF1E62A8),
                searchInputDecoration:
                    const InputDecoration(hintText: 'Search...'),
                isSearchable: true,
                title: const Text('Select your language'),
                onValuePicked: (Language language) => setState((){
                      _selectedDialogLanguage = language;

                     //////////// change langage clear controller///
                      mycontroller.clear();
                      setState(() {
                        translated = "";
                      });
                      ////////////

                      print(_selectedDialogLanguage.name);
                      print(_selectedDialogLanguage.isoCode);
                    }),
                itemBuilder: _buildDialogItem)),
      );

  void _openLanguagePickerDialog2() => showDialog(
        context: context,
        builder: (context) => Theme(
            data: Theme.of(context).copyWith(
              primaryColor: const Color(0xFF1E62A8),
            ),
            child: LanguagePickerDialog(
                // isDividerEnabled: true,
                titlePadding: const EdgeInsets.all(8.0),
                searchCursorColor: const Color(0xFF1E62A8),
                searchInputDecoration:
                    const InputDecoration(hintText: 'Search...'),
                isSearchable: true,
                title: const Text('Select your language'),
                onValuePicked: (Language language) =>
                    setState(() async {
                      _selectedDialogLanguage2 = language;


                      ////////  change languae auto translet/////////
                      final translation =
                          await mycontroller.text.translate(
                        from: "auto",
                        to: _selectedDialogLanguage2.isoCode,
                      );

                      translated = translation.text;

                      setState(() {});

                      Navigator.pop(context);

                      ////////////////////////

                      print(_selectedDialogLanguage2.name);
                      print(_selectedDialogLanguage2.isoCode);
                    }),
                itemBuilder: _buildDialogItem)),
      );

  // -------------------- Image To Text --------------------
  void getImage(ImageSource source) async {
    try {
      final pickedImage = await ImagePicker().pickImage(source: source);
      if (pickedImage != null) {
        textScanning = true;
        imageFile = pickedImage;
        setState(() {});
        getRecognisedText(pickedImage);
      }
    } catch (e) {
      textScanning = false;
      imageFile = null;
      scannedText = "Error occured while scanning";
      setState(() {});
    }
  }

  void getRecognisedText(XFile image) async {
    final inputImage = InputImage.fromFilePath(image.path);
    final textDetector = GoogleMlKit.vision.textDetector();
    RecognisedText recognisedText = await textDetector.processImage(inputImage);
    await textDetector.close();
    scannedText = "";
    for (TextBlock block in recognisedText.blocks) {
      for (TextLine line in block.lines) {
        scannedText = scannedText + line.text + "\n";
        mycontroller.text = scannedText;
      }
    }
    textScanning = false;
    setState(() {});
  }

  //--------------------------------------//

  Database? db;

  @override
  void initState() {
    // TODO: implement initState
    // initializeTts();
    initializeTts1();
    _initSpeech();
    super.initState();

    DbHelper().createDatabase().then((value) {
      db = value;
    });
    //
    if (widget.m != null) {
      _selectedDialogLanguage.name = widget.m!['language_1'];
      mycontroller.text = widget.m!['text_controller'];
      _selectedDialogLanguage2.name = widget.m!['language_2'];
    }
  }

  //-------------------Speech to text 2nd Language----------------------//

  void initializeTts1() {
    _flutterTts1.setStartHandler(() {
      setState(() {
        isSpeaking1 = true;
      });
    });
    _flutterTts1.setCompletionHandler(() {
      setState(() {
        isSpeaking1 = false;
      });
    });
    _flutterTts1.setErrorHandler((message) {
      setState(() {
        isSpeaking1 = false;
      });
    });
  }

  void speak1(String ss) async {
    if (mycontroller.text.isNotEmpty) {
      await _flutterTts1.speak(ss);
    }
  }

  void stop1() async {
    await _flutterTts1.stop();
    setState(() {
      isSpeaking1 = false;
    });
  }

  // ----------- Fetch Data Dialog --------------

  //-----------------------------------------//

  @override
  void dispose() {
    super.dispose();
    _flutterTts.stop();
    _flutterTts1.stop();
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context); // Toast
    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: WillPopScope(
            onWillPop: showExitPopup,
            child: Scaffold(
              resizeToAvoidBottomInset: false, // Open Keyboard On Container...
              backgroundColor: Colors.white,
              appBar: AppBar(
                  title: Text(
                    APPNAME,
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
                  ),
                  backgroundColor: const Color(0xFF1E62A8),
                  actions: [
                    _popup_button(),
                    const SizedBox(
                      width: 8,
                    )
                  ]),
              body: Column(
                children: [
                  Container(
                    height: 60,
                    width: double.infinity,
                    alignment: Alignment.center,
                    // color: Colors.amber,
                    child: Row(
                      children: [
                        const SizedBox(width: 7),
                        Expanded(
                          child: InkWell(
                            onTap: () => _openLanguagePickerDialog(),
                            child: Container(
                                height: 40,
                                // width: double.infinity,
                                // color: Colors.amber.shade100,
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const SizedBox(width: 5),
                                    Flexible(
                                        child: Text(
                                      _selectedDialogLanguage.name,

                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w400,
                                          color: Color(0xFF1E62A8)),
                                    )),
                                    const Icon(
                                      Icons.arrow_drop_down_sharp,
                                      size: 35,
                                      color: Colors.black,
                                    )
                                  ],
                                )),
                          ),
                        ),
                        IconButton(
                            onPressed: () {
                              setState(() {
                                _isswitch = !_isswitch;

                                var val1 = _selectedDialogLanguage.name;
                                var val2 = _selectedDialogLanguage2.name;
                                //
                                _selectedDialogLanguage.name = val2;
                                _selectedDialogLanguage2.name = val1;

                                var valIso1 = _selectedDialogLanguage.isoCode;
                                var valIso2 = _selectedDialogLanguage2.isoCode;
                                //
                                _selectedDialogLanguage.isoCode = valIso2;
                                _selectedDialogLanguage2.isoCode = valIso1;

                                print(
                                    "_selectedDialogLanguage = ${_selectedDialogLanguage.name}");
                                print(
                                    "_selectedDialogLanguage2 = ${_selectedDialogLanguage2.name}");

                                print(
                                    "_selectedDialogLanguageIso = ${_selectedDialogLanguage.isoCode}");
                                print(
                                    "_selectedDialogLanguage2Iso = ${_selectedDialogLanguage2.isoCode}");
                              });
                              mycontroller.clear();
                              translated = "";
                            },
                            icon: const Icon(
                              Icons.compare_arrows_outlined,
                              size: 40,
                            )),
                        Expanded(
                          child: InkWell(
                            onTap: () => _openLanguagePickerDialog2(),
                            child: Container(
                                height: 40,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    // const Spacer(),
                                    Flexible(
                                        child: Text(

                                      _selectedDialogLanguage2.name,

                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w400,
                                          color: Color(0xFF1E62A8)),
                                    )),
                                    const Icon(
                                      Icons.arrow_drop_down_sharp,
                                      size: 35,
                                      color: Colors.black,
                                    )
                                  ],
                                )),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(
                    color: Colors.black,
                    thickness: 1,
                    height: 1,
                  ),
                  const SizedBox(height: 5),
                  Container(
                    height: MediaQuery.of(context).size.height / 2.75,
                    width: MediaQuery.of(context).size.width,
                    // color: Colors.amber.shade200,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      children: [
                        Container(
                          height: 40,
                          width: double.infinity,
                          // color: Colors.purple.shade100,
                          child: Row(
                            children: [
                              const Icon(Icons.volume_up,
                                  color: Colors.black, size: 30),
                              const SizedBox(width: 7),
                              Text(
                                // widget.m!=null ?  _isswitch
                                //     ? widget.m!['language_2'] : widget.m!['language_1'] :
                                _selectedDialogLanguage.name,
                                style: const TextStyle(fontSize: 20),
                              ),
                              const Spacer(),
                              IconButton(
                                  onPressed: () {
                                    mycontroller.clear();
                                    setState(() {
                                      translated = "";
                                    });
                                    // translated.toString();
                                  },
                                  icon: const Icon(
                                    Icons.close,
                                    size: 30,
                                    color: Colors.black,
                                  )),
                              IconButton(
                                  onPressed: () {
                                    firstp = false;
                                    setState(() {});
                                    _speechToText.isNotListening
                                        ? _startListening()
                                        : _stopListening();
                                  },
                                  icon: _speechToText.isListening
                                      ? const AvatarGlow(
                                          glowColor: Colors.blue,
                                          endRadius: 70,
                                          duration:
                                              Duration(milliseconds: 2000),
                                          repeat: true,
                                          showTwoGlows: true,
                                          repeatPauseDuration:
                                              Duration(milliseconds: 100),
                                          child: Icon(
                                            Icons.mic,
                                            color: Colors.black,
                                            size: 30,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.mic_off_rounded,
                                          color: Colors.black,
                                          size: 30,
                                        )),
                              IconButton(
                                onPressed: () {
                                  isSpeaking1
                                      ? stop1()
                                      : speak1(mycontroller.text);
                                },
                                icon: Icon(
                                  isSpeaking1
                                      ? Icons.volume_off
                                      : Icons.volume_up,
                                  color: Colors.black,
                                  size: 30,
                                ),
                              )
                            ],
                          ),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: TextField(
                                        controller: mycontroller,
                                        // focusNode: FocusNode(canRequestFocus: false),
                                        autofocus: false,
                                        clipBehavior:
                                            Clip.antiAliasWithSaveLayer,
                                        keyboardType: TextInputType.multiline,
                                        maxLines: 9999,
                                        cursorHeight: 25,
                                        cursorColor: Colors.black,
                                        decoration: InputDecoration(
                                            hintText:
                                                "Type/Speak ${_selectedDialogLanguage.name} here",
                                            hintStyle:
                                                const TextStyle(fontSize: 18),
                                            border: InputBorder.none),
                                        style: const TextStyle(
                                          fontSize: 19,
                                          decoration: TextDecoration.none,
                                          // Input Text Remove UnderLine
                                          decorationThickness: 0,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Stack(
                    alignment: AlignmentDirectional.center,
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height / 2.4,
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        padding: const EdgeInsets.fromLTRB(15, 20, 15, 10),
                        decoration: BoxDecoration(
                            color: const Color(0xFF1E62A8),
                            borderRadius: BorderRadius.circular(16)),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.volume_up,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                  const SizedBox(width: 7),
                                  Text(
                                    _selectedDialogLanguage2.name,
                                    style: const TextStyle(
                                        fontSize: 20, color: Colors.white),
                                  ),
                                  const Spacer(),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Container(
                                      // color: Colors.amber,
                                      child: translated.isEmpty
                                          ? const Text(
                                              "Your Translation will be here",
                                              style: TextStyle(
                                                  color: Colors.white54,
                                                  fontSize: 18))
                                          : Text(translated.toString(),
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 19))),
                                ),
                              ),
                              translated.isEmpty
                                  ? Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: const [
                                        Icon(
                                          Icons.volume_up,
                                          color: Colors.white,
                                          size: 30,
                                        ),
                                      ],
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            FlutterClipboard.copy(translated)
                                                .then(
                                              (value) {
                                                print("copied");
                                                Toast.show("copied",
                                                    duration: Toast.lengthShort,
                                                    gravity: Toast.bottom,
                                                    backgroundColor:
                                                        Colors.black45);
                                              },
                                            );
                                          },
                                          icon: const Icon(
                                            Icons.copy,
                                            color: Colors.white,
                                            size: 30,
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            Share.share(translated);
                                          },
                                          icon: const Icon(
                                            Icons.share,
                                            color: Colors.white,
                                            size: 30,
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            isSpeaking1
                                                ? stop1()
                                                : speak1(translated);
                                          },
                                          icon: Icon(
                                            isSpeaking1
                                                ? Icons.volume_off
                                                : Icons.volume_up,
                                            color: Colors.white,
                                            size: 30,
                                          ),
                                        )
                                      ],
                                    ),
                            ]),
                      ),
                      Positioned(
                        right: 0,
                        left: 0,
                        top: -350,
                        bottom: 0,
                        child: Center(
                            child: InkWell(
                          onTap: () async {
                            FocusScope.of(context).requestFocus(
                                FocusNode()); // When TextField closed Keyboard Close..

                            _fetchData(context); // loading Dialog

                            final translation =
                                await mycontroller.text.translate(
                              from: "auto",
                              to: _selectedDialogLanguage2.isoCode,
                            );

                            translated = translation.text;

                            setState(() {});

                            print("Language 1 :${_selectedDialogLanguage.name}");
                            print(
                                "Language 2 : ${_selectedDialogLanguage2.name}");
                            print("Mycontroller : ${mycontroller.text}");
                            print("Translated : $translated");
                            print(
                                "Iso Code1 : ${_selectedDialogLanguage.isoCode}");
                            print(
                                "Iso Code2 : ${_selectedDialogLanguage2.isoCode}");

                            //------------------ Sqlite ------------------//

                            String language1 = _selectedDialogLanguage.name;
                            String language2 = _selectedDialogLanguage2.name;

                           if (widget.m == null) {
                              String qry =
                                  "insert into Test (language_1,text_controller,language_2,text_translated,isFav) values('${language1.toString()}','${mycontroller.text.toString()}','${language2.toString()}','${translated.toString()}','1')";

                              int a = await db!.rawInsert(qry);

                              print(a);

                              // Favourite mAte 1 = false and 0 = true
                            } else {
                              int id = widget.m!['id'];

                              String qry =
                                  "update Test set language_1='${language1.toString()}',text_controller='${mycontroller.text.toString()}',language_2='${language2.toString()}',text_translated='${translated.toString()}',isFav='1' where id = '$id'";

                              int a = await db!.rawUpdate(qry);

                              print(a);
                            }

                            if (!mounted) return; // loading Dialog
                            Navigator.of(context).pop(); // loading Dialog

                          },
                          child: const SizedBox(
                              height: 60,
                              width: 60,
                              child: CircleAvatar(
                                  backgroundColor: Colors.white,
                                  child: Icon(Icons.send,
                                      size: 34, color: Color(0xFF1E62A8)))),
                        )),
                      ),
                    ],
                  ),
                  // const SizedBox(height: 40),
                ],
              ),
            )));
  }

  Future<bool> goBack() {
    showDialog(
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: AlertDialog(
              content: const Text("Are you sure want to exit?"),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "NO",
                      style: TextStyle(color: Colors.black),
                    )),
                TextButton(
                    onPressed: () async {
                      exit(0);
                    },
                    child: const Text(
                      "YES",
                      style: TextStyle(color: Color(0xFF1E62A8)),
                    )),
              ],
            ),
          );
        },
        context: context);
    return Future.value();
  }

  Future<bool> showExitPopup() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: const RoundedRectangleBorder(
                borderRadius: const BorderRadius.all(Radius.circular(16))),
            // backgroundColor: const Color(0xFF0B1222),
            title: const Text(
              'Exit app',
              style: TextStyle(
                fontSize: 22,
                letterSpacing: 0.7,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: const Text(
              'Are you sure want to exit?',
              style: TextStyle(
                fontSize: 18.5,
                letterSpacing: 0.7,
              ),
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: const Color(0xFF868383),
                      onPrimary: Colors.white,
                      shadowColor: const Color(0xFF868383),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32.0)),
                      minimumSize: const Size(90, 35), //////// HERE
                    ),
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text(
                      'No',
                      style: const TextStyle(
                        fontSize: 18,
                        letterSpacing: 0.7,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: const Color(0xFF1E62A8),
                      // onPrimary: Colors.white,
                      shadowColor: const Color(0xFF1E62A8),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32.0)),
                      minimumSize: const Size(90, 35), //////// HERE
                    ),
                    onPressed: () => widget.m != null
                        ? Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Home_Screen()))
                        : exit(0),
                    child: const Text(
                      'Yes',
                      style: TextStyle(
                        fontSize: 18,
                        letterSpacing: 0.7,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20)
            ],
          ),
        ) ??
        false;
  }

  Widget _popup_button() {
    return PopupMenuButton(
      // padding: EdgeInsets.fromLTRB(15,15,200,15),
      child: const Center(
          child: Icon(
        Icons.more_vert,
        color: Colors.white,
      )),
      itemBuilder: (context) {
        return [
          const PopupMenuItem(
            padding: EdgeInsets.only(right: 50, left: 20),
            child: Text(
              "Share",
              style: TextStyle(fontWeight: FontWeight.normal, fontSize: 18),
            ),
            // value: '/hello',
          ),
          PopupMenuItem(
            onTap: () {
              Future.delayed(
                  const Duration(seconds: 0),
                  () => Navigator.pushReplacement(context, MaterialPageRoute(
                        builder: (context) {
                          return History_Screen();
                        },
                      )));
            },
            padding: EdgeInsets.only(right: 50, left: 20),
            child: Text(
              "History",
              style: TextStyle(fontWeight: FontWeight.normal, fontSize: 18),
            ),
            // value: '/about',
          ),
          PopupMenuItem(
            onTap: () {
              Future.delayed(
                  const Duration(seconds: 0),
                  () => showDialog(
                        context: context,
                        builder: (ctx) => SimpleDialog(
                          contentPadding: const EdgeInsets.only(
                              left: 15, top: 20, bottom: 10, right: 10),
                          // alignment: Alignment.center,
                          title: const Text(
                            'Select Action',
                            style: TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 20),
                          ),
                          children: [
                            InkWell(
                                onTap: () {
                                  // pickImageFromGallery();
                                  getImage(ImageSource.gallery);
                                  Navigator.pop(context);
                                },
                                child: Container(
                                    height: 40,
                                    width: double.infinity,
                                    alignment: Alignment.centerLeft,
                                    child: Row(
                                      children: const [
                                        Icon(Icons.photo, color: Colors.black),
                                        SizedBox(width: 10),
                                        FittedBox(
                                            child: Text(
                                          "Select photo from gallery",
                                          style: TextStyle(
                                              fontWeight: FontWeight.normal,
                                              fontSize: 16),
                                        )),
                                      ],
                                    ))),
                            const SizedBox(
                              height: 2,
                            ),
                            InkWell(
                                onTap: () {
                                  // pickImageFromCamera();
                                  getImage(ImageSource.camera);
                                  Navigator.pop(context);
                                },
                                child: Container(
                                    height: 40,
                                    width: double.infinity,
                                    alignment: Alignment.centerLeft,
                                    child: Row(
                                      children: const [
                                        Icon(Icons.camera_alt,
                                            color: Colors.black),
                                        SizedBox(width: 10),
                                        FittedBox(
                                            child: Text(
                                          "Capture photo from Camera",
                                          style: TextStyle(
                                              fontWeight: FontWeight.normal,
                                              fontSize: 16),
                                        )),
                                      ],
                                    ))),
                            const SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                      ));
            },
            padding: const EdgeInsets.only(right: 50, left: 20),
            child: const Text(
              "Camera",
              style: TextStyle(fontWeight: FontWeight.normal, fontSize: 18),
            ),
            // value: '/contact',
          )
        ];
      },
    );
  }

  // Fetch Dialog
  void _fetchData(BuildContext context, [bool mounted = true]) async {
    // show the loading dialog
    showDialog(
        // The user CANNOT close this dialog  by pressing outsite it
        barrierDismissible: false,
        context: context,
        builder: (_) {
          return Dialog(
            // The background color
            backgroundColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 20, right: 05),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  // The loading indicator
                  SizedBox(
                    width: 20,
                  ),
                  CircularProgressIndicator(color: Color(0xFF1E62A8)),
                  SizedBox(
                    width: 20,
                  ),
                  // Some text
                  Flexible(
                      child: Text(
                    'Please wait, translating...',
                    style: TextStyle(fontSize: 16.5),
                  ))
                ],
              ),
            ),
          );
        });
  }
}
