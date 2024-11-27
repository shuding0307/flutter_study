import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class SecondScreen extends StatefulWidget {
  const SecondScreen({super.key});

  @override
  State<SecondScreen> createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now();
  final TextEditingController _controller = TextEditingController();

  final Map<DateTime, List<Map<String, dynamic>>> tasks = {};

  List<Map<String, dynamic>> get selectedDayTasks {
    return tasks[selectedDay] ?? [];
  }

  void _addTask(String task) {
    setState(() {
      if (tasks[selectedDay] == null) {
        tasks[selectedDay] = [];
      }
      tasks[selectedDay]!.add({'task': task, 'isChecked': false});
    });
    _controller.clear();
  }

  void _toggleCheckbox(int index) {
    setState(() {
      tasks[selectedDay]![index]['isChecked'] =
          !tasks[selectedDay]![index]['isChecked'];
    });
  }

  void _deleteTask(int index) {
    setState(() {
      tasks[selectedDay]!.removeAt(index);
      if (tasks[selectedDay]!.isEmpty) {
        tasks.remove(selectedDay);
      }
    });
  }

  Widget formatDate(BuildContext context, DateTime day) {
    switch (day.weekday) {
      case 6:
        return const Center(
          child: Text(
            '토',
            style: TextStyle(color: Colors.blue),
          ),
        );
      case 7:
        return const Center(
          child: Text(
            '일',
            style: TextStyle(color: Colors.red),
          ),
        );
      default:
        return Center(
          child: Text(['월', '화', '수', '목', '금'][day.weekday - 1]),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = selectedDay.toLocal().toString().split(' ')[0];

    return Scaffold(
      body: Column(
        children: [
          TableCalendar(
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
            focusedDay: focusedDay,
            firstDay: DateTime(2000),
            lastDay: DateTime(2100),
            selectedDayPredicate: (day) => isSameDay(selectedDay, day),
            onDaySelected: (newSelectedDay, newFocusedDay) {
              setState(() {
                selectedDay = newSelectedDay;
                focusedDay = newFocusedDay;
              });
            },
            calendarBuilders: CalendarBuilders(
              dowBuilder: (context, day) => formatDate(context, day),
            ),
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Color.fromARGB(255, 202, 202, 202),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Column(
            children: [
              Text(
                formattedDate,
                style: const TextStyle(
                  fontSize: 18,
                  color: Color.fromARGB(255, 253, 101, 91),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: selectedDayTasks.isEmpty
                ? const Center(
                    child: Text(
                      '할 일을 추가하세요.',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
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
                          icon: const Icon(Icons.delete, color: Colors.grey),
                          onPressed: () => _deleteTask(index),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.5),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: '할 일 추가',
                      border: InputBorder.none,
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
