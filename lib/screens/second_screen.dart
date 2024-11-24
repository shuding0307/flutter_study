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

  formatDate(BuildContext context, DateTime day) {
    switch (day.weekday) {
      case 1:
        return const Center(
          child: Text('월'),
        );
      case 2:
        return const Center(
          child: Text('화'),
        );
      case 3:
        return const Center(
          child: Text('수'),
        );
      case 4:
        return const Center(
          child: Text('목'),
        );
      case 5:
        return const Center(
          child: Text('금'),
        );
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
    }
    return null;
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
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                this.selectedDay = selectedDay;
                this.focusedDay = focusedDay;
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
          Container(
            height: 30,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                '선택된날짜',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              Text(
                formattedDate,
                style: const TextStyle(
                  fontSize: 18,
                  color: Color.fromARGB(255, 253, 101, 91),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
