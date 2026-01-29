# Smart Gym App - Setup Instructions

## Prerequisites
- Flutter SDK installed.
- Firebase Account.

## Firebase Setup (CRITICAL)
This app requires Firebase services. You must configure it before running.

1.  **Create a Firebase Project**: Go to [Firebase Console](https://console.firebase.google.com/).
2.  **Enable Authentication**:
    -   Go to Authentication > Get Started.
    -   Enable **Email/Password** sign-in method.
3.  **Enable Firestore**:
    -   Go to Firestore Database > Create Database.
    -   Start in **Test Mode** (for development).
4.  **Configure Flutter App**:
    -   Install FlutterFire CLI: `dart pub global activate flutterfire_cli`
    -   Run in your terminal at the project root:
        ```bash
        flutterfire configure
        ```
    -   Select your project and platforms (iOS, Android).
    -   This will replace `lib/firebase_options.dart` with the real credentials.

## Running the App
After configuring Firebase:

```bash
flutter pub get
flutter run
```

## Default Roles
- **Member**: Can register via the app.
- **Admin**: Needs to be manually set in Firestore.
    1.  Register a new user in the app.
    2.  Go to Firestore Console > `users` collection.
    3.  Find your user document.
    4.  Change the `role` field from `'member'` to `'admin'`.
    5.  Restart the app to see the Admin Dashboard.
