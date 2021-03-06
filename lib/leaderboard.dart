import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:async/async.dart';
import 'package:WasteLess/wasteless-data.dart';

/**
 * Initialises leaderboard page
 */
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

  NumberFormat nf = NumberFormat("##0.00", "en_US");

  String _selectedType = "Select Type";
  String _selectedTrend = "Select Trend";

  List<bool> _typeChosen = [true, false, false];

  List<bool> _trendChosen = [true, false, false, false];
  List<String> _trendList = ["Select Trend", "Week", "Month", "All Time"];

  static String staticType = "Select Trend";
  static String staticTrend = "Select Type";

  List list = List();
  Map map = Map();

  final dfFilter = DateFormat("yyyy-MM-dd");
  final df3 = DateFormat('d MMM yyyy');

  @override
  void initState() {
    _selectedTrend = "Week";
    _selectedType = chosenType;
    _trendChosen = [false, true, false, false];
    switch (chosenType){
      case "Rubbish":{
        _typeChosen = [false,true,false];
        break;
      }
      case "Recyclables":{
        _typeChosen = [false,false,true];
        break;
      }

    }
  }


  /**
   * retrieves data from firebase based on information selected on the filter, saves in list data structure
   */
  _fetchData(String type, String time) async {
    String currentTypeNum;
    String currentTrend;

    if (type == "Rubbish") {
      //general trash
      currentTypeNum = '3';
    } else {
      //paper, plastic, general
      currentTypeNum = '4';
    }

    if (time == "All Time") {
      currentTrend = "allTime";
    } else if (time == "Month") {
      currentTrend = "month";
    } else {
      currentTrend = "week";
    }

    String link = "https://yt7s7vt6bi.execute-api.ap-southeast-1.amazonaws.com/dev/waste/leaderboard?type=${currentTypeNum}&aggregateBy=${currentTrend}";
    print("leaderboard " + link);
    final response = await http.get(link, headers: {"x-api-key": WasteLessData.userKey});

    if (response.statusCode == 200) {
      map = json.decode(response.body) as Map;
      list = map["data"];
      print(list);
      print("leaderboard data^^ for " + currentTypeNum.toString());
    } else {
      throw Exception('Failed to load data');
    }
  }

  /**
   * returns list shown on scaffold
   */
  Widget _buildList(String type, String trend) {

    List newList = list;
    print(list);

    if (type != 'Rubbish') {
      newList = new List.from(newList.reversed);
    }

    if (_typeChosen[0] || _trendChosen[0]) {
      return Expanded(
        child: Center(
          child: Text("Please select your desired trend",
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
                color: _typeChosen[1] ? ((index % 2 == 0) ? Colors.brown[100] : Colors.white10) : ((index % 2 == 0) ? Colors.lightGreen[200] : Colors.white10),
                child: ListTile(
                  leading: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding:  EdgeInsets.fromLTRB(10,0,0,0),
                        child: Text((index+1).toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20
                          ),
                        ),
                      )
                    ],
                  ),
                  contentPadding: EdgeInsets.all(10.0),
                  title: new Text(newList[index]["username"],
                  style: TextStyle(
                    fontSize: 25,
                  ),
                  ),
                  trailing: new Text(nf.format((newList[index]["weight"]/1000000)) + " kg",
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width/15,
                      fontWeight: FontWeight.bold
                    ),),
                  ),
              );
            },
          )
      );
    }
  }

  /**
   * scaffold of either general or recyclables leaderboard depending on which leaderboard user selects along with the filtered criterion
   */
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
          title: Text(
              (chosenType == "Rubbish" ? "🗑" : "♻️")
              + " Leaderboard"
            + (_selectedTrend == "All Time" ? " (AT)" : " (${_selectedTrend[0]})") ,
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

            FutureBuilder(
              future: _fetchData(_selectedType, _selectedTrend),
              builder: (context, snapshot) {
                print("Future obtained: " + _selectedType + "and " + _selectedTrend);
                if (snapshot.connectionState == ConnectionState.done) {
                  return _buildList(_selectedType, _selectedTrend);
                } else {
                  return CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                  );
                }
              }
            ),
          ],
        ),
      )
    );
  }
}