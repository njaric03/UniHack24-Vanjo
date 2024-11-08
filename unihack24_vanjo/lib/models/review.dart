class Review {
  String? text;
  int? rating;

  Review({this.text, this.rating});

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      text: map['text'],
      rating: map['rating']?.toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'rating': rating,
    };
  }
}
