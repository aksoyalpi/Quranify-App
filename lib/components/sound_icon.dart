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

  OverlayEntry _createOverlayEntry(BuildContext context, SurahsProvider value) {
    RenderBox renderBox =
        _iconKey.currentContext!.findRenderObject() as RenderBox;
    Offset position = renderBox.localToGlobal(Offset.zero);
    double iconWidth = renderBox.size.width;
    double iconHeight = renderBox.size.height;

    return OverlayEntry(
      builder: (context) => Positioned(
        top: position.dy - (iconHeight + 20),
        left: position.dx - 65,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: _isExpanded ? 150 : 0,
          height: _isExpanded ? 40 : 0,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Theme.of(context).colorScheme.secondary),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              value.soundIconDatas.length,
              (index) => GestureDetector(
                  onTap: () {
                    setState(() {
                      _isExpanded = false;
                    });
                    value.soundIndex = index;
                    _overlayEntry?.remove();
                    _overlayEntry = null;
                  },
                  child: Icon(value.soundIconDatas[index])),
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
