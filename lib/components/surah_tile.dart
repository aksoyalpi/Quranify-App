import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran_fi/models/surah.dart';
import 'package:quran_fi/page_manager.dart';
import 'package:quran_fi/services/service_locator.dart';

class SurahTile extends StatefulWidget {
  const SurahTile(
      {super.key,
      required this.surah,
      required this.onSlide,
      required this.onTap,
      required this.isChosen});

  final Surah surah;
  final void Function(BuildContext) onSlide;
  final void Function() onTap;
  final bool isChosen;

  @override
  State<SurahTile> createState() => _SurahTileState();
}

class _SurahTileState extends State<SurahTile> {
  final pageManager = getIt<PageManager>();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      elevation: 10,
      child: Slidable(
        startActionPane: ActionPane(
          motion: const StretchMotion(),
          children: [
            SlidableAction(
              backgroundColor: Colors.green,
              autoClose: true,
              onPressed: widget.onSlide,
              icon: Icons.queue_music,
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            leading: widget.isChosen
                ? const Icon(Icons.check)
                : Stack(alignment: Alignment.center, children: [
                    Image.asset("assets/images/frame.png"),
                    Text(
                      widget.surah.id.toString(),
                      style: GoogleFonts.bodoniModa(
                          color: const Color.fromARGB(500, 134, 81, 253),
                          fontSize: 20),
                    )
                  ]),
            title: Text(
              widget.surah.title,
              style: GoogleFonts.bodoniModa(),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(widget.surah.arabicTitle),

                const SizedBox(
                  width: 20,
                ),

                ValueListenableBuilder(
                  valueListenable: pageManager.playlistNotifier,
                  builder: (_, playlist, __) {
                    return Icon(
                      Icons.playlist_add_check,
                      color: playlist.contains(widget.surah.title)
                          ? Colors.green.shade800
                          : Colors.transparent,
                    );
                  },
                ),

                // favorites icon (heart)
                ValueListenableBuilder(
                    valueListenable: pageManager.favoritesNotifier,
                    builder: (_, favorites, __) {
                      final isFavorite = favorites.contains(widget.surah);
                      return IconButton(
                          onPressed: () async {
                            final tmpFavorites = favorites;
                            if (favorites.contains(widget.surah)) {
                              tmpFavorites.removeWhere(
                                (favorite) => favorite.id == widget.surah.id,
                              );
                            } else {
                              tmpFavorites.add(widget.surah);
                            }
                            await pageManager.changeFavorites(tmpFavorites);
                          },
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ));
                    }),

                // // checkbox if in choose mode
                // ValueListenableBuilder(
                //     valueListenable: pageManager.isChooseMode,
                //     builder: (context, value, child) {
                //       if (isChooseMode) {
                //         return Checkbox(
                //           value: false,
                //           onChanged: (value) {},
                //         );
                //       } else {
                //         return SizedBox.shrink();
                //       }
                //     })
              ],
            ),
            onTap: widget.onTap,
          ),
        ),
      ),
    );
  }
}
