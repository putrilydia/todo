import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todo/Custom/TodoCard.dart';
import 'package:todo/Service/Auth_Service.dart';
import 'package:flutter/material.dart';
import 'package:todo/pages/AddTodo.dart';
import 'package:intl/intl.dart';
import 'package:todo/pages/ViewPage.dart';

import '../main.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  AuthClass authClass = AuthClass();

  List<Select> selected = [];

  final Stream<QuerySnapshot> _stream =
      FirebaseFirestore.instance.collection("Todo").snapshots();

  String getToday() {
    DateTime today = DateTime.now();
    String formattedDate = DateFormat('EEEE, d MMM, ' 'yyyy').format(today);
    return formattedDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: Text(
          "Today's Schedule",
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          CircleAvatar(
            backgroundImage: AssetImage('assets/profile.png'),
          ),
          SizedBox(
            width: 25,
          ),
        ],
        bottom: PreferredSize(
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(top: 10, left: 22),
              child: Row(
                children: [
                  Text(
                    getToday(),
                    style: TextStyle(
                      fontSize: 33,
                      fontWeight: FontWeight.w600,
                      color: Colors.purpleAccent,
                    ),
                  ),
                  IconButton(
                      onPressed: () {
                        var instance =
                            FirebaseFirestore.instance.collection("Todo");
                        for (var i = 0; i < selected.length; i++) {
                          instance.doc(selected[i].id).delete();
                        }
                      },
                      icon: Icon(
                        Icons.delete,
                        color: Colors.red[400],
                        size: 30,
                      )),
                ],
              ),
            ),
          ),
          preferredSize: Size.fromHeight(35),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: BottomNavigationBar(
          backgroundColor: Colors.black87,
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
                size: 32,
                color: Colors.white,
              ),
              title: Container(),
            ),
            BottomNavigationBarItem(
              icon: InkWell(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (builder) => AddTodoPage()));
                },
                child: Container(
                  height: 52,
                  width: 52,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(colors: [
                        Colors.indigoAccent,
                        Colors.purple,
                      ])),
                  child: Icon(
                    Icons.add,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
              ),
              title: Container(),
            ),
            BottomNavigationBarItem(
              backgroundColor: Colors.black87,
              icon: IconButton(
                  icon: Icon(
                    Icons.logout,
                    color: Colors.white,
                    size: 32,
                  ),
                  onPressed: () async {
                    await authClass.signOut();
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (builder) => MyApp()),
                        (route) => false);
                  }),
              title: Container(),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: StreamBuilder(
            stream: _stream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    CircularProgressIndicator(),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "You don't have Todos yet\nOr maybe there is an error :(",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    )
                  ],
                ));
              }
              return ListView.builder(
                  itemCount: (snapshot.data! as QuerySnapshot).docs.length,
                  itemBuilder: (context, index) {
                    IconData iconData;
                    Color iconColor;
                    Map<String, dynamic> data =
                        (snapshot.data! as QuerySnapshot).docs[index].data()
                            as Map<String, dynamic>;
                    switch (data["category"]) {
                      case "Work":
                        iconData = Icons.work;
                        iconColor = Colors.red;
                        break;
                      case "Workout":
                        iconData = Icons.run_circle_outlined;
                        iconColor = Colors.teal;
                        break;
                      case "Food":
                        iconData = Icons.local_grocery_store;
                        iconColor = Colors.blue;
                        break;
                      case "Design":
                        iconData = Icons.design_services;
                        iconColor = Colors.purple;
                        break;
                      case "Run":
                        iconData = Icons.run_circle_rounded;
                        iconColor = Colors.black;
                        break;
                      default:
                        iconData = Icons.work;
                        iconColor = Colors.red;
                    }
                    selected.add(Select(
                        id: (snapshot.data! as QuerySnapshot).docs[index].id,
                        checkValue: false));
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (builder) => ViewPage(
                                      data: data,
                                      id: (snapshot.data! as QuerySnapshot)
                                          .docs[index]
                                          .id,
                                    )));
                      },
                      child: data.isNotEmpty
                          ? TodoCard(
                              title: data["title"] ?? "NO TITLE",
                              check: selected[index].checkValue,
                              iconBgColor: Colors.white,
                              iconColor: iconColor,
                              iconData: iconData,
                              index: index,
                              onChange: onChange,
                              time: "10 AM",
                            )
                          : Center(
                              child: Text(
                                "No data",
                                style: TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                    );
                  });
            }),
      ),
    );
  }

  void onChange(int index) {
    setState(() {
      selected[index].checkValue = !selected[index].checkValue;
    });
  }
}

class Select {
  String id;
  bool checkValue = false;
  Select({required this.id, required this.checkValue});
}
