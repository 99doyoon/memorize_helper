import 'package:flutter/material.dart';
import 'dart:math';
import 'database_helper.dart';
import 'AddWordPage.dart';
import 'package:flutter_tts/flutter_tts.dart'; // 이 줄을 추가하세요

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
  final FlutterTts flutterTts = FlutterTts(); // 이 줄을 추가하세요

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
    // 기존 _checkAnswer 메소드의 로직...
  }

  Future<void> _speak(String text) async { // 이 메소드를 추가하세요
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.category} 단어 퀴즈'),
        actions: [ // 발음 듣기 버튼을 앱 바에 추가
          IconButton(
            icon: Icon(Icons.volume_up),
            onPressed: _shuffledWords.isNotEmpty ? () => _speak(_shuffledWords.first['word']) : null,
          ),
        ],
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
