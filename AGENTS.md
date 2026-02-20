# ChatApp - BLoC Clean Architecture

## Tech Stack
- Flutter
- flutter_bloc (state management)
- go_router (navigation)
- get_it + injectable (dependency injection)
- shared_preferences (local storage)
- http (network)
- firebase_core, firebase_messaging (push notification)

## Struktur Folder

```
lib/
├── main.dart
├── app.dart
├── injection.dart
│
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_strings.dart
│   │   └── app_assets.dart
│   ├── router/
│   │   ├── app_router.dart
│   │   └── route_names.dart
│   ├── utils/
│   │   ├── user_storage.dart
│   │   ├── date_formatter.dart
│   │   └── validators.dart
│   └── widgets/
│       ├── my_text.dart
│       ├── my_button.dart
│       ├── loading_widget.dart
│       ├── empty_state.dart
│       └── avatar_widget.dart
│
├── data/
│   ├── models/
│   │   ├── user_model.dart
│   │   ├── message_model.dart
│   │   ├── conversation_model.dart
│   │   └── contact_model.dart
│   ├── repositories/
│   │   ├── auth_repository.dart
│   │   ├── chat_repository.dart
│   │   └── contact_repository.dart
│   └── services/
│       ├── api/
│       │   ├── auth_service.dart
│       │   ├── chat_service.dart
│       │   └── contact_service.dart
│       └── firebase/
│           └── firebase_service.dart
│
├── presentation/
│   ├── splash/
│   │   └── splash_page.dart
│   │
│   ├── intro/
│   │   ├── bloc/
│   │   │   ├── intro_bloc.dart
│   │   │   ├── intro_event.dart
│   │   │   └── intro_state.dart
│   │   └── intro_page.dart
│   │
│   ├── auth/
│   │   ├── bloc/
│   │   │   ├── auth_bloc.dart
│   │   │   ├── auth_event.dart
│   │   │   └── auth_state.dart
│   │   ├── widgets/
│   │   │   ├── login_form.dart
│   │   │   └── register_form.dart
│   │   ├── login_page.dart
│   │   └── register_page.dart
│   │
│   ├── home/
│   │   ├── bloc/
│   │   │   ├── home_bloc.dart
│   │   │   ├── home_event.dart
│   │   │   └── home_state.dart
│   │   ├── widgets/
│   │   │   ├── conversation_tile.dart
│   │   │   ├── search_bar.dart
│   │   │   └── fab_new_chat.dart
│   │   └── home_page.dart
│   │
│   ├── chat/
│   │   ├── bloc/
│   │   │   ├── chat_bloc.dart
│   │   │   ├── chat_event.dart
│   │   │   └── chat_state.dart
│   │   ├── widgets/
│   │   │   ├── message_bubble.dart
│   │   │   ├── chat_input.dart
│   │   │   ├── chat_app_bar.dart
│   │   │   └── message_list.dart
│   │   └── chat_page.dart
│   │
│   ├── contacts/
│   │   ├── bloc/
│   │   │   ├── contacts_bloc.dart
│   │   │   ├── contacts_event.dart
│   │   │   └── contacts_state.dart
│   │   ├── widgets/
│   │   │   ├── contact_tile.dart
│   │   │   └── contact_search.dart
│   │   └── contacts_page.dart
│   │
│   ├── profile/
│   │   ├── bloc/
│   │   │   ├── profile_bloc.dart
│   │   │   ├── profile_event.dart
│   │   │   └── profile_state.dart
│   │   ├── widgets/
│   │   │   ├── profile_header.dart
│   │   │   ├── profile_menu.dart
│   │   │   └── edit_profile_form.dart
│   │   └── profile_page.dart
│   │
│   └── settings/
│       ├── bloc/
│       │   ├── settings_bloc.dart
│       │   ├── settings_event.dart
│       │   └── settings_state.dart
│       ├── widgets/
│       │   └── settings_tile.dart
│       └── settings_page.dart
│
└── firebase_options.dart
```

---

## Rules

### core/
- Tidak bergantung ke layer lain
- `constants/` = nilai statis global (warna, string, path)
- `router/` = go_router config & route names
- `utils/` = helper, storage, formatter, validator
- `widgets/` = widget reusable lintas feature

### data/
- `models/` = dariJson(), toJson(), copyWith()
- `repositories/` = business logic, combine services
- `services/api/` = HTTP requests
- `services/firebase/` = FCM, Realtime DB

### presentation/
- `bloc/` = gunakan equatable untuk state/event
- `widgets/` = komponen kecil per feature
- `*_page.dart` = 1 file = 1 screen
- Tidak akses services langsung, harus via repository

### BLoC Pattern
- 3 file per bloc: `*_bloc.dart`, `*_event.dart`, `*_state.dart`
- State extend Equatable
- Event extend Equatable
- Minimal 3 state: Initial, Loading, Success/Error

### Naming Convention
- File: snake_case (`auth_bloc.dart`)
- Class: PascalCase (`AuthBloc`)
- Variables: camelCase (`currentUser`)
- Constants: camelCase (`appColors`)

### Dependency Injection
```dart
// injection.dart
final sl = GetIt.instance;

Future<void> init() async {
  // Services
  sl.registerLazySingleton(() => AuthService());
  sl.registerLazySingleton(() => ChatService());
  sl.registerLazySingleton(() => FirebaseService());
  
  // Repositories
  sl.registerLazySingleton(() => AuthRepository(sl()));
  sl.registerLazySingleton(() => ChatRepository(sl(), sl()));
  
  // Blocs (Factory = new instance every time)
  sl.registerFactory(() => AuthBloc(sl()));
  sl.registerFactory(() => ChatBloc(sl()));
}
```

---

## Commands

### Run App
```bash
flutter run
```

### Build Runner (generate code)
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Clean
```bash
flutter clean && flutter pub get
```
