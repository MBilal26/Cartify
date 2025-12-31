# 🛍️ Cartify - Modern E-Commerce Application

<div align="center">
  <img src="cartify/assets/images/glass-logo.png" alt="Cartify Logo" height="150"/>
  <br/><br/>
  
  [![Flutter](https://img.shields.io/badge/Flutter-3.19.0-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
  [![Dart](https://img.shields.io/badge/Dart-3.3.0-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
  [![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)
  [![License](https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge)](LICENSE)

  <h3>Thinking of shopping? Think Cartify!</h3>
  
  <p align="center">
    A feature-rich, intelligent, and visually stunning e-commerce mobile application built with Flutter & Firebase.
  </p>
</div>

---

## 📱 About The Project

**Cartify** is not just another shopping app; it's a semester project capable of scaling into a real-world product. It combines modern UI design principles with robust backend functionality to deliver a seamless shopping experience.

Featuring an AI-powered shopping assistant ("Carti"), real-time database updates, secure authentication flows, and a dynamic theming engine, Cartify represents the cutting edge of mobile app development.

---

## ✨ Key Features

### 👤 Customer Experience
*   **🔐 Secure Authentication**: 
    *   Email/Password Login & Signup
    *   **OTP Verification** for email (Powered by EmailJS)
    *   Password Reset functionality
*   **🛍️ Smart Shopping**:
    *   Categorized product browsing (Men, Women, Kids, Accessories)
    *   Advanced search & filtering
    *   Real-time cart management
*   **🤖 AI Assistant**:
    *   **Carti Chatbot**: Powered by Google Gemini AI to answer product queries and give recommendations.
*   **💳 Checkout & Orders**:
    *   Address selection via **Google Maps** integration
    *   Streamlined checkout process
    *   Order history tracking
*   **🎁 Loyalty System**:
    *   Earn rewards points on every purchase
*   **🎨 Personalization**:
    *   **Dynamic Theming**: Customize app colors per page
    *   Dark/Light mode support

### 🛡️ Admin Dashboard
*   **📈 Analytics**: View sales, user growth, and order statuses.
*   **📦 Product Management**: Add, edit, or delete products and categories.
*   **🖼️ Media Manager**: Upload product images directly to Firebase Storage.
*   **🎨 UI Control**: Customize the app's look and feel remotely.

---

## 🛠️ Tech Stack

### Frontend
*   **Framework**: Flutter (v3.x)
*   **Language**: Dart
*   **State Management**: `setState`, `ValueListenableBuilder`
*   **UI Library**: Material Design 3

### Backend (Firebase)
*   **Authentication**: User management & security
*   **Cloud Firestore**: NoSQL database for real-time data
*   **Storage**: Cloud storage for product images & assets

### External Services
*   **AI**: Google Generative AI (Gemini)
*   **Maps**: Google Maps Platform
*   **Email**: EmailJS (for OTPs and notifications)

---

## 🚀 Getting Started

Follow these instructions to get a copy of the project running on your local machine.

### Prerequisites

*   **Flutter SDK**: `>=3.0.0`
*   **Dart SDK**: `>=3.0.0`
*   **Firebase Account**: For backend services
*   **API Keys**: Google Gemini, Google Maps, EmailJS

### Installation

1.  **Clone the repository**
    ```bash
    git clone https://github.com/MBilal26/Cartify.git
    cd Cartify/cartify
    ```

2.  **Install dependencies**
    ```bash
    flutter pub get
    ```

3.  **Environment Setup**
    Create a `.env` file in the `assets/` directory (create it if it doesn't exist) and add your keys:

    ```env
    # Google AI (Gemini)
    GEMINI_API_KEY=your_gemini_api_key

    # Google Maps
    GOOGLE_MAPS_API_KEY=your_google_maps_api_key

    # EmailJS (For OTP & Email Services)
    EMAILJS_SERVICE_ID=your_service_id
    EMAILJS_TEMPLATE_ID_OTP=your_otp_template_id
    EMAILJS_TEMPLATE_ID_RESET=your_reset_template_id
    EMAILJS_USER_ID=your_public_key
    ```
    > **Note**: Verify that `.env` is listed in your `pubspec.yaml` assets section.

4.  **Firebase Configuration**
    Use the FlutterFire CLI to configure your project:
    ```bash
    flutterfire configure
    ```
    *Select your Firebase project and the platforms (Android/iOS) you want to support.*

5.  **Run the App**
    ```bash
    flutter run
    ```

---

## 📁 Project Structure

A quick look at the top-level directory structure:

```text
lib/
├── constants/           # App-wide constants (NEW)
├── utils/               # Utility classes (Email, OTP, Validators) (NEW)
├── main.dart            # Entry point
├── app_imports.dart     # Centralized export file
├── firebase_options.dart# Firebase config (generated)
├── login_and_signup.dart
├── profile.dart
├── cart.dart
├── ... (Feature Files)
└── admin_panel.dart     # Admin dashboard logic
```

---

## 📸 Screenshots

| Splash Screen | Login | Home | Product Detail |
|:---:|:---:|:---:|:---:|
| <img src="assets/screenshots/splash.png" width="200" alt="splash"/> | <img src="assets/screenshots/login.png" width="200" alt="login"/> | <img src="assets/screenshots/home.png" width="200" alt="home"/> | <img src="assets/screenshots/detail.png" width="200" alt="detail"/> |

| Cart | Admin Panel | Customization | Chatbot |
|:---:|:---:|:---:|:---:|
| <img src="assets/screenshots/cart.png" width="200" alt="cart"/> | <img src="assets/screenshots/admin.png" width="200" alt="admin"/> | <img src="assets/screenshots/custom.png" width="200" alt="custom"/> | <img src="assets/screenshots/chat.png" width="200" alt="chat"/> |

*(Note: Add screenshot images to `assets/screenshots/` folder to make them visible)*

---

## 🤝 Contributing

Contributions are what make the open-source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1.  Fork the Project
2.  Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3.  Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4.  Push to the Branch (`git push origin feature/AmazingFeature`)
5.  Open a Pull Request

---

## 📝 Note

**There are too many bugs and errors in the app. We are working on it as we dont have a dedicated testing person we are slowly resolving all the bugs.**

## 👨‍💻 Authors

*   **Muhammad Bilal** - *Lead Developer* - [GitHub](https://github.com/MBilal26)
*   **Usaidullah Rehan** - *Developer*

<br/>
<div align="center">
  <p>Made with ❤️ in Flutter</p>
</div>
