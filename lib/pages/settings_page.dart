import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran_fi/models/recitator.dart';
import 'package:quran_fi/page_manager.dart';
import 'package:quran_fi/services/service_locator.dart';
import 'package:quran_fi/services/shared_prefs.dart';
import 'package:quran_fi/themes/theme_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late Recitator? defaultRecitator;
  final pageManager = getIt<PageManager>();
  late final List<Recitator> recitations;

  @override
  void initState() {
    super.initState();
    recitations = pageManager.recitators;
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final defaultRecitatorId = await SharedPrefs.getDefaultRecitator();
    if (defaultRecitatorId == null) {
      setState(() {
        defaultRecitator =
            recitations.firstWhere((reciter) => reciter.id == 92);
      });
      await SharedPrefs.setDefaultRecitator(
          recitations.firstWhere((reciter) => reciter.id == 92).id);
    } else {
      setState(() {
        defaultRecitator = recitations
            .firstWhere((recitator) => recitator.id == defaultRecitatorId);
      });
    }
  }

  void changeReciter(Recitator? newRecitator) async {
    if (newRecitator != null) {
      setState(() {
        defaultRecitator = newRecitator;
      });
      SharedPrefs.setDefaultRecitator(newRecitator.id);
      await pageManager.setDefaultRecitator(newRecitator.id);
    }
  }

  void openRecitatorsSetting() {
    showDialog(
        context: context,
        builder: (context) => Dialog(
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: recitations.length,
                  itemBuilder: (context, index) {
                    final reciter = recitations[index];

                    return RadioListTile(
                      title: Text(reciter.name),
                      groupValue: defaultRecitator!.id,
                      value: reciter.id,
                      onChanged: (int? newId) =>
                          changeReciter(recitations.firstWhere(
                        (recitator) => recitator.id == newId,
                      )),
                    );
                  }),
            ));
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final defaultRecitator = SharedPrefs.getDefaultRecitator();

    return Column(
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
                    return Text(recitations
                        .firstWhere(
                            (reciter) => reciter.id == (snapshot.data ?? 92))
                        .name);
                  } else if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  return const Text("?");
                },
              )),
        ),
      ],
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
