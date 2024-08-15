import 'package:flutter/material.dart';

import 'package:random_string/random_string.dart';
import 'package:todo/database.dart';

class AddButtton extends StatefulWidget {
  const AddButtton({super.key});

  @override
  State<AddButtton> createState() => _AddButttonState();
}

class _AddButttonState extends State<AddButtton> {
  TextEditingController todoController = TextEditingController();

  void submitTodo() async {
    String id = randomAlphaNumeric(10);
    Map<String, dynamic> todoMap = {
      "todo": todoController.text,
    };
    if (todoController.text.trim().isEmpty) {
      showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text("No data!"),
            content: const Text(
              "Todo cannot be empty!",
              style: TextStyle(
                color: Color.fromARGB(255, 206, 40, 38),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                },
                child: const Text("Ok"),
              )
            ],
          );
        },
      );
      return;
    } else {
      await DatabaseModel().addTodo(todoMap, id).then((value) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Todo Saved Successfully!"),
          ),
        );
        todoController.clear();
        Navigator.of(context).pop();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        showModalBottomSheet(
          useSafeArea: true,
          isScrollControlled: true,
          context: context,
          builder: (ctx) {
            return SizedBox(
              height: MediaQuery.of(ctx).size.height * 0.9,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: todoController,
                      decoration: InputDecoration(
                        labelText: 'Add a new TODO',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text("cancle")),
                        const SizedBox(
                          width: 10,
                        ),
                        OutlinedButton.icon(
                            onPressed: submitTodo,
                            icon: const Icon(Icons.check, ),
                            label: const Text("Save!"))
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
      child: const Icon(Icons.add),
    );
  }
}
