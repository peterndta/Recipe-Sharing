// ignore_for_file: prefer_const_constructors, prefer_final_fields, camel_case_types

import 'package:flutter/material.dart';
import '../object/category_item.dart';
import 'checkbox.dart';

class FilterCategory extends StatefulWidget {
  Function fetchInfinitePosts;

  FilterCategory({
    required this.fetchInfinitePosts,
  });

  @override
  State<FilterCategory> createState() => _FilterCategoryState();
}

class _FilterCategoryState extends State<FilterCategory> {
  Widget buildingSingleCheckbox(
      CheckboxModal select, List<dynamic> selectedItems) {
    return StatefulBuilder(builder: (context, setState) {
      return CheckboxListTile(
        value: select.value,
        title: Text(select.item.toString()),
        onChanged: (value) => setState(() {
          select.value = value!;
          (select.value)
              ? selectedItems.add(select.item)
              : selectedItems.remove(select.item);
        }),
      );
    });
  }

  TextEditingController searchController = TextEditingController();
  final checkboxListItem = [];
  final List<CategoryItem> selectedCategories = [];
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.25,
      height: MediaQuery.of(context).size.height * 0.06,
      child: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20))),
              isScrollControlled: true,
              context: context,
              builder: (BuildContext context) {
                return StatefulBuilder(builder: (BuildContext context,
                    StateSetter setModalState /*You can rename this!*/) {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height * 0.9,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(
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
                                    onPressed: () {
                                      setModalState(() {
                                        checkboxListItem.clear();
                                        selectedCategories.clear();
                                        searchController.clear();
                                      });
                                    },
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
                                  height: MediaQuery.of(context).size.height *
                                      0.023,
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.9,
                                  height:
                                      MediaQuery.of(context).size.height * 0.06,
                                  child: TextField(
                                    //autofocus: true,
                                    controller: searchController,

                                    //onSubmitted:
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      hintText: 'Keywords',
                                      suffixIcon: IconButton(
                                        onPressed: searchController.clear,
                                        icon: Icon(Icons.clear),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.022,
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
                            height: MediaQuery.of(context).size.height * 1.19,
                            padding: EdgeInsets.only(top: 5, left: 15),
                            alignment: Alignment.topLeft,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Categories',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25,
                                  ),
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.01,
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.height * 0.6,
                                  height:
                                      MediaQuery.of(context).size.height * 1.02,
                                  child: FutureBuilder(
                                      future: fetchCategories(),
                                      builder: ((context, snapshot) {
                                        if (snapshot.data == null) {
                                          return Container();
                                        } else {
                                          for (var i in snapshot.data) {
                                            checkboxListItem
                                                .add(CheckboxModal(item: i));
                                          }
                                          return ListView(
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            children: [
                                              ...checkboxListItem
                                                  .map((item) =>
                                                      buildingSingleCheckbox(
                                                          item,
                                                          selectedCategories))
                                                  .toList()
                                            ],
                                          );
                                        }
                                      })),
                                ),
                                Center(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                      minimumSize: Size(
                                          MediaQuery.of(context).size.width *
                                              0.8,
                                          MediaQuery.of(context).size.height *
                                              0.06),
                                    ),
                                    onPressed: () {
                                      List<String> categories = [];
                                      selectedCategories.forEach((element) {
                                        categories.add(element.type);
                                      });
                                      widget
                                          .fetchInfinitePosts(categories,
                                              searchController.text, 1)
                                          .whenComplete(() {
                                        Navigator.pop(context);
                                      });
                                    },
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
                    ),
                  );
                });
              });
        },
        shape: BeveledRectangleBorder(borderRadius: BorderRadius.zero),
        backgroundColor: Colors.orange,
        child: Padding(
          padding: const EdgeInsets.only(left: 5.0),
          child: Row(
            children: const [
              Icon(Icons.tune, color: Colors.white),
              Text(
                'Filter',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 18),
              )
            ],
          ),
        ),
      ),
    );
  }
}
