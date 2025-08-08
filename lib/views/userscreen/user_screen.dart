import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:svareignadmin/viewmodel/userviewmde/user_view_model.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<UserViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text("All Users")),
      body:
          vm.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: vm.users.length,
                itemBuilder: (context, index) {
                  final user = vm.users[index];
                  return ListTile(
                    title: Text(user.name),
                    subtitle: Text("${user.email} - ${user.phone}"),
                    trailing: Text(user.role),
                  );
                },
              ),
    );
  }
}
