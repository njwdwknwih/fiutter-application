import 'package:babyshophub/models/notification_type.dart';
import 'package:babyshophub/repositories/notification_repositories.dart';
import 'package:babyshophub/utils/app_textsStyle.dart';
import 'package:babyshophub/utils/notification_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/instance_manager.dart';


class NotificationScreen extends StatefulWidget {

   const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
    final NotificationRepositories _repositories = NotificationRepositories();
  @override
  Widget build(BuildContext context) {
    final notifications = _repositories.getNotifications(); 
    final isDark = Theme.of(context).brightness ==  Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back() , 
          icon: Icon(
            Icons.arrow_back_ios,
            color: isDark ? Colors.white : Colors.black,
          )
          ),
          title: Text(
            'Notifications',
            style: AppTextStyle.withColor(
              AppTextStyle.h3,
              isDark ? Colors.white : Colors.black,
            ),
          ),
          actions: [
            TextButton(
              onPressed: (){}, 
              child: Text(
                'Mark all as read',
                style: AppTextStyle.withColor(
                  AppTextStyle.bodyMedium,
                  Theme.of(context).primaryColor,
                ),
              ))
          ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) => _buildNotificationCards(
          context,
          notifications[index],
        ),
      ),
    );
  }
  Widget _buildNotificationCards(BuildContext context,NotificationItem notifications){
     final isDark = Theme.of(context).brightness ==  Brightness.dark;
     return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: notifications.isRead
        ? Theme.of(context).cardColor
        : Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark 
            ? Colors.black.withOpacity(0.2)
            : Colors.grey.withOpacity(0.1),
          )
        ]
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: NotificationUtils.getIconBackgroundColor(
              context, 
              notifications.type
              ),
              shape: BoxShape.circle
          ),
          child: Icon(
            NotificationUtils.getNotificationIcon(notifications.type),
            color: NotificationUtils.getIconColor(context, notifications.type),
          ),
        ),
        title: Text(
          notifications.title,
          style: AppTextStyle.withColor(
            AppTextStyle.bodyLarge,
            Theme.of(context).textTheme.bodyLarge!.color!
          ),
        ),
         subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
           children: [
            SizedBox(height: 4,),
             Text(
              notifications.message,
              style: AppTextStyle.withColor(
                AppTextStyle.bodySmall,
                isDark ? Colors.grey[400]! : Colors.grey[600]!,
              ),
                     ),
           ],
         ),
      ),
     );     
  }
}