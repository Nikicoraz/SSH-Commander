import 'package:shared_preferences/shared_preferences.dart';

class SSHCommand{
  String title;
  String host;
  String user;
  String password;
  String command;

  SSHCommand({required this.title, required this.host, required this.user, required this.password, required this.command});

  static Future<bool> save(SSHCommand s) async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    if(keys.contains(s.title)){
      return false;
    }else{
      return await prefs.setStringList(s.title, [s.host, s.user, s.password, s.command]);
    }
  }

  static Future<SSHCommand?> load(String title) async {
    final prefs = await SharedPreferences.getInstance();
    final attr = prefs.getStringList(title);
    
    if(attr == null){
      return null;
    }

    return SSHCommand(title: title, host: attr.elementAt(0), user: attr.elementAt(1), password: attr.elementAt(2), command: attr.elementAt(3));
  }
}