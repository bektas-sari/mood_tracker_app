# Mood Tracker App 🌟(FLUTTER)

A modern, minimal Flutter app to track your daily mood using emojis, write notes, and visualize your emotional trends. This app includes daily notification reminders and an alert system for prolonged negative moods.

---

## 🚀 Features

- Emoji-based mood tracking (happy, neutral, sad, angry, sleepy)
- Optional note input for each mood entry
- Date selection using DatePicker
- Mood history list
- Pie chart visualization of mood statistics
- Daily reminder notifications (8:00 PM)
- Warning alert if sad mood is logged 3 times in a row
- Clean and responsive UI with gradient background

---

## ⚖️ Technologies Used

- Flutter (Material 3)
- Dart
- flutter_local_notifications
- pie_chart
- timezone

---

## ⚡ Installation

1. **Clone the repo:**
   ```bash
   git clone https://github.com/bektas-sari/mood_tracker_app.git
   cd mood_tracker_app
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the app:**
   ```bash
   flutter run
   ```

> Make sure you have Flutter installed and your Android/iOS emulator set up.

---

## 📅 Daily Notification Setup (Android)

Ensure the following is done:
- Add `POST_NOTIFICATIONS` permission in `AndroidManifest.xml`
- Request permission in `MainActivity.kt` for Android 13+

---

## 🙌 Contributing

Feel free to fork the project, open issues, or create pull requests.

---

## ✉️ Contact

If you have questions or feedback:
- GitHub Issues
- Email: bektas.sari@gmail.com

---

## 🌐 License

This project is open source and available under the [MIT License](LICENSE).

---

**Made with Flutter ❤️**

