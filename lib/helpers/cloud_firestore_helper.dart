import 'package:cloud_firestore/cloud_firestore.dart';

class CloudFirestoreHelper {
  CloudFirestoreHelper._();
  static final CloudFirestoreHelper cloudFirestoreHelper =
      CloudFirestoreHelper._();

  static final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  late CollectionReference studentsRef;
  late CollectionReference counterRef;

  connectionWithStudentsCollection() {
    studentsRef = firebaseFirestore.collection('notes');
  }

  connectionWithCounterCollection() {
    counterRef = firebaseFirestore.collection('counters');
  }

  Future<void> insertData({required Map<String, dynamic> data}) async {
    connectionWithCounterCollection();
    connectionWithStudentsCollection();

    DocumentSnapshot documentSnapshot =
        await counterRef.doc("note_counters").get();

    Map<String, dynamic> counterData =
        documentSnapshot.data() as Map<String, dynamic>;

    int counter = counterData["counter"];

    await studentsRef.doc("${++counter}").set(data);

    await counterRef.doc("note_counters").update({"counter": counter});
  }

  Stream<QuerySnapshot<Object?>> selectRecords() {
    connectionWithStudentsCollection();
    return studentsRef.snapshots();
  }

  Future<void> updateRecords(
      {required String id, required Map<String, dynamic> data}) async {
    connectionWithStudentsCollection();

    studentsRef.doc(id).update(data);
  }

  Future<void> deleteRecords({required String id}) async {
    connectionWithStudentsCollection();

    studentsRef.doc(id).delete();
  }
}
