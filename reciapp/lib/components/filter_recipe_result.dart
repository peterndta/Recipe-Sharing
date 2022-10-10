// ignore_for_file: prefer_const_constructors, prefer_final_fields

import 'package:flutter/material.dart';
import 'checkbox.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class FilterRecipeResult extends StatefulWidget {
  bool isSelected;

  FilterRecipeResult(this.isSelected);

  @override
  State<FilterRecipeResult> createState() => _FilterRecipeResultState();
}

class Continent {
  int id;
  String continent;
  Continent(this.id, this.continent);
}

class Use {
  int id;
  String usesOfFood;
  Use(this.id, this.usesOfFood);
}

class _FilterRecipeResultState extends State<FilterRecipeResult> {
  var _controller = TextEditingController();
  bool isSelected = false;

  Future getContinentData() async {
    var response = await http.get(
      Uri.parse('https://reciapp.azurewebsites.net/api/RecipeRegions'),
      headers: {
        "content-type": "application/json",
        "accept": "application/json",
      },
    );
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      List<Continent> continents = [];
      for (var cate in jsonData['data']) {
        Continent continent = Continent(cate['id'], cate['continents']);
        continents.add(continent);
      }
      // print(methods.length);
      // print(methods);
      return continents;
    }
  }

  Future getUseData() async {
    var response = await http.get(
      Uri.parse('https://reciapp.azurewebsites.net/api/Uses'),
      headers: {
        "content-type": "application/json",
        "accept": "application/json",
      },
    );
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      List<Use> uses = [];
      for (var cate in jsonData['data']) {
        Use use = Use(cate['id'], cate['usesOfFood']);
        uses.add(use);
      }
      // print(methods.length);
      // print(methods);
      return uses;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        showModalBottomSheet(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            isScrollControlled: true,
            context: context,
            builder: (BuildContext context) {
              return Container(
                height: MediaQuery.of(context).size.height * 0.9,
                // color: Colors.amber,
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  // mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.orange,
                            width: 3.0,
                          ),
                        ),
                      ),
                      height: MediaQuery.of(context).size.height * 0.08,
                      // color: Colors.red,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CloseButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          Text(
                            'Filter',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(right: 10),
                            child: OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.all(5),
                                side: BorderSide(
                                    width: 1.0, color: Colors.orange),
                                shape: RoundedRectangleBorder(),
                                backgroundColor: Colors.white,
                              ),
                              child: Text(
                                'Clear All',
                                style: TextStyle(
                                    fontSize: 17, color: Colors.black),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 15, left: 15),
                      // alignment: Alignment.bottomLeft,
                      height: MediaQuery.of(context).size.height * 0.17,
                      child: Column(
                        // mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Recipe or Keyword',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.023,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.9,
                            height: MediaQuery.of(context).size.height * 0.06,
                            child: TextField(
                              controller: _controller,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Keywords',
                                suffixIcon: IconButton(
                                  onPressed: _controller.clear,
                                  icon: Icon(Icons.clear),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.022,
                          ),
                          Divider(
                            color: Colors.orange,
                            height: 3,
                            thickness: 2,
                            indent: 50,
                            endIndent: 60,
                          ),
                        ],
                      ),
                      // color: Colors.yellow,
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.25,
                      padding: EdgeInsets.only(top: 5, left: 15),
                      alignment: Alignment.topLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Continents',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 25,
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.8,
                            height: MediaQuery.of(context).size.height * 0.15,
                            child: FutureBuilder(
                                future: getContinentData(),
                                builder: ((context, snapshot) {
                                  if (snapshot.data == null) {
                                    return Container();
                                  } else {
                                    return ListView.builder(
                                      itemCount: snapshot.data.length,
                                      itemBuilder: (context, index) => CheckBox(
                                          isSelected,
                                          snapshot.data[index].continent),
                                    );
                                  }
                                })),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02,
                          ),
                          Divider(
                            color: Colors.orange,
                            height: 3,
                            thickness: 2,
                            indent: 50,
                            endIndent: 60,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.35,
                      padding: EdgeInsets.only(top: 5, left: 15),
                      alignment: Alignment.topLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Uses',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 25,
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.8,
                            height: MediaQuery.of(context).size.height * 0.2,
                            child: FutureBuilder(
                                future: getUseData(),
                                builder: ((context, snapshot) {
                                  if (snapshot.data == null) {
                                    return Container();
                                  } else {
                                    return ListView.builder(
                                      itemCount: snapshot.data.length,
                                      itemBuilder: (context, index) => CheckBox(
                                          isSelected,
                                          snapshot.data[index].usesOfFood),
                                    );
                                  }
                                })),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02,
                          ),
                          Center(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                minimumSize: Size(
                                    MediaQuery.of(context).size.width * 0.8,
                                    MediaQuery.of(context).size.height * 0.06),
                              ),
                              onPressed: () {},
                              child: const Text(
                                'Show Result',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25,
                                    color: Colors.white),
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              );
            });
      },
      shape: BeveledRectangleBorder(borderRadius: BorderRadius.zero),
      backgroundColor: Colors.orange,
      child: Icon(Icons.tune),
    );
  }
}
