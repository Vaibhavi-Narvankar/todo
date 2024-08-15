import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:todo/add_buttton.dart';
import 'package:todo/database.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  Stream<QuerySnapshot>? todoStream;

  Future<void> getOnReload() async {
    todoStream = await DatabaseModel().getTodo();
    setState(() {});
  }

  Future<void> editTodo(String id, String currentTodo) async {
    TextEditingController todoController =
        TextEditingController(text: currentTodo);
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit TODO"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: todoController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                String updatedTodo = todoController.text.trim();
                if (updatedTodo.isNotEmpty) {
                  Map<String, dynamic> updatedData = {
                    "todo": updatedTodo,
                  };
                  await DatabaseModel()
                      .updateTodo(id, updatedData)
                      .then((value) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Todo Updated Successfully!"),
                      ),
                    );
                    Navigator.pop(context);
                    getOnReload(); // Close the dialog
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Todo cannot be empty!"),
                    ),
                  );
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteTodo(String id) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirm Deletion"),
          content: const Text("Are you sure you want to delete this TODO?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );

    if (confirm ?? false) {
      await DatabaseModel().deleteTodo(id).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Todo Deleted Successfully!"),
          ),
        );
        getOnReload(); // Refresh the list
      });
    }
  }

  Widget todoDetails() {
    return StreamBuilder<QuerySnapshot>(
      stream: todoStream,
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (ctx, index) {
              DocumentSnapshot ds = snapshot.data!.docs[index];
              Map<String, dynamic> data = ds.data() as Map<String, dynamic>;
              String id = ds.id;
              return Card(
                elevation: 4.0,
                child: ListTile(
                  leading: const Icon(Icons.notes),
                  title: Text(data["todo"] ?? "No title"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          editTodo(id, data["todo"] ?? "");
                        },
                        icon: const Icon(
                          Icons.edit,
                          size: 20,
                        ),
                      ),
                      IconButton(
                        onPressed: (){
                           deleteTodo(id);
                        },
                        icon: const Icon(
                          Icons.delete,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        } else {
          return const Center(child: Text("No TODO items found"));
        }
      },
    );
  }

  @override
  void initState() {
    getOnReload();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "TODO",
          style: Theme.of(context)
              .textTheme
              .titleLarge!
              .copyWith(color: Theme.of(context).cardColor),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: todoDetails(),
      ),
      floatingActionButton: const AddButtton(),
    );
  }
}
