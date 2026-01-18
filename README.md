# ProChat: Luxe Noir Edition 🏛️💎🥂

ProChat is a premium, high-performance messaging application built with Flutter and Firebase. Designed with an elite "Luxe Noir" aesthetic, it combines modern minimalism with robust, real-time communication features.

![App Icon](assets/app_icon.png)

## 💎 Elite Features

### 🏛️ Luxe Noir Experience
- **Premium Design System**: Immersive dark mode with pure gold accents and glassmorphism throughout.
- **Refined Auth Flow**: Minimalist Login and Register screens with subtle radial glow effects for a high-end first impression.
- **Dynamic UI**: Smooth transitions and micro-animations that make the interface feel alive.

### 💬 Advanced Messaging
- **Real-Time Communication**: Instant message delivery powered by Firebase Cloud Firestore.
- **Private & Group Chats**: Seamlessly switch between one-on-one deep conversations and high-energy group dynamics.
- **Privacy Core**:
    - **Delete for Me**: Clear your own messaging history while keeping it for others.
    - **Delete for Everyone**: Permanently remove messages from both ends.
    - **Smart Synchronization**: Chat lists automatically update to hide deleted messages and show the most recent active text.

### ⚙️ Under the Hood
- **Sync Architecture**: Centralized `ChatProvider` for state management.
- **Push Notifications**: Real-time alerts via Firebase Cloud Messaging (FCM).
- **Theme System**: Intelligent light/dark mode switching with persisting preferences.

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (^3.9.2)
- Firebase Account & Project

### Installation

1. **Clone the repository**
   ```bash
   git clone [repository-url]
   cd prochat
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Configuration**
   - Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS).
   - Ensure Firestore rules allow for `chat_rooms` and `groups` collections.

4. **Run the application**
   ```bash
   flutter run
   ```

## 📜 License
This project is private and intended for elite use.

---
*Crafted with precision for the ultimate messaging experience.* 🏛️✨
