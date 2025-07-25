import 'dart:io';

import 'package:fixastreet_app/conrollers/location.dart';
import 'package:fixastreet_app/widgets/reportSubmit.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  String? selectedCategory = 'Select Category';
  TextEditingController locationController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  File? selectedImage;
  String? imagePath;
  String apiUrl = 'https://fixa-street-ke-api.vercel.app/api/reports'; // Replace with your API URL
  bool isSubmitting = false;

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
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Issue Title *',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  hintText: 'Brief description of the issue',
                  hintStyle: TextStyle(
                    color: Colors.blueGrey[500],
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                  ),

                  contentPadding: const EdgeInsets.symmetric(horizontal: 10.0),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.blueGrey[100]!,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.green[800]!,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                'Detailed Description *',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              TextField(
                controller: descriptionController,
                maxLines: 5,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  hintText: 'Provide more details about the issue',
                  hintStyle: TextStyle(
                    color: Colors.blueGrey[500],
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                    vertical: 10.0,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.blueGrey[100]!,
                      width: 1.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.green[800]!,
                      width: 2.0,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                'Category*',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10.0),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.blueGrey[100]!,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.green[800]!,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                isExpanded: true,
                value: selectedCategory,
                items:
                    <String>[
                      'Select Category',
                      'Roads',
                      'Street Lights',
                      'Public Toilets',
                      'Signage',
                      'Sidewalks',
                      'Traffic Management',
                      'Flooding',
                    ].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedCategory = newValue;
                  });
                },
              ),
              SizedBox(height: 16.0),
              Text(
                'Location *',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: locationController,
                      readOnly: true,

                      decoration: InputDecoration(
                        hintStyle: TextStyle(
                          color: Colors.blueGrey[500],
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                        ),

                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10.0,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.blueGrey[100]!,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.green[800]!,
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.0),
                  GetLocatiState(locationController: locationController),
                ],
              ),
              SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: GestureDetector(
                        onTap: () async {
                          final picker = ImagePicker();
                          final pickedFile = await picker.pickImage(
                            source: ImageSource.camera,
                            maxWidth: 800,
                            maxHeight: 800,
                          );
                          if (pickedFile != null) {
                            setState(() {
                              selectedImage = File(pickedFile.path);
                              imagePath = pickedFile.path;
                            });
                            // print('Image selected: ${pickedFile.path}');
                          } else {
                            // print('No image selected.');
                            return;
                          }
                        },
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.camera_alt,
                                  size: 40,
                                  color: Colors.green[600],
                                ),
                                SizedBox(height: 8.0),
                                Text(
                                  "Take a Photo",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: GestureDetector(
                        onTap: () async {
                          final picker = ImagePicker();
                          final pickedFile = await picker.pickImage(
                            source: ImageSource.gallery,
                            maxWidth: 800,
                            maxHeight: 800,
                          );
                          if (pickedFile != null) {
                            setState(() {
                              selectedImage = File(pickedFile.path);
                              imagePath = pickedFile.path;
                            });
                            // print('Image selected: ${pickedFile.path}');
                          } else {
                            // print('No image selected.');
                            return;
                          }
                        },
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.file_upload_outlined,
                                  size: 40,
                                  color: Colors.green[600],
                                ),
                                SizedBox(height: 8.0),
                                Text(
                                  "upload a Photo",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: isSubmitting ? null : () async {
                  setState(() {
                    isSubmitting = true;
                  });
                  
                  await submitReport(
                    context,
                    selectedCategory,
                    titleController.text,
                    descriptionController.text,
                    locationController.text,
                    selectedImage,
                    apiUrl,
                    titleController,
                    descriptionController,
                    locationController,
                    imagePath,
                    () {
                      // Success callback to clear form
                      setState(() {
                        selectedCategory = 'Select Category';
                        selectedImage = null;
                        imagePath = null;
                      });
                      titleController.clear();
                      descriptionController.clear();
                      locationController.clear();
                    },
                  );
                  
                  setState(() {
                    isSubmitting = false;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: Center(
                  child: Text(
                    'Submit Report',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
