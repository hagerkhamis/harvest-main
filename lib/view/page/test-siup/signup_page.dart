// signup_page.dart
import 'package:flutter/material.dart';
import 'package:hatvest/view/page/test-siup/%20branch_model.dart';
import 'package:provider/provider.dart';
import 'signup_viewmodel.dart';

class SignUpPage extends StatefulWidget {
  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // @override
  // void initState() {
  //   super.initState();
  //   Provider.of<SignUpViewModel>(context, listen: false).loadData();
  // }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SignUpViewModel>(context, listen: false).loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sign Up")),
      body: Consumer<SignUpViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) return Center(child: CircularProgressIndicator());

          return Padding(
            padding: EdgeInsets.all(16),
            child: ListView(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: "Name"),
                ),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: "Email"),
                ),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: "Password"),
                ),
                SizedBox(height: 16),
                DropdownButton<Branch>(
                  hint: Text("Select Branch"),
                  value: vm.selectedBranch,
                  items: vm.branches.map((branch) {
                    return DropdownMenuItem(
                      value: branch,
                      child: Text(branch.name),
                    );
                  }).toList(),
                  onChanged: (branch) {
                    if (branch != null) vm.setBranch(branch);
                  },
                ),
                DropdownButton<Country>(
                  hint: Text("Select Country"),
                  value: vm.selectedCountry,
                  items: vm.countries.map((country) {
                    return DropdownMenuItem(
                      value: country,
                      child: Text(country.name),
                    );
                  }).toList(),
                  onChanged: (country) {
                    if (country != null) vm.setCountry(country);
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    await vm.signUp(
                      _nameController.text,
                      _emailController.text,
                      _passwordController.text,
                    );
                  },
                  child: Text("Sign Up"),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
