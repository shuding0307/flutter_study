import 'package:flutter/material.dart';

class ThirdScreen extends StatefulWidget {
  const ThirdScreen({super.key});

  @override
  State<ThirdScreen> createState() => _ThirdScreenState();
}

class _ThirdScreenState extends State<ThirdScreen> {
  final TextEditingController _controller = TextEditingController();

  List<Map<String, dynamic>> tasks = [
    {'task': '할 일 1', 'isChecked': false},
    {'task': '오늘 할 일', 'isChecked': false},
  ];

  void _addTask(String task) {
    setState(() {
      tasks.add({'task': task, 'isChecked': false});
    });
    _controller.clear();
  }

  void _toggleCheckbox(int index) {
    setState(() {
      tasks[index]['isChecked'] = !tasks[index]['isChecked'];
    });
  }

  void _deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isTaskListEmpty = tasks.isEmpty;

    return Scaffold(
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '오늘 할 일',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(width: 10),
                Icon(Icons.plagiarism_rounded),
              ],
            ),
          ),
          Expanded(
            child: isTaskListEmpty
                ? const Center(
                    child: Text(
                      '할 일을 추가하세요.',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: Checkbox(
                          value: tasks[index]['isChecked'],
                          onChanged: (_) => _toggleCheckbox(index),
                        ),
                        title: Text(
                          tasks[index]['task'],
                          style: TextStyle(
                            decoration: tasks[index]['isChecked']
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.grey,
                          ),
                          onPressed: () => _deleteTask(index),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: '할 일 추가',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      _addTask(_controller.text);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
