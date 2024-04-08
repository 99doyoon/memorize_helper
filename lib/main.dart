import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'database_helper.dart'; // 'your_project_name'을 여러분의 프로젝트 이름으로 변경하세요.
import 'CategorySelectionPage.dart';

void main() {
  // FFI용 SQLite 데이터베이스 팩토리를 초기화합니다.
  sqfliteFfiInit();

  // 데이터베이스 팩토리를 FFI로 설정합니다. 이 부분이 핵심입니다.
  databaseFactory = databaseFactoryFfi;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '단어 저장 앱',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CategorySelectionPage(),
    );
  }
}