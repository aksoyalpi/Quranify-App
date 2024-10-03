import 'package:get_it/get_it.dart';
import 'package:audio_service/audio_service.dart';
import 'package:quran_fi/choose_mode_manager.dart';
import 'package:quran_fi/page_manager.dart';
import 'package:quran_fi/services/playlist_repository.dart';
import 'audio_handler.dart';

GetIt getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  getIt.registerSingleton<AudioHandler>(await initAudioService());
  // services
  getIt.registerLazySingleton<PlaylistRepository>(() => DemoPlaylist());

  // page state
  getIt.registerLazySingleton<PageManager>(() => PageManager());

  // choose mode state
  getIt.registerLazySingleton<ChooseModeManager>(
    () => ChooseModeManager(),
  );
}
