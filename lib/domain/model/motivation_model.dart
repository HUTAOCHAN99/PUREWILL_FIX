class MotivationModel {
  final String quote;
  final String author;

  MotivationModel({required this.quote, required this.author});

  factory MotivationModel.fromJson(Map<String, dynamic> json) {
    return MotivationModel(
      quote: json['q'] as String? ?? 'Keep going, you got this!',
      author: json['a'] as String? ?? 'Unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {'q': quote, 'a': author};
  }

  @override
  String toString() => 'MotivationModel(quote: $quote, author: $author)';
}
