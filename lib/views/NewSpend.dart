import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_extra_fields/form_builder_extra_fields.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:spend_tracker/models/SpendModel.dart';
import 'package:intl/intl.dart';

import '../Utils/Toast.dart';
import '../models/CategoryModel.dart';

class NewSpend extends StatefulWidget {
  final SpendModel? spendModel;
  const NewSpend({Key? key, this.spendModel}) : super(key: key);

  @override
  State<NewSpend> createState() => _NewSpendState();
}

class _NewSpendState extends State<NewSpend> {
  final _formKey = GlobalKey<FormBuilderState>();
  SpendModel? spendModelToEdit;
  List<CategoryModel> categories = [];

  @override
  initState() {
    super.initState();
    if (mounted) _loadCategories();
    if (widget.spendModel != null) {
      spendModelToEdit = widget.spendModel;
    }
  }

  void _loadCategories() {
    CategoryModel.getList(limit: 100).then((response) {
      setState(() {
        categories = response.items as List<CategoryModel>;
      });
    });
  }

  void _save(BuildContext context) async {
    try {
      _formKey.currentState!.save();
      if (_formKey.currentState!.validate()) {
        Map<String, dynamic> jsonSpend = _formKey.currentState!.value;
        SpendModel spend = SpendModel.fromCustomJson(jsonSpend);
        if (spendModelToEdit == null) {
          await spend.save();
        } else {
          spend.id = spendModelToEdit?.id;
          await spend.update();
        }
        if(!mounted) return;
        showToast(context, 'Spend created successfully', toastStatus: ToastStatus.success);
        Navigator.pop(context, spend);
      } else {
        if(!mounted) return;
        showToast(context, 'Please fill required fields', toastStatus: ToastStatus.warning);
      }
    } catch(ex) {
      showToast(context, 'There was an error during saving', toastStatus: ToastStatus.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Add New Spend', style: TextStyle(color: Colors.black),),
        elevation: 0.0,
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
        height: MediaQuery.of(context).size.height,
        color: Colors.white,
        child: FormBuilder(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                FormBuilderTextField(
                  name: 'description',
                  decoration: const InputDecoration(
                    labelText:
                    'Description',
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(errorText: 'Description field is required'),
                  ]),
                  keyboardType: TextInputType.text,
                  initialValue: spendModelToEdit?.description,
                ),
                FormBuilderTextField(
                  name: 'amount',
                  decoration: const InputDecoration(
                    labelText:
                    'Amount (L)',
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(errorText: 'Amount field is required'),
                  ]),
                  keyboardType: TextInputType.number,
                  initialValue: spendModelToEdit?.amount.toString(),
                ),
                FormBuilderDateTimePicker(
                  name: 'date',
                  firstDate: DateTime(1970),
                  lastDate: DateTime.now(),
                  initialValue: spendModelToEdit != null? spendModelToEdit?.date : DateTime.now(),
                  decoration: const InputDecoration(
                    labelText: 'Date',
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(errorText: 'Date field is required'),
                  ]),
                  inputType: InputType.date,
                  format: DateFormat('dd/MM/yyyy'),
                  valueTransformer: (date) {
                    return date?.millisecondsSinceEpoch.toString();
                  },
                ),
                FormBuilderTypeAhead<String>(
                  decoration: const InputDecoration(
                      labelText: 'Category',
                  ),
                  name: 'idCategory',
                  itemBuilder: (context, category) {
                    return ListTile(title: Text(category));
                  },
                  valueTransformer: (categoryName) {
                    CategoryModel? category = categories.firstWhere((element) => element.name == categoryName);
                    return category.id;
                  },
                  initialValue: spendModelToEdit?.categoryModel?.name,
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _save(context);
        },
        child: const Icon(Icons.save),
      ),
    );
  }
}
