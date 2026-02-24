import 'package:get_it/get_it.dart';
import 'package:chatapp/core/utils/user_storage.dart';
import 'package:chatapp/data/services/api/auth_service.dart';
import 'package:chatapp/data/services/api/chat_service.dart';
import 'package:chatapp/data/services/websocket/chat_socket_service.dart';
import 'package:chatapp/data/repositories/auth_repository.dart';
import 'package:chatapp/data/repositories/chat_repository.dart';
import 'package:chatapp/data/repositories/chat_room_repository.dart';
import 'package:chatapp/presentation/auth/bloc/auth_bloc.dart';
import 'package:chatapp/presentation/home/bloc/home_bloc.dart';
import 'package:chatapp/presentation/chat/bloc/chat_bloc.dart';
import 'package:chatapp/presentation/verify_pin/bloc/verify_pin_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Utils
  sl.registerLazySingleton(() => UserStorage());

  // Services
  sl.registerLazySingleton(() => AuthService());
  sl.registerLazySingleton(() => ChatService(sl()));

  // WebSocket service — singleton so stream controllers are never destroyed
  sl.registerLazySingleton(() => ChatSocketService(sl()));

  // Repositories
  sl.registerLazySingleton(() => AuthRepository(sl(), sl()));
  sl.registerLazySingleton(() => ChatRepository(sl()));

  // ChatRoomRepository MUST be lazySingleton (not factory) so it shares
  // the same ChatSocketService instance and its stable stream controllers.
  sl.registerLazySingleton(() => ChatRoomRepository(sl(), sl()));

  // Blocs — factory is correct here (new instance per page)
  sl.registerFactory(() => AuthBloc(sl()));
  sl.registerFactory(() => HomeBloc(sl()));
  sl.registerFactory(() => ChatBloc(sl()));
  sl.registerFactory(() => VerifyPinBloc(sl()));
}
