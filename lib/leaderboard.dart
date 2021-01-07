import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:LessApp/styles.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:async/async.dart';
import 'package:LessApp/wasteless-data.dart';

class LeaderboardPage extends StatefulWidget{
  final FirebaseUser user;
  String chosenType;
  LeaderboardPage(this.user, this.chosenType);
  @override
  LeaderboardPageState createState() => new LeaderboardPageState(this.user, this.chosenType);
}

class LeaderboardPageState extends  State<LeaderboardPage> {
  String chosenType;
  FirebaseUser user;
  LeaderboardPageState(this.user, this.chosenType);

  NumberFormat nf = NumberFormat("###.00", "en_US");

  String _selectedType = "Select Type";
  String _selectedTrend = "Select Trend";

  List<bool> _typeChosen = [true, false, false];
  List<String> _typeList = ["Select Type", "Trash", "Recyclables"];

  List<bool> _trendChosen = [true, false, false, false];
  List<String> _trendList = ["Select Trend", "Week", "Month", "All Time"];

  static String staticType = "Select Trend";
  static String staticTrend = "Select Type";

  List list = List();
  Map map = Map();

  final dfFilter = DateFormat("yyyy-MM-dd");
  final df3 = DateFormat('d MMM yyyy');

  AsyncMemoizer _memoizer;

  @override
  void initState() {
    _memoizer = AsyncMemoizer();
    _selectedTrend = "Week";
    _selectedType = chosenType;
    _trendChosen = [false, true, false, false];
    switch (chosenType){
      case "Trash":{
        _typeChosen = [false,true,false];
        break;
      }
      case "Recyclables":{
        _typeChosen = [false,true,true];
        break;
      }

    }
  }


  _fetchData(String type, String time) async {
    String currentType;
    String currentTrend;

    //trash selected
    if (type == "Trash") {
      currentType = "general";
    } else {
      currentType = "all";
    }

    if (time == "All Time") {
      currentTrend = "allTime";
    } else if (time == "Month") {
      currentTrend = "month";
    } else {
      currentTrend = "week";
    }

    //String link = "https://yt7s7vt6bi.execute-api.ap-southeast-1.amazonaws.com/dev/waste/leaderboard?aggregateBy=week&type=general";
    String link = "https://yt7s7vt6bi.execute-api.ap-southeast-1.amazonaws.com/dev/waste/leaderboard?type=${currentType}&aggregateBy=${currentTrend}";

    final response = await http.get(link, headers: {"x-api-key": WasteLessData.userKey});

    if (response.statusCode == 200) {
      map = json.decode(response.body) as Map;
      list = map["data"];
    } else {
      throw Exception('Failed to load data');
    }
  }



  Widget _buildList(String type, String trend) {

    print(type);
    print(trend);

    var now = new DateTime.now();
    List newList = list;
    print(list);


    newList = new List.from(newList.reversed);

    if (_typeChosen[0] || _trendChosen[0]) {
      return Expanded(
        child: Center(
          child: Text("Please select your desired \nType and Trend",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 25,
              //fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    else if (newList.length == 0) {
      return Expanded(
        child: Center(
          child: Text("NO DATA",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    } else {
      return Expanded(
          child: ListView.builder(
            itemCount: newList.length,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                color:   _typeChosen[1] ? ((index % 2 == 0) ? Colors.brown[100] : Colors.white10) : ((index % 2 == 0) ? Colors.lightGreen[200] : Colors.white10),
                child: ListTile(
                  leading: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding:  EdgeInsets.fromLTRB(10,0,0,0),
                        child: Text((index+1).toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ],
                  ),
                  contentPadding: EdgeInsets.all(10.0),
                  title: new Text("UserID is: " + newList[index]["username"].toString()),
                    //title: new Text(df3.format(DateTime.fromMillisecondsSinceEpoch(newList[index]["userId"] * 1000)).toString()),
                    //title: new Text(DateTime.now().month.toString()),
                  subtitle: new Text("${_selectedType} thrown ${_selectedTrend}: " + newList[index]["weight"].toString() + "kg"),
                  ),
              );
            },
          )
      );
    }
  }



  @override
  Widget build(BuildContext context) {



    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
            }),
          title: Text((_selectedTrend == "All Time" ? _selectedTrend : _selectedTrend + "ly" ) + " " +chosenType + " Leaderboard",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.green[900],
          elevation: 0,
        actions: <Widget>[
          PopupMenuButton(
              icon: Icon(Icons.filter_list_outlined, color: Colors.white),
              tooltip: "Filter",
              itemBuilder: (context) {
                return _trendList.map((String value) {
                  return new PopupMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList();
              },
            onSelected: (String newValue) {
                      setState(() {
                        for (int i = 0; i < _trendList.length; i++) {
                          String currType = _trendList[i];
                          if (newValue == currType) {
                            _trendChosen[i] = true;
                          } else {
                            _trendChosen[i] = false;
                          }
                        }
                        _selectedTrend = newValue;
                      });
                    },
          ),
        ],

      ),

      body: Container(
          alignment: Alignment.center,
          color: Colors.white,

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[

            // Container(
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.center,
            //     children: <Widget>[
            //       DropdownButton<String>(
            //         value: _selectedType,
            //         items: _typeList.map((String value) {
            //           return new DropdownMenuItem<String>(
            //             value: value,
            //             child: new Text(value),
            //           );
            //         }).toList(),
            //         onChanged: (String newValue) {
            //           setState(() {
            //             for (int i = 0; i < _typeList.length; i++) {
            //               String currType = _typeList[i];
            //               if (newValue == currType) {
            //                 _typeChosen[i] = true;
            //               } else {
            //                 _typeChosen[i] = false;
            //               }
            //             }
            //             _selectedType = newValue;
            //           });
            //         },
            //       ),
            //
            //       SizedBox(
            //         height: 10,
            //         width: 50,
            //       ),
            //
            //       // DropdownButton<String>(
            //       //   value: _selectedTrend,
            //       //   items: _trendList.map((String value) {
            //       //     return new DropdownMenuItem<String>(
            //       //       value: value,
            //       //       child: new Text(value),
            //       //     );
            //       //   }).toList(),
            //       //   onChanged: (String newValue) {
            //       //     setState(() {
            //       //       for (int i = 0; i < _trendList.length; i++) {
            //       //         String currType = _trendList[i];
            //       //         if (newValue == currType) {
            //       //           _trendChosen[i] = true;
            //       //         } else {
            //       //           _trendChosen[i] = false;
            //       //         }
            //       //       }
            //       //       _selectedTrend = newValue;
            //       //     });
            //       //   },
            //       // ),
            //     ],
            //   ),
            // ),

            FutureBuilder(
              future: _fetchData(_selectedType, _selectedTrend),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return _buildList(_selectedType, _selectedTrend);
                } else {
                  return CircularProgressIndicator();
                }
              }
            ),
          ],
        ),
      )
    );
  }
}