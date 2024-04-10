import 'package:flutter/material.dart';
import 'database_helper.dart';

class AddWordPage extends StatefulWidget {
  final String category;

  AddWordPage({Key? key, required this.category}) : super(key: key);

  @override
  _AddWordPageState createState() => _AddWordPageState();
}

class _AddWordPageState extends State<AddWordPage> {
  final TextEditingController _wordController = TextEditingController();
  final TextEditingController _meaningController = TextEditingController();

  List<Map<String, dynamic>> _words = [];

  @override
  void dispose() {
    _wordController.dispose();
    _meaningController.dispose();
    super.dispose();
  }

  void _addNewWord() async {
    String word = _wordController.text.trim();
    String meaning = _meaningController.text.trim();
    if (word.isEmpty || meaning.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('단어와 뜻을 모두 입력해주세요.'),
        ),
      );
      return;
    }

    try {
      await DatabaseHelper.instance.addWord(word, meaning);
      _refreshWords();
      _wordController.clear();
      _meaningController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$word 단어가 추가되었습니다.'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('단어 추가에 실패했습니다. 오류: $e'),
        ),
      );
    }
  }

  void _deleteWord(String word) async {
    try {
      await DatabaseHelper.instance.deleteWord(word);
      _refreshWords();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$word 단어가 삭제되었습니다.'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('단어 삭제에 실패했습니다. 오류: $e'),
        ),
      );
    }
  }

  void _refreshWords() async {
    List<Map<String, dynamic>> updatedWords = await DatabaseHelper.instance.getWords();
    setState(() {
      _words = updatedWords;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('단어 추가/삭제'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                TextField(
                  controller: _wordController,
                  decoration: InputDecoration(hintText: '단어를 입력하세요'),
                ),
                TextField(
                  controller: _meaningController,
                  decoration: InputDecoration(hintText: '뜻을 입력하세요'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _addNewWord,
                  child: Text('단어 추가'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _words.length,
              itemBuilder: (context, index) {
                final word = _words[index];
                return ListTile(
                  title: Text(word['word']),
                  subtitle: Text(word['meaning']),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _deleteWord(word['word']),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _refreshWords();
  }
}
