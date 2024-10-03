import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran_fi/models/surah.dart';
import 'package:quran_fi/page_manager.dart';
import 'package:quran_fi/services/service_locator.dart';

class SurahTile extends StatelessWidget {
  const SurahTile(
      {super.key,
      required this.surah,
      required this.onSlide,
      required this.onTap});

  final Surah surah;
  final void Function(BuildContext) onSlide;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<PageManager>();
    bool isFavorite = pageManager.favoritesNotifier.value.contains(surah);

    return Slidable(
      startActionPane: ActionPane(
        motion: const StretchMotion(),
        children: [
          SlidableAction(
            backgroundColor: Colors.green,
            autoClose: true,
            onPressed: onSlide,
            icon: Icons.queue_music,
          )
        ],
      ),
      child: Card(
        elevation: 10,
        child: ListTile(
          leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(alignment: Alignment.center, children: [
                Image.asset("assets/images/frame.png"),
                Text(
                  surah.id.toString(),
                  style: GoogleFonts.bodoniModa(
                      color: Color.fromARGB(500, 134, 81, 253), fontSize: 20),
                )
              ])),
          title: Text(surah.title),
          subtitle: Text("Surah ${surah.id}"),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(surah.arabicTitle),
              ValueListenableBuilder(
                  valueListenable: pageManager.favoritesNotifier,
                  builder: (_, favorites, __) {
                    return IconButton(
                        onPressed: () {
                          pageManager.changeFavorites(favorites);
                        },
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ));
                  })
            ],
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
