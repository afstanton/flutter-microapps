import 'package:flutter/material.dart';

void main() {
  runApp(const FormValidationExample());
}

class FormValidationExample extends StatelessWidget {
  const FormValidationExample({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Form Validation Example'),
        ),
        body: const Padding(
          padding: EdgeInsets.all(16.0),
          child: MyCustomForm(),
        ),
      ),
    );
  }
}

class MyCustomForm extends StatefulWidget {
  const MyCustomForm({super.key});

  @override
  MyCustomFormState createState() {
    return MyCustomFormState();
  }
}

class MyCustomFormState extends State<MyCustomForm> {
  final _formKey = GlobalKey<FormState>();
  bool _agreeToTerms = false;
  String _gender = 'male';
  String _selectedOption = 'Option 1';
  String _comments = '';
  int _age = 0;
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        children: <Widget>[
          TextFormField(
            decoration: const InputDecoration(
              hintText: 'Enter your email',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter some text';
              }
              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),
          TextFormField(
            decoration: const InputDecoration(
              hintText: 'Enter your password',
            ),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter some text';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters long';
              }
              return null;
            },
          ),
          CheckboxListTile(
            title: const Text('I agree to the terms and conditions'),
            value: _agreeToTerms,
            onChanged: (bool? value) {
              setState(() {
                _agreeToTerms = value ?? false;
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
            subtitle: !_agreeToTerms
                ? const Text(
                    'You must agree before submitting.',
                    style: TextStyle(color: Colors.red),
                  )
                : null,
          ),
          Column(
            children: <Widget>[
              ListTile(
                title: const Text('Male'),
                leading: Radio<String>(
                  value: 'male',
                  groupValue: _gender,
                  onChanged: (String? value) {
                    setState(() {
                      _gender = value!;
                    });
                  },
                ),
              ),
              ListTile(
                title: const Text('Female'),
                leading: Radio<String>(
                  value: 'female',
                  groupValue: _gender,
                  onChanged: (String? value) {
                    setState(() {
                      _gender = value!;
                    });
                  },
                ),
              ),
            ],
          ),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              hintText: 'Select an option',
            ),
            value: _selectedOption,
            onChanged: (String? newValue) {
              setState(() {
                _selectedOption = newValue!;
              });
            },
            items: <String>['Option 1', 'Option 2', 'Option 3']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          TextFormField(
            decoration: const InputDecoration(
              hintText: 'Enter your comments',
            ),
            maxLines: 3,
            onChanged: (value) {
              setState(() {
                _comments = value;
              });
            },
          ),
          TextFormField(
            decoration: const InputDecoration(
              hintText: 'Enter your age',
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your age';
              }
              final int? age = int.tryParse(value);
              if (age == null || age <= 0) {
                return 'Please enter a valid age';
              }
              return null;
            },
            onChanged: (value) {
              setState(() {
                _age = int.tryParse(value) ?? 0;
              });
            },
          ),
          TextFormField(
            decoration: const InputDecoration(
              hintText: 'Select your birthdate',
            ),
            controller: TextEditingController(
              text: _selectedDate != null
                  ? "${_selectedDate!.toLocal()}".split(' ')[0]
                  : '',
            ),
            readOnly: true,
            onTap: () async {
              FocusScope.of(context).requestFocus(FocusNode());
              DateTime? picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              if (picked != null && picked != _selectedDate) {
                setState(() {
                  _selectedDate = picked;
                });
              }
            },
            validator: (value) {
              if (_selectedDate == null) {
                return 'Please select your birthdate';
              }
              return null;
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton(
              onPressed: () {
                // Validate returns true if the form is valid, or false otherwise.
                if (_formKey.currentState!.validate() && _agreeToTerms) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Processing Data')),
                  );
                }
              },
              child: const Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }
}
