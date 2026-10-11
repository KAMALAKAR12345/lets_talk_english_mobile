# 📱 Let's Talk English — Mobile Frontend (Flutter)

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![FastAPI](https://img.shields.io/badge/FastAPI%20Backend-009688?style=for-the-badge&logo=fastapi&logoColor=white)

The cross-platform mobile frontend for **Let's Talk English**, a real-time bilingual (English–Telugu) AI voice tutor. Built with Flutter, featuring a glassmorphic dark UI, a continuous speech-to-text conversation loop, and a custom audio-reactive voice orb.

> 🔗 **Companion Backend Repository:** The FastAPI + Google Gemini + Edge-TTS backend powering this app is located at [**language-tutor-backend**](https://github.com/KAMALAKAR12345/language-tutor-backend).

## 📱 UI Preview

<p align="center">
  <img src="https://raw.githubusercontent.com/KAMALAKAR12345/language-tutor-backend/main/assets/home_screen.jpg" width="45%" alt="Home Screen UI" />
  <img src="https://raw.githubusercontent.com/KAMALAKAR12345/language-tutor-backend/main/assets/bilingual_chat.jpg" width="45%" alt="Bilingual Chat Drawer" />
</p>

---

## ✨ Key Mobile Features

* **🎙️ Continuous Hands-Free Voice Loop:** Automatically transitions from playing synthesized AI speech (`audioplayers`) back into active microphone listening (`speech_to_text`).
* **🔮 3mm Audio-Reactive Breathing Orb:** Custom `AnimationController` widget (`lib/breathing_orb.dart`) that shifts from a calm 2-second breathing aura to a tight, rapid 3mm edge-vibration synchronized with AI voice output.
* **💬 Glassmorphic Transcript Drawer:** Slide-up blurred overlay (`BackdropFilter`) displaying synchronized English replies and Telugu translations, with silent text-input fallback for error correction.
* **🎭 Roleplay & Voice Customization:** Dynamic selection of real-world practice scenarios (*Job Interview, Coffee Shop, Casual Conversation*) and Indian neural voices (`Neerja` and `Prabhat`).

---

## 📂 Project Structure (`lib/`)

```text
lib/
├── main.dart                  # App entry point & Home Screen (Voice/Scenario selectors)
├── conversation_screen.dart   # Live voice loop, API state management & slide-up chat drawer
├── breathing_orb.dart         # Custom 3mm audio-reactive AnimationController visualizer
├── control_panel.dart         # Glassmorphic dropdown controls & Telugu CTA button
└── space_background.dart      # Deep-space radial gradient theme
```

---

## 🚀 Running Locally

```bash
git clone [https://github.com/KAMALAKAR12345/lets_talk_english_mobile.git](https://github.com/KAMALAKAR12345/lets_talk_english_mobile.git)
cd lets_talk_english_mobile
flutter pub get
flutter run
```

---

## 👨‍💻 Author

**T. Kamalakar**  
*Python Backend & Flutter Developer | FastAPI & AI Integrations*
