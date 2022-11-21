import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app/helpers/cloud_firestore_helper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  String? title;
  String? note;
  String? date;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notes App"),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          insertAndUpdateRecord(isUpdate: false);
        },
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: CloudFirestoreHelper.cloudFirestoreHelper.selectRecords(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          } else if (snapshot.hasData) {
            List<QueryDocumentSnapshot> data = snapshot.data!.docs;

            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, i) {
                return Container(
                  padding: const EdgeInsets.all(15),
                  margin: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.circular(20),
                    color: ([...Colors.primaries]..shuffle()).first.shade100,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Column(
                            children: [
                              Text(
                                "${data[i]["title"]}",
                                style: GoogleFonts.lato(
                                  fontSize: 25,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () {
                              titleController.text = "${data[i]["title"]}";
                              dateController.text = "${data[i]["date"]}";
                              noteController.text = "${data[i]["note"]}";

                              insertAndUpdateRecord(
                                  isUpdate: true, id: data[i].id);
                            },
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.blue,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              CloudFirestoreHelper.cloudFirestoreHelper
                                  .deleteRecords(id: data[i].id);
                            },
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        "${data[i]["note"]}",
                        style: GoogleFonts.lato(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          "${data[i]["date"]}",
                          style: GoogleFonts.lato(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  insertAndUpdateRecord({required bool isUpdate, id}) {
    (isUpdate) ? null : clearControllersAndVar();
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        scrollable: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Center(child: Text((isUpdate) ? "Update Note" : "Insert Note")),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 15),
              TextFormField(
                controller: titleController,
                decoration: textFieldDecoration("Title", Icons.title),
                onSaved: (val) {
                  title = val;
                },
                validator: (val) => (val!.isEmpty) ? "Enter Title First" : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: dateController,
                keyboardType: TextInputType.datetime,
                decoration: textFieldDecoration("Date", Icons.calendar_month),
                onSaved: (val) {
                  date = val;
                },
                validator: (val) => (val!.isEmpty) ? "Enter Date First." : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: noteController,
                decoration: textFieldDecoration("Note", Icons.note_alt_rounded),
                onSaved: (val) {
                  note = val;
                },
                validator: (val) => (val!.isEmpty) ? "Enter Note First." : null,
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(shape: const StadiumBorder()),
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();

                Map<String, dynamic> data = {
                  "title": title,
                  "date": date,
                  "note": note,
                };

                if (isUpdate) {
                  CloudFirestoreHelper.cloudFirestoreHelper
                      .updateRecords(data: data, id: id);
                } else {
                  CloudFirestoreHelper.cloudFirestoreHelper
                      .insertData(data: data);
                }

                Navigator.of(context).pop();
              }
            },
            child: Text((isUpdate) ? "Update" : "Add"),
          ),
          OutlinedButton(
            style: OutlinedButton.styleFrom(shape: const StadiumBorder()),
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }

  textFieldDecoration(String hint, var icon) {
    return InputDecoration(
      prefixIcon: Icon(icon),
      hintText: "Enter $hint Hear...",
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(50)),
      label: Text(hint),
    );
  }

  clearControllersAndVar() {
    titleController.clear();
    dateController.clear();
    noteController.clear();

    title = null;
    note = null;
    date = null;
  }
}
