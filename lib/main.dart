import 'dart:convert';

import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ssh_commander/add_ssh_command.dart';
import 'package:ssh_commander/generic_components.dart';
import 'package:ssh_commander/ssh_command.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  MainAppState createState() => MainAppState();
}

class MainAppState extends State<MainApp> {
  List<SSHCommand> commandList = [];

  void _loadList() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();

    commandList.clear();

    for (var key in keys) {
      final s = await SSHCommand.load(key);
      if (s != null) {
        setState(() {
          commandList.add(s);
        });
      }
    }
  }

  void _removeCommand(SSHCommand command) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(command.title);

    setState(() {
      commandList.remove(command);
    });
  }

  @override
  void initState() {
    super.initState();
    _loadList();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "SSH Commander",
      home: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppBar(
                title: const Text("SSH Commander"),
                backgroundColor: Colors.yellow,
              ),
              GrayBorderSection(
                child: Builder(builder: (context) {
                  return ElevatedButton(
                    style: const ButtonStyle(
                      shape: MaterialStatePropertyAll(BeveledRectangleBorder()),
                    ),
                    onPressed: () {
                      Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AddSSHCommand()))
                          .then((value) => _loadList());
                    },
                    child: const Text("Add new command"),
                  );
                }),
              ),
              GrayBorderSection(
                child: Column(
                  children: [
                    const Text(
                      "SSH Commands",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                    for (var c in commandList)
                      SSHCommandWidget(command: c, parent: this),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class SSHCommandWidget extends StatelessWidget {
  final SSHCommand command;
  final MainAppState parent;

  const SSHCommandWidget(
      {super.key, required this.command, required this.parent});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 5, bottom: 5),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
        ),
        padding: const EdgeInsets.all(4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              flex: 7,
              child: Center(child: Text(command.title)),
            ),
            Flexible(
              flex: 4,
              fit: FlexFit.tight,
              child: ElevatedButton(
                style: const ButtonStyle(
                    shape: MaterialStatePropertyAll(BeveledRectangleBorder())),
                onPressed: () {
                  executeSSHCommand(command.host, command.user,
                          command.password, command.command)
                      .then((value) {
                    Navigator.pop(context);
                    showDialog(
                        context: context,
                        builder: (context) {
                          return Dialog(
                              child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      color: Colors.black),
                                  padding: const EdgeInsets.all(20),
                                  width: 500,
                                  child: SingleChildScrollView(
                                    child: Center(
                                      child: Column(children: [
                                        const Text(
                                          "RESULT",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                        const SizedBox(height: 15),
                                        Text(
                                          value,
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                      ]),
                                    ),
                                  )));
                        });
                  });
                  showDialog(
                      context: context,
                      builder: (context) {
                        return Dialog(
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15)),
                            padding: const EdgeInsets.all(20),
                            height: 300,
                            width: 500,
                            child: const Column(
                              children: [
                                CircularProgressIndicator(),
                              ],
                            ),
                          ),
                        );
                      });
                },
                child: const Text("Execute"),
              ),
            ),
            Flexible(
              flex: 1,
              child: IconButton(
                  icon: const Icon(
                    Icons.remove_circle_outline,
                    color: Colors.red,
                  ),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text("Remove command"),
                            content: const Text("Are you sure you want to remove this command?"),
                            actions: [
                              TextButton(
                                child: const Text("Yes"),
                                onPressed: () {
                                  parent._removeCommand(command);
                                  Navigator.pop(context);
                                },
                              ),
                              TextButton(
                                child: const Text("Cancel"),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              )
                            ],
                          );
                        });
                    //  parent._removeCommand(command),
                  }),
            )
          ],
        ),
      ),
    );
  }
}

Future<String> executeSSHCommand(
    String host, String user, String password, String command) async {
  final connection = SSHClient(
    await SSHSocket.connect(host, 22),
    username: user,
    onPasswordRequest: () => password,
  );

  command = command.replaceAll("sudo", "echo '$password' | sudo -S ");

  final ret = utf8.decode(await connection.run(command));

  return ret.isEmpty || ret == "[sudo] password for $user: " ? "Command executed successfully" : ret;
}
