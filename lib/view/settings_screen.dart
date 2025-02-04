import 'package:flutter/material.dart';
import '../util/db_helper.dart';

class SettingsScreen extends StatefulWidget {
  SettingsScreen();

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  List<Map<String, String>> languages = [
    {"code": "ar", "name": "Arabic"},
    {"code": "de", "name": "German"},
    {"code": "en", "name": "English"},
    {"code": "es", "name": "Spanish"},
    {"code": "fr", "name": "French"},
    {"code": "he", "name": "Hebrew"},
    {"code": "it", "name": "Italian"},
    {"code": "nl", "name": "Dutch"},
    {"code": "no", "name": "Norwegian"},
    {"code": "pt", "name": "Portuguese"},
    {"code": "ru", "name": "Russian"},
    {"code": "sv", "name": "Swedish"},
    {"code": "ud", "name": "Urdu"},
    {"code": "zh", "name": "Chinese (Mandarin)"}
  ];

  DbHelper dbHelper = DbHelper();
  String? selectedLanguageCode;

  @override
  void initState() {
    super.initState();
    getSelectedLanguage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Language Settings'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var language in languages)
              RadioListTile<String>(
                title: Text(language['name']!),
                value: language['code']!,
                groupValue: selectedLanguageCode,
                activeColor: Colors.blue[800],
                onChanged: (String? value) {
                  setState(() {
                    selectedLanguageCode = value;
                  });
                },
              ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue.shade800,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article),
            label: 'All News',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'Saved',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: 4,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/home');
              break;
            case 1:
              Navigator.pushNamed(context, '/allNews');
              break;
            case 2:
              Navigator.pushNamed(context, '/search');
              break;
            case 3:
              Navigator.pushNamed(context, '/saved');
              break;
            case 4:
              Navigator.pushNamed(context, '/settings');
              break;
          }
        },
      ),
      floatingActionButton: ElevatedButton(
        onPressed: () async {
          await saveSelectedLanguage(context);
        },
        child: Icon(Icons.save, color: Colors.white),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[800],
          shape: CircleBorder(),
          padding: EdgeInsets.all(20),
        ),
      ),
    );
  }

  Future<void> saveSelectedLanguage(BuildContext context) async {
    if (selectedLanguageCode != null) {
      await dbHelper.deleteAllLanguages();
      Map<String, Object?> language = {'code': selectedLanguageCode!};
      await dbHelper.insertLanguage(language);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Language saved successfully!'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No language selected to save!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> getSelectedLanguage() async {
    String? savedLanguage = await dbHelper.getSelectedLanguage();

    setState(() {
      selectedLanguageCode = savedLanguage;
    });
  }
}
