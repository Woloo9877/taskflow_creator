# TaskFlow Creator

A Flutter to-do list application built for content creators and digital builders, developed as a one-week individual mobile development assessment (Track B).

## Features

**Core functionality**
- Email/password registration, login, and logout via Firebase Authentication
- Create, view, edit, delete, complete, and uncomplete tasks
- Tasks stored in Cloud Firestore, isolated per user (enforced both client-side and via server-side security rules)
- Loading, empty, validation, and error states throughout

**Creator-focused features**
- **Daily Consistency Progress Ring** - an animated circular progress indicator (hand-drawn with `CustomPainter`, no charting package) showing today's task completion percentage
- **Creator Priority Matrix** - filterable priority tiers (Critical / High-Value / Growth) with color-coded task cards

## Tech stack

- **Flutter & Dart** - Android target
- **Firebase Authentication** - email/password sign-in
- **Cloud Firestore** - task data storage with security-rule-enforced isolation
- **No external state management package** - uses Flutter's built-in `ChangeNotifier` + `InheritedNotifier` for the one piece of global UI state (theme), and `StreamBuilder` directly against Firestore/Auth streams for everything else
- **No UI kit or template** - theme, components, and layouts built from scratch

## Architecture
```text
lib/
├── core/
│   ├── constants/     # AppColors, AppTextStyles - single source of truth for styling
│   ├── theme/         # Light/dark ThemeData + ThemeController (ChangeNotifier)
│   └── utils/         # Input validators, date formatting helpers
│
├── data/
│   ├── models/        # TaskModel - immutable, with Firestore (de)serialization
│   └── services/      # FirebaseAuthService, FirestoreService - the only classes
│                      # that touch the Firebase SDK directly
│
├── presentation/
│   ├── screens/       # AuthScreen, DashboardScreen, TaskDetailScreen, ProfileScreen
│   └── widgets/       # CustomProgressRing, TaskCard
│
└── main.dart          # Firebase init, theme wiring, auth-state routing
```

Dependency direction is one-way: `presentation` depends on `data`, `data` depends on `core`, never the reverse. UI widgets never call the Firebase SDK directly - they go through `FirebaseAuthService` / `FirestoreService`.

## Data isolation

Every Firestore query is scoped to the signed-in user's `uid` on the client, and this is independently enforced server-side via `firestore.rules` - a user can only read, create, update, or delete a task document whose `ownerId` field matches their own authenticated uid, even if the client-side query logic were bypassed entirely.

## Getting started

This repo does not include Firebase configuration files (`google-services.json`, `lib/firebase_options.dart`) or any secrets - they're excluded via `.gitignore` by design. To run this project yourself:

1. Clone the repo and run `flutter pub get`
2. Create your own Firebase project at console.firebase.google.com
3. Enable **Authentication -> Email/Password** and **Firestore Database**
4. Install the FlutterFire CLI and run `flutterfire configure` from the project root, selecting Android
5. Publish the security rules in `firestore.rules` to your Firestore project's Rules tab
6. Run `flutter run` on a connected Android device or emulator

## Build
flutter build apk --release
Output: `build/app/outputs/flutter-apk/app-release.apk`
