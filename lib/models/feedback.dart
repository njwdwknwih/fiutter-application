

class FeedbackModel {
  final String id;
  final String userName;
  final String email;
  final String message;
  final int rating; 
  final DateTime timestamp;

  FeedbackModel({
    required this.id,
    required this.userName,
    required this.email,
    required this.message,
    required this.rating,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory FeedbackModel.fromJson(Map<String, dynamic> json) => FeedbackModel(
        id: json['id'] as String,
        userName: json['userName'] as String,
        email: json['email'] as String,
        message: json['message'] as String,
        rating: json['rating'] as int,
        timestamp: DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now(),
      );


  Map<String, dynamic> toJson() => {
        'id': id,
        'userName': userName,
        'email': email,
        'message': message,
        'rating': rating,
        'timestamp': timestamp.toIso8601String(),
      };
}
