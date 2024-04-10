import 'package:flutter/material.dart';
import 'AddWordPage.dart';  // 단어 추가 페이지
import 'database_helper.dart';  // 데이터베이스 헬퍼
import 'AddCategoryPage.dart';  // 카테고리 추가 페이지

class CategorySelectionPage extends StatefulWidget {
  @override
  _CategorySelectionPageState createState() => _CategorySelectionPageState();
}

class _CategorySelectionPageState extends State<CategorySelectionPage> {
  List<String> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  void _loadCategories() async {
    final categories = await DatabaseHelper.instance.getCategories();
    setState(() {
      _categories = categories;
    });
  }

  void _navigateToAddCategoryPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddCategoryPage()),
    );
    _loadCategories();
  }

  void _deleteCategory(String name) async {
    bool confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('카테고리 삭제'),
          content: Text('$name 카테고리를 삭제하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              child: Text('취소'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text('삭제'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirm) {
      await DatabaseHelper.instance.deleteCategory(name);
      _loadCategories();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('$name 카테고리가 삭제되었습니다.'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('카테고리 선택'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _navigateToAddCategoryPage,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_categories[index]),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => _deleteCategory(_categories[index]),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddWordPage(category: _categories[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
