import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran_fi/models/surahs_provider.dart';

class SoundIcon extends StatefulWidget {
  const SoundIcon({super.key});

  @override
  State<SoundIcon> createState() => _SoundIconState();
}

class _SoundIconState extends State<SoundIcon>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<SurahsProvider>(
      builder: (context, value, child) => Column(
        children: [
          // animated container for selecting nature sound
          Center(
            child: AnimatedContainer(
              duration: Durations.short4,
              curve: Curves.bounceIn,
              width: _isExpanded ? 150 : 0,
              height: _isExpanded ? 40 : 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  value.soundIconDatas.length,
                  (index) => GestureDetector(
                      onTap: () {
                        setState(() {
                          _isExpanded = false;
                        });
                        value.soundIndex = index;
                      },
                      child: Icon(value.soundIconDatas[index])),
                ),
              ),
            ),
          ),

          // Icon showing current nature sound
          GestureDetector(
              onTap: () => setState(() {
                    _isExpanded = true;
                  }),
              child: Icon(
                value.soundIconData,
                color: value.soundOn
                    ? Theme.of(context).colorScheme.onPrimary
                    : null,
              )),
        ],
      ),
    );
  }
}
