import 'package:bubble_bottom_bar/bubble_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_extra_fields/form_builder_extra_fields.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spend_tracker/models/FilterModel.dart';
import 'package:spend_tracker/views/Categories.dart';
import 'package:spend_tracker/views/Charts.dart';
import 'package:spend_tracker/views/Home.dart';
import 'package:spend_tracker/views/Settings.dart';
import 'package:spend_tracker/views/Table.dart';
import 'package:intl/intl.dart';
import '../Utils/Transformation.dart';
import '../models/CategoryModel.dart';

class Index extends StatefulWidget {
  const Index({Key? key}) : super(key: key);

  @override
  State<Index> createState() => _IndexState();
}

class _IndexState extends State<Index> with AutomaticKeepAliveClientMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<CategoryModel> categories = [];
  int _selectedIndex = 0;
  FilterModel filter = FilterModel();

  final _controller = PageController();

  @override
  void initState() {
    super.initState();
    if (mounted) {
      _loadCategories();
      setInitialPreference();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    if (mounted) filter.dispose();
    super.dispose();
  }

  void _loadCategories() {
    CategoryModel.getList(limit: 100).then((response) {
      setState(() {
        categories = response.items as List<CategoryModel>;
      });
    });
  }

  void _onItemTapped(int? index) {
    setState(() {
      _selectedIndex = index!;
    });
    _controller.animateToPage(
      index!,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  void setInitialPreference() async {
    final prefs = await SharedPreferences.getInstance();
    String? currency = prefs.getString('currency');
    String? symbol = prefs.getString('symbol');
    if (currency == null && symbol == null) {
      prefs.setString('currency', 'Dollar');
      prefs.setString('symbol', '\$');
    }
  }

  void showFilterModal(BuildContext context) {
    try {
      Widget cancelButton = TextButton(
        child: const Text('Cancel'),
        onPressed:  () {
          Navigator.of(context).pop();
        },
      );

      // set up the AlertDialog
      AlertDialog alert = AlertDialog(
        title: const Text('Filter'),
        content: FormBuilder(
          child: SingleChildScrollView(
            child: Column(
              children: [
                FormBuilderDateRangePicker(
                  name: 'dateRange',
                  firstDate: DateTime(1970),
                  lastDate: DateTime(2030),
                  format: DateFormat('dd/MM/yyyy'),
                  onChanged: (dateTimeRange) {
                    setState(() {
                      filter.dateRange = dateTimeRange;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Date Range',
                  ),
                ),
                FormBuilderTypeAhead<String>(
                  decoration: const InputDecoration(
                    labelText: 'Category',
                  ),
                  name: 'idCategory',
                  itemBuilder: (context, category) {
                    return ListTile(title: Text(category));
                  },
                  onChanged: (categoryName) {
                    CategoryModel? category = categories.firstWhere((element) => element.name == categoryName);
                    setState(() {
                      filter.idCategory = category.id;
                    });
                  },
                  suggestionsCallback: (query) {
                    List<String> categoriesList = categories.map((e) => e.name!).toList();
                    if (query.isNotEmpty) {
                      var lowercaseQuery = query.toLowerCase();
                      return categoriesList.where((category) {
                        return category.toLowerCase().contains(lowercaseQuery);
                      }).toList(growable: false)
                        ..sort((a,b) => a.toLowerCase().indexOf(lowercaseQuery).compareTo(b.toLowerCase().indexOf(lowercaseQuery)));
                    } else {
                      return categoriesList;
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          cancelButton,
          TextButton(
            child: const Text('Ok'),
            onPressed:  () {
              filter.notify();
              Navigator.of(context).pop();
            },
          ),
        ],
      );

      // show the dialog
      showDialog(
        context: context,
        builder: (BuildContext _) {
          return alert;
        },
      );
    } catch (ex) {
      print(ex);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Spends Tracker', style: TextStyle(color: Colors.black),),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          filter.dateRange == null && filter.idCategory == null ? IconButton(
              onPressed: () {
                showFilterModal(context);
              },
              tooltip: 'Set filter',
              icon: const Icon(Icons.filter_alt_rounded, color: Colors.blueAccent,)
          ) : IconButton(onPressed: () {
            setState(() {
              filter.dateRange = null;
              filter.idCategory = null;
            });
            filter.notify();
          }, icon: const Icon(Icons.filter_alt_off, color: Colors.redAccent), tooltip: 'Remove filter',),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Settings()),
              ).then((value) {
                if (value == true) {
                  filter.notify();
                }
              });
            }, 
            icon: const Icon(Icons.settings, color: Colors.blueAccent,)
          )
        ],
      ),
      body: PageView(
        controller: _controller,
        children: [
          Home(filter: filter,),
          const Categories(),
          Chart(filter: filter,),
          TableView(filter: filter,),
        ],
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      bottomNavigationBar: BubbleBottomBar(
        opacity: 0.2,
        items: const [
          BubbleBottomBarItem(
            icon: Icon(Icons.home, color: Colors.black87,),
            activeIcon: Icon(Icons.home),
            title: Text('Home'),
            backgroundColor: Colors.red
          ),
          BubbleBottomBarItem(
            icon: Icon(Icons.list, color: Colors.black87,),
            activeIcon: Icon(Icons.list),
            title: Text('Categories'),
            backgroundColor: Colors.deepPurple
          ),
          BubbleBottomBarItem(
            icon: Icon(Icons.pie_chart, color: Colors.black87,),
            activeIcon: Icon(Icons.pie_chart),
            title: Text('Chart'),
            backgroundColor: Colors.indigo
          ),
          BubbleBottomBarItem(
            icon: Icon(Icons.table_chart, color: Colors.black87,),
            activeIcon: Icon(Icons.table_chart),
            title: Text('Table'),
            backgroundColor: Colors.green
          )
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        hasInk: true,
        inkColor: Colors.black12
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
