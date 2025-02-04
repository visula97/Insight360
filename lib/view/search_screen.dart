import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/news_viewmodel.dart';
import 'news_detail_screen.dart';
import 'package:intl/intl.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String selectedSort = 'publishedAt';
  final List<String> sortOptions = ['publishedAt', 'relevancy', 'popularity'];
  final Map<String, String> sortOptionLabels = {
    'publishedAt': 'Published Date',
    'relevancy': 'Relevancy',
    'popularity': 'Popularity',
  };
  String query = '*';
  DateTimeRange? selectedDateRange;

  @override
  void initState() {
    super.initState();
    Provider.of<NewsViewModel>(context, listen: false).clearNews();

    Provider.of<NewsViewModel>(context, listen: false).fetchNews(
      query: query,
      sortBy: selectedSort,
    );

  }

  @override
  Widget build(BuildContext context) {
    final newsViewModel = Provider.of<NewsViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search for News',
                labelStyle: TextStyle(
                  color: Colors.grey,
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.blue[800]!,
                    width: 2.0,
                  ),
                ),
                border: OutlineInputBorder(),
                floatingLabelStyle: TextStyle(
                  color: Colors.blue[800],
                ),
              ),
              cursorColor: Colors.blue[800],
              onSubmitted: (value) async {
                if (value.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please enter a search term')),
                  );
                  return;
                }
                query = value.trim();
                await _fetchNewsWithFilters(newsViewModel);
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(
                      Icons.date_range,
                      color: Colors.blue[800],
                    ),
                    label: Text(
                      selectedDateRange == null
                          ? 'Select Date Range'
                          : '${DateFormat('MMM dd').format(selectedDateRange!.start)} - ${DateFormat('MMM dd').format(selectedDateRange!.end)}',
                      style: TextStyle(
                        color: Colors.blue[800],
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.blue[800], backgroundColor: Colors.white,
                      elevation: 2,
                    ),
                    onPressed: () async {
                      final DateTimeRange? pickedRange =
                      await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                        initialDateRange: selectedDateRange,
                        builder: (context, child) {
                          return Theme(
                            data: ThemeData.light().copyWith(
                              primaryColor: Colors.blue[800],
                              hintColor: Colors.blue[800],
                              buttonTheme: ButtonThemeData(
                                textTheme: ButtonTextTheme.primary
                              ),
                              colorScheme: ColorScheme.light(primary: Colors.blue.shade800),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (pickedRange != null) {
                        setState(() {
                          selectedDateRange = pickedRange;
                        });
                        await _fetchNewsWithFilters(newsViewModel);
                      }
                    },
                  ),
                ),


                const SizedBox(width: 8),

                Row(
                  children: [
                    const Icon(Icons.sort, size: 20, color: Colors.black),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: selectedSort,
                      onChanged: (newValue) async {
                        setState(() {
                          selectedSort = newValue!;
                        });
                        await _fetchNewsWithFilters(newsViewModel);
                      },
                      items: sortOptions.map((option) {
                        return DropdownMenuItem<String>(
                          value: option,
                          child: Text(sortOptionLabels[option]!),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: newsViewModel.searchedNews.isNotEmpty
                ? ListView.builder(
              itemCount: newsViewModel.searchedNews.length,
              itemBuilder: (context, index) {
                final article = newsViewModel.searchedNews[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                      vertical: 5, horizontal: 8),
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
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              NewsDetailScreen(article: article),
                        ),
                      );
                    },
                  ),
                );
              },
            )
                : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search_off,
                      size: 80, color: Colors.grey),
                  const SizedBox(height: 10),
                  const Text(
                    'No results found',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Try searching with different keywords',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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
        currentIndex: 2,
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

  Future<void> _fetchNewsWithFilters(NewsViewModel newsViewModel) async {
    String? from;
    String? to;

    if (selectedDateRange != null) {
      from = DateFormat('yyyy-MM-dd').format(selectedDateRange!.start);
      to = DateFormat('yyyy-MM-dd').format(selectedDateRange!.end);
    }

    await newsViewModel.searchNews(
      query: query,
      sortBy: selectedSort,
      from: from,
      to: to,
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
