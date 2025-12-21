class ShopFollower {
  final int followerId;
  final int userId;
  final DateTime followAt;

  ShopFollower({
    required this.followerId,
    required this.userId,
    required this.followAt
  });

  factory ShopFollower.fromJson(Map<String, dynamic> json) {
    return ShopFollower(
      followerId: json['followerId'],
      userId: json['userId'],
      followAt: json['followAt']
    );
  }
}