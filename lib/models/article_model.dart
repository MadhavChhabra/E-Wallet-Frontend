class Article {
  final String title;
  final String url;
  final String urlToImage;

  Article({required this.title, required this.url, required this.urlToImage});

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      title: json['title'],
      url: json['url'],
      urlToImage: json['urlToImage'],
    );
  }
}