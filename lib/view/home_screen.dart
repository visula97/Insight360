import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/news_viewmodel.dart';
import 'news_detail_screen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  String selectedCategory = 'general';
  String selectedSort = 'newest';
  final List<String> categories = [
    'business',
    'entertainment',
    'general',
    'health',
    'science',
    'sports',
    'technology'
  ];

  final List<String> sortOptions = ['newest', 'oldest', 'author'];
  final Map<String, String> sortOptionLabels = {
    'newest': 'Newest First',
    'oldest': 'Oldest First',
    'author': 'Author',
  };

  @override
  void initState() {
    super.initState();
    Provider.of<NewsViewModel>(context, listen: false)
        .fetchHeadlines(selectedCategory, sortBy: selectedSort);

  }

  @override
  Widget build(BuildContext context) {
    final newsViewModel = Provider.of<NewsViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Top Headlines', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 50,
            color: Colors.blue[50],
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategory = category;
                    });
                    newsViewModel.fetchHeadlines(selectedCategory, sortBy: selectedSort);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    margin: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: selectedCategory == category
                          ? Colors.blue[300]
                          : Colors.blue[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        category.toUpperCase(),
                        style: TextStyle(
                          color: selectedCategory == category
                              ? Colors.white
                              : Colors.blue[800],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start, // Align left
              children: [
                // Sort Icon
                const Icon(
                  Icons.sort,
                  size: 20,
                  color: Colors.black,
                ),
                const SizedBox(width: 8),

                const Text(
                  'Sort By',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),

                DropdownButton<String>(
                  value: selectedSort,
                  onChanged: (newValue) {
                    setState(() {
                      selectedSort = newValue!;
                    });
                    newsViewModel.fetchHeadlines(
                      selectedCategory,
                      sortBy: selectedSort,
                    );
                  },
                  items: sortOptions.map((option) {
                    return DropdownMenuItem<String>(
                      value: option,
                      child: Text(sortOptionLabels[option]!),
                    );
                  }).toList(),
                  hint: const Text("Select Sort Option"),
                ),
              ],
            ),
          ),

          // News Articles List
          Expanded(
            child: FutureBuilder(
              future: newsViewModel.headlines.isEmpty
                  ? newsViewModel.fetchHeadlines(selectedCategory, sortBy: selectedSort)
                  : Future.value([]),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error fetching news: ${snapshot.error}'),
                  );
                } else if (newsViewModel.headlines.isNotEmpty) {
                  return ListView.builder(
                    itemCount: newsViewModel.headlines.length,
                    itemBuilder: (context, index) {
                      final article = newsViewModel.headlines[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                        child: ListTile(
                          leading: article['urlToImage'] != null
                              ? Image.network(
                            article['urlToImage'],
                            width: 50,
                            fit: BoxFit.cover,
                          )
                              : const Icon(Icons.image, size: 50),
                          title: Text(
                            article['title'] ?? 'No Title',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                article['source']['name'] ?? 'Unknown Source',
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatDate(article['publishedAt']),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.download_for_offline, color: Colors.blue.shade800),
                            onPressed: () {
                              newsViewModel.saveArticle(context, article);
                            },
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => NewsDetailScreen(article: article),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                } else {
                  return const Center(child: Text('No data available'));
                }
              },
            ),
          ),
        ],
      ),
      // Footer Bar
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue.shade800,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article),
            label: 'All News',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'Saved',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/home');
              break;
            case 1:
              Navigator.pushNamed(context, '/allNews');
              break;
            case 2:
              Navigator.pushNamed(context, '/search');
              break;
            case 3:
              Navigator.pushNamed(context, '/saved');
              break;
            case 4:
              Navigator.pushNamed(context, '/settings');
              break;
          }
        },
      ),
    );
  }
}

String _formatDate(String dateString) {
  try {
    DateTime dateTime = DateTime.parse(dateString);
    return DateFormat('MMM dd, yyyy').format(dateTime);
  } catch (e) {
    return 'Unknown Date';
  }
}


