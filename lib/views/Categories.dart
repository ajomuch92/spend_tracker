import 'package:flutter/material.dart';
import 'package:flutter_is_dark_color_hsp/flutter_is_dark_color_hsp.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:spend_tracker/Utils/Toast.dart';
import 'package:spend_tracker/models/CategoryModel.dart';
import 'package:spend_tracker/models/ResponseModel.dart';
import 'package:spend_tracker/views/NewCategory.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../Utils/Transformation.dart';

class Categories extends StatefulWidget {
  const Categories({Key? key}) : super(key: key);

  @override
  State<Categories> createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  List<CategoryModel> list = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  initState() {
    super.initState();
    if (mounted) {
      loadPage();
    }
  }

  Future<void> loadPage({int limit = 25, offset = 0}) async {
    ResponseModel response = await CategoryModel.getList(
        offset: offset, limit: limit);
    setState(() {
      list = [...list, ...response.items];
    });
  }

  void reloadPage() {
    if (!mounted) return;
    setState(() {
      list = [];
    });
    loadPage();
  }

  void deleteItem(CategoryModel categoryModel) {
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
          bool deleted = await categoryModel.delete();
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
        content: const Text('Do you want to delete this category?'),
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
        child: list.isEmpty
            ? const Center(child: Text('No categories added'),)
            : _buildList(context),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NewCategory()),
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
        Expanded(
          child: ListView.builder(
            itemBuilder: (c, i) => _renderTile(context, list[i]),
            itemCount: list.length,
          ),
        ),
        VisibilityDetector(
            key: const Key('0'),
            onVisibilityChanged: (visibilityInfo) {
              double visiblePercent = visibilityInfo.visibleFraction * 100;
              print(visiblePercent);
            },
            child: Container(
              height: 1.0,
            )
        )
      ],
    );
  }

  Widget _renderTile(BuildContext context, CategoryModel item) {
    Color color = Color(item.color!);
    return Slidable(
      key: const ValueKey(0),
      startActionPane: ActionPane(
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
            onPressed: (context) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NewCategory(categoryModel: item,)),
              ).then((value) {
                if (value != null) {
                  reloadPage();
                }
              });
            },
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Edit',
          ),
        ],
      ),
      child: ListTile(
        title: Text(item.name!),
        leading: Container(
          height: 50.0,
          width: 50.0,
          color: color,
          child: Icon(
            IconTransformation.getIconDataFromString(item.icon!),
            color: isDarkHsp(color)! ? Colors.white: Colors.black,
          ),
        ),
      ),
    );
  }
}
