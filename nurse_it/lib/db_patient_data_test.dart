import 'package:mongo_dart/mongo_dart.dart';

Future<void> main() async {
  // Connect to MongoDB Atlas and select the "PatientData" database.
  final db = await Db.create(
    "mongodb+srv://quackquack:GoGoDucks111@cluster0.zgrxa.mongodb.net/PatientData?retryWrites=true&w=majority"
  );
  await db.open();
  print('********** Connected to PatientData **********');

  // ---------- Appointments Collection ----------
  final appointmentsCollection = db.collection("Appointments");
  var sampleAppointment = {"patient": "John Doe", "date": "2025-02-25", "time": "10:00 AM"};
  await appointmentsCollection.insertOne(sampleAppointment);
  print('********** Sample Appointment inserted **********');

  final appointments = await appointmentsCollection.find().toList();
  print('********** Appointments Collection Documents Start **********');
  for (final appointment in appointments) {
    print(appointment);
  }
  print('********** Appointments Collection Documents End **********');

  // ---------- Data Collection ----------
  final dataCollection = db.collection("Data");
  var sampleData = {"patient": "John Doe", "height": 180, "weight": 75};
  await dataCollection.insertOne(sampleData);
  print('********** Sample Data inserted **********');

  final dataDocuments = await dataCollection.find().toList();
  print('********** Data Collection Documents Start **********');
  for (final data in dataDocuments) {
    print(data);
  }
  print('********** Data Collection Documents End **********');

  // ---------- Records Collection ----------
  final recordsCollection = db.collection("Records");
  var sampleRecord = {"patient": "John Doe", "record": "No complications", "date": "2025-02-20"};
  await recordsCollection.insertOne(sampleRecord);
  print('********** Sample Record inserted **********');

  final records = await recordsCollection.find().toList();
  print('********** Records Collection Documents Start **********');
  for (final record in records) {
    print(record);
  }
  print('********** Records Collection Documents End **********');

  // Close the database connection.
  await db.close();
  print('********** Disconnected from PatientData **********');
}