import 'package:flutter/material.dart';
import 'package:hatvest/view/page/notifications/notifications_page.dart';

import 'package:hatvest/features/auth/presentation/pages/login_page.dart';
import 'package:hatvest/features/auth/presentation/pages/new_password_page.dart';
import 'package:hatvest/features/auth/presentation/pages/otp_page.dart';
import 'package:hatvest/features/auth/presentation/pages/reset_password_email_page.dart';
import 'package:hatvest/features/auth/presentation/pages/reset_password_phone_page.dart';
import 'package:hatvest/features/auth/presentation/pages/signup_page.dart';
import 'package:hatvest/features/auth/presentation/pages/splash_page.dart';
import 'package:hatvest/features/auth/presentation/pages/welcome_selection_page.dart';
import 'package:hatvest/features/home/presentation/pages/bottom_nav_page.dart';
import 'package:hatvest/view/page/Inquiries-requests/Inquiries-requests.dart';
import 'package:hatvest/view/page/about-page/about-page.dart' show AboutPage;
import 'package:hatvest/view/page/adult-exam/adult-exam.dart';
import 'package:hatvest/view/page/all-certificate/all-certificate.dart'
    show CertificatesTabsPage;
import 'package:hatvest/view/page/branch/branch.dart';
import 'package:hatvest/view/page/cambridge-cretivcate/cambridge-certificate.dart';
import 'package:hatvest/view/page/change-password/change-password.dart';
import 'package:hatvest/view/page/complain_request/complain_request.dart';
import 'package:hatvest/view/page/connect-us/connect-us.dart';
import 'package:hatvest/view/page/digetal-book/digetal-book.dart';
import 'package:hatvest/view/page/edit-profiel/edit-profile.dart';
import 'package:hatvest/view/page/get_help/get_help.dart';
import 'package:hatvest/view/page/harvest-cretivcate/harvest-certificate.dart';
import 'package:hatvest/view/page/kids-pt-exam/kids-pt-exam.dart';
import 'package:hatvest/view/page/my-payment/my-payment.dart';
import 'package:hatvest/view/page/profile/profile.dart';
import 'package:hatvest/view/page/select-level/select-level.dart';
import 'package:hatvest/view/page/servies/servies-page.dart';
import 'package:hatvest/view/page/start-deplom/start-deplom.dart';
import 'package:hatvest/view/page/track-progress/test.dart';
import 'package:hatvest/view/page/track-progress/track-progress.dart';
import 'package:hatvest/view/page/exams/exams_page.dart';
import 'package:hatvest/view/page/offers/offers-page.dart';

class Routes {
  static final Map<String, WidgetBuilder> routes = {
    '/': (BuildContext context) => const SplashScreen(),
    '/welcome': (BuildContext context) => const WelcomeSelectionPage(),
    '/branch-selection': (BuildContext context) => const SingupPage(),
    '/login': (BuildContext context) => const Login(),
    '/singUp': (BuildContext context) => const SingupPage(),
    '/resetPhone': (BuildContext context) => const ResetPassPhone(),
    '/resetEmail': (BuildContext context) => const ResetPassEmail(),
    '/bottomNav': (BuildContext context) => BottomNav(),
    '/startDeplom': (BuildContext context) => StartDeplom(),
    '/profilePage': (BuildContext context) => ProfilePage(),
    '/editPrifile': (BuildContext context) => EditProfile(),
    '/changePassword': (BuildContext context) => ChangePassword(),
    '/serviesPage': (BuildContext context) => ServiesPage(),
    '/myPayment': (BuildContext context) => MyPayment(),
    '/select-level': (BuildContext context) => SelectLevel(),
    '/adult-exam': (BuildContext context) => AdultExam(),
    '/digtal-book': (BuildContext context) => DigetalBook(),
    '/track-progress': (BuildContext context) => TrackProgressPage(),
    '/test': (BuildContext context) => HorizontalArabicBarChart(),
    '/harvest-certificate': (BuildContext context) => HatvestCertificate(),
    '/cambridge-certificate': (BuildContext context) => CambridgeCertificate(),
    '/inquiries-requests': (BuildContext context) => InquiriesRequests(),
    '/complain_request': (BuildContext context) => ComplainRequest(),
    '/branches': (BuildContext context) => BranchPage(),
    '/connect-us': (BuildContext context) => ConnectUs(),
    '/kids-pt': (BuildContext context) => KidsPtExam(),
    '/all-certificate': (BuildContext context) => CertificatesTabsPage(),
    '/about-page': (BuildContext context) => AboutPage(),
    '/get_help': (BuildContext context) => GetHelpPage(),
    '/notifications': (BuildContext context) => const NotificationsPage(),
    '/exams': (BuildContext context) => const ExamsPage(),
    '/offers': (BuildContext context) => OffersPage(),
  };
}
