import 'package:flutter/material.dart';
import 'package:study_flutter/screens/fourth_screen.dart';
import 'package:study_flutter/screens/second_screen.dart';
import 'package:study_flutter/screens/third_screen.dart';
import 'package:study_flutter/widgets/bottom_nav.dart';

void main() {
  runApp(const Main());
}

class Main extends StatelessWidget {
  const Main({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: false,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const SecondScreen(),
    const ThirdScreen(),
    const FourthScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
      _pageController.jumpToPage(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getAppBarTitle(),
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red[200],
      ),
      body: GestureDetector(
        onHorizontalDragUpdate: (_) {},
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: _pages,
        ),
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Home';
      case 1:
        return 'Second';
      case 2:
        return '메모장';
      case 3:
        return 'Fourth';
      default:
        return 'Home';
    }
  }
}
