import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  late SharedPreferences prefs;
  String? currency, symbol;
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  void initState() {
    super.initState();
    if (mounted) {
      loadSharedPreference();
    }
  }

  void loadSharedPreference() async {
    prefs = await SharedPreferences.getInstance();
    String? currency = prefs.getString('currency');
    String? symbol = prefs.getString('symbol');
    setState(() {
      this.currency = currency;
      this.symbol = symbol;
    });
    _formKey.currentState!.patchValue({
      'currency': currency,
      'symbol': symbol,
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(color: Colors.black),),
        backgroundColor: Colors.white,
        elevation: 0.0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FormBuilder(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                FormBuilderTextField(
                  name: 'currency',
                  decoration: const InputDecoration(
                    labelText:
                    'Currency',
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(errorText: 'Description field is required'),
                  ]),
                  keyboardType: TextInputType.name,
                  initialValue: currency,
                  onChanged: (val) {
                    setState(() {
                      currency = val;
                    });
                  },
                ),
                FormBuilderTextField(
                    name: 'symbol',
                    decoration: const InputDecoration(
                      labelText:
                      'Symbol',
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(errorText: 'Description field is required'),
                    ]),
                    keyboardType: TextInputType.name,
                    initialValue: symbol,
                    onChanged: (val) {
                      setState(() {
                        symbol = val;
                      });
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
        child: ElevatedButton(
          onPressed: () {
            prefs.setString('currency', currency!);
            prefs.setString('symbol', symbol!);
            Navigator.of(context).pop(true);
          },
          style: ElevatedButton.styleFrom(
            primary: Colors.blueAccent,
          ),
          child: const Text('Save', style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}