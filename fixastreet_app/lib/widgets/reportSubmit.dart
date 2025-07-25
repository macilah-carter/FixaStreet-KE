import 'package:fixastreet_app/pages/navigation_page.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;

Future<void> submitReport(
  BuildContext context,
  String? selectedCategory,
  String title,
  String description,
  String location,
  File? selectedImage,
  String apiUrl,
  TextEditingController titleController,
  TextEditingController descriptionController,
  TextEditingController locationController,
  String? imagePath,
  VoidCallback onSuccess,
) async {
  if (selectedCategory == 'Select Category') {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a category')));
    }
    return;
  }

  if (titleController.text.isEmpty) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a title')));
    }
    return;
  }

  if (descriptionController.text.isEmpty) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a description')),
      );
    }
    return;
  }

  // if (locationController.text.isEmpty) {
  //   if (context.mounted) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Please select a location')),
  //     );
  //   }
  //   return;
  // }

  try {
    var request = http.MultipartRequest('POST', Uri.parse(apiUrl));

    request.fields['category'] = selectedCategory ?? '';
    request.fields['title'] = titleController.text;
    request.fields['description'] = descriptionController.text;
    request.fields['location'] = locationController.text;
    request.fields['timestamp'] = DateTime.now().toIso8601String();
    request.fields['status'] = 'pending';

    // Handle image upload for different platforms
    if (selectedImage != null) {
      try {
        http.MultipartFile imageFile;

        if (kIsWeb) {
          // For web platform, read as bytes
          Uint8List imageBytes = await selectedImage.readAsBytes();
          imageFile = http.MultipartFile.fromBytes(
            'image',
            imageBytes,
            filename: 'report_image.jpg',
          );
        } else {
          // For mobile platforms, use fromPath
          imageFile = await http.MultipartFile.fromPath(
            'image',
            selectedImage.path,
          );
        }

        request.files.add(imageFile);
      } catch (imageError) {
        developer.log('Error adding image: $imageError', name: 'ReportSubmit');
        // Continue without image if there's an error
      }
    }

    var response = await request.send();

    if (context.mounted) {
      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report submitted successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        // Call the success callback to clear form
        onSuccess();

        // Wait for the SnackBar to be visible, then navigate
        await Future.delayed(const Duration(seconds: 2));
        if (context.mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) {
                return NavigationPage(); // Navigate to the main page
              },
            ),
          ); // Close the report submission dialog
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to submit report. Status: ${response.statusCode}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  } catch (e) {
    developer.log('Error submitting report: $e', name: 'ReportSubmit');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting report: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
