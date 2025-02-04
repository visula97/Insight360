import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../util/db_helper.dart';

class NewsViewModel extends ChangeNotifier {
  List<dynamic> headlines = [];
  List<dynamic> news = [];
  List<dynamic> searchedNews = [];
  List<dynamic> savedNews = [];

  DbHelper dbHelper = DbHelper();
  String selectedLanguageCode = '';

  NewsViewModel() {
    _initialize();
  }
  
  Future<void> _initialize() async {
    await getSelectedLanguage();
    await fetchSavedArticles();
  }

  Future<void> fetchHeadlines(String category, {String? country, required String sortBy, String? query}) async {
    await getSelectedLanguage();
    try {
      String uri = 'https://newsapi.org/v2/top-headlines?category=$category&apiKey=6c7863c0318541eb9b1539adf6b6f733';

      if (query != null) {
        uri += '&q=$query';
      }
      if (country != null) {
        uri += '&country=$country';
      }

      final response = await http.get(Uri.parse(uri));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> articles = data['articles'];

        articles = articles.where((article) {
          String title = article['title'] ?? '';
          String description = article['description'] ?? '';
          return !title.contains('[Removed]') && !description.contains('[Removed]');
        }).toList();

        if (sortBy == 'newest') {
          articles.sort((a, b) {
            DateTime dateA = DateTime.parse(a['publishedAt']);
            DateTime dateB = DateTime.parse(b['publishedAt']);
            return dateB.compareTo(dateA);
          });
        } else if (sortBy == 'oldest') {
          articles.sort((a, b) {
            DateTime dateA = DateTime.parse(a['publishedAt']);
            DateTime dateB = DateTime.parse(b['publishedAt']);
            return dateA.compareTo(dateB);
          });
        } else if (sortBy == 'author') {
          articles.sort((a, b) {
            String sourceA = a['source']?['name'] ?? '';
            String sourceB = b['source']?['name'] ?? '';
            return sourceA.compareTo(sourceB);
          });
        } else {
          articles.sort((a, b) => a['title'].compareTo(b['title']));
        }

        this.headlines = articles;
        notifyListeners();
      } else {
        throw Exception('Failed to load news');
      }
    } catch (e) {
      print('Error: $e');
      throw e;
    }
  }

  Future<void> fetchNews({required String query, String? from, String? to, String? sortBy, String? domains}) async {
    await getSelectedLanguage();
    try {
      String uri = 'https://newsapi.org/v2/everything?q=$query&apiKey=6c7863c0318541eb9b1539adf6b6f733';

      if (from != null) {
        uri += '&from=$from';
      }
      if (to != null) {
        uri += '&to=$to';
      }
      if (sortBy != null) {
        uri += '&sortBy=$sortBy';
      }
      if (domains != null) {
        uri += '&domains=$domains';
      }
      if (selectedLanguageCode != '') {
        uri += '&language=$selectedLanguageCode';
      }

      final response = await http.get(Uri.parse(uri));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> articles = data['articles'];

        articles = articles.where((article) {
          String title = article['title'] ?? '';
          String description = article['description'] ?? '';
          return !title.contains('[Removed]') && !description.contains('[Removed]');
        }).toList();

        this.news = articles;
        notifyListeners();
      } else {
        throw Exception('Failed to load news');
      }
    } catch (e) {
      print('Error: $e');
      throw e;
    }
  }

  Future<void> searchNews({required String query, String? from, String? to, String? sortBy, String? domains}) async {
    await getSelectedLanguage();
    try {
      String uri = 'https://newsapi.org/v2/everything?q=$query&apiKey=6c7863c0318541eb9b1539adf6b6f733';

      if (from != null) {
        uri += '&from=$from';
      }
      if (to != null) {
        uri += '&to=$to';
      }
      if (sortBy != null) {
        uri += '&sortBy=$sortBy';
      }
      if (domains != null) {
        uri += '&domains=$domains';
      }
      if (selectedLanguageCode != '') {
        uri += '&language=$selectedLanguageCode';
      }

      final response = await http.get(Uri.parse(uri));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> articles = data['articles'];

        articles = articles.where((article) {
          String title = article['title'] ?? '';
          String description = article['description'] ?? '';
          return !title.contains('[Removed]') && !description.contains('[Removed]');
        }).toList();

        this.searchedNews = articles;
        notifyListeners();
      } else {
        throw Exception('Failed to load news');
      }
    } catch (e) {
      print('Error: $e');
      throw e;
    }
  }

  Future<void> fetchSavedArticles() async {
    this.savedNews = await dbHelper.getSavedArticles();
    notifyListeners();
  }

  Future<List<Map<String, dynamic>>> getSavedArticles() async {
    return dbHelper.getSavedArticles();
  }

  Future<void> saveArticle(BuildContext context, article) async {
    final dbHelper = DbHelper();

    final articleData = {
      'title': article['title'] ?? '',
      'source': article['source']?['name'] ?? '',
      'publishedAt': article['publishedAt'] ?? '',
      'description': article['description'] ?? '',
      'url': article['url'] ?? '',
      'urlToImage': article['urlToImage'] ?? '',
    };

    try {
      await dbHelper.saveArticle(articleData);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Article saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save the article.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> deleteArticle(BuildContext context, id) async {
    final dbHelper = DbHelper();

    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text('Do you want to remove this article from saved?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue[800],
              ),
              child: Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue[800],
              ),
              child: Text('Yes'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await dbHelper.deleteArticle(id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Article deleted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacementNamed(context, '/saved');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete the article.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void clearNews() {
    searchedNews = [];
    notifyListeners();
  }

  Future<void> getSelectedLanguage() async {
    String? savedLanguage = await dbHelper.getSelectedLanguage();
    selectedLanguageCode = savedLanguage ?? 'en';
  }

}

