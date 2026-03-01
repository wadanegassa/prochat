# ProChat

ProChat is a modern, real-time messaging application built with **Flutter** and **Firebase**. It offers a seamless communication experience with features like 1-on-1 chats, group conversations, and push notifications, all wrapped in a sleek, theme-aware user interface.

## 🚀 Overview

ProChat is designed to be a robust and scalable chat solution. It leverages a clean, feature-based architecture to ensure maintainability and scalability, making it easy to extend and manage. The app utilizes Firebase for its backend needs, ensuring real-time data synchronization, secure authentication, and reliable messaging.

## ✨ Features

ProChat comes packed with a rich set of features designed for a modern messaging experience:

*   **Secure Authentication**: Robust user login and registration, including password reset, powered by Firebase Authentication.
*   **1-on-1 Real-time Messaging**: Instant, secure, and private conversations between individual users.
*   **Group Chats**: Create, manage, and participate in group conversations for team collaboration or community discussions.
*   **User Profile Management**: Customize user profiles with avatars, status messages, and personal information.
*   **Rich Media Sharing**: Seamlessly share images within chats, with efficient caching for a smooth user experience.
*   **Theming**: Full support for Light and Dark modes, adapting to system preferences or user choice for a personalized look.
*   **Comprehensive Notifications**: Stay updated with real-time push notifications using Firebase Messaging and local notifications for an uninterrupted experience.
*   **Message Status**: Track message delivery and read status (if implemented) to ensure effective communication.

## 🎨 Design & User Experience

ProChat prioritizes a clean, intuitive, and responsive user interface. The design adheres to modern UI/UX principles, ensuring ease of use and a pleasant visual experience across different devices. With theme-aware components, the app seamlessly adapts to user preferences, providing a consistent and engaging environment.

## 🛠 Tech Stack

ProChat is built using the following cutting-edge technologies:

### Framework & Language
-   **[Flutter](https://flutter.dev/)**: The UI toolkit for building beautiful, natively compiled applications for mobile, web, and desktop from a single codebase.
-   **[Dart](https://dart.dev/)**: The programming language used for Flutter development, known for its efficiency and performance.

### Backend (Firebase)
-   **[Firebase Core](https://pub.dev/packages/firebase_core)**: Initialization and core functionality for all Firebase services.
-   **[Firebase Auth](https://pub.dev/packages/firebase_auth)**: Secure and scalable user authentication and management.
-   **[Cloud Firestore](https://pub.dev/packages/cloud_firestore)**: A flexible, scalable NoSQL cloud database for storing and syncing chat history, user data, and more in real-time.
-   **[Firebase Messaging](https://pub.dev/packages/firebase_messaging)**: A cross-platform messaging solution that lets you reliably send notifications.

### State Management
-   **[Provider](https://pub.dev/packages/provider)**: A simple yet powerful state management solution for Flutter, enabling efficient dependency injection and state updates.

### Utilities & UI
-   **[Intl](https://pub.dev/packages/intl)**: For internationalization, including date, time, and number formatting.
-   **[Cached Network Image](https://pub.dev/packages/cached_network_image)**: For efficient image loading and caching from the internet, improving performance and user experience.
-   **[Flutter Local Notifications](https://pub.dev/packages/flutter_local_notifications)**: For handling local notifications, complementing push notifications for a robust notification system.

## 📂 Project Structure

The project follows a feature-based directory structure for better organization, maintainability, and scalability:

```
lib/
├── core/           # Shared utilities, services, theme, constants, and base classes
├── features/       # Feature-specific code (e.g., Auth, Chat, Groups, Profile)
│   ├── auth/       # Authentication related screens, logic, and services
│   ├── chat/       # Chat screens, message handling, and chat room logic
│   ├── groups/     # Group management, creation, and group chat specific features
│   └── profile/    # User profile viewing and editing
├── providers/      # State management providers for various parts of the app
└── main.dart       # Application entry point and global configurations
```

## 🚀 Getting Started

To run this project locally, follow these steps:

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
    -   Configure your Android and iOS apps within the Firebase console.
    -   Download the `google-services.json` (for Android) and `GoogleService-Info.plist` (for iOS) files and place them in their respective directories (`android/app/` and `ios/Runner/`).
    -   *Alternatively, use the FlutterFire CLI to configure the project automatically for a streamlined setup.*

4.  **Run the app:**
    ```bash
    flutter run
    ```

## 🤝 Contributing

Contributions are highly welcome! If you have suggestions, bug reports, or want to contribute code, please feel free to submit a Pull Request or open an issue.

---

Built with ❤️ using Flutter.
