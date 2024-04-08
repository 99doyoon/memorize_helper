import 'package:flutter/material.dart';
import 'database_helper.dart';

class AddCategoryPage extends StatefulWidget {
  @override
  _AddCategoryPageState createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {
  final TextEditingController _categoryController = TextEditingController();

  @override
  void dispose() {
    _categoryController.dispose();
    super.dispose();
  }

  void _saveCategory() async {
    String categoryName = _categoryController.text.trim();
    if (categoryName.isEmpty) {
      // 사용자가 카테고리 이름을 입력하지 않은 경우
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('카테고리 이름을 입력해주세요.'),
        ),
      );
      return;
    }

    try {
      // 데이터베이스에 카테고리를 추가하는 로직을 구현하세요.
      await DatabaseHelper.instance.addCategory(categoryName);

      // 성공 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$categoryName 카테고리가 추가되었습니다.'),
        ),
      );

      // 카테고리 추가 후 이전 화면으로 돌아갑니다.
      Navigator.pop(context);
    } catch (e) {
      // 오류 발생 시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('카테고리 추가에 실패했습니다. 오류: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('카테고리 추가'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: _categoryController,
              decoration: InputDecoration(
                labelText: '카테고리 이름',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveCategory,
              child: Text('저장'),
            ),
          ],
        ),
      ),
    );
  }
}
