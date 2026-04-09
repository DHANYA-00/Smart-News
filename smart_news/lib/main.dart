import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/main_navigation_screen.dart';
import 'services/auth_service.dart';
import 'services/news_service.dart';
import 'services/groq_service.dart';
import 'providers/news_provider.dart';
import 'providers/quiz_provider.dart';
import 'providers/chatbot_provider.dart';
import 'providers/language_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/settings_provider.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file
  await dotenv.load();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final prefs = await SharedPreferences.getInstance();
  runApp(SmartNewsApp(prefs: prefs));
}

class SmartNewsApp extends StatefulWidget {
  const SmartNewsApp({super.key, required this.prefs});

  final SharedPreferences prefs;

  @override
  State<SmartNewsApp> createState() => _SmartNewsAppState();
}

class _SmartNewsAppState extends State<SmartNewsApp> {
  // Initialize services once so they're shared across providers.
  final NewsService _newsService = NewsService();
  final GroqService _groqService = GroqService();

  // Pre-create providers so we can call init() before first build.
  final LanguageProvider _languageProvider = LanguageProvider();
  final ThemeProvider _themeProvider = ThemeProvider();

  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = Future.wait([
      _languageProvider.init(),
      _themeProvider.init(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _languageProvider),
        ChangeNotifierProvider.value(value: _themeProvider),
        ChangeNotifierProvider(
          create: (_) => NewsProvider(_newsService, groqService: _groqService),
        ),
        ChangeNotifierProvider(
          create: (_) => QuizProvider(_groqService),
        ),
        ChangeNotifierProxyProvider<LanguageProvider, ChatbotProvider>(
          create: (_) => ChatbotProvider(_groqService),
          update: (_, languageProvider, chatbotProvider) {
            chatbotProvider!.updateLanguage(languageProvider.getLanguageName());
            return chatbotProvider;
          },
        ),
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(widget.prefs),
        ),
      ],
      child: FutureBuilder<void>(
        future: _initFuture,
        builder: (context, snapshot) {
          // Use Consumer to rebuild MaterialApp whenever theme or language changes
          return Consumer2<ThemeProvider, LanguageProvider>(
            builder: (context, themeProvider, languageProvider, _) {
              return MaterialApp(
                title: 'SmartNews',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.light,
                darkTheme: AppTheme.dark,
                // Driven by ThemeProvider (persisted preference)
                themeMode: themeProvider.themeMode,
                locale: languageProvider.currentLocale,
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: const [
                  Locale('en'),
                  Locale('hi'),
                  Locale('ta'),
                  Locale('te'),
                  Locale('kn'),
                  Locale('ml'),
                ],
                home: snapshot.connectionState == ConnectionState.done
                    ? const _AuthGate()
                    : const SplashScreen(),
              );
            },
          );
        },
      ),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthUser?>(
      stream: AuthService.instance.authStateChanges,
      builder: (context, snapshot) {
        // Still checking auth → keep splash
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }

        // No user → login
        if (!snapshot.hasData) {
          return const LoginScreen();
        }

        // Logged in → main navigation (Home, India, Quiz, Chat, Settings tabs)
        return const MainNavigationScreen();
      },
    );
  }
}