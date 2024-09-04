import 'package:flutter/material.dart';
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

  void _toggleOverlay(BuildContext context) {
    if (_isExpanded) {
      _overlayEntry?.remove();
      _overlayEntry = _createOverlayEntry(context);
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

  OverlayEntry _createOverlayEntry(BuildContext context) {
    final pageManager = getIt<PageManager>();
    RenderBox renderBox =
        _iconKey.currentContext!.findRenderObject() as RenderBox;
    Offset position = renderBox.localToGlobal(Offset.zero);
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
            child: ValueListenableBuilder(
              valueListenable: pageManager.currentSoundIndex,
              builder: (_, soundIndex, __) => Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Slider for quran volume
                  ValueListenableBuilder(
                      valueListenable: pageManager.quranVolume,
                      builder: (_, quranVolume, __) => Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(quranVolume != 0
                                  ? Icons.record_voice_over_outlined
                                  : Icons.voice_over_off_outlined),
                              Slider(
                                activeColor:
                                    Theme.of(context).colorScheme.onPrimary,
                                value: quranVolume,
                                onChanged: (volume) {
                                  pageManager.setQuranVolume(volume);
                                },
                              ),
                            ],
                          )),

                  // Slider for sound volume
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(soundIndex != 0
                          ? Icons.music_note_outlined
                          : Icons.music_off_outlined),
                      ValueListenableBuilder(
                          valueListenable: pageManager.soundVolume,
                          builder: (_, soundVolume, __) => Slider(
                                activeColor: soundIndex != 0
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : Theme.of(context).colorScheme.primary,
                                value: soundIndex == 0 ? 0 : soundVolume,
                                onChanged: (volume) =>
                                    pageManager.setSoundVolume(volume),
                              )),
                    ],
                  ),

                  // Icons for different nature sounds
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(
                      pageManager.sounds.length,
                      (index) => GestureDetector(
                          onTap: () {
                            //setState(() {
                            //  _isExpanded = false;
                            //});
                            pageManager.setSoundIndex(index);
                            //_overlayEntry?.remove();
                            //_overlayEntry = null;
                          },
                          child: Icon(
                            pageManager.sounds.values.elementAt(index),
                            color: index == soundIndex
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
    final pageManager = getIt<PageManager>();

    return Column(
      children: [
        // animated container for selecting nature sound

        // Icon showing current nature sound
        GestureDetector(
            key: _iconKey,
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
                _toggleOverlay(context);
              });
            },
            child: ValueListenableBuilder(
                valueListenable: pageManager.currentSoundIndex,
                builder: (_, soundIndex, __) => Icon(
                      pageManager.sounds.values.elementAt(soundIndex),
                      color: soundIndex != 0
                          ? Theme.of(context).colorScheme.onPrimary
                          : null,
                    ))),
      ],
    );
  }
}
