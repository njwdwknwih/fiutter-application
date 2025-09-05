import 'package:babyshophub/models/notification_type.dart';

class NotificationRepositories {
  List<NotificationItem> getNotifications(){
    return const[
      NotificationItem(
        title: 'Order Confirmed', 
        message: 'Your order #1102 has been confirmed and is being processed.', 
        time: '2 minutes ago', 
        type: NotificationType.promo,
        isRead: true
        ),
        NotificationItem(
        title: 'Special Offer', 
        message: 'Get 20% off on all toys this weekend.', 
        time: '20 minutes ago', 
        type: NotificationType.order,
        ),
        NotificationItem(
        title: 'Out for Delivery', 
        message: 'Your order #1356 is out for delivery..', 
        time: '2 hours ago', 
        type: NotificationType.delivery,
        isRead: true
        ),
        NotificationItem(
        title: 'Payment Successful', 
        message: 'Payment for order #1356 was successful', 
        time: '30 minutes ago', 
        type: NotificationType.payment,
        isRead: true
        )
    ];
  }
}