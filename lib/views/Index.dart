import 'package:flutter/material.dart';
import 'package:spend_tracker/views/Categories.dart';
import 'package:spend_tracker/views/Charts.dart';
import 'package:spend_tracker/views/Home.dart';
import 'package:spend_tracker/views/Table.dart';

class Index extends StatefulWidget {
  const Index({Key? key}) : super(key: key);

  @override
  State<Index> createState() => _IndexState();
}

class _IndexState extends State<Index> with AutomaticKeepAliveClientMixin{
  int _selectedIndex = 0;
  static const TextStyle optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetList = <Widget>[
    Home(),
    Categories(),
    Chart(),
    TableView(),
  ];

  final _controller = PageController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spends Tracker', style: TextStyle(color: Colors.black),),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: PageView(
        controller: _controller,
        children: _widgetList,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.blueAccent,),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list, color: Colors.blueAccent,),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart, color: Colors.blueAccent,),
            label: 'Chart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.table_chart, color: Colors.blueAccent,),
            label: 'Table',
          )
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
