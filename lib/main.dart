import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web_scraper/web_scraper.dart';
import 'dart:collection';

void main() {
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wiki Links',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Wiki Links'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<HashMap<String, String>> listArray = [];

  final myController = TextEditingController();
  bool loading = true;

  void _onSubmit() async {
    print(myController.text);
    var url = '/wiki/' + myController.text;
    Map<String, bool> visited = new Map();
    listArray = [];
    recursiveCall(url, "", visited);
  }

  void recursiveCall(String url, String previous,
      Map<String, bool> visited) async {
    visited[url] = true;
    var firstLink = await parseUrl(url);
    setState(() {
      if (previous != ""){
        var map = new HashMap<String,String>();
        map[previous.replaceAll("/wiki/", "").replaceAll("_", " ")] =
            url.replaceAll("/wiki/", "").replaceAll("_", " ");
        listArray.add(map);
      }else{
        var map = new HashMap<String,String>();
        map[myController.text] =
            myController.text;
        listArray.add(map);

      }

    });
    if (firstLink != previous && !visited.containsKey(firstLink)) {
      recursiveCall(firstLink, url, visited);
    }
  }

  Future<String> parseUrl(String url) async {
    final webScraper = WebScraper('https://en.wikipedia.org');
    if (await webScraper.loadWebPage(url+"?origin=*")) {
      List<Map<String, dynamic>> elements = webScraper.getElement(
          'div.mw-body > '
              'div.mw-body-content > div.mw-content-ltr > div.mw-parser-output > p > a',
          ['href', 'title']);
      for (var i = 0; i < elements.length; i++) {
        var element = elements[i];
        var link = element["attributes"]["href"] as String;
        if (!link.contains("#") &&
            !link.contains("Latin") &&
            !link.contains("wikimedia") &&
            !link.contains("wiktionary") &&
            !link.contains("Greek") &&
            !link.contains("English") &&
            !link.contains("File")) {
          return link;
        }
      }
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              decoration: const InputDecoration(
                hintText: 'Enter your wiki link',
              ),
              controller: myController,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter wiki';
                }
                return null;
              },
            ),
            new Row(
              children: <Widget>[
                Expanded(
                  child: SizedBox(
                    height: 600.0,
                    child: new ListView.separated(
                      padding: const EdgeInsets.all(8),
                      itemCount: listArray.length,
                      scrollDirection: Axis.vertical,
                      itemBuilder: (BuildContext ctxt, int index) {
                        //                        return ;
                        var dots ="";
                        for(var i=0;i<index;i++){
                          dots+=". ";
                        }
                        return new Row( children: <Widget>[
//                          Expanded(child: InkWell(child: new Text(new List.from(listArray.reversed)[index].keys.elementAt(0)),onTap: (){
//                            launch("https://en.wikipedia.org/wiki/"+listArray[index].keys.elementAt(0).replaceAll(" ", "_"));
//                          },)),
                          new Text(dots,style: TextStyle(fontSize: 20)),
                          Expanded(child: InkWell(child: new Text(new List.from(listArray.reversed)[index].values.elementAt(0),style: TextStyle(fontSize: 20)),onTap: (){
                            launch("https://en.wikipedia.org/wiki/"+new List.from(listArray.reversed)[index].values.elementAt(0).replaceAll(" ", "_"));
                          },)),


                        ]);
                      },
                      separatorBuilder: (BuildContext context,
                          int index) => const Divider(),
                    ),
                  ),
                ),
              ],
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onSubmit,
        tooltip: 'Submit',
        child: Text("Submit",style: TextStyle(fontSize: 10)),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
