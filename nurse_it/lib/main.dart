import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
// import 'db_config.dart'; // Uncomment when needed

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nurse It',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.deepPurpleAccent,
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepPurpleAccent,
          titleTextStyle: TextStyle(
            fontSize: 20, 
            fontWeight: FontWeight.bold,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurpleAccent,
            minimumSize: const Size(double.infinity, 60),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      home: const LoginPage(),
    );
  }
}

// ----------------------------------------------------
// LOGIN PAGE
// ----------------------------------------------------
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  
  void _login() {
    if (_formKey.currentState!.validate()) {
      final username = _usernameController.text.trim().toLowerCase();
      final password = _passwordController.text;
      String role = '';
      // For doctor portal, use admin credentials; for patient portal, use customer credentials.
      if (username == 'quack' && password == 'quackquack') {
        role = 'admin'; // Doctor
      } else if (username == 'duck' && password == 'duckduck') {
        role = 'customer'; // Patient
      } else {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Login Error'),
            content: const Text('Invalid credentials.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DashboardPage(role: role)),
      );
    }
  }
  
  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    print("Building Login Page");
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(labelText: 'Username'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your username';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _login,
                  child: const Text('Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ----------------------------------------------------
// DASHBOARD PAGE (Portal)
// ----------------------------------------------------
class DashboardPage extends StatelessWidget {
  final String role;
  const DashboardPage({super.key, required this.role});
  
  @override
  Widget build(BuildContext context) {
    final String portalTitle = role == 'admin' ? "Doctor Portal" : "Patient Portal";
    return Scaffold(
      appBar: AppBar(
        title: Text(portalTitle),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'profile') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfilePage(
                      username: role == 'admin' ? 'doc' : 'patient',
                      isPatient: role != 'admin',
                    ),
                  ),
                );
              } else if (value == 'logout') {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'profile',
                child: Text('Profile'),
              ),
              PopupMenuItem(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Welcome to the $portalTitle!',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              if (role == 'admin') ...[
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProfilePage(
                          username: 'doc',
                          isPatient: false,
                        ),
                      ),
                    );
                  },
                  child: const Text('My Profile'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ManagePatientsPage()),
                    );
                  },
                  child: const Text('Manage Patients'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ManageAppointmentsPage()),
                    );
                  },
                //   child: const Text('Manage Appointments'),
                // ),
                // const SizedBox(height: 16),
                // ElevatedButton(
                //   onPressed: () {
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(
                //           builder: (_) => const ReportsAnalyticsPage()),
                //     );
                //   },
                  child: const Text('Reports & Analytics'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const SettingsPage()),
                    );
                  },
                  child: const Text('Settings'),
                ),
              ] else ...[
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProfilePage(
                          username: 'patient',
                          isPatient: true,
                        ),
                      ),
                    );
                  },
                  child: const Text('My Profile'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const CustomerAppointmentsPage()),
                    );
                  },
                  child: const Text('My Appointments'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const CustomerRecordsPage()),
                    );
                  },
                  child: const Text('My Records'),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}

// ----------------------------------------------------
// PROFILE PAGE (Doctor/Nurse)
// ----------------------------------------------------
class ProfilePage extends StatefulWidget {
  final String username;
  // Set isPatient to true for patient profiles; false for doctor/nurse.
  final bool isPatient;
  const ProfilePage({super.key, required this.username, this.isPatient = false});
  
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  // Common field:
  final TextEditingController _nameController = TextEditingController();
  // For patient profiles.
  final TextEditingController _addressController = TextEditingController();
  // For doctor/nurse profiles.
  final TextEditingController _locationController = TextEditingController();
  String? _selectedRole; // When not a patient.
  
  @override
  void initState() {
    super.initState();
    _loadProfile();
  }
  
  // Simulated function to fetch profile data for a given username.
  Future<String?> fetchProfileForUser(String username) async {
    // Replace with a real database call.
    await Future.delayed(const Duration(seconds: 1));
    // For demonstration:
    if (username == 'doc') {
      // Doctor's profile
      return '{"name": "Dr. Alice", "location": "City Hospital", "role": "Doctor"}';
    } else if (username == 'patient') {
      // Patient's profile
      return '{"name": "Patient Eve", "address": "123 Main St", "role": "Patient"}';
    }
    return null; // No profile found.
  }
  
  // Simulated function to save profile data for a given username.
  Future<void> saveProfileForUser(String username, String jsonProfile) async {
    // Replace with a real database call.
    await Future.delayed(const Duration(milliseconds: 500));
    print('Profile for $username saved: $jsonProfile');
  }
  
