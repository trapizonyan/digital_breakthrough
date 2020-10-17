import 'package:digital_hack/Models/db.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:tree_view/tree_view.dart';

class MapVkld extends StatefulWidget {
  @override
  _MapVkldState createState() => _MapVkldState();
}

class _MapVkldState extends State<MapVkld> {
  Future<List<Deparament>> _getJson() async {
    var tstData = await http.get(
        "https://my-json-server.typicode.com/mentoster/digital_breakthrough/departments");
    var jsonData = json.decode(tstData.body);
    List<Deparament> deparaments = [];
    for (var dpr in jsonData[0]["company"]) {
      List<Profiles> profiles = [];
      for (var profile in jsonData[0]["company"][0]["profiles"]) {
        List<Tasks> tasks = [];
        if (profile["tasks"] != null)
          for (var tsk in profile["tasks"]) {
            Tasks tsknew = Tasks(tsk["id"], tsk["deadline"], tsk["title"],
                tsk["tags"], tsk["color"], tsk["body"]);
            tasks.add(tsknew);
          }
        Profiles prf = Profiles(profile["id"], profile["name"], profile["img"],
            profile["position"], profile["phone"], profile["email"], tasks);
        profiles.add(prf);
      }
      Deparament deparament =
          Deparament(dpr["id"], dpr["name"], dpr["url"], profiles);
      deparaments.add(deparament);
    }

    return deparaments;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text("Задачи"),
      ),
      body: FutureBuilder(
          future: _getJson(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.data == null) {
              return Container(
                child: Center(
                  child: Text("Загрузка..."),
                ),
              );
            } else {
              return tree(snapshot.data);
            }
          }),
    );
  }

  TreeView tree(List<Deparament> snapshot) {
    return TreeView(parentList: [
      Parent(
        parent: _buildCard("ООО <<МОЯ ОБОРОНА>>", 0),
        childList: ChildList(
          children: <Widget>[
            _treePrint(snapshot[0].name, snapshot[0].profiles),
            _treePrint(snapshot[1].name, snapshot[1].profiles),
            _treePrint(snapshot[2].name, snapshot[2].profiles),
            _treePrint(snapshot[3].name, snapshot[3].profiles),
          ],
        ),
      ),
    ]);
  }

  Parent _treePrint(String parent, List<dynamic> childs) {
    return Parent(
      parent: _buildCard(parent, 20),
      childList: ChildList(
        children: List.generate(childs.length, (index) {
          if (childs is List<Profiles>) {
            return _treePrint(childs[index].name, childs[index].tasks);
          } else if (childs is List<Tasks>) {
            print("89. map -> childs[index].title: " +
                childs[index].title.toString());
            _buildCard(childs[index].title, 40);
          } else
            return Text('');
        }),
      ),
    );
  }

  // ignore: unused_element
  Widget _buildCard(String name, double leftMargin) => SizedBox(
        child: Card(
          margin: EdgeInsets.fromLTRB(leftMargin, 1, 0, 1),
          child: Column(
            children: [
              ListTile(
                title:
                    Text(name, style: TextStyle(fontWeight: FontWeight.w500)),
                trailing: IconButton(
                  onPressed: () {
                    // Interactivity or events codes here
                  },
                  splashRadius: 25,
                  icon: Icon(
                    Icons.keyboard_arrow_right,
                    color: Colors.green,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
