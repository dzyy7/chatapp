# ChatApp - BLoC Clean Architecture

## Build Commands

```bash
# Run the app
flutter run

# Analyze code
flutter analyze

# Clean and reinstall dependencies
flutter clean && flutter pub get

# Run all tests
flutter test

# Run single test file
flutter test test/path/to/test_file.dart

# Run specific test by name
flutter test --name "testName" test/path/to/test_file.dart
```

## Architecture Overview

```
lib/
├── main.dart              # App entry point
├── injection.dart         # GetIt DI setup
├── core/                  # Shared utilities (no feature dependencies)
│   ├── constants/         # AppColors, AppStrings, AppAssets
│   ├── router/            # go_router config & route names
│   ├── utils/             # UserStorage, formatters, validators
│   └── widgets/           # Reusable widgets across features
├── data/                  # Data layer
│   ├── models/            # fromJson(), toJson(), copyWith()
│   ├── repositories/      # Business logic, combine services
│   └── services/          # API calls, WebSocket, storage
└── presentation/          # UI layer
    └── <feature>/
        ├── bloc/          # *_bloc.dart, *_event.dart, *_state.dart
        ├── widgets/       # Feature-specific widgets
        └── *_page.dart    # Screen (1 file = 1 screen)
```

## Import Order

```dart
// 1. Dart SDK imports
import 'dart:async';
import 'dart:convert';

// 2. Flutter SDK imports
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

// 3. External package imports (alphabetical)
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

// 4. Internal package imports (alphabetical)
import 'package:chatapp/core/constants/app_colors.dart';
import 'package:chatapp/data/repositories/auth_repository.dart';
```

## Code Style

### Naming Conventions
- **Files**: snake_case (`auth_bloc.dart`, `login_page.dart`)
- **Classes**: PascalCase (`AuthBloc`, `LoginPage`)
- **Variables/Methods**: camelCase (`currentUser`, `_handleLogin`)
- **Constants**: camelCase (`appColors`, `primary`)
- **Private members**: underscore prefix (`_authService`, `_onLogin`)

### Formatting
- Use `const` constructors wherever possible
- Use trailing commas in multi-line lists/parameters
- Use double quotes for strings with interpolation, single quotes otherwise

### Widget Structure
```dart
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<AuthBloc>(),
      child: const _LoginForm(),
    );
  }
}

class _LoginForm extends StatefulWidget {
  const _LoginForm();

  @override
  State<_LoginForm> createState() => _LoginFormState();
}
```

## BLoC Pattern

### File Structure
Each feature's BLoC uses 3 files:
- `*_event.dart` - Events extend Equatable
- `*_state.dart` - States extend Equatable
- `*_bloc.dart` - Bloc class with event handlers

### State Classes
```dart
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthSuccess extends AuthState {
  final String message;
  const AuthSuccess({this.message = 'Success'});

  @override
  List<Object?> get props => [message];
}
class AuthError extends AuthState {
  final String message;
  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}
```

### Bloc Implementation
```dart
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(AuthInitial()) {
    on<AuthLoginEvent>(_onLogin);
  }

  Future<void> _onLogin(AuthLoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final response = await _authRepository.login(
        username: event.username,
        password: event.password,
      );
      if (response.isSuccess) {
        emit(AuthSuccess(message: response.message));
      } else {
        emit(AuthError(message: response.message));
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }
}
```

## Error Handling

### In Services (API/WebSocket)
```dart
try {
  final response = await http.post(url, headers: headers, body: body);
  final json = jsonDecode(response.body);
  return Model.fromJson(json);
} catch (e) {
  debugPrint('❌ Service Error: $e');
  rethrow;
}
```

### In Repositories
```dart
try {
  final response = await _service.login(...);
  if (response.isSuccess && response.data != null) {
    await _storage.saveToken(response.data!.token);
  }
  return response;
} catch (e) {
  debugPrint('❌ Repository Error: $e');
  rethrow;
}
```

### In BLoCs
```dart
try {
  // operation
  emit(SuccessState());
} catch (e) {
  emit(ErrorState(message: e.toString()));
}
```

## Logging Convention

Use `debugPrint` with emoji prefixes:
```dart
debugPrint('════════════════════════════════════════');
debugPrint('🔐 AuthService - Login Request');
debugPrint('📍 URL: $url');
debugPrint('✅ Success');
debugPrint('❌ Error: $e');
debugPrint('⏳ Loading...');
debugPrint('════════════════════════════════════════');
```

## Dependency Injection

```dart
// injection.dart
final sl = GetIt.instance;

Future<void> init() async {
  // Utils (singleton)
  sl.registerLazySingleton(() => UserStorage());

  // Services (singleton)
  sl.registerLazySingleton(() => AuthService());
  sl.registerLazySingleton(() => ChatService(sl()));

  // Repositories (singleton for stateless, factory for stateful)
  sl.registerLazySingleton(() => AuthRepository(sl(), sl()));

  // Blocs (factory = new instance each time)
  sl.registerFactory(() => AuthBloc(sl()));
}
```

## Layer Rules

### core/
- No dependencies on other layers
- Pure utilities, constants, and shared widgets

### data/
- Models: JSON serialization only, no business logic
- Services: HTTP/WebSocket calls, return raw models
- Repositories: Combine services, handle business logic

### presentation/
- Access repositories via BLoC only, never services directly
- Pages provide BlocProvider, contain private widget implementations
- Widgets are feature-specific, reusable widgets go to core/widgets

## Testing

```bash
# Run all tests
flutter test

# Run single test file
flutter test test/presentation/auth/auth_bloc_test.dart

# Run with coverage
flutter test --coverage
```

### Test File Location
Mirror the lib structure in test/:
```
test/
├── presentation/
│   └── auth/
│       └── auth_bloc_test.dart
├── data/
│   └── repositories/
│       └── auth_repository_test.dart
```
