import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran_fi/page_manager.dart';
import 'package:quran_fi/services/service_locator.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

class SleepTimerDialog extends StatefulWidget {
  const SleepTimerDialog({super.key});

  @override
  State<SleepTimerDialog> createState() => _SleepTimerDialogState();
}

class _SleepTimerDialogState extends State<SleepTimerDialog> {
  final List<int> times = [5, 10, 15, 30, 45, 60];
  int sleepTime = 0;

  void _setSleepTimer() {
    final pageManager = getIt<PageManager>();
    pageManager.setSleepTimer(sleepTime);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actions: [
        TextButton(
            onPressed: Navigator.of(context).pop, child: const Text("Cancel")),
        TextButton(
            onPressed: () {
              _setSleepTimer();
              Navigator.of(context).pop();
            },
            child: const Text("Ok"))
      ],
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Sleep Timer",
            style: GoogleFonts.trispace(fontSize: 24),
          ),
          const SizedBox(
            height: 30,
          ),

          // circular slider
          SleekCircularSlider(
            appearance: CircularSliderAppearance(
                customWidths: CustomSliderWidths(progressBarWidth: 20),
                infoProperties: InfoProperties(
                  mainLabelStyle: GoogleFonts.trispace(fontSize: 50),
                  modifier: (percentage) => percentage.toInt().toString(),
                ),
                angleRange: 360,
                size: 200,
                startAngle: 270,
                counterClockwise: false,
                customColors: CustomSliderColors(
                    dynamicGradient: false,
                    progressBarColor: Theme.of(context).colorScheme.onPrimary,
                    shadowColor: null,
                    shadowMaxOpacity: 0)),
            onChange: (double value) =>
                setState(() => sleepTime = value.toInt()),
            min: 0,
            max: 60,
            initialValue: sleepTime.toDouble(),
          ),

          const SizedBox(
            height: 30,
          ),

          // quick access settings (buttons)
          SizedBox(
            height: 200,
            width: double.maxFinite,
            child: GridView.count(
              shrinkWrap: true,
              crossAxisCount: 3,
              children: List.generate(
                times.length,
                (index) => InkWell(
                  onTap: () => setState(() => sleepTime = times[index]),
                  child: Card(
                    child: Center(child: Text(times[index].toString())),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
