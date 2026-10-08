import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hatvest/core/theme/font_manager.dart';
import 'package:hatvest/core/theme/styles_manager.dart';
import 'package:hatvest/core/theme/styles.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "notifications".tr(),
          style: getBoldStyle(color: blackColors, fontSize: FontSize.s20),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: 5,
        separatorBuilder: (context, index) => const SizedBox(height: 15),
        itemBuilder: (context, index) {
          return Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.notifications_active_outlined, color: primaryColor),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.locale.languageCode == 'ar' ? "تنبيه جديد" : "New Notification",
                        style: getBoldStyle(color: blackColors, fontSize: FontSize.s16),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        context.locale.languageCode == 'ar' 
                          ? "هذا نص تجريبي لمحتوى الإشعار الخاص بك في تطبيق هارفست."
                          : "This is a dummy text for your notification content in Harvest app.",
                        style: getRegularStyle(color: grey, fontSize: FontSize.s14),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Text(
                  context.locale.languageCode == 'ar' ? "منذ 2س" : "2h ago",
                  style: getLightStyle(color: grey, fontSize: FontSize.s12),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
