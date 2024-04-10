import 'package:flutter/material.dart';
import 'dart:math';
import 'database_helper.dart';
import 'AddWordPage.dart';

class WordTestPage extends StatefulWidget {
  final String category;

  WordTestPage({Key? key, required this.category}) : super(key: key);

  @override
  _WordTestPageState createState() => _WordTestPageState();
}

class _WordTestPageState extends State<WordTestPage> {
  late List<Map<String, dynamic>> _words;
  late List<Map<String, dynamic>> _shuffledWords;
  final TextEditingController _answerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadWords();
  }

  void _loadWords() async {
    List<Map<String, dynamic>> words = await DatabaseHelper.instance.getWords(widget.category);
    setState(() {
      _words = words;
      _shuffledWords = List.from(_words)..shuffle(Random());
    });
  }

  void _checkAnswer() {
    if (_shuffledWords.isNotEmpty) {
      String correctAnswer = _shuffledWords.first['word'].toString().trim().toLowerCase();
      if (_answerController.text.trim().toLowerCase() == correctAnswer) {
        // 정답인 경우
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('정답입니다!'),
          duration: Duration(seconds: 2),
        ));
        _shuffledWords.removeAt(0); // 정답인 단어를 리스트에서 제거
      } else {
        // 오답인 경우
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('틀렸습니다.'),
          duration: Duration(seconds: 2),
        ));
        _shuffledWords.add(_shuffledWords.removeAt(0)); // 틀린 단어를 리스트의 맨 끝으로 이동
      }
      _answerController.clear();
    } else {
      // 모든 단어를 클리어했을 때의 로직
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('축하합니다!'),
            content: Text('모든 단어를 클리어하셨습니다!'),
            actions: <Widget>[
              TextButton(
                child: Text('돌아가기'),
                onPressed: () {
                  Navigator.of(context).pop(); // 대화상자 닫기
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => AddWordPage(category: widget.category))// AddWordPage로 이동
                  );
                },
              ),
            ],
          );
        },
      );
    }
    setState(() {});
  }


  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.category} 단어 퀴즈'),
      ),
      body: _shuffledWords == null
          ? Center(child: CircularProgressIndicator())
          : _shuffledWords.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('모든 단어를 클리어하셨습니다!'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => AddWordPage(category: widget.category))
                );
              },
              child: Text('돌아가기'),
            ),
          ],
        ),
      )
          : Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('단어의 철자를 입력하세요:'),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(_shuffledWords.first['meaning']),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: _answerController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: '단어의 철자',
              ),
              onSubmitted: (value) {
                _checkAnswer();
              },
            ),
          ),
        ],
      ),
    );
  }
}
