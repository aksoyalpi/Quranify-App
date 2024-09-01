import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran_fi/consts/recitations.dart';
import 'package:quran_fi/services/shared_prefs.dart';
import 'package:quran_fi/themes/theme_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late String? defaultRecitator;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    defaultRecitator = await SharedPrefs.getDefaultRecitator();
    print("default Recitator $defaultRecitator");
    if (defaultRecitator == null) {
      setState(() {
        defaultRecitator = recitations[0]["reciter_name"].toString();
      });
      await SharedPrefs.setDefaultRecitator(
          recitations[0]["reciter_name"].toString());
    }
  }

  void changeReciter(String? reciter) {
    if (reciter != null) {
      setState(() {
        defaultRecitator = reciter;
      });
      SharedPrefs.setDefaultRecitator(reciter);
    }
  }

  void openRecitatorsSetting() {
    showDialog(
        context: context,
        builder: (context) => Dialog(
              child: Expanded(
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: recitations.length,
                    itemBuilder: (context, index) {
                      final reciter =
                          recitations[index]["reciter_name"].toString();

                      return ListTile(
                          leading: Radio(
                            groupValue: defaultRecitator,
                            value: reciter,
                            onChanged: changeReciter,
                          ),
                          title: Text(reciter));
                    }),
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final defaultRecitator = SharedPrefs.getDefaultRecitator();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text("S E T T I N G S"),
      ),
      body: Column(
        children: [
          // dark and light mode
          SettingsTile(context,
              title: "Dark Mode",
              child:

                  // switch
                  CupertinoSwitch(
                value: themeProvider.isDarkMode,
                onChanged: (_) => themeProvider.toggleTheme(),
              )),

          // defualt recitator
          InkWell(
            onTap: openRecitatorsSetting,
            child: SettingsTile(context,
                title: "Default Recitator",
                child: FutureBuilder(
                  future: defaultRecitator,
                  builder: (_, snapshot) {
                    if (snapshot.hasData) {
                      return Text(snapshot.data.toString());
                    } else if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }
                    return Text("?");
                  },
                )),
          ),
        ],
      ),
    );
  }
}

Widget SettingsTile(BuildContext context,
        {required String title, required Widget child}) =>
    Container(
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // dark mode
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),

          child
        ],
      ),
    );
