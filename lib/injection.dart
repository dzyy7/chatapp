import 'package:get_it/get_it.dart';
import 'package:chatapp/core/utils/user_storage.dart';
import 'package:chatapp/data/services/api/auth_service.dart';
import 'package:chatapp/data/repositories/auth_repository.dart';
import 'package:chatapp/presentation/auth/bloc/auth_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Utils
  sl.registerLazySingleton(() => UserStorage());

  // Services
  sl.registerLazySingleton(() => AuthService());

  // Repositories
  sl.registerLazySingleton(() => AuthRepository(sl(), sl()));

  // Blocs
  sl.registerFactory(() => AuthBloc(sl()));
}
