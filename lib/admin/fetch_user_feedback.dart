import 'package:babyshophub/utils/app_textsStyle.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class FetchUserFeedback extends StatelessWidget {
  const FetchUserFeedback({super.key});

  Stream<List<Map<String, dynamic>>> _fetchAllFeedbacks() {
    return FirebaseFirestore.instance
        .collectionGroup('users_feedback')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .where((doc) => doc.data().containsKey('timestamp'))
            .toList()
              ..sort((a, b) {
                final tsA = a['timestamp'] as Timestamp?;
                final tsB = b['timestamp'] as Timestamp?;
                return (tsB?.compareTo(tsA!) ?? 0);
              }))
        .map((docs) => docs.map((doc) => doc.data()).toList());
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'Unknown';
    return DateFormat('dd MMM yyyy • hh:mm a').format(timestamp.toDate());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back_ios,
              color: theme.appBarTheme.foregroundColor ??
                  (isDark ? Colors.white : Colors.black)),
        ),
        title: Text(
          'User Feedbacks',
          style: AppTextStyle.withColor(AppTextStyle.h3, theme.primaryColor),
        ),
        elevation: 0,
        backgroundColor: theme.appBarTheme.backgroundColor ??
            theme.scaffoldBackgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor ??
            (isDark ? Colors.white : Colors.black),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _fetchAllFeedbacks(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final feedbacks = snapshot.data ?? [];

          if (feedbacks.isEmpty) {
            return const Center(child: Text('No feedback available.'));
          }

          // ✅ Compute Average Rating Safely
          final totalRating = feedbacks.fold<double>(0.0, (sum, fb) {
            final rawRating = fb['rating'];
            final rating = rawRating is num
                ? rawRating.toDouble()
                : double.tryParse(rawRating.toString()) ?? 0.0;
            return sum + rating;
          });

          final avgRating =
              (totalRating / feedbacks.length).clamp(0.0, 5.0); // range safety

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: feedbacks.length + 1, // One extra for average rating
            itemBuilder: (context, index) {
              if (index == 0) {
                // ⭐ Top Overall Rating Card
                return Card(
                  color: theme.cardColor,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text('Overall App Rating', style: AppTextStyle.h3),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (i) {
                            return Icon(
                              i < avgRating.round()
                                  ? Icons.star
                                  : Icons.star_border,
                              color: theme.colorScheme.secondary,
                              size: 28,
                            );
                          }),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${avgRating.toStringAsFixed(1)} / 5.0',
                          style: theme.textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                );
              }

              final fb = feedbacks[index - 1];

              return Card(
                color: theme.cardColor,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// User Info Row
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: theme.primaryColor,
                            child: Text(
                              fb['userName']?.toString()[0].toUpperCase() ?? '?',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  fb['userName'] ?? 'Unknown User',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  fb['email'] ?? 'No Email',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            _formatTimestamp(fb['timestamp']),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      /// Rating Stars
                      Row(
                        children: List.generate(5, (i) {
                          final rating = (fb['rating'] ?? 0).toInt();
                          return Icon(
                            i < rating ? Icons.star : Icons.star_border,
                            color: theme.colorScheme.secondary,
                            size: 20,
                          );
                        }),
                      ),

                      const SizedBox(height: 12),

                      /// Feedback Message
                      Text(
                        fb['message'] ?? 'No message provided.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark ? Colors.grey[200] : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
