import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// Import UI Pages
import 'package:chatapp/presentation/auth/login_page.dart';
import 'package:chatapp/presentation/home/home_page.dart'; 

// Import Bloc, Repository, dan Service yang baru kita buat
import 'package:chatapp/presentation/home/bloc/home_bloc.dart';
import 'package:chatapp/data/repositories/chat_repository.dart';
import 'package:chatapp/data/services/api/chat_service.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) {
        // Bungkus HomePage dengan BlocProvider
        return BlocProvider(
          create: (context) => HomeBloc(
            // Inisialisasi Repository dan Service secara berurutan
            chatRepository: ChatRepository(
              apiService: ChatService(),
            ),
          ),
          child: HomePage(),
        );
      },
    ),
  ],
);