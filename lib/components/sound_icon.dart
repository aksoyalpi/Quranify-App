import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran_fi/models/surahs_provider.dart';
import 'package:quran_fi/page_manager.dart';
import 'package:quran_fi/services/service_locator.dart';

class SoundIcon extends StatefulWidget {
  const SoundIcon({super.key});

  @override
  State<SoundIcon> createState() => _SoundIconState();
}

class _SoundIconState extends State<SoundIcon>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  OverlayEntry? _overlayEntry;
  final GlobalKey _iconKey = GlobalKey();

  void _toggleOverlay(BuildContext context, SurahsProvider value) {
    if (_isExpanded) {
      _overlayEntry?.remove();
      _overlayEntry = _createOverlayEntry(context, value);
      Overlay.of(context).insert(_overlayEntry!);
    } else {
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  OverlayEntry _createOverlayEntry(BuildContext context, SurahsProvider prov) {
    final pageManager = getIt<PageManager>();
    RenderBox renderBox =
        _iconKey.currentContext!.findRenderObject() as RenderBox;
    Offset position = renderBox.localToGlobal(Offset.zero);
    double iconWidth = renderBox.size.width;
    double iconHeight = renderBox.size.height;
    double containerWidth = 250;
    double containerHeigth = 150;

    return OverlayEntry(
      builder: (context) => Positioned(
        top: position.dy - (iconHeight + containerHeigth - 20),
        left: position.dx - containerWidth / 2 + 12,
        child: Material(
          color: Colors.transparent,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: _isExpanded ? containerWidth : 0,
            height: _isExpanded ? containerHeigth : 0,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Theme.of(context).colorScheme.secondary),
            child: Consumer<SurahsProvider>(
              builder: (context, value, child) => Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Slider for quran volume
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(value.quranVolume != 0
                          ? Icons.record_voice_over_outlined
                          : Icons.voice_over_off_outlined),
                      ValueListenableBuilder(
                          valueListenable: pageManager.quranVolume,
                          builder: (_, quranVolume, __) => Slider(
                                activeColor:
                                    Theme.of(context).colorScheme.onPrimary,
                                value: quranVolume,
                                onChanged: (volume) {
                                  print(quranVolume);
                                  pageManager.setQuranVolume(volume);
                                },
                              )),
                    ],
                  ),

                  // Slider for sound volume
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(value.soundOn
                          ? Icons.music_note_outlined
                          : Icons.music_off_outlined),
                      Slider(
                        activeColor: value.soundOn
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.primary,
                        value: value.soundVolume,
                        onChanged: (volume) => value.soundVolume = volume,
                      ),
                    ],
                  ),

                  // Icons for different nature sounds
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(
                      value.soundIconDatas.length,
                      (index) => GestureDetector(
                          onTap: () {
                            //setState(() {
                            //  _isExpanded = false;
                            //});
                            value.soundIndex = index;
                            //_overlayEntry?.remove();
                            //_overlayEntry = null;
                          },
                          child: Icon(
                            value.soundIconDatas[index],
                            color: index == value.soundIndex
                                ? Theme.of(context).colorScheme.onPrimary
                                : null,
                          )),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SurahsProvider>(
      builder: (context, value, child) => Column(
        children: [
          // animated container for selecting nature sound

          // Icon showing current nature sound
          GestureDetector(
              key: _iconKey,
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                  _toggleOverlay(context, value);
                });
              },
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
