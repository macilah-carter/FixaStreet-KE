import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:timeago/timeago.dart' as timeago;

class Progress extends StatefulWidget {
  const Progress({super.key});

  @override
  State<Progress> createState() => _ProgressState();
}

class _ProgressState extends State<Progress> {
  final List<Map<String, dynamic>> progressIssues = [];
  Future <List<Map<String, dynamic>>> fetchProgressIssues()async{
    try{
      final response =await http.get(Uri.parse('https://fixa-street-ke-api.vercel.app/api/reports'));
      if(response.statusCode == 200){
        final List<dynamic> data = json.decode(response.body);
        return data.map((issue) => issue as Map<String, dynamic>).toList();
      } else {
        throw Exception('Failed to load pending issues');
      }
    }
    catch(e){
      print("Error fetching pending issues: $e");
      return [];
    }
  } // Example data

  @override
  void initState() {
    super.initState();
    fetchProgressIssues().then((issues) {
      setState(() {
        progressIssues.addAll(issues.where((issue) => issue['status'] == 'in_progress'));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pending Issues"),
        backgroundColor: Colors.green[600],
      ),
      body: ListView.builder(
        itemCount: progressIssues.length, // Example count
        itemBuilder: (context, index) {
          final issue = progressIssues[index];
          final timeStamp = timeago.format(
            DateTime.parse(issue['createdAt'].toString()),
            locale: 'en_short',
          );
          // print(issue);
          return Card(
            elevation: 2,
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
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
                          "https://images.unsplash.com/photo-1751971725935-84dd6f5e3544?q=80&w=387&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(0.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          issue['status'].toString() ==
                                              'resolved'
                                          ? Colors.green[100]
                                          : issue['status'].toString() ==
                                                'in_progress'
                                          ? Colors.blue[100]
                                          : Colors.red[100],
                                      borderRadius: BorderRadius.circular(
                                        12,
                                      ),
                                    ),
                                    child: Text(
                                      issue['status'].toString(),
                                      style: TextStyle(
                                        color:
                                            issue['status'] == 'resolved'
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            Text(
                              issue['location'].toString(),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blueGrey[600],
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
    );
  }
}