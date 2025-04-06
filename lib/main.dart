import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  await NotificationService().init();
  runApp(const MoodTrackerApp());
}

class MoodTrackerApp extends StatelessWidget {
  const MoodTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mood Tracker',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
      home: const MoodTrackerHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MoodTrackerHomePage extends StatefulWidget {
  const MoodTrackerHomePage({super.key});

  @override
  State<MoodTrackerHomePage> createState() => _MoodTrackerHomePageState();
}

class _MoodTrackerHomePageState extends State<MoodTrackerHomePage> {
  final List<MoodEntry> moodHistory = [];
  final TextEditingController _noteController = TextEditingController();

  DateTime selectedDate = DateTime.now();
  String? selectedMood;

  final List<String> moods = ['😃', '😐', '😢', '😡', '😴'];

  @override
  void initState() {
    super.initState();
    NotificationService().scheduleDailyReminder();
  }

  Map<String, double> _buildMoodDataMap() {
    final Map<String, double> dataMap = {};
    for (var entry in moodHistory) {
      dataMap[entry.mood] = (dataMap[entry.mood] ?? 0) + 1;
    }
    return dataMap;
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _checkNegativeMoodStreak() {
    final recentEntries = moodHistory
        .where((entry) => entry.mood == '😢')
        .toList()
        .reversed
        .take(3)
        .toList();

    if (recentEntries.length == 3) {
      final allSad = recentEntries.map((e) => e.mood).every((m) => m == '😢');
      if (allSad) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Are you feeling okay?"),
            content: const Text(
              "You’ve logged a sad mood for 3 days in a row. It might help to talk to someone you trust.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    }
  }

  void _saveMood() {
    if (selectedMood != null) {
      setState(() {
        moodHistory.add(
          MoodEntry(
            date: selectedDate,
            mood: selectedMood!,
            note: _noteController.text,
          ),
        );
        _noteController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Mood $selectedMood saved for ${selectedDate.toLocal().toString().split(' ')[0]}!',
          ),
        ),
      );

      _checkNegativeMoodStreak();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal, Colors.blueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (moodHistory.isNotEmpty) ...[
                  const SizedBox(height: 30),
                  const Text(
                    'Mood Statistics',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 200,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: PieChart(
                      dataMap: _buildMoodDataMap(),
                      animationDuration: const Duration(milliseconds: 800),
                      chartRadius: 120,
                      chartValuesOptions: const ChartValuesOptions(
                        showChartValuesInPercentage: true,
                        showChartValues: true,
                      ),
                      legendOptions: const LegendOptions(
                        showLegends: true,
                        legendPosition: LegendPosition.bottom,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 30),
                const Text(
                  'How are you feeling today?',
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 16,
                  children: moods.map((mood) {
                    final isSelected = mood == selectedMood;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedMood = mood;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : Colors.white24,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          mood,
                          style: TextStyle(
                            fontSize: 32,
                            color: isSelected ? Colors.teal : Colors.white,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _noteController,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Write a short note...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _selectDate,
                  icon: const Icon(Icons.calendar_today),
                  label: Text(
                    '${selectedDate.toLocal().toString().split(' ')[0]}',
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveMood,
                  child: const Text('Save Mood'),
                ),
                const SizedBox(height: 30),
                if (moodHistory.isNotEmpty) ...[
                  const Text(
                    'Mood History',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 150,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: moodHistory.length,
                      itemBuilder: (context, index) {
                        final entry = moodHistory[index];
                        return ListTile(
                          leading: Text(
                            entry.mood,
                            style: const TextStyle(fontSize: 24),
                          ),
                          title: Text(
                            entry.date.toLocal().toString().split(' ')[0],
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            entry.note,
                            style: const TextStyle(color: Colors.white70),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MoodEntry {
  final DateTime date;
  final String mood;
  final String note;

  MoodEntry({required this.date, required this.mood, required this.note});
}

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(initializationSettings);
  }

  Future<void> scheduleDailyReminder() async {
    await _notificationsPlugin.zonedSchedule(
      0,
      'Mood Reminder',
      'Don’t forget to log your mood today!',
      _nextInstanceOf8PM(),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_mood_channel',
          'Daily Mood Reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  tz.TZDateTime _nextInstanceOf8PM() {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, 20);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
