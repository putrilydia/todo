import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todo/Custom/TodoCard.dart';
import 'package:todo/Service/Auth_Service.dart';
import 'package:flutter/material.dart';
import 'package:todo/pages/AddTodo.dart';
import 'package:intl/intl.dart';
import 'package:todo/pages/ViewPage.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  AuthClass authClass = AuthClass();

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
              padding: const EdgeInsets.only(left: 22),
              child: Text(
                getToday(),
                style: TextStyle(
                  fontSize: 33,
                  fontWeight: FontWeight.w600,
                  color: Colors.purpleAccent,
                ),
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
              icon: Icon(
                Icons.settings,
                size: 32,
                color: Colors.white,
              ),
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
                      child: TodoCard(
                        title: data["title"] ?? "NO TITLE",
                        check: true,
                        iconBgColor: Colors.white,
                        iconColor: iconColor,
                        iconData: iconData,
                        time: "10 AM",
                      ),
                    );
                  });
            }),
      ),
    );
  }
}
// IconButton(
//               icon: Icon(Icons.logout),
//               onPressed: () async {
//                 await authClass.signOut();
//                 Navigator.pushAndRemoveUntil(
//                     context,
//                     MaterialPageRoute(builder: (builder) => MyApp()),
//                     (route) => false);
//               }),
