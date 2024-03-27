import 'package:flutter/material.dart';
import 'package:ssh_commander/generic_components.dart';
import 'package:ssh_commander/ssh_command.dart';

class AddSSHCommand extends StatelessWidget {
  final title = TextEditingController();
  final host = TextEditingController();
  final user = TextEditingController();
  final password = TextEditingController();
  final command = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  AddSSHCommand({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a SSH command'),
      ),
      body: GrayBorderSection(
          child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: const InputDecoration(
                      border: UnderlineInputBorder(), labelText: "Title"),
                  controller: title,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(right: 10),
              child: const Text(
                "SSH Connection Details",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            Row(
              children: [
                Flexible(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      decoration: const InputDecoration(
                          border: UnderlineInputBorder(), labelText: "Host"),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a host';
                        }else if(!RegExp(r"^(([0-9](?![0-9]{2})|[0-2])[0-9]{0,2}(\.(?=[0-9])|$)){4}").hasMatch(value)){
                          return 'Not a valid host';
                        }
                        return null;
                      },
                      controller: host,
                    ),
                  ),
                ),
                Flexible(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      decoration: const InputDecoration(
                          border: UnderlineInputBorder(), labelText: "User"),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a user';
                        }
                        return null;
                      },
                      controller: user,
                      autocorrect: false,
                      enableSuggestions: false,
                    ),
                  ),
                ),
                Flexible(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                        obscureText: true,
                        decoration: const InputDecoration(
                            border: UnderlineInputBorder(),
                            labelText: "Password"),
                        controller: password),
                  ),
                ),
              ],
            ),
            Flexible(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: const InputDecoration(
                      border: UnderlineInputBorder(), labelText: "Command"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a command';
                    }
                    return null;
                  },
                  controller: command,
                  autocorrect: false,
                  enableSuggestions: false,
                ),
              ),
            ),
            Row(
              children: [
                Flexible(
                  flex: 2,
                  fit: FlexFit.tight,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      style: const ButtonStyle(
                        shape:
                            MaterialStatePropertyAll(BeveledRectangleBorder()),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                  ),
                ),
                Flexible(
                  flex: 2,
                  fit: FlexFit.tight,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      style: const ButtonStyle(
                        shape:
                            MaterialStatePropertyAll(BeveledRectangleBorder()),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          SSHCommand.save(SSHCommand(
                              title: title.text,
                              host: host.text,
                              user: user.text,
                              password: password.text,
                              command: command.text)).then((value) {
                                if(value){
                                  Navigator.pop(context);
                                }else{
                                  showDialog(context: context, builder: (context) {
                                    return const AlertDialog(
                                      title: Text("This title already exists!"),
                                    );
                                  });
                                }
                              });
                        }
                      },
                      child: const Text("Add command"),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      )),
    );
  }
}
