import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flyssh/constants/main.dart';
import 'package:flyssh/models/host.dart';
import 'package:flyssh/screens/hosts/add.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_spinkit/flutter_spinkit.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<List<Host>> fetchHosts() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token")!;
    final req = await http.get(Uri.parse("$BACKEND_URL/hosts"), headers: {"Authorization": "Token $token"});
    final body = jsonDecode(req.body) as List<dynamic>;
    return body.map((e) => Host(hostname: e['hostname'], username: e['username'], key: e['key'], label: e['label'], password: e['password'])).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => const AddHostScreen(), transition: Transition.rightToLeftWithFade)?.then((value) => setState(() {}));
        },
        child: const Icon(
          Icons.add,
        ),
      ),
      appBar: AppBar(
        title: const Text(
          "Hosts",
          style: TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
          )
        ],
      ),
      drawer: const Drawer(),
      body: FutureBuilder<List<Host>>(
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SpinKitFadingCircle(
              itemBuilder: (BuildContext context, int index) {
                return DecoratedBox(
                  decoration: BoxDecoration(
                    color: index.isEven ? Colors.red : Colors.green,
                  ),
                );
              },
            );
          }
          if (snapshot.hasData) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.separated(
                itemBuilder: (context, index) {
                  final host = snapshot.data![index];
                  return ListTile(
                    title: Text(host.label ?? host.hostname),
                    tileColor: Colors.grey.shade900,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    subtitle: Text(
                      "ssh, ${host.username}",
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    enabled: true,
                    onTap: () {},
                    onLongPress: () {},
                    leading: Container(
                      decoration: BoxDecoration(
                        color: Colors.teal,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: const Icon(Icons.terminal),
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return const SizedBox();
                },
                itemCount: snapshot.data!.length,
              ),
            );
          }
          return const SizedBox();
        },
        initialData: const [],
        future: fetchHosts(),
      ),
    );
  }
}
