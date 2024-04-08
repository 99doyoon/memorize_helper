import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
// 데이터베이스 헬퍼 클래스를 임포트해야 합니다.
// import 'path_to_your_database_helper.dart';

class AddWordPage extends StatefulWidget {
  final String category;

  AddWordPage({Key? key, required this.category}) : super(key: key);

  @override
  _AddWordPageState createState() => _AddWordPageState();
}

class _AddWordPageState extends State<AddWordPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _wordController = TextEditingController();
  final TextEditingController _meaningController = TextEditingController();

  @override
  void dispose() {
    _wordController.dispose();
    _meaningController.dispose();
    super.dispose();
  }

  void _saveWord() async {
    if (_formKey.currentState!.validate()) {
      String word = _wordController.text.trim();
      String meaning = _meaningController.text.trim();
      if (word.isNotEmpty && meaning.isNotEmpty) {
        // 데이터베이스에 단어와 의미를 추가하는 로직을 구현하세요.
        // 예: await DatabaseHelper.instance.addWord(widget.category, word, meaning);

        // 단어 추가 후 이전 화면으로 돌아갑니다.
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.category}에 단어 추가'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: _wordController,
                decoration: InputDecoration(
                  labelText: '단어',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '단어를 입력해주세요';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _meaningController,
                decoration: InputDecoration(
                  labelText: '의미',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '의미를 입력해주세요';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveWord,
                child: Text('저장'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
