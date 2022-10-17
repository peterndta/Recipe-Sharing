import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reciapp/components/infinite_scroll.dart';

import '../login_support/check_auth.dart';
import '../components/copyright.dart';
import '../object/get_posts_homepage.dart';
import '../object/recipe_review.dart';
import 'package:http/http.dart' as http;

class CollectionPage extends StatefulWidget {
  CollectionPage(this.userId, {super.key});
  final int userId;

  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  TextEditingController keywords = TextEditingController();
  final controller = ScrollController();
  int page = 1;
  bool isLoading = false;
  bool hasMore = true;
  Future fetchInfinitePosts(int userId) async {
    if (isLoading) return;
    isLoading = true;
    const limit = 6;
    http.Response response = await http.get(
      Uri.parse(
          'https://reciapp.azurewebsites.net/api/user/$userId/post/page/$page?PageSize=$limit'),
      headers: {
        "content-type": "application/json",
        "accept": "application/json",
      },
    );
    if (response.statusCode == 200) {
      var responseJson = json.decode(response.body);
      if (!mounted) return;
      setState(() {
        //final List jsonData = responseJson['data'];
        isLoading = false;
        page++;
        if (responseJson['data'].length < limit) {
          hasMore = false;
        }
        _listReciepReviews.addAll(responseJson['data']
            .map<GetPosts>((p) => GetPosts.fromJson(p))
            .toList());
      });
    }
  }

  int userId = 0;

  @override
  void initState() {
    super.initState();
    userId = widget.userId;
    print("User ID: $userId");
    fetchInfinitePosts(userId);
    controller.addListener(() {
      if (controller.position.maxScrollExtent == controller.offset) {
        fetchInfinitePosts(userId);
        print(' more');
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  final List<GetPosts> _listReciepReviews = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('User Bookmark'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.orange,
        titleTextStyle: const TextStyle(
            fontSize: 28, fontWeight: FontWeight.bold, color: Colors.orange),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
        child: Column(
          children: [
            Container(
              alignment: Alignment.topCenter,
              height: MediaQuery.of(context).size.height * 0.1,
              child: Form(
                  child: TextFormField(
                      validator: (String? value) {
                        return (value == null || value.isEmpty)
                            ? 'Please enter'
                            : null;
                      },
                      controller: keywords,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Search Key',
                        alignLabelWithHint: false,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                        ),
                      ))),
            ),
            ListRecipeReview(0.72, _listReciepReviews, controller, hasMore)
          ],
        ),
      ),
      bottomNavigationBar: const Copyright(),
    );
  }
}
