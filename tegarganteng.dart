import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

void main() => runApp(MyApp());

Future<List<Todos>> fetchPosts() async {
  final response = await http
      .get(Uri.parse('https://calm-plum-jaguar-tutu.cyclic.app/todos'));
  if (response.statusCode == 200) {
    final List<dynamic> jsonResponse = json.decode(response.body)['data'];
    List<Todos> posts =
        jsonResponse.map((dynamic item) => Todos.fromJson(item)).toList();
    return posts;
  } else {
    throw Exception('Failed to load posts');
  }
}

class Todos {
  final String id;
  final String todoName;
  final bool isComplete;
  final String createdAt;
  final String updatedAt;

  Todos(
      {required this.id,
      required this.todoName,
      required this.isComplete,
      required this.createdAt,
      required this.updatedAt});

  factory Todos.fromJson(Map<String, dynamic> json) {
    return Todos(
      id: json['_id'] ?? '',
      todoName: json['todoName'] ?? '',
      isComplete: json['isComplete'] ?? false,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final Future<List<Todos>> todos = fetchPosts();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todos from API'),
      ),
      body: Center(
        child: FutureBuilder<List<Todos>>(
          future: todos,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 5,
                    margin: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    child: ListTile(
                      title: Text(snapshot.data![index].todoName,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      subtitle: Text(
                          ' ${snapshot.data![index].isComplete.toString()}',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DetailScreen(post: snapshot.data![index]),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}

class DetailScreen extends StatelessWidget {
  final Todos post;
  DetailScreen({required this.post});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Post Detail'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text('ID: ${post.id}',
            //     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            // SizedBox(height: 8),
            Text('Name: ${post.todoName}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Is Complete: ${post.isComplete}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            // Text('Created At: ${post.createdAt}',
            //     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            // SizedBox(height: 8),
            // Text('Updated At: ${post.updatedAt}',
            //     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
