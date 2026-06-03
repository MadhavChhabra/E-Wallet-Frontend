// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:flutter_ewallet/models/article_model.dart';

// class NewsApiService {
//   final String apiKey = "aeb743f661914b71ae2e3029e5d84429";
//   final String baseUrl = "http://newsapi.org/v2";

//   Future<List<Article>> fetchTopHeadlines({required String category}) async {
//     final response = await http.get(
//         Uri.parse('$baseUrl/top-headlines?category=$category&apiKey=$apiKey'));

//     if (response.statusCode == 200) {
//       List jsonResponse = json.decode(response.body)['articles'];
//       print(jsonResponse.toList().toString());
//       return jsonResponse.map((article) => Article.fromJson(article)).toList();
//     } else {
//       throw Exception('Failed to load articles');
//     }
//   }
// }


import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_ewallet/models/article_model.dart';
class NewsApiService {
  final endPointUrl = "newsapi.org";
  final client = http.Client();

  Future<List<Article>> fetchTopHeadlines() async {
    
    final queryParameters = {
      'country': 'in',
      'category': 'business',
      'apiKey': 'aeb743f661914b71ae2e3029e5d84429'
    };

    final uri = Uri.https(endPointUrl, '/v2/top-headlines', queryParameters);
    final response = await client.get(uri);
    Map<String, dynamic> json = jsonDecode(response.body);
    List<dynamic> body = json['articles'];
    List<Article> articles = body.map((dynamic item) => Article.fromJson(item)).toList();
    return articles;
  }
}