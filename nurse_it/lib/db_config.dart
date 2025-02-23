import 'package:mongo_dart/mongo_dart.dart';

const String mongoDBUsername = 'quackquack';
const String mongoDBPassword = 'GoGoDucks111';

class DatabaseService {
  final String dbName;
  late Db db;

  DatabaseService(this.dbName);

  /// Connects to MongoDB using the provided dbName, for example "PatientData" or "DoctorData".
  Future<void> connect() async {
    final connectionString =
        'mongodb+srv://$mongoDBUsername:$mongoDBPassword@cluster0.zgrxa.mongodb.net/$dbName?retryWrites=true&w=majority';
    db = Db(connectionString);
    await db.open();
    print('Connected to $dbName');
  }

  /// Closes the connection.
  Future<void> close() async {
    await db.close();
    print('Disconnected from $dbName');
  }
  
  /// Retrieves a doctor's information from the "information" collection in DoctorData.
  Future<Map<String, dynamic>?> getDoctorInfo(String doctorId) async {
    var collection = db.collection('Information');
    return await collection.findOne({'_id': doctorId});
  }
  
  /// Retrieves all appointments from the "Appointments" collection in PatientData.
  Future<List<Map<String, dynamic>>> getAppointments() async {
    var collection = db.collection('Appointments');
    return await collection.find({}).toList();
  }
}
