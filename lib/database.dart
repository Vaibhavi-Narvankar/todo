import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseModel {
  Future addTodo(Map<String, dynamic> todoMap, String id) async {
    FirebaseFirestore.instance.collection("todoData").doc(id).set(todoMap);
  }

  Future<Stream<QuerySnapshot>> getTodo() async {
    return FirebaseFirestore.instance.collection("todoData").snapshots();
  }


  Future<void> updateTodo(String id, Map<String, dynamic> updatedData) async {
    await FirebaseFirestore.instance.collection("todoData").doc(id).update(updatedData);
  }

  Future<void> deleteTodo(String id) async {
    await FirebaseFirestore.instance.collection("todoData").doc(id).delete();
  }

}
