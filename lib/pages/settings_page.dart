import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_donation_buttons/donationButtons/ko-fiButton.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:provider/provider.dart';
import 'package:quran_fi/helper_functions.dart';
import 'package:quran_fi/models/recitator.dart';
import 'package:quran_fi/page_manager.dart';
import 'package:quran_fi/services/service_locator.dart';
import 'package:quran_fi/services/shared_prefs.dart';
import 'package:quran_fi/themes/theme_provider.dart';
import 'package:share_plus/share_plus.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late Recitator? defaultRecitator;
  final pageManager = getIt<PageManager>();
  late final List<Recitator> recitations;
  int defaultRecitatorId = 7;

  @override
  void initState() {
    super.initState();
    recitations = pageManager.recitators;
    _loadPrefs();
  }

  void _goToPlayStore() async {
    InAppReview inAppReview = InAppReview.instance;

    if (await inAppReview.isAvailable()) inAppReview.openStoreListing();
  }

  void _shareHandler(context) async {
    late final ShareResult result;
    try {
      result = await Share.shareXFiles(
          [XFile("assets\\icons\\whiteOnPurple_512x512.png")],
          text:
              "Check out this cool App to listen to the holy Quran with calming nature sounds in the background\n: https://play.google.com/store/apps/details?id=com.alaksoftware.quranify&pcampaignid=web_share");
    } catch (e) {
      result = await Share.share(
          "Check out this cool App to listen to the holy Quran with calming nature sounds in the background\n: https://play.google.com/store/apps/details?id=com.alaksoftware.quranify&pcampaignid=web_share");
    }
    if (result.status == ShareResultStatus.success) {
      if (mounted) showSnackBar(context, "Thank your for sharing my App :)");
    }
  }

  Future<void> _loadPrefs() async {
    final defaultRecitatorId = await SharedPrefs.getDefaultRecitator();
    if (defaultRecitatorId == null) {
      setState(() {
        defaultRecitator = recitations
            .firstWhere((reciter) => reciter.id == defaultRecitatorId);
      });
      await SharedPrefs.setDefaultRecitator(recitations
          .firstWhere((reciter) => reciter.id == defaultRecitatorId)
          .id);
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
        settingsTile(context,
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
          child: settingsTile(context,
              title: "Default Recitator",
              child: FutureBuilder(
                future: defaultRecitator,
                builder: (_, snapshot) {
                  if (snapshot.hasData) {
                    return Text(recitations
                        .firstWhere((reciter) =>
                            reciter.id ==
                            (snapshot.data ?? defaultRecitatorId)) // Mishari
                        .name);
                  } else if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  return const Text("?");
                },
              )),
        ),

        // Feedback button
        InkWell(
          onTap: _goToPlayStore,
          child: settingsTile(context,
              title: "Give Feedback",
              child: const Icon(Icons.feedback_outlined)),
        ),

        // Share App Button
        InkWell(
            onTap: () => _shareHandler(context),
            child: settingsTile(context,
                title: "Share App with others",
                child: const Icon(Icons.share))),

        KofiButton(
            kofiName: "alaksoftware",
            kofiColor: KofiColor.Red,
            onDonation: () {
              // TODO
            }),
      ],
    );
  }
}

Widget settingsTile(BuildContext context,
        {required String title, Widget? child}) =>
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

          if (child != null) child
        ],
      ),
    );
