# SmartNews 📱

**AI-powered news app for Indian students**  
Stay updated with smart summaries, quizzes, and an AI assistant — all in your preferred language.

---

## 🚀 Features

### 📰 News Feed
- Categorized news (General, Sports, Politics, Tech, Business, Science, Health)
- AI-generated 3-line summaries
- India-focused curated news
- Pull-to-refresh with smooth loading states

### 🧠 Quiz System
- Auto-generated MCQs from latest news
- Exam-style questions (JEE/NEET/UPSC inspired)
- Instant feedback with explanations
- Score tracking

### 💬 AI Chatbot
- Context-aware conversations
- Answers based on current news
- Designed for student learning & current affairs

### 🌐 Multilingual Support
- English, Hindi, Tamil, Telugu, Kannada, Malayalam
- Persistent language preference
- Full UI localization

### 🔖 Bookmarks
- Save and access important articles
- Local persistent storage

### 🔐 Authentication
- Firebase Email/Password login
- Secure session handling

---

## 🛠️ Tech Stack

**Frontend**
- Flutter

**Backend & Services**
- Firebase (Auth + Firestore)

**APIs**
- Groq API (AI features)
- NewsAPI / GNews (news data)
- OpenRouter (fallback AI)

**State Management**
- Provider

**Storage**
- SharedPreferences

---

## 📁 Project Structure

```
lib/
├── config/
├── localization/
├── models/
├── providers/
├── screens/
├── services/
├── theme/
├── widgets/
├── main.dart
```

---

## ⚙️ Setup

### 1. Clone Repository
```bash
git clone https://github.com/yourusername/smart-news.git
cd smart-news/smart_news
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Environment Setup
Create `.env` file:

```env
NEWSAPI_API_KEY=your_key
GNEWS_API_KEY=your_key
GROQ_API_KEY=your_key
OPENROUTER_API_KEY=your_key
```

### 4. Firebase Setup
- Create project in Firebase Console
- Enable Authentication (Email/Password)
- Enable Firestore
- Add config files:
  - `android/app/google-services.json`
  - `ios/Runner/GoogleService-Info.plist`

---

## ▶️ Run the App

```bash
flutter run
```

---

## 🧩 Architecture

```
UI → Provider → Services → APIs
```

---

## 📌 Current Status

🚧 In Development (Active)

---

## 🚀 Future Improvements

- Offline reading
- Push notifications
- User profiles
- Advanced search
- Cloud sync for bookmarks

---

## 👩‍💻 Author

**Dhanya Lakshmi S S**
