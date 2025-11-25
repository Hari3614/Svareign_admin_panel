import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class CreateAdScreen extends StatefulWidget {
  const CreateAdScreen({super.key});

  @override
  State<CreateAdScreen> createState() => _CreateAdScreenState();
}

class _CreateAdScreenState extends State<CreateAdScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController redirectUrlController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  // List<PlatformFile> selectedFiles = [];

  // Future<void> pickMedia() async {
  //   final result = await FilePicker.platform.pickFiles(
  //     allowMultiple: true,
  //     type: FileType.custom,
  //     allowedExtensions: ['jpg', 'jpeg', 'png', 'mp4', 'mov'],
  //   );

  //   if (result != null) {
  //     setState(() {
  //       selectedFiles = result.files;
  //     });
  //   }
  // }
  static const imageMaxSize = 5 * 1024 * 1024; // 5MB
  static const videoMaxSize = 20 * 1024 * 1024; // 20MB

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> pickMedia() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'mp4', 'mov'],
      withData: true, // IMPORTANT for Flutter Web to access file.bytes
    );

    if (result != null) {
      List<PlatformFile> validFiles = [];

      for (var file in result.files) {
        final ext = file.extension?.toLowerCase();

        // Determine if it's image or video
        final isImage = ['jpg', 'jpeg', 'png'].contains(ext);
        final isVideo = ['mp4', 'mov'].contains(ext);

        // Check size
        if (isImage && file.size > imageMaxSize) {
          _showError("${file.name} is larger than 5MB");
          continue;
        }
        if (isVideo && file.size > videoMaxSize) {
          _showError("${file.name} is larger than 20MB");
          continue;
        }

        validFiles.add(file);
      }

      setState(() {
        selectedFiles = validFiles;
      });
    }
  }

  List<PlatformFile> selectedFiles = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Advertisement")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ------------------ UPLOAD MEDIA ------------------
            const Text(
              "Upload Media",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            Center(
              child: InkWell(
                onTap: pickMedia,
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  width: 600,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.grey.shade300, width: 1.4),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.grey.shade50, Colors.grey.shade200],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.cloud_upload_outlined,
                        size: 58,
                        color: Colors.blueGrey.shade600,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Tap to Upload Media",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Images or Videos",
                        // (Drag & Drop Supported)",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),

            if (selectedFiles.isNotEmpty)
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children:
                    selectedFiles.map((file) {
                      final isImage =
                          file.extension == 'jpg' ||
                          file.extension == 'png' ||
                          file.extension == 'jpeg';

                      return Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child:
                            isImage
                                ? Image.memory(file.bytes!, fit: BoxFit.cover)
                                : const Center(
                                  child: Icon(
                                    Icons.videocam,
                                    size: 40,
                                    color: Colors.blueGrey,
                                  ),
                                ),
                      );
                    }).toList(),
              ),
            const SizedBox(height: 30),

            // ------------------ TITLE ------------------
            const Text(
              "Title",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Enter ad title",
              ),
            ),

            const SizedBox(height: 20),

            // ------------------ DESCRIPTION ------------------
            const Text(
              "Description",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: descriptionController,
              maxLines: 5,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Enter ad description",
              ),
            ),

            const SizedBox(height: 20),

            // ------------------ REDIRECT URL ------------------
            const Text(
              "Redirect URL",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: redirectUrlController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "https://example.com/offer-page",
              ),
            ),

            const SizedBox(height: 20),

            // ------------------ LOCATION ------------------
            const Text(
              "Location",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: locationController,
              readOnly: true,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: "Search location",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.location_on_outlined),
                  onPressed: () {
                    // open google map search modal
                  },
                ),
              ),
            ),

            const SizedBox(height: 30),

            // ------------------ PUBLISH BUTTON ------------------
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(15),
                ),
                child: const Text("Publish Ad", style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
