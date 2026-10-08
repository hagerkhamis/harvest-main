import 'package:flutter/material.dart';
import 'package:hatvest/core/theme/app_colors.dart';
import 'package:hatvest/core/theme/font_manager.dart';
import 'package:hatvest/core/theme/styles_manager.dart';

class WelcomeSelectionPage extends StatelessWidget {
  const WelcomeSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Quote
              Text(
                '"Learning opens doors to the world.\nReady to step through?"',
                textAlign: TextAlign.center,
                style: getMediumStyle(
                  color: context.textPrimary,
                  fontSize: FontSize.s14,
                ).copyWith(fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 20),
              // Logo and App Name
              Directionality(
                textDirection: TextDirection.ltr,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Harvest',
                      style: getBoldStyle(
                        color: context.textPrimary,
                        fontSize: FontSize.s24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Image.asset(
                      'assets/images/logo.png',
                      width: 40,
                      height: 40,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Title
              Text(
                'Welcome to your\nLearning Journey!',
                textAlign: TextAlign.center,
                textDirection: TextDirection.ltr,
                style: getBoldStyle(
                  color: context.textPrimary,
                  fontSize: FontSize.s28,
                ),
              ),
              const SizedBox(height: 30),
              // Subtitle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Embark on your personal path to mastery. Complete our placement test, choose your courses, and create your account. We are here to support your growth.',
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.ltr,
                  style: getMediumStyle(
                    color: context.textSecondary,
                    fontSize: FontSize.s16,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // Cards
              Row(
                children: [
                  // New Student Card
                  Expanded(
                    child: _buildSelectionCard(
                      context: context,
                      title: 'New\nCustomer',
                      subtitle: 'Explore our curated\npaths, take a placement\ntest, and create your\naccount.\n\nA warm welcome to\nHarvest Family.',
                      icon: Icons.person_add_alt_1_outlined,
                      onTap: () {
                         Navigator.pushNamed(context, '/singUp');
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Returning Student Card
                  Expanded(
                    child: _buildSelectionCard(
                      context: context,
                      title: 'Current\nClient',
                      subtitle: 'Revisit your courses,\ncontinue where you left\noff, and access your\npersonal dashboard.\n\nGlad to have you with\nus again.',
                      icon: Icons.person_search_outlined,
                      onTap: () {
                        Navigator.pushNamed(context, '/login');
                      },
                    ),
                  ),
                ],
              ),
              const Spacer(),
              const SizedBox(height: 30),
            ],
          ),
        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 340,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Icon(
              icon,
              size: 50,
              color: context.textPrimary,
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              textDirection: TextDirection.ltr,
              style: getBoldStyle(
                color: context.textPrimary,
                fontSize: FontSize.s18,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              textDirection: TextDirection.ltr,
              style: getRegularStyle(
                color: context.textSecondary,
                fontSize: FontSize.s12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
