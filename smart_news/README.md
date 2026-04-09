# SmartNews 📱

> **AI-Powered News Application for Indian Students**  
> Stay informed with intelligent summaries, AI-generated quizzes, and a smart chatbot assistant—all in your preferred Indian language.

[![Flutter](https://img.shields.io/badge/Flutter-3.10+-blue.svg)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Ready-orange.svg)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Version](https://img.shields.io/badge/Version-1.0.0-blue.svg)](pubspec.yaml)

---

## 🎯 Overview

**SmartNews** is an AI-powered mobile application designed to transform how Indian students (ages 15-22) consume news and stay updated with current affairs. Leveraging advanced AI APIs and real-time news sources, SmartNews provides intelligent news summaries, auto-generated quizzes, personalized chatbot assistance, and curated India-specific news—all in multiple Indian languages.

The app combines real-time news feeds with artificial intelligence to make news consumption interactive, educational, and engaging for students preparing for competitive exams.

---

## ✨ Key Features

### 📰 **Smart News Feed**
- **7 News Categories:** General, Sports, Politics, Technology, Business, Science, Health
- **AI-Powered Summaries:** Get 3-sentence context-aware summaries for any article via one-click "What's this about?" button
- **Pull-to-Refresh:** Updated news automatically synced from multiple news sources
- **Shimmer Loading:** Beautiful skeleton loading animation for smooth UX
- **Category Filtering:** Swipe through horizontal category tabs with color-coded badges
- **India Curated Tab:** AI-filtered articles specifically relevant to India using Groq AI
- **Article Cards:** Rich cards with headline, source, timestamp, thumbnail, and summary

### 🎯 **Intelligent Quiz Generator**
- **Auto-Generated Questions:** System automatically generates 5 multiple-choice questions from the 10 most recent news articles
- **Exam-Style Format:** Questions formatted like competitive exams (JEE, NEET, UPSC style)
- **4 Options Per Question:** Each question has 4 options with only one correct answer
- **Instant Feedback:** Visual feedback (green/red highlighting) for correct/incorrect answers
- **Score Card:** Display final score with percentage and motivational messages
- **Detailed Explanations:** Each question includes reasoning for the correct answer
- **Progress Tracking:** See "Question X of 5" progress indicator
- **Auto-Advance:** Questions automatically advance after 1.5 seconds of answer selection

### 💬 **SmartBot - AI Chatbot Assistant**
- **Multi-Turn Conversations:** Maintain full conversation history with context awareness
- **WhatsApp-Style UI:** Intuitive blue/gray bubble interface familiar to users
- **Typing Indicators:** Real-time typing animation to show when bot is responding
- **Welcome Screen:** Suggested starter questions to help new users
- **Article Context:** Chatbot can reference the article being read for contextual answers
- **Domain-Specific Responses:** Specialized for Indian students with focus on:
  - News and current affairs explanation
  - Competitive exam preparation tips
  - General knowledge assistance
  - Current events analysis
- **Smart Limits:** 150-word response limit (expandable if user asks for more)
- **Clear History:** Button to clear conversation and start fresh

### 🇮🇳 **India-Centric Experience**
- **AI-Powered News Filter:** Automatically identifies India-relevant articles from global news feeds
- **India Badge:** Shows 🇮🇳 badge on all India-curated articles
- **Smart Filtering:** Uses Groq AI to detect:
  - Articles mentioning India or Indians
  - News affecting Indian economy/politics/sports/students
  - Indian public figures and their actions
- **Regional Relevance:** Filters over 50+ global news to find most important for Indian audience

### 🌐 **Multilingual Support**
- **6 Indian Languages:** English, Hindi, Tamil, Telugu, Kannada, Malayalam
- **Persistent Preference:** Language choice saved automatically
- **System Locale Detection:** App detects device language and sets appropriate UI language
- **Complete Translation:** All UI elements translated, not just content
- **Language Selector:** Floating action button for quick language switching
- **Native Typography:** Google Fonts for beautiful rendering of Indian languages

### 🔐 **Secure Authentication**
- **Firebase Authentication:** Industry-standard security
- **Email/Password Login:** Secure account creation and login
- **Session Management:** Persistent sessions across app restarts
- **Logout Functionality:** Clear sessions securely
- **User Data Protection:** All user data encrypted in transit

### 📚 **Bookmark System**
- **Save Articles:** One-tap bookmarking of favorite articles
- **Local Storage:** Bookmarks stored locally on device
- **Quick Access:** Dedicated bookmarks section for easy retrieval
- **Persistent Storage:** Bookmarks survive app restarts

### 🎨 **Beautiful UI/UX**
- **Light & Dark Themes:** Automatic theme switching based on system settings
- **Responsive Design:** Optimized for all phone sizes and orientations
- **Smooth Animations:** Loading spinners, transitions, and interactive elements
- **Google Fonts Typography:** Modern, readable typefaces
- **Cached Images:** Network images cached for faster loading and offline access

---

## 📊 Screenshots & Features

### Home Screen - News Feed
- Clean, scrollable feed of news articles
- Category tabs at top for quick filtering
- Each article card shows: headline, source, "time posted ago", thumbnail, and "What's this about?" button
- Pull-to-refresh gesture support
- Loading skeleton while fetching news

### Quiz Screen
- Question displayed prominently
- 4 selectable options with radio buttons
- Question progress bar: "Question 2 of 5"
- Answer feedback (green checkmark for correct, red X for incorrect)
- Auto-advance after selection
- Final scorecard with total score and percentage
- Detailed results showing all Q&A with explanations

### Chatbot Screen
- Message input box at bottom with send button
- Chat bubbles: blue for user, gray for bot
- Typing indicator animation when bot is thinking
- Welcome screen with suggested prompts on first load
- Scrollable message history
- Clear chat button for fresh start

### India Tab
- Filtered news articles relevant to India only
- 🇮🇳 badge showing India-curated content
- "Curated for India by AI" label
- Same article card interface as main feed

### Language Selector
- FAB button showing current language code (EN, HI, TA, TE, KN, ML)
- Dialog showing all available languages
- Checkmark next to currently selected language
- Instant UI update when language changes

---

## 🛠️ Tech Stack

### **Frontend Framework**
- **Flutter** (v3.10.8+) - Cross-platform mobile development (Android, iOS, Web, Desktop)

### **State Management**
- **Provider** (v6.1.5) - Reactive state management with ChangeNotifier pattern

### **Backend & Cloud**
- **Firebase Core** (v4.6.0) - Firebase initialization and services
- **Firebase Authentication** (v6.3.0) - Secure user authentication
- **Cloud Firestore** (v6.2.0) - Real-time NoSQL database

### **AI & API Integration**
- **Groq API** - AI-powered summaries, quiz generation, chatbot, and article filtering
- **NewsAPI** - Real-time news from 30,000+ sources
- **GNews API** - Backup news source with global coverage
- **OpenRouter API** - Alternative AI provider for redundancy

### **UI & UX Libraries**
- **Google Fonts** (v7.0.0) - Beautiful typography including Indian font support
- **Cached Network Image** (v3.3.1) - Image caching and lazy loading
- **Shimmer** (v3.0.0) - Skeleton loading animations
- **Timeago** (v3.6.1) - Human-readable relative timestamps ("2 hours ago")
- **Cupertino Icons** (v1.0.8) - iOS-style icons

### **Data & Storage**
- **SharedPreferences** (v2.3.2) - Local persistent storage for preferences and settings
- **Intl** (v0.20.2) - Internationalization (i18n) and date/number formatting

### **Utilities**
- **flutter_dotenv** (v5.1.0) - Environment variable management
- **http** (v1.6.0) - HTTP client for API requests
- **url_launcher** (v6.3.2) - Open URLs and email clients
- **Flutter Localizations** - Official Flutter i18n support

### **Development**
- **Flutter Lints** (v6.0.0) - Dart code analysis and linting
- **Dart** (v3.10.8+) - Programming language

---

## 📁 Project Structure

```
smart_news/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── firebase_options.dart        # Firebase configuration
│   ├── config/                      # Configuration files
│   ├── localization/                # Internationalization (i18n)
│   │   ├── app_localizations.dart   # Main localization coordinator
│   │   └── languages/               # Language files
│   │       ├── en.dart              # English translations
│   │       ├── hi.dart              # Hindi translations
│   │       ├── ta.dart              # Tamil translations
│   │       ├── te.dart              # Telugu translations
│   │       ├── kn.dart              # Kannada translations
│   │       └── ml.dart              # Malayalam translations
│   ├── models/                      # Data models
│   │   ├── article.dart
│   │   ├── quiz.dart
│   │   └── ...
│   ├── providers/                   # State management
│   │   ├── news_provider.dart       # News state & logic
│   │   ├── quiz_provider.dart       # Quiz state & logic
│   │   ├── chatbot_provider.dart    # Chatbot state & logic
│   │   └── language_provider.dart   # Language state & logic
│   ├── screens/                     # UI screens
│   │   ├── splash_screen.dart
│   │   ├── login_screen.dart
│   │   ├── main_navigation_screen.dart
│   │   ├── news_feed_screen.dart
│   │   ├── quiz_screen.dart
│   │   ├── chatbot_screen.dart
│   │   └── ...
│   ├── services/                    # API & business logic
│   │   ├── auth_service.dart        # Firebase authentication
│   │   ├── news_service.dart        # News API integration
│   │   ├── groq_service.dart        # Groq AI API integration
│   │   ├── firestore_service.dart   # Firestore database
│   │   ├── bookmarks_service.dart   # Bookmark management
│   │   ├── quiz_generation_service.dart
│   │   ├── summarization_service.dart
│   │   └── ...
│   ├── theme/                       # App theming
│   │   └── app_theme.dart           # Light/Dark themes
│   └── widgets/                     # Reusable components
│       ├── enhanced_news_card.dart
│       ├── quiz_progress_bar.dart
│       ├── chat_bubble.dart
│       ├── typing_indicator.dart
│       ├── language_selector.dart
│       └── ...
├── .env                             # Environment variables (API keys)
├── .env.example                     # Example env file
├── android/                         # Android-specific files
├── ios/                             # iOS-specific files
├── test/                            # Unit/widget tests
├── web/                             # Web platform files
├── windows/                         # Windows platform files
├── linux/                           # Linux platform files
├── macos/                           # macOS platform files
├── pubspec.yaml                     # Dependencies & project config
├── analysis_options.yaml            # Lint rules
└── firebase.json                    # Firebase configuration
```

---

## 🚀 Getting Started

### Prerequisites

Before you begin, ensure you have:

- **Flutter SDK** (v3.10.8 or higher) - [Install Flutter](https://flutter.dev/docs/get-started/install)
- **Dart SDK** (included with Flutter)
- **Android Studio** (for Android development) or **Xcode** (for iOS development)
- **Git** for version control
- **API Keys** from:
  - Groq API: https://console.groq.com
  - NewsAPI: https://newsapi.org/register
  - GNews: https://gnews.io/register
  - OpenRouter: https://openrouter.ai/keys

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/smart-news.git
   cd smart-news/smart_news
   ```

2. **Install Flutter dependencies**
   ```bash
   flutter pub get
   ```

3. **Create `.env` file** (copy from `.env.example`)
   ```bash
   cp .env.example .env
   ```

4. **Add your API keys to `.env`** (see Configuration section below)

5. **Get Flutter packages again** (to load env vars)
   ```bash
   flutter pub get
   ```

6. **For Firebase setup:**
   - Go to [Firebase Console](https://console.firebase.google.com)
   - Create a new project or use existing one
   - Enable Authentication (Email/Password)
   - Enable Cloud Firestore
   - Download google-services.json (Android) and GoogleService-Info.plist (iOS)
   - Place them in appropriate directories (android/app/, ios/Runner/)

---

## ⚙️ Configuration

### API Keys Setup

Create a `.env` file in the `smart_news/` directory with the following content:

```env
# NewsAPI - News feed data from 30,000+ global sources
NEWSAPI_API_KEY='your_newsapi_key_here'

# GNews API - Backup news source for global coverage
GNEWS_API_KEY='your_gnews_api_key_here'

# Groq API - AI for summaries, quizzes, chatbot, filtering
GROQ_API_KEY='your_groq_api_key_here'

# OpenRouter API - Alternative AI provider for redundancy
OPENROUTER_API_KEY='your_openrouter_api_key_here'
```

### Getting Each API Key

**1. Groq API** (Most Important - Used for AI features)
- Visit: https://console.groq.com
- Sign up with email
- Create an API key in the "API Keys" section
- Copy the key and paste in .env

**2. NewsAPI** (News source)
- Visit: https://newsapi.org
- Click "Register" and create account
- Get your API key from dashboard
- Add to NEWSAPI_API_KEY in .env

**3. GNews** (Backup news source)
- Visit: https://gnews.io
- Sign up for free account
- Get API key from settings
- Add to GNEWS_API_KEY in .env

**4. OpenRouter** (Alternative AI)
- Visit: https://openrouter.ai/keys
- Create account
- Generate API key
- Add to OPENROUTER_API_KEY in .env

### Firebase Configuration

1. Create Firebase project at https://firebase.google.com
2. Enable these services:
   - Authentication → Email/Password
   - Cloud Firestore
   - Storage (optional)
3. Download configuration files and place in:
   - **Android:** `android/app/google-services.json`
   - **iOS:** `ios/Runner/GoogleService-Info.plist`

---

## 🏃 Running the Application

### Development Mode

```bash
cd smart_news
flutter run
```

### Run on Specific Device

```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d <device_id>
```

### Run with Different Flavors

```bash
# Debug (default)
flutter run

# Release
flutter run --release

# Profile (for performance testing)
flutter run --profile
```

### Build APK (Android)

```bash
# Debug APK
flutter build apk

# Release APK
flutter build apk --release

# Split APK by ABI (smaller file sizes)
flutter build apk --split-per-abi --release
```

### Build for iOS

```bash
flutter build ios --release
```

### Build for Web

```bash
flutter build web --release
```

---

## 🏗️ Architecture & Design Patterns

### State Management Architecture

**Provider Pattern** with ChangeNotifier:
```
UI Layer (Screens/Widgets)
    ↓
Consumer<Provider> (Reactive rebuilds)
    ↓
Provider/ChangeNotifier (Business Logic)
    ↓
Services (API calls & data)
    ↓
External APIs (Groq, NewsAPI, Firebase)
```

**Key Providers:**
- `NewsProvider` - Manages news feed, categories, summaries
- `QuizProvider` - Manages quiz state and scoring
- `ChatbotProvider` - Manages conversation history
- `LanguageProvider` - Manages language preference
- `AuthProvider` (via Service) - Manages user authentication

### Service Layer Architecture

1. **NewsService** - Fetches news from NewsAPI
2. **GroqService** - AI operations (summaries, quizzes, chat, filtering)
3. **AuthService** - Firebase authentication
4. **FirestoreService** - Database operations
5. **BookmarksService** - Local bookmark storage

### API Integration Strategy

```
App
├── GroqService (Primary AI)
│   ├── Summaries (3-sentence format)
│   ├── Quiz Generation (5 questions)
│   ├── Chatbot Response (contextual)
│   └── India News Filter (relevance detection)
│
├── NewsService (News Source)
│   └── Fetch articles by category
│
├── AuthService (Firebase)
│   ├── User signup
│   ├── User login
│   └── Session management
│
└── FirestoreService
    └── User data persistence
```

---

## 📋 Feature Details

### How News Summary Works

1. User taps "What's this about?" on any news article
2. Article content is sent to Groq AI API
3. AI generates 3-sentence summary:
   - **What happened:** Main event
   - **Why it matters:** Impact/significance
   - **Background:** Context
4. Summary displayed in modal/dialog below article card
5. Result cached for faster future access

### How Quiz Generation Works

1. App fetches 10 most recent news articles
2. Articles sent to Groq AI in batches
3. AI generates 5 multiple-choice questions
4. Questions returned in JSON format:
   ```json
   {
     "questions": [
       {
         "question": "What happened in...",
         "options": ["A. ...", "B. ...", "C. ...", "D. ..."],
         "correct": "A",
         "explanation": "This is the reasoning..."
       }
     ]
   }
   ```
5. Questions displayed one at a time
6. User score calculated based on correct answers

### How Chatbot Works

1. User enters a message
2. Message sent to Groq API with conversation history
3. System prompt provides context (Indian student focus)
4. Bot generates response based on:
   - User message
   - Conversation history (last 6 messages)
   - Article context (if reading specific article)
   - Language preference
5. Response displayed with typing indicator
6. Full conversation history maintained locally

### How India Filter Works

1. App fetches ~50 global news articles
2. Sends articles to Groq AI with filter criteria
3. Groq identifies India-relevant articles:
   - Mentions India/Indians
   - Affects Indian economy/politics/sports
   - Involves Indian public figures
4. Returns list of relevant article IDs
5. UI adds 🇮🇳 badge to filtered articles
6. Separate India tab shows only filtered news

---

## 📱 Platform Support

- **Android** 5.0+ (Android SDK 21+)
- **iOS** 11.0+
- **Web** (Chrome, Firefox, Safari)
- **Windows** 10+
- **macOS** 10.13+
- **Linux** (Ubuntu 18.04+)

---

## 🔒 Security & Privacy

- **API Keys:** Stored in `.env` file (never in source code)
- **User Data:** Encrypted in transit with HTTPS
- **Local Storage:** SharedPreferences uses platform-secure storage
- **Firebase:** Industry-standard Google Cloud security
- **No Tracking:** App doesn't track user behavior
- **Open Source:** Code publicly available for audit

---

## 🐛 Known Limitations

1. **API Rate Limits:**
   - Groq: ~30 requests/minute (free tier)
   - NewsAPI: ~100 requests/day (free tier)
   - GNews: ~100 requests/day (free tier)

2. **Article Filtering Accuracy:**
   - India filter depends on Groq model accuracy
   - Occasional false positives/negatives

3. **Network Dependency:**
   - All AI features require internet connectivity
   - News feed needs active internet

4. **Quiz Generation:**
   - Depends on sufficient recent articles
   - May not generate quiz if <5 articles available

5. **Offline Support:**
   - Currently no offline reading
   - Cached images only available if previously loaded

---

## 🚀 Future Enhancements

- [ ] Offline article reading with download functionality
- [ ] Push notifications for breaking news
- [ ] User profiles with reading history
- [ ] Social sharing to WhatsApp, Twitter, Facebook
- [ ] Advanced search functionality
- [ ] News source filtering/preferences
- [ ] Reading time estimates
- [ ] PDF export of articles
- [ ] Dark mode toggle (in addition to system theme)
- [ ] Cloud sync for bookmarks across devices
- [ ] Podcast/audio news version
- [ ] Regional language news sources
- [ ] User-generated content/comments
- [ ] Article recommendation algorithm
- [ ] Multi-device synchronization

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Development Guidelines

- Follow Dart style guide: https://dart.dev/guides/language/effective-dart/style
- Use meaningful variable and function names
- Add comments for complex logic
- Test features before submitting PR
- Update README if adding new features

---

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

## 👥 Author

**Dhanya Lakshmi S S**

---

## 📞 Support & Contact

For issues, questions, or suggestions:

- **GitHub Issues:** Open an issue on the repository
- **Email:** [your-email@example.com]
- **Twitter:** [@yourhandle]

---

## 🙏 Acknowledgments

- **Flutter Team** for the amazing framework
- **Groq AI** for powerful AI models
- **Firebase** for backend infrastructure
- **NewsAPI** for news data
- **Google Fonts** for typography
- **Provider Package** for state management

---

## 📊 Project Statistics

- **Lines of Code:** 10,000+
- **Number of Screens:** 8+
- **API Integrations:** 4
- **Supported Languages:** 6
- **Dependencies:** 20+
- **Development Time:** Actively maintained

---

## 🔄 Version History

### v1.0.0 (Current)
- ✅ News Feed with 7 categories
- ✅ AI-powered summaries
- ✅ Quiz generation from articles
- ✅ SmartBot chatbot assistant
- ✅ India-centric news filtering
- ✅ Multilingual support (6 languages)
- ✅ Firebase authentication
- ✅ Bookmark system
- ✅ Dark/Light themes
- ✅ Offline caching

---

**Last Updated:** April 9, 2026  
**Build Status:** ✅ Stable  
**Code Quality:** ✅ No Lint Issues
