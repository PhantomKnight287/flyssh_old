import 'dart:convert';

import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/material.dart';
import 'package:flyssh/constants/main.dart';
import 'package:flyssh/virtual_keyboard.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xterm/xterm.dart';
import 'package:http/http.dart' as http;
import 'package:ansicolor/ansicolor.dart';

class SshScreen extends StatefulWidget {
  final String username;
  final int id;
  final String? password;
  final String? address;
  final String? label;
  const SshScreen({
    super.key,
    required this.username,
    required this.id,
    this.password,
    this.address,
    this.label,
  });

  @override
  State<SshScreen> createState() => _SshScreenState();
}

class _SshScreenState extends State<SshScreen> {
  late final terminal = Terminal(inputHandler: keyboard);
  final keyboard = VirtualKeyboard(defaultInputHandler);
  late var title = widget.address;
  late final SSHSession session;
  bool loaded = false;

  @override
  void initState() {
    super.initState();
    initTerminal();
  }

  @override
  void dispose() {
    super.dispose();
    session?.close();
  }

  Future<void> initTerminal() async {
    final prefs = await SharedPreferences.getInstance();
    final master_key = prefs.getString("master_key");
    final token = prefs.getString("token");

    final req = await http.post(Uri.parse("$BACKEND_URL/hosts/password"),
        headers: {"Authorization": "Token $token", "Content-Type": "application/json"}, body: jsonEncode({"master_key": master_key, "id": widget.id}));
    if (req.statusCode != 200) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Failed to connect to host"),
        backgroundColor: Colors.red,
      ));
      return;
    }
    final body = jsonDecode(req.body);
    terminal.write("Connecting...\r\n");
    try {
      SSHClient client;
      if (body["key"] == false) {
        client = SSHClient(await SSHSocket.connect(widget.address!, 22), username: widget.username, onPasswordRequest: () => body['password']);
      } else {
        client = SSHClient(await SSHSocket.connect(widget.address!, 22), username: widget.username, identities: [
          ...SSHKeyPair.fromPem(body["password"], body['passphrase']),
        ]);
      }
      session = await client.shell(
          pty: SSHPtyConfig(
        width: terminal.viewHeight,
        height: terminal.viewHeight,
      ));
      setState(() {
        loaded = true;
      });
      terminal.onResize = (width, height, pixelWidth, pixelHeight) {
        session.resizeTerminal(width, height, pixelWidth, pixelHeight);
      };

      terminal.onOutput = (data) {
        session.write(utf8.encode(data));
      };

      session.stdout.cast<List<int>>().transform(const Utf8Decoder()).listen(terminal.write);

      session.stderr.cast<List<int>>().transform(const Utf8Decoder()).listen(terminal.write);
      terminal.write("Connected\r\n");
      terminal.buffer.clear();
      terminal.buffer.setCursor(0, 0);

      terminal.onTitleChange = (title) {
        setState(() {
          this.title = title;
        });
      };
      await session.done;
      Get.back();
    } catch (e) {
      AnsiPen pen = AnsiPen()..red(bold: true);
      terminal.write(pen(e.toString()));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Failed to connect to host"),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.label ?? widget.username),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!loaded)
            const Center(
              child: CircularProgressIndicator(),
            ),
          if (!loaded)
            Column(
              children: [
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Connecting to ${widget.label ?? widget.username}",
                ),
              ],
            ),
          if (loaded)
            Expanded(
              child: TerminalView(
                terminal,
                cursorType: TerminalCursorType.block,
              ),
            ),
          if (loaded) VirtualKeyboardView(keyboard),
        ],
      ),
    );
  }
}
