import 'package:flutter/material.dart';
import 'package:flutter_is_dark_color_hsp/flutter_is_dark_color_hsp.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:spend_tracker/models/ResponseModel.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../Utils/Toast.dart';
import '../Utils/Transformation.dart';
import '../models/SpendModel.dart';
import 'package:intl/intl.dart';
import 'NewSpend.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<SpendModel> list = [];
  double totalLastMonth = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  initState() {
    super.initState();
    if (mounted) {
      loadPage();
    }
  }

  Future<void> loadPage({int limit = 25, offset = 0}) async{
    ResponseModel response = await SpendModel.getList(offset: offset, limit: limit);
    double total = response.items.isNotEmpty ? await SpendModel.getTotalLastMonth() : 0;
    setState(() {
      list = [...list, ...response.items];
      totalLastMonth = total;
    });
  }

  void reloadPage() {
    if (!mounted) return;
    setState(() {
      list = [];
    });
    loadPage();
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
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text('L $totalLastMonth'),
          ],
        ),
        Expanded(
          child: ListView.builder(
            itemBuilder: (c, i) => _renderTile(context, list[i]),
            itemCount: list.length,
          ),
        ),
        VisibilityDetector(
            key: const Key('1'),
            onVisibilityChanged: (visibilityInfo) {
              double visiblePercent = visibilityInfo.visibleFraction * 100;
            },
            child: Container(
              height: 1.0,
            )
        )
      ],
    );
  }

  Widget _renderTile(BuildContext context, SpendModel item) {
    Color _color = Color(item.categoryModel!.color!);
    return Slidable(
      key: const ValueKey(0),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        dismissible: DismissiblePane(onDismissed: () {}),
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
            onPressed: (context){},
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
        trailing: Text(item.amount!.toString()),
        leading: Container(
          width: 50.0,
          height: 50.0,
          color: _color,
          child: Icon(
            getIconDataFromString(item.categoryModel!.icon!),
            color: isDarkHsp(_color)! ? Colors.white: Colors.black,
          ),
        ),
      ),
    );
  }
}