  Future<void> _loadProfile() async {
    final storedJson = await fetchProfileForUser(widget.username);
    if (storedJson != null) {
      final data = jsonDecode(storedJson);
      setState(() {
        _nameController.text = data['name'] ?? '';
        if (widget.isPatient) {
          _addressController.text = data['address'] ?? '';
        } else {
          _locationController.text = data['location'] ?? '';
          _selectedRole = data['role'];
        }
      });
    } else {
      // No profile found; clear fields.
      setState(() {
        _nameController.text = '';
        if (widget.isPatient) {
          _addressController.text = '';
        } else {
          _locationController.text = '';
          _selectedRole = null;
        }
      });
    }
  }
  
  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      Map<String, dynamic> profileData;
      if (widget.isPatient) {
        profileData = {
          'name': _nameController.text.trim(),
          'address': _addressController.text.trim(),
          'role': 'Patient',
        };
      } else {
        profileData = {
          'name': _nameController.text.trim(),
          'location': _locationController.text.trim(),
          'role': _selectedRole,
        };
      }
      final jsonProfile = jsonEncode(profileData);
      saveProfileForUser(widget.username, jsonProfile);
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Profile Saved'),
          content: Text('Profile data:\n$jsonProfile'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _locationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Name Field (common)
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              if (widget.isPatient) ...[
                // For patients: Address field instead of practice location.
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(labelText: 'Address'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your address';
                    }
                    return null;
                  },
                ),
              ] else ...[
                // For doctor/nurse profiles:
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(labelText: 'Practice Location'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your practice location';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  hint: const Text('Select Role'),
                  decoration: const InputDecoration(labelText: 'Role'),
                  items: <DropdownMenuItem<String>>[
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Select Role'),
                    ),
                    const DropdownMenuItem(
                      value: 'Doctor',
                      child: Text('Doctor'),
                    ),
                    const DropdownMenuItem(
                      value: 'Nurse',
                      child: Text('Nurse'),
                    ),
                  ],
                  onChanged: (newValue) {
                    setState(() {
                      _selectedRole = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a role';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 24),
              // Save Profile Button.
              ElevatedButton(
                onPressed: _saveProfile,
                child: const Text('Save Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ----------------------------------------------------
// MANAGE PATIENTS PAGE (Doctor)
// ----------------------------------------------------
class ManagePatientsPage extends StatelessWidget {
  const ManagePatientsPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Patients')),
      body: const Center(child: Text('Patient management interface.')),
    );
  }
}

// ----------------------------------------------------
// MANAGE APPOINTMENTS PAGE (Doctor)
// ----------------------------------------------------
class ManageAppointmentsPage extends StatelessWidget {
  const ManageAppointmentsPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Appointments')),
      body: const Center(
        child: Text("No appointments available."),
      ),
    );
  }
}

// ----------------------------------------------------
// REPORTS & ANALYTICS PAGE (Doctor)
// ----------------------------------------------------
class ReportsAnalyticsPage extends StatelessWidget {
  const ReportsAnalyticsPage({super.key});
  
  Future<Map<String, int>> _fetchReportsData() async {
    // Replace with actual data retrieval logic.
    await Future.delayed(const Duration(seconds: 2));
    return {
      'totalPatients': 120,
      'totalAppointments': 45,
      'upcomingAppointments': 8,
    };
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reports & Analytics')),
      body: FutureBuilder<Map<String, int>>(
        future: _fetchReportsData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong.'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No report data available.'));
          }
          final data = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Card(
                  child: ListTile(
                    title: const Text('Total Patients'),
                    trailing: Text('${data['totalPatients']}'),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: ListTile(
                    title: const Text('Total Appointments'),
                    trailing: Text('${data['totalAppointments']}'),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: ListTile(
                    title: const Text('Upcoming Appointments'),
                    trailing: Text('${data['upcomingAppointments']}'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ----------------------------------------------------
// SETTINGS PAGE (Both Portals)
// ----------------------------------------------------
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  
  void _logout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _logout(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
          ),
        ],
      ),
      body: const Center(child: Text('Settings page content goes here.')),
    );
  }
}

// ----------------------------------------------------
// CUSTOMER APPOINTMENTS PAGE (Patient Portal)
// ----------------------------------------------------
class CustomerAppointmentsPage extends StatefulWidget {
  const CustomerAppointmentsPage({super.key});
  
  @override
  State<CustomerAppointmentsPage> createState() => _CustomerAppointmentsPageState();
}

class _CustomerAppointmentsPageState extends State<CustomerAppointmentsPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  // Dummy appointments map, initially empty.
  final Map<DateTime, List<String>> _appointments = {};
  
  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }
  
  List<String> _getAppointmentsForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _appointments[normalizedDay] ?? [];
  }
  
  @override
  Widget build(BuildContext context) {
    final appointmentsForSelectedDay = _selectedDay != null 
      ? _getAppointmentsForDay(_selectedDay!) 
      : <String>[];
    
    return Scaffold(
      appBar: AppBar(title: const Text('My Appointments')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              height: 400,
              child: Container(
                width: double.infinity,
                child: TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  calendarStyle: const CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Colors.deepPurple,
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Colors.deepPurpleAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Appointments on ${_selectedDay!.month}/${_selectedDay!.day}/${_selectedDay!.year}: ${appointmentsForSelectedDay.length}",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            appointmentsForSelectedDay.isEmpty
                ? const Center(child: Text("No appointments added."))
                : Expanded(
                    child: ListView.builder(
                      itemCount: appointmentsForSelectedDay.length,
                      itemBuilder: (context, index) {
                        final appointment = appointmentsForSelectedDay[index];
                        return ListTile(
                          title: Text(appointment),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------
// CUSTOMER RECORDS PAGE (Patient Portal)
// ----------------------------------------------------
class CustomerRecordsPage extends StatelessWidget {
  const CustomerRecordsPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Records')),
      body: const Center(child: Text('Customer records interface.')),
    );
  }
}

// ----------------------------------------------------
// CALENDAR PAGE (Standalone)
// ----------------------------------------------------
class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});
  
  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  
  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calendar Only')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 400,
          child: Container(
            width: double.infinity,
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              calendarStyle: const CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.deepPurple,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.deepPurpleAccent,
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
