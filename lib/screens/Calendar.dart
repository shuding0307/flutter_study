import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  DateTime selectedDay = DateTime.now();
  final TextEditingController _controller = TextEditingController();
  Map<String, List<Map<String, dynamic>>> tasks = {}; // 날짜별 할 일 목록

  @override
  void initState() {
    super.initState();
    _loadTasks(); // 앱 시작 시 할 일 목록 불러오기
  }

  // SharedPreferences에서 할 일 목록 불러오기
  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? savedTasks = prefs.getStringList('tasks');

    if (savedTasks != null) {
      setState(() {
        tasks = savedTasks.fold({},
            (Map<String, List<Map<String, dynamic>>> acc, task) {
          final taskMap = json.decode(task);
          final date = taskMap['date'];
          if (acc[date] == null) {
            acc[date] = [];
          }
          acc[date]!.add({
            'task': taskMap['task'],
            'isChecked': taskMap['isChecked'],
          });
          return acc;
        });
      });
    }
  }

  // SharedPreferences에 할 일 목록 저장
  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> encodedTasks = [];

    tasks.forEach((date, taskList) {
      for (var task in taskList) {
        encodedTasks.add(json.encode({
          'date': date,
          'task': task['task'],
          'isChecked': task['isChecked'],
        }));
      }
    });
    await prefs.setStringList('tasks', encodedTasks);
  }

  // 할 일 추가
  void _addTask(String task) {
    setState(() {
      final dateString = selectedDay
          .toIso8601String()
          .split('T')[0]; // 날짜를 "yyyy-MM-dd" 형식으로 변환
      if (tasks[dateString] == null) {
        tasks[dateString] = [];
      }
      tasks[dateString]!.add({'task': task, 'isChecked': false});
    });
    _controller.clear();
    _saveTasks();
  }

  // 체크박스 상태 변경
  void _toggleCheckbox(int index) {
    setState(() {
      final dateString = selectedDay.toIso8601String().split('T')[0];
      tasks[dateString]![index]['isChecked'] =
          !tasks[dateString]![index]['isChecked'];
    });
    _saveTasks();
  }

  // 할 일 삭제
  void _deleteTask(int index) {
    setState(() {
      final dateString = selectedDay.toIso8601String().split('T')[0];
      tasks[dateString]!.removeAt(index);
      if (tasks[dateString]!.isEmpty) {
        tasks.remove(dateString);
      }
    });
    _saveTasks();
  }

  // 선택한 날짜의 할 일 목록
  List<Map<String, dynamic>> get selectedDayTasks {
    final dateString = selectedDay.toIso8601String().split('T')[0];
    return tasks[dateString] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Todo App')),
      body: Column(
        children: [
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
          Expanded(
            child: selectedDayTasks.isEmpty
                ? const Center(child: Text('할 일이 없습니다.'))
                : ListView.builder(
                    itemCount: selectedDayTasks.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: Checkbox(
                          value: selectedDayTasks[index]['isChecked'],
                          onChanged: (_) => _toggleCheckbox(index),
                        ),
                        title: Text(
                          selectedDayTasks[index]['task'],
                          style: TextStyle(
                            decoration: selectedDayTasks[index]['isChecked']
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteTask(index),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
