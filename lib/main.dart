import 'package:flutter/material.dart';
import 'database_helper.dart'; // 'your_project_name'을 여러분의 프로젝트 이름으로 변경하세요.

void main() {
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
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('단어 저장 앱'),
      ),
      body: Center(
        child: ElevatedButton(
          child: Text('단어 추가하기'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddWordPage()),
            );
          },
        ),
      ),
    );
  }
}

class AddWordPage extends StatefulWidget {
  @override
  _AddWordPageState createState() => _AddWordPageState();
}

class _AddWordPageState extends State<AddWordPage> {
  final _formKey = GlobalKey<FormState>();
  final _wordController = TextEditingController();
  final _meaningController = TextEditingController();

  @override
  void dispose() {
    _wordController.dispose();
    _meaningController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('단어 추가'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _wordController,
                decoration: InputDecoration(labelText: '단어'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '단어를 입력해주세요.';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _meaningController,
                decoration: InputDecoration(labelText: '의미'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '의미를 입력해주세요.';
                  }
                  return null;
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await DatabaseHelper.instance.insert({
                        DatabaseHelper.columnWord: _wordController.text,
                        DatabaseHelper.columnMeaning: _meaningController.text,
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: Text('추가하기'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
