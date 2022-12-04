import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

void main() {
  runApp(const MyApp());
}

///
class MyApp extends StatelessWidget {
  ///
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

///
class HomePage extends StatefulWidget {
  ///
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final accessKey = 'Cqo8u4OPs6uEOwpd82sfOcdfXuk3nsjkBf1u5C1hbM0';
  bool isLoading = true;
  final nrImages = 30;
  List<String> images = [];
  final scrollController = ScrollController();

  Future<void> _getImages() async {
    setState(() {
      isLoading = true;
    });
    final url =
        'https://api.unsplash.com/photos/random/?count=$nrImages&client_id=$accessKey';
    final response = await get(Uri.parse(url));
    final jsonListImages =
        jsonDecode(response.body) as List<Map<dynamic, dynamic>>;
    for (final item in jsonListImages) {
      final urls = item['urls'] as Map<String, dynamic>;
      images.add(urls['small'] as String);
    }
    setState(() => isLoading = false);
  }

  void onScroll() {
    if (scrollController.offset >=
        scrollController.position.maxScrollExtent -
            MediaQuery.of(context).size.height / 2) {
      _getImages();
    }
  }

  @override
  void initState() {
    super.initState();
    _getImages();
    scrollController.addListener(onScroll);
  }

  Future<void> _refresh() async {
    return Future(() {
      images = [];
      _getImages();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text('Images!!!'),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: CustomScrollView(
          controller: scrollController,
          slivers: <Widget>[
            SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 350,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return Image.network(images[index]);
                },
                childCount: images.length,
              ),
            ),
            SliverToBoxAdapter(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : const SizedBox(
                      width: 100,
                      height: 100,
                    ),
            )
          ],
        ),
      ),
    );
  }
}
