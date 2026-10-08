import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show ProviderScope;
import 'package:hatvest/core/routing/app_router.dart';
import 'package:hatvest/proveider/locale_provider.dart';
import 'package:hatvest/proveider/theme_provider.dart';
import 'package:hatvest/services/auth_service.dart';
import 'package:hatvest/viewmodel/aboutview-model.dart' show AboutViewModel;
import 'package:hatvest/viewmodel/adult-pt-viewmodel.dart';
import 'package:hatvest/viewmodel/app-viewmodel.dart';
import 'package:hatvest/viewmodel/auth_viewmodel.dart';
import 'package:hatvest/viewmodel/branches_viewmodel.dart';
import 'package:hatvest/viewmodel/calendar_viewmodel.dart';
import 'package:hatvest/viewmodel/cart-viewmodel.dart';
import 'package:hatvest/viewmodel/exam-viewmodel.dart' show ExamQuizViewModel;
import 'package:hatvest/viewmodel/exam_list_viewmodel.dart';
import 'package:hatvest/viewmodel/home-viewmodel.dart' show HomeViewModel;
import 'package:hatvest/viewmodel/serives.dart';
import 'package:hatvest/viewmodel/survey-viewmodel.dart' show SurveyViewModel;
import 'package:hatvest/viewmodel/user.dart';
import 'package:provider/provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   final authService = AuthService();
//   final prefs = await SharedPreferences.getInstance();
//   final flutterSecureStorage = const FlutterSecureStorage();

//   // اقرأ هل المستخدم عامل تسجيل خروج؟
//   final isLogout = await flutterSecureStorage.read(key: "is_logout");

//   // فقط لو المستخدم مش عامل Logout نحاول نعمل refreshToken
//   if (isLogout != "true") {
//     await authService.refreshToken();
//   }

