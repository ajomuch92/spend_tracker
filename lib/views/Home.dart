import 'package:flutter/material.dart';
import 'package:flutter_is_dark_color_hsp/flutter_is_dark_color_hsp.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spend_tracker/models/FilterModel.dart';
import 'package:spend_tracker/models/ResponseModel.dart';
import '../Utils/Toast.dart';
import '../Utils/Transformation.dart';
import '../models/SpendModel.dart';
import 'package:intl/intl.dart';
import 'NewSpend.dart';

class Home extends StatefulWidget {
  final FilterModel? filter;
  const Home({Key? key, this.filter}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<SpendModel> list = [];
  double totalLastMonth = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? symbol = '';

  @override
  initState() {
    super.initState();
    if (mounted) {
      loadPage();
      setListener();
      loadSharedPreference();
    }
  }

  Future<void> loadPage({int limit = 100, offset = 0}) async{
    ResponseModel response = await SpendModel.getList(offset: offset, limit: limit, filter: widget.filter);
    double total = response.items.isNotEmpty ? await SpendModel.getTotalLastMonth(filter: widget.filter) : 0;
    setState(() {
      list = [...list, ...response.items];
      totalLastMonth = total;
    });
  }

  void setListener() {
    if (widget.filter != null) {
      widget.filter!.addListener(() {
        if (mounted) reloadPage();
      });
    }
  }

  void loadSharedPreference() async {
    var prefs = await SharedPreferences.getInstance();
    setState(() {
      symbol = prefs.getString('symbol');
    });
  }

  void reloadPage() {
    if (!mounted) return;
    setState(() {
      list = [];
    });
    loadPage();
    loadSharedPreference();
  }

  void deleteItem(SpendModel spendModel) {
    try {
      BuildContext _context = _scaffoldKey.currentContext!;
      Widget cancelButton = TextButton(
        child: const Text('Cancel'),
        onPressed:  () {
          Navigator.of(_context).pop();
        },
      );
      Widget continueButton = TextButton(
        child: const Text('Delete'),
        onPressed:  () async {
          bool deleted = await spendModel.delete();
          if (deleted) {
            reloadPage();
            if (!mounted) return;
            Navigator.of(_context).pop();
            showToast(_context, 'Category deleted', toastStatus: ToastStatus.success);
          } else  {
            if (!mounted) return;
            Navigator.of(_context).pop();
            showToast(_context, 'There was an error during deletion', toastStatus: ToastStatus.error);
          }
        },
      );

      // set up the AlertDialog
      AlertDialog alert = AlertDialog(
        title: const Text('Delete'),
        content: const Text('Do you want to delete this spend?'),
        actions: [
          cancelButton,
          continueButton,
        ],
      );

      // show the dialog
      showDialog(
        context: _context,
        builder: (BuildContext context) {
          return alert;
        },
      );
    } catch (ex) {
      print(ex);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        color: Colors.white,
        child: list.isEmpty ? const Center(child: Text('No spends added'),) : _buildList(context),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NewSpend()),
          ).then((value) {
            if (value != null) {
              reloadPage();
            }
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildList(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const Text('Total wasted:'),
            Text('$symbol ${totalLastMonth.toStringAsFixed(2)}'),
          ],
        ),
        Expanded(
          child: ListView.builder(
            itemBuilder: (c, i) => _renderTile(context, list[i]),
            itemCount: list.length,
          ),
        ),
      ],
    );
  }

  Widget _renderTile(BuildContext context, SpendModel item) {
    Color _color = Color(item.categoryModel!.color!);
    return Slidable(
      key: const ValueKey(0),
      startActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) {
              deleteItem(item);
            },
            backgroundColor: const Color(0xFFFE4A49),
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
          SlidableAction(
            onPressed: (context){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NewSpend(spendModel: item,)),
              ).then((value) {
                if (value != null) {
                  reloadPage();
                }
              });
            },
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            icon: Icons.share,
            label: 'Edit',
          ),
        ],
      ),
      child: ListTile(
        title: Text(item.description!),
        subtitle: Text((DateFormat('dd/MM/yyyy')).format(item.date!)),
        trailing: Text('$symbol ${item.amount!}'),
        leading: Container(
          width: 50.0,
          height: 50.0,
          color: _color,
          child: Icon(
            IconTransformation.getIconDataFromString(item.categoryModel!.icon!),
            color: isDarkHsp(_color)! ? Colors.white: Colors.black,
          ),
        ),
      ),
    );
  }
}
