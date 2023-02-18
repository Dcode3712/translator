import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart';
import 'package:toast/toast.dart';
import 'package:universal_translator/Screens/Home_Screen.dart';
import 'DbHelper.dart';

class History_Screen extends StatefulWidget {
  const History_Screen({Key? key}) : super(key: key);

  @override
  State<History_Screen> createState() => _History_ScreenState();
}

class _History_ScreenState extends State<History_Screen> {

  bool starfav = false;

  int _selectedindex = 0;

  Database? db;

 List<Map<String, Object?>> ReveList = [];

  @override
  void initState() {
    super.initState();

    getAllData();
  }

  Future<List<Map<String, Object?>>> getAllData() async {
    db = await DbHelper().createDatabase();

    String qry = "select * from Test";

    List<Map<String, Object?>> l1 = await db!.rawQuery(qry);

    print(qry);
    return l1;
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context); // Toast
    return WillPopScope(
        onWillPop: goBack,
        child: Scaffold(
          // backgroundColor: Colors.white70,
          appBar: AppBar(
            backgroundColor: const Color(0xFF1E62A8),
            leading: IconButton(
                onPressed: () =>   Navigator.pushReplacement(context, MaterialPageRoute(
                  builder: (context) {
                    return Home_Screen();
                  },
                )),
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                )),
            title: const Text("History"),
            centerTitle: true,
          ),
          body: FutureBuilder(
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData) {
                  List<Map<String, Object?>> l = snapshot.data as List<Map<String, Object?>>;

                  ReveList =  List.from(l.reversed);

                  l = ReveList;

                  return (l.length > 0
                      ? ListView.separated(

                      itemBuilder: (BuildContext context, int index) {
                        Map m = l[index];
                        print("--------** ${l[index]}");
                        print(l[index]['isFav']);

                        return Container(
                          // color: Colors.amber.shade200,
                          width: double.infinity,
                          margin: const EdgeInsets.only(top: 8),
                          child: Column(children: [
                            Container(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 8),
                              // color: Colors.purple.shade100,
                              child: Column(children: [
                                Container(
                                  width: double.infinity,
                                  // color: Colors.green,
                                  child: Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment.start,
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 10),
                                        Text(
                                          "${m['language_1']}",
                                          style: const TextStyle(fontSize: 20),
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            const SizedBox(width: 15),
                                            Expanded(
                                                child: Text(
                                                  "${m['text_controller']}",
                                                  style:
                                                  const TextStyle(fontSize: 17.5),
                                                )),
                                          ],
                                        ),
                                        const SizedBox(height: 5),
                                      ]),
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  width: double.infinity,
                                  // color: Colors.lightBlueAccent,
                                  child: Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment.start,
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 5),
                                        Text(
                                          "${m['language_2']}",
                                          style: const TextStyle(fontSize: 20,fontWeight:
                                          FontWeight.w500),
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            const SizedBox(width: 20),
                                            Expanded(
                                                child: Text(
                                                  "${m['text_translated']}",
                                                  style: const TextStyle(
                                                      fontSize: 19,
                                                      fontWeight:
                                                      FontWeight.w500),
                                                )),
                                          ],
                                        ),
                                        // const SizedBox(height: 5),
                                      ]),
                                ),
                              ]),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                    onPressed: () {
                                      Navigator.pushReplacement(context,
                                          MaterialPageRoute(
                                            builder: (context) {
                                              return Home_Screen(m: m);
                                            },
                                          ));
                                     print( "---------------------------language_1 : ${m['language_1']}");
                                      print("---------------------------language_2 :  ${m['language_2']}");
                                      print("---------------------------language_1 Iso Code :  ${m['language1IsoCode1']}");
                                      print("---------------------------language_2 Iso Code :  ${m['language2IsoCode2']}");
                                    },
                                    icon: const Icon(
                                      Icons.autorenew_rounded,
                                      size: 27,
                                      color: Colors.black,
                                    )),
                                IconButton(
                                    onPressed: () {
                                      showDialog(
                                          builder: (context) {
                                            return Padding(
                                              padding: const EdgeInsets.all(20.0),
                                              child: AlertDialog(
                                              content: const Text(
                                                  "Are you sure, you want to delete this record?"),
                                              actions: [
                                                TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: const Text("NO",style: TextStyle(color: Colors.black),)),
                                                TextButton(
                                                    onPressed: () async {
                                                      Navigator.pop(context);
                                                      int id = m['id'];

                                                      String qry =
                                                          "delete from Test where id = '$id'";

                                                      await db!.rawDelete(qry);
                                                      setState(() {});
                                                    },
                                                    child: const Text("YES",style: TextStyle(color: Color(0xFF1E62A8) ),)),

                                              ],
                                              ),
                                            );
                                          },
                                          context: context);
                                    },
                                    icon: const Icon(
                                      Icons.delete,
                                      size: 27,
                                      color: Colors.black,
                                    )),
                                IconButton(
                                    onPressed: () {
                                      FlutterClipboard.copy("${m['text_translated']}").then(
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
                                      size: 27,
                                      color: Colors.black,
                                    )),
                                IconButton(
                                    onPressed: () {
                                      Share.share("${m['text_translated']}");
                                    },
                                    icon: const Icon(
                                      Icons.share,
                                      size: 27,
                                      color: Colors.black,
                                    )),
                                IconButton(
                                    onPressed: () async{

                                      // setState(() {
                                        if( l[index]['isFav'] == "0")
                                          {
                                            int id = int.parse(l[index]['id'].toString());

                                            print("Id : $id");

                                            String qry =
                                                "update Test set isFav='1' where id = '$id'";

                                            int a = await db!.rawUpdate(qry);

                                            print(a);

                                          }
                                        else
                                          {
                                            int id = int.parse(l[index]['id'].toString());


                                            print("Id in else : $id");

                                            String qry =
                                                "update Test set isFav='0' where id = '$id'";

                                            int a = await db!.rawUpdate(qry);

                                            print(a);
                                          }

                                        // print("HEllooooooo");
                                      // });
                                      setState(() {});
                                    },
                                    icon:
                                    l[index]['isFav'] == "0" ? const Icon(
                                       Icons.star_border_outlined,
                                      size: 30,
                                      color:  Colors.yellow,
                                    ) :
                                      const Icon(
                                        Icons.star_border_outlined,
                                        size: 27,
                                        color:  Colors.black
                                    )),
                              ],
                            ),
                            const SizedBox(height: 10),
                          ]),
                        );
                      },
                      separatorBuilder: (context, index) =>const Divider(height: 1,thickness: 3, color: Colors.black26),
                      itemCount: l.length,)
                      : const Center(child: const Text("NO HISTORY FOUND")));
                } else {
                  const Center(child: const Text("No Data Here"));
                }
              }
              return const Center(child: CircularProgressIndicator());
            },
            future: getAllData(),
          ),
        ));
  }

  Future<bool> goBack() {
    Navigator.pushReplacement(context, MaterialPageRoute(
      builder: (context) {
        return Home_Screen();
      },
    ));
    return Future.value();
  }
}
