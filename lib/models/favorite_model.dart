class Favorite {
  final int? id;
  final int userId;
  final int foodItemId;
  final DateTime addedDate;

  Favorite({
    this.id,
    required this.userId,
    required this.foodItemId,
    required this.addedDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'foodItemId': foodItemId,
      'addedDate': addedDate.toIso8601String(),
    };
  }

  factory Favorite.fromMap(Map<String, dynamic> map) {
    return Favorite(
      id: map['id'],
      userId: map['userId'],
      foodItemId: map['foodItemId'],
      addedDate: DateTime.parse(map['addedDate']),
    );
  }
}