//   runApp(const MyApp());
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await initializeDateFormatting('ar');
  await initializeDateFormatting('en');

  final authService = AuthService();
  final flutterSecureStorage = const FlutterSecureStorage();

  final isLogout = await flutterSecureStorage.read(key: "is_logout");

  if (isLogout != "true") {
    await authService.refreshToken();
  }

  runApp(
    ProviderScope(
      child: EasyLocalization(
        supportedLocales: const [Locale('ar'), Locale('en')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        startLocale: const Locale('ar'),
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => LocaleProvider(context),
        ),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => BranchesViewModel()),
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
        ChangeNotifierProvider(create: (_) => CourseViewModel()..fetchCoursesOflien()),
        ChangeNotifierProvider(create: (_) => ExamViewModel()),
        ChangeNotifierProvider(create: (_) => CartViewModel()),
        ChangeNotifierProvider(create: (_) => ExamQuizViewModel()),
        ChangeNotifierProvider(create: (_) => ExamListViewModel()),
        ChangeNotifierProvider(create: (_) => SurveyViewModel()),
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => AboutViewModel()),
        ChangeNotifierProvider(create: (_) => CalendarViewModel()),
      ],
      child: Consumer2<LocaleProvider, ThemeProvider>(
        builder: (context, localeProvider, themeProvider, _) {
          Locale locale;
          List<Locale> supportedLocales;
          Iterable<LocalizationsDelegate<dynamic>> localizationsDelegates;

          try {
            locale = context.locale;
            supportedLocales = context.supportedLocales;
            localizationsDelegates = context.localizationDelegates;
          } catch (_) {
            locale = const Locale('ar');
            supportedLocales = const [Locale('ar'), Locale('en')];
            localizationsDelegates = GlobalMaterialLocalizations.delegates;
          }

          return MaterialApp(
            title: "Harvest",
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode,
            theme: ThemeData(
              brightness: Brightness.light,
              scaffoldBackgroundColor: const Color(0xFFF8FAFC),
              cardColor: Colors.white,
              canvasColor: Colors.white,
              fontFamily: 'Cairo',
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF162740),
                brightness: Brightness.light,
                surface: Colors.white,
                background: const Color(0xFFF8FAFC),
              ),
              textTheme: const TextTheme(
                displayLarge:  TextStyle(fontFamily: 'Cairo', fontSize: 26, fontWeight: FontWeight.w600, color: Color(0xFF0F172A), height: 1.4),
                displayMedium: TextStyle(fontFamily: 'Cairo', fontSize: 22, fontWeight: FontWeight.w600, color: Color(0xFF0F172A), height: 1.4),
                displaySmall:  TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF0F172A), height: 1.4),
                headlineLarge: TextStyle(fontFamily: 'Cairo', fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF0F172A), height: 1.4),
                headlineMedium:TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.w500, color: Color(0xFF0F172A), height: 1.4),
                headlineSmall: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF0F172A), height: 1.4),
                titleLarge:    TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF0F172A), height: 1.4),
                titleMedium:   TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF0F172A), height: 1.5),
                titleSmall:    TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF334155), height: 1.5),
                bodyLarge:     TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.w400, color: Color(0xFF1E293B), height: 1.6),
                bodyMedium:    TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF1E293B), height: 1.6),
                bodySmall:     TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.w400, color: Color(0xFF64748B), height: 1.6),
                labelLarge:    TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF162740), height: 1.4),
                labelMedium:   TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.w400, color: Color(0xFF475569), height: 1.4),
                labelSmall:    TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.w400, color: Color(0xFF94A3B8), height: 1.4),
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.transparent,
                elevation: 0,
                foregroundColor: Color(0xFF162740),
                titleTextStyle: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF162740),
                ),
              ),
              cardTheme: CardThemeData(
                color: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              inputDecorationTheme: const InputDecorationTheme(
                fillColor: Color(0xFFF1F5F9),
                filled: true,
                hintStyle: TextStyle(fontFamily: 'Cairo', fontSize: 14, color: Color(0xFF94A3B8)),
                labelStyle: TextStyle(fontFamily: 'Cairo', fontSize: 14, color: Color(0xFF64748B)),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  textStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
              outlinedButtonTheme: OutlinedButtonThemeData(
                style: OutlinedButton.styleFrom(
                  textStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  textStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              scaffoldBackgroundColor: const Color(0xFF0F172A),
              cardColor: const Color(0xFF1E293B),
              canvasColor: const Color(0xFF1E293B),
              fontFamily: 'Cairo',
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF162740),
                brightness: Brightness.dark,
                surface: const Color(0xFF1E293B),
                background: const Color(0xFF0F172A),
              ),
              textTheme: const TextTheme(
                displayLarge:  TextStyle(fontFamily: 'Cairo', fontSize: 26, fontWeight: FontWeight.w600, color: Colors.white, height: 1.4),
                displayMedium: TextStyle(fontFamily: 'Cairo', fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white, height: 1.4),
                displaySmall:  TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white, height: 1.4),
                headlineLarge: TextStyle(fontFamily: 'Cairo', fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white, height: 1.4),
                headlineMedium:TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white, height: 1.4),
                headlineSmall: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white, height: 1.4),
                titleLarge:    TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white, height: 1.4),
                titleMedium:   TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white, height: 1.5),
                titleSmall:    TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFFCBD5E1), height: 1.5),
                bodyLarge:     TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.w400, color: Color(0xFFE2E8F0), height: 1.6),
                bodyMedium:    TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFFE2E8F0), height: 1.6),
                bodySmall:     TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.w400, color: Color(0xFF94A3B8), height: 1.6),
                labelLarge:    TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white, height: 1.4),
                labelMedium:   TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.w400, color: Color(0xFF94A3B8), height: 1.4),
                labelSmall:    TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.w400, color: Color(0xFF64748B), height: 1.4),
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.transparent,
                elevation: 0,
                foregroundColor: Colors.white,
                titleTextStyle: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              cardTheme: CardThemeData(
                color: const Color(0xFF1E293B),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              inputDecorationTheme: const InputDecorationTheme(
                fillColor: Color(0xFF263548),
                filled: true,
                hintStyle: TextStyle(fontFamily: 'Cairo', fontSize: 14, color: Color(0xFF64748B)),
                labelStyle: TextStyle(fontFamily: 'Cairo', fontSize: 14, color: Color(0xFF94A3B8)),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  textStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
              outlinedButtonTheme: OutlinedButtonThemeData(
                style: OutlinedButton.styleFrom(
                  textStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  textStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
              dividerColor: Colors.white12,
            ),

            locale: locale,
            supportedLocales: supportedLocales,
            localizationsDelegates: localizationsDelegates,

            navigatorKey: navigatorKey,
            scaffoldMessengerKey: scaffoldMessengerKey,
            routes: Routes.routes,

            builder: (context, child) {
              return Directionality(
                textDirection: localeProvider.textDirection,
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => LocaleProvider()),
//         ChangeNotifierProvider(create: (_) => AuthViewModel()),
//         ChangeNotifierProvider(create: (_) => BranchesViewModel()),
//         ChangeNotifierProvider(create: (_) => LoginViewModel()),
//         ChangeNotifierProvider(create: (_) => ProfileViewModel()),
//         ChangeNotifierProvider(create: (_) => CourseViewModel()),
//         ChangeNotifierProvider(create: (_) => ExamViewModel()),
//         ChangeNotifierProvider(create: (_) => CartViewModel()),
//         ChangeNotifierProvider(create: (_) => ExamQuizViewModel()),
//         ChangeNotifierProvider(create: (_) => SurveyViewModel()),
//         ChangeNotifierProvider(create: (_) => HomeViewModel()),
//         ChangeNotifierProvider(create: (_) => AboutViewModel()),
//       ],
//       child: Consumer<LocaleProvider>(
//         builder: (context, localeProvider, _) {
//           return Consumer<LocaleProvider>(
//             builder: (context, localeProvider, _) {
//               return MaterialApp(
//                 title: "Harvest",
//                 debugShowCheckedModeBanner: false,
//                 locale: localeProvider.locale, // ✅ اللغة
//                 supportedLocales: const [
//                   Locale('ar'),
//                   Locale('en'),
//                 ],
//                 localizationsDelegates: const [
//                   GlobalMaterialLocalizations.delegate,
//                   GlobalWidgetsLocalizations.delegate,
//                   GlobalCupertinoLocalizations.delegate,
//                 ],
//                 scaffoldMessengerKey: scaffoldMessengerKey,
//                 navigatorKey: navigatorKey,
//                 routes: Routes.routes,
//                 builder: (context, child) {
//                   return Directionality(
//                     textDirection: localeProvider.textDirection, // ✅ الاتجاه
//                     child: child!,
//                   );
//                 },
//               );
//             },
//           );

//           // return MaterialApp(
//           //   title: "Harvest",
//           //   debugShowCheckedModeBanner: false,
//           //   initialRoute: '/',
//           //   routes: Routes.routes,
//           //   navigatorKey: navigatorKey,
//           //   scaffoldMessengerKey: scaffoldMessengerKey,
//           //   builder: (context, child) {
//           //     return Directionality(
//           //       textDirection: localeProvider.textDirection,
//           //       child: child!,
//           //     );
//           //   },
//           // );
//         },
//       ),
//     );
//   }
// }
