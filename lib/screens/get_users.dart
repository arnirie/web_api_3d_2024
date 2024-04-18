import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class GetUsers extends StatelessWidget {
  const GetUsers({super.key});

  Future<void> register() async {
    var url = Uri.http('192.168.103.71', 'backend/users.php');
    var response = await http.post(url, body: {
      'username': 'controller',
      'password': '123',
      'fullname': 'arni tamayo'
    });
    //check the response if "ok"
  }

  Future<List<dynamic>> getUsers() async {
    //http://192.168.103.71/backend/users.php
    List<dynamic> data = [];
    var url = Uri.http('192.168.103.71', 'backend/users.php');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      data = jsonDecode(response.body);
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    getUsers();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
      ),
      body: FutureBuilder(
          future: getUsers(),
          builder: (_, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.data == null) {
              return Center(
                child: Text('No data'),
              );
            }
            var data = snapshot.data!;
            return ListView.builder(
              itemBuilder: (_, index) {
                return Card(
                    child: ListTile(title: Text(data[index]['fullname'])));
              },
              itemCount: data.length,
            );
          }),
    );
  }
}
