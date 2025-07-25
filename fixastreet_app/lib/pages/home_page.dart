// import 'package:fixastreet_app/utils/data.dart';
import 'dart:convert';

import 'package:fixastreet_app/widgets/pending.dart';
import 'package:fixastreet_app/widgets/progess.dart';
import 'package:fixastreet_app/widgets/resolved.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:timeago/timeago.dart' as timeago;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController searchController = TextEditingController();
  final String apiUrl = 'https://fixa-street-ke-api.vercel.app/api/reports';
  // Replace with your actual API URL
  Future<List<Map<String, dynamic>>> fetchIssues() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);

        // Replace with actual parsing logic
        return jsonData
            .map((item) => item as Map<String, dynamic>)
            .toList(); // Replace with actual parsing logic
      } else {
        throw Exception('Failed to load issues');
      }
    } catch (e) {
      // print('Error fetching issues: $e');
      return [];
    }
  }

  List<Map<String, dynamic>> filteredIssues = [];
  List<Map<String, dynamic>> issuesData =
      []; // Global variable to hold fetched data
  List<Map<String, dynamic>> pendingIssues = []; // Example data
  List<Map<String, dynamic>> progressIssues = [];
  List<Map<String, dynamic>> resolvedIssues = [];

  @override
  void initState() {
    super.initState();
    fetchIssues().then((data) {
      setState(() {
        issuesData = data;
        if (issuesData.isEmpty) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('No Issues Found'),
              content: const Text('There are currently no issues reported.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        } else {
          pendingIssues = issuesData
              .where((issue) => issue['status'] == 'pending')
              .toList();
          progressIssues = issuesData
              .where((issue) => issue['status'] == 'in_progress')
              .toList();
          resolvedIssues = issuesData
              .where((issue) => issue['status'] == 'resolved')
              .toList();
          filteredIssues = issuesData;
        }
      });
    });

    searchController.addListener(() {
      filterIssues();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void filterIssues() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredIssues = issuesData.where((issue) {
        return issue['title'].toLowerCase().contains(query) ||
            issue['description'].toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Fix A Street\n Community reporting',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.green[600],
        actions: [
          IconButton(
            iconSize: 30,
            color: Colors.white,
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Navigate to notifications page or show notifications
            },
          ),
        ],
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Search issues...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15.0),
                    border: Border.all(width: 0.5),
                  ),
                  child: IconButton(
                    highlightColor: Colors.green,
                    hoverColor: Colors.transparent,
                    icon: Icon(Icons.filter_alt_outlined, color: Colors.black),
                    onPressed: () {
                      // Implement filter functionality
                    },
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    // Navigate to pending issues page
                    Navigator.of(
                      context,
                    ).push(MaterialPageRoute(builder: (context) => Pending()));
                  },
                  child: Container(
                    height: 60,
                    margin: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                          child: Text(
                            pendingIssues.length.toString(),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepOrange[800],
                            ),
                          ),
                        ),
                        Text(
                          'Pending',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.blueGrey[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    // Navigate to in-progress issues page
                    Navigator.of(
                      context,
                    ).push(MaterialPageRoute(builder: (context) => Progress()));
                  },
                  child: Container(
                    height: 60,
                    margin: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                          child: Text(
                            progressIssues.length.toString(),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        Text(
                          'In Progress',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.blueGrey[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    // Navigate to resolved issues page
                    Navigator.of(
                      context,
                    ).push(MaterialPageRoute(builder: (context) => Resolved()));
                  },
                  child: Container(
                    height: 60,
                    margin: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                          child: Text(
                            resolvedIssues.length.toString(),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[600],
                            ),
                          ),
                        ),
                        Text(
                          'Resolved',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.blueGrey[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          filteredIssues.isEmpty
              ? Expanded(
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.green[600]!,
                      ), // Show loading indicator if no issues found
                    ),
                  ),
                )
              : Expanded(
                  child: ListView.builder(
                    itemCount: filteredIssues.length, // Example count
                    itemBuilder: (context, index) {
                      final issue = filteredIssues[index];
                      final timeStamp = timeago.format(
                        DateTime.parse(issue['createdAt'].toString()),
                        locale: 'en_short',
                      );
                      // print(issue['imageUrl']);
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.all(8.0),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                            10.0,
                            10.0,
                            10.0,
                            0.0,
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 3.0,
                                    ),
                                    child: Image.network(
                                      // "https://fixa-street-ke-api.vercel.app${issue['imageUrl']}",
                                      issue['imageUrl'] ??
                                          'https://via.placeholder.com/100',
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(0.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,

                                            children: [
                                              Expanded(
                                                child: Text(
                                                  issue['title'],
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ),

                                              Icon(
                                                Icons.watch_later_outlined,
                                                size: 15,
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                timeStamp == 'just now'
                                                    ? 'Just now'
                                                    : '$timeStamp ago',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.blueGrey[600],
                                                ),
                                              ),
                                              SizedBox(width: 8),

                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color:
                                                      issue['status']
                                                              .toString() ==
                                                          'resolved'
                                                      ? Colors.green[100]
                                                      : issue['status']
                                                                .toString() ==
                                                            'in_progress'
                                                      ? Colors.blue[100]
                                                      : Colors.red[100],
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  issue['status'].toString(),
                                                  style: TextStyle(
                                                    color:
                                                        issue['status'] ==
                                                            'resolved'
                                                        ? Colors.green
                                                        : issue['status'] ==
                                                              'in_progress'
                                                        ? Colors.blue
                                                        : Colors.red,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            issue['description'].toString(),
                                            style: TextStyle(fontSize: 14),
                                          ),
                                          SizedBox(height: 10),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 2.0,
                                      vertical: 8.0,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.error_outline,
                                          size: 16,
                                          color: Colors.red,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 3.0,
                                          ),
                                          child: Text(
                                            issue['category'].toString(),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.blueGrey[600],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.location_on,
                                          size: 15,
                                          color: Colors.green[600],
                                        ),
                                        SizedBox(width: 3),
                                        Expanded(
                                          child: Text(
                                            issue['location'].toString(),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.blueGrey[600],
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }
}
