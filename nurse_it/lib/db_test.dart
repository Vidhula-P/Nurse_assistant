//// filepath: /Users/smalviya/Code/Apps/nurse_it/lib/db_test.dart
import 'package:mongo_dart/mongo_dart.dart';

Future<void> main() async {
  // Connect to MongoDB Atlas and select the "DoctorData" database.
  final db = await Db.create(
    "mongodb+srv://quackquack:GoGoDucks111@cluster0.zgrxa.mongodb.net/DoctorData?retryWrites=true&w=majority"
  );
  await db.open();
  print('********** Connected to DrData **********');

  // Select the "Information" collection.
  final infoCollection = db.collection("Information");

  // Insert sample data into the Information collection.
  var sampleDoctor = {"name": "Dr. Alice", "specialty": "Cardiology", "experience": 10};
  await infoCollection.insertOne(sampleDoctor);
  print('********** Sample Doctor inserted **********');

  // Retrieve and print all documents from the Information collection.
  final doctors = await infoCollection.find().toList();
  for (final doctor in doctors) {
    print('********** Document Start **********');
    print(doctor);
    print('********** Document End **********');
  }

  await db.close();
  print('********** Disconnected from DrData **********');
}