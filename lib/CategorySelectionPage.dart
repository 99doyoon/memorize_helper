import 'package:flutter/material.dart';
import 'AddWordPage.dart';
import 'database_helper.dart';
import 'AddCategoryPage.dart';

class CategorySelectionPage extends StatefulWidget {
  @override
  _CategorySelectionPageState createState() => _CategorySelectionPageState();
}

class _CategorySelectionPageState extends State<CategorySelectionPage> {
  final TextEditingController _categoryController = TextEditingController();
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

  void _addCategory(String name) async {
    if (name.isNotEmpty) {
      await DatabaseHelper.instance.addCategory(name);
      _categoryController.clear();
      _loadCategories();
    }
  }

  void _navigateToAddCategoryPage() async {
    // AddCategoryPage로 이동하고, 돌아올 때 카테고리 목록을 다시 로드합니다.
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddCategoryPage()),
    );

    // 여기서 result를 사용하여 특정 작업을 수행할 수 있습니다.
    // 예를 들어, AddCategoryPage에서 새 카테고리 추가 후 결과로 무언가를 반환하게 할 수 있습니다.
    // 현재 예제에서는 새 카테고리가 추가되었을 때 카테고리 목록을 갱신하기 위해 _loadCategories()를 호출합니다.
    _loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('카테고리 선택'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _navigateToAddCategoryPage, // 수정된 부분
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_categories[index]),
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
          ),
        ],
      ),
    );
  }
}
