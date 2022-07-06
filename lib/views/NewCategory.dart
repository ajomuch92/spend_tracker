import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_extra_fields/form_builder_extra_fields.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import 'package:spend_tracker/Utils/IconList.dart';
import 'package:spend_tracker/Utils/Toast.dart';
import 'package:spend_tracker/models/CategoryModel.dart';

import '../Utils/Transformation.dart';

class NewCategory extends StatefulWidget {
  final CategoryModel? categoryModel;
  const NewCategory({Key? key, this.categoryModel}) : super(key: key);

  @override
  State<NewCategory> createState() => _NewCategoryState();
}

class _NewCategoryState extends State<NewCategory> {
  final _formKey = GlobalKey<FormBuilderState>();
  SimpleFontelicoProgressDialog? _dialog;
  CategoryModel? categoryModelToEdit;
  final List<String> icons = icon_list;
  // IList<String> ilist = IList(const []);

  @override
  initState(){
    super.initState();
    // ilist = IList(icons);
    if (widget.categoryModel != null) {
      categoryModelToEdit = widget.categoryModel;
    }
  }

  void _save(BuildContext context) async {
    try {
      _dialog ??= SimpleFontelicoProgressDialog(context: context, barrierDimisable:  false);
      _formKey.currentState!.save();
      if (_formKey.currentState!.validate()) {
        Map<String, dynamic> jsonSpend = _formKey.currentState!.value;
        Color color = jsonSpend['colorPicker'] as Color;
        CategoryModel category = CategoryModel.fromCustomJson(jsonSpend);
        category.color = color.value;
        _dialog!.show(message: 'Saving');
        if (categoryModelToEdit == null) {
          await category.save();
        } else {
          category.id = categoryModelToEdit?.id;
          await category.update();
        }
        _dialog!.hide();
        if(!mounted) return;
        showToast(context, 'Category created successfully', toastStatus: ToastStatus.success);
        Navigator.pop(context, category);
      } else {
        if(!mounted) return;
        showToast(context, 'Please fill required fields', toastStatus: ToastStatus.warning);
      }
    } catch (ex) {
      _dialog!.hide();
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
                  name: 'name',
                  decoration: const InputDecoration(
                    labelText:
                    'Name',
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(errorText: 'Description field is required'),
                  ]),
                  keyboardType: TextInputType.name,
                  initialValue: categoryModelToEdit?.name,
                ),
                FormBuilderColorPickerField(
                  name: 'colorPicker',
                  colorPickerType: ColorPickerType.materialPicker,
                  decoration: const InputDecoration(labelText: 'Color'),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(errorText: 'Color field is required'),
                  ]),
                  initialValue: categoryModelToEdit != null ? Color(categoryModelToEdit?.color ?? 0) : null,
                ),
                FormBuilderTypeAhead<String>(
                  decoration: const InputDecoration(
                    labelText: 'Icon',
                  ),
                  name: 'icon',
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(errorText: 'Icon field is required'),
                  ]),
                  itemBuilder: (context, icon) {
                    return ListTile(
                      leading: Icon(
                        IconTransformation.getIconDataFromString(icon)
                      ),
                      title: Text(icon.replaceAll('-', ' ')),
                    );
                  },
                  initialValue: categoryModelToEdit?.icon,
                  debounceDuration: const Duration(milliseconds: 800),
                  suggestionsCallback: (query) {
                    if (query.isNotEmpty) {
                      var lowercaseQuery = query.toLowerCase();
                      if (lowercaseQuery.length < 5) {
                        return icons.where((icon) {
                          return icon.toLowerCase().startsWith(lowercaseQuery);
                        }).toList(growable: false)
                          ..sort((a, b) => a
                              .toLowerCase()
                              .indexOf(lowercaseQuery)
                              .compareTo(
                              b.toLowerCase().indexOf(lowercaseQuery)));
                      }
                      var result = icons.where((icon) {
                        return icon.toLowerCase().contains(lowercaseQuery);
                      }).toList(growable: false)
                        ..sort((a, b) => a
                            .toLowerCase()
                            .indexOf(lowercaseQuery)
                            .compareTo(
                            b.toLowerCase().indexOf(lowercaseQuery)));
                      return result;
                    } else {
                      return icons.sublist(0, 10);
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
