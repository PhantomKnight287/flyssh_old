import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flyssh/components/input.dart';
import 'package:flyssh/constants/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class AddHostScreen extends StatefulWidget {
  const AddHostScreen({super.key});

  @override
  State<AddHostScreen> createState() => _AddHostScreenState();
}

class _AddHostScreenState extends State<AddHostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _labelController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isPasswordVisible = false;
  bool loading = false;

  void _createHost() async {
    if (_formKey.currentState!.validate() == false) {
      return;
    }
    setState(() {
      loading = true;
    });
    final prefs = await SharedPreferences.getInstance();
    final token = await prefs.getString("token")!;
    final masterKey = await prefs.getString("master_key");
    final req = await http.post(Uri.parse("$BACKEND_URL/hosts"),
        headers: {"Authorization": "Token $token", "Content-Type": "application/json"},
        body: jsonEncode({"username": _usernameController.text, "password": _passwordController.text, "label": _labelController.text, "hostname": _addressController.text, "master_key": masterKey}));
    setState(() {
      loading = false;
    });
    final body = jsonDecode(req.body);
    print(body);
    if (req.statusCode != 200 && req.statusCode != 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(body['message'] ?? "Failed to create host."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("New host created"),
        backgroundColor: Colors.green,
      ),
    );
    Get.back();
  }

  @override
  void dispose() {
    _addressController.dispose();
    _labelController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Add New Host",
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: !loading ? _createHost : null,
            icon: !loading
                ? const Icon(
                    Icons.check,
                    color: Colors.greenAccent,
                  )
                : const CircularProgressIndicator(),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Label",
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  InputField(
                    hintText: "Staging",
                    keyboardType: TextInputType.name,
                    controller: _labelController,
                    fillColor: const Color(0xff1f1e21),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(
                        color: Colors.greenAccent,
                        width: 1,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your host\'s label';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    "Ip or Hostname",
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  InputField(
                    hintText: "192.168.1.2",
                    keyboardType: TextInputType.name,
                    controller: _addressController,
                    fillColor: const Color(0xff1f1e21),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your host\'s ip or hostname';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    "Connection Username",
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  InputField(
                    hintText: "phantom",
                    keyboardType: TextInputType.name,
                    controller: _usernameController,
                    fillColor: const Color(0xff1f1e21),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your connection username';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    "Connection Password",
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  InputField(
                    hintText: "*******",
                    keyboardType: TextInputType.visiblePassword,
                    controller: _passwordController,
                    obscureText: !isPasswordVisible,
                    fillColor: const Color(0xff1f1e21),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          isPasswordVisible = !isPasswordVisible;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
