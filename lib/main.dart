import 'package:flutter/material.dart';
import 'package:app/utils/platform_util.dart';
import 'package:app/home.dart';
import 'package:flutter/cupertino.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    if (isCupertino()) {
      return const CupertinoApp(title: 'Flutter Demo', home: TodoListScreen());
    }
    return const Text("The app is not running on a Cupertino platform");
  }
}
