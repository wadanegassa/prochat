# ProChat

ProChat is a modern, real-time messaging application built with **Flutter** and **Firebase**. It offers a seamless communication experience with features like 1-on-1 chats, group conversations, and push notifications, all wrapped in a sleek, theme-aware user interface.

## 🚀 Overview

ProChat is designed to be a robust and scalable chat solution. It uses a clean, feature-based architecture to ensure maintainability and scalability. The app leverages Firebase for its backend needs, ensuring real-time data synchronization and secure authentication.

## ✨ Features

-   **Authentication**: Secure user login and registration powered by Firebase Auth.
-   **Real-time Messaging**: Instant messaging with 1-on-1 chat support.
-   **Group Chats**: Create and manage group conversations for team or community discussions.
-   **Profile Management**: extensive user profile customization.
-   **Theming**: Full support for Light and Dark modes, adapting to system preferences or user choice.
-   **Notifications**: Comprehensive push notification system using Firebase Messaging and Flutter Local Notifications.
-   **Media Sharing**: Support for sharing images with caching handled by `cached_network_image`.

## 🛠 Tech Stack

ProChat is built using the following technologies:

### Framework & Language
-   **[Flutter](https://flutter.dev/)**: The UI toolkit for building beautiful, natively compiled applications.
-   **[Dart](https://dart.dev/)**: The programming language used for Flutter development.

### Backend (Firebase)
-   **[Firebase Core](https://pub.dev/packages/firebase_core)**: Initialization and core functionality.
-   **[Firebase Auth](https://pub.dev/packages/firebase_auth)**: User authentication and management.
-   **[Cloud Firestore](https://pub.dev/packages/cloud_firestore)**: NoSQL cloud database for storing chat history and user data.
-   **[Firebase Messaging](https://pub.dev/packages/firebase_messaging)**: Push notifications.

### State Management
-   **[Provider](https://pub.dev/packages/provider)**: For efficient state management and dependency injection.

### Utilities & UI
-   **[Intl](https://pub.dev/packages/intl)**: For date and number formatting.
-   **[Cached Network Image](https://pub.dev/packages/cached_network_image)**: For efficient image loading and caching.
-   **[Flutter Local Notifications](https://pub.dev/packages/flutter_local_notifications)**: For handling local notifications.

## 📂 Project Structure

The project follows a feature-based directory structure for better organization:

```
lib/
├── core/           # Shared utilities, services, theme, and constants
├── features/       # Feature-specific code (Auth, Chat, Groups, Profile)
│   ├── auth/
│   ├── chat/
│   ├── groups/
│   └── profile/
├── providers/      # State management providers
└── main.dart       # Application entry point
```

## 🚀 Getting Started

To run this project locally:

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/yourusername/prochat.git
    cd prochat
    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Firebase Setup:**
    -   Create a new Firebase project in the [Firebase Console](https://console.firebase.google.com/).
    -   Configure your Android and iOS apps in the Firebase console.
    -   Download the `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) files and place them in their respective directories (`android/app/` and `ios/Runner/`).
    -   *Alternatively, use the FlutterFire CLI to configure the project automatically.*

4.  **Run the app:**
    ```bash
    flutter run
    ```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

---

Built with ❤️ using Flutter.
