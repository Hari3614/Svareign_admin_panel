import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'dart:convert';
import 'dart:js' as js;

// import 'package:http/http.dart' as http;

class CreateAdsScreen extends StatefulWidget {
  const CreateAdsScreen({super.key});

  @override
  State<CreateAdsScreen> createState() => _CreateAdsScreenState();
}

class _CreateAdsScreenState extends State<CreateAdsScreen> {
  // String googleApiKey = "AIzaSyDqpOdQdfhCp5iv-2TdmOCYJwEI0K_O8IY";

  bool isLoading = false;
  double? selectedLat;
  double? selectedLng;
  String adminUid = "";
  String adminName = "";
  String adminEmail = "";
  List<PlatformFile> selectedFiles = [];
  List<dynamic> placeSuggestions = [];
  bool isSearchingLocation = false;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController redirectUrlController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  // Future<void> fetchLocationSuggestions(String input) async {
  //   if (input.isEmpty) {
  //     setState(() => placeSuggestions = []);
  //     return;
  //   }

  //   // final url =
  //   //     "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$googleApiKey&components=country:in";

  //   setState(() => isSearchingLocation = true);

  //   final response = await http.get(Uri.parse(url));

  //   if (response.statusCode == 200) {
  //     final data = jsonDecode(response.body);
  //     setState(() {
  //       placeSuggestions = data["predictions"];
  //     });
  //   }

  //   setState(() => isSearchingLocation = false);
  // }

  // Future<void> fetchPlaceDetails(String placeId) async {
  //   final url =
  //       "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$googleApiKey";

  //   final response = await http.get(Uri.parse(url));

  //   if (response.statusCode == 200) {
  //     final data = jsonDecode(response.body);

  //     final result = data["result"];

  //     final lat = result["geometry"]["location"]["lat"];
  //     final lng = result["geometry"]["location"]["lng"];
  //     final formattedAddress = result["formatted_address"];

  //     setState(() {
  //       selectedLat = lat;
  //       selectedLng = lng;
  //       locationController.text = formattedAddress;
  //       placeSuggestions = [];
  //     });

  //     log("Selected Address: $formattedAddress");
  //     log("Lat: $lat  Lng: $lng");
  //   }
  // }

  Future<void> loadAdminDetails() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      adminUid = user.uid;

      final adminDoc =
          await FirebaseFirestore.instance
              .collection("admins")
              .doc(adminUid)
              .get();

      if (adminDoc.exists) {
        adminName = adminDoc["name"];
        adminEmail = adminDoc["email"];
      }
    }
  }

  Future<String> uploadSingleFile(PlatformFile file) async {
    final ext = file.extension!.toLowerCase();

    // Detect type for metadata
    final isImage = ['jpg', 'jpeg', 'png'].contains(ext);
    final isVideo = ['mp4', 'mov'].contains(ext);

    final metadata = SettableMetadata(
      contentType:
          isImage
              ? "image/$ext"
              : isVideo
              ? "video/$ext"
              : "application/octet-stream",
    );

    final ref = FirebaseStorage.instance.ref().child(
      "ads/${DateTime.now().millisecondsSinceEpoch}_${file.name}",
    );

    // FIX: Upload with Metadata
    final uploadTask = await ref.putData(file.bytes!, metadata);

    return await uploadTask.ref.getDownloadURL();
  }

  Future<List<String>> uploadAllMedia() async {
    List<String> urls = [];

    for (var file in selectedFiles) {
      final url = await uploadSingleFile(file);
      urls.add(url);
    }

    return urls;
  }

  Future<void> publishAd() async {
    if (titleController.text.isEmpty) {
      _showError("Please enter title");
      return;
    }

    if (selectedFiles.isEmpty) {
      _showError("Please upload at least 1 media file");
      return;
    }

    setState(() => isLoading = true);

    try {
      final mediaUrls = await uploadAllMedia();

      await FirebaseFirestore.instance.collection("ads").add({
        "title": titleController.text.trim(),
        "description": descriptionController.text.trim(),
        "mediaUrls": mediaUrls,
        "redirectUrl": redirectUrlController.text.trim(),
        "location": {
          "lat": selectedLat ?? 0,
          "lng": selectedLng ?? 0,
          "address": locationController.text.trim(),
        },
        "createdAt": FieldValue.serverTimestamp(),
        "createdByUid": adminUid,
        "createdByName": adminName,
        "createdByEmail": adminEmail,
        "status": "active",
      });
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ad Published Successfully!")),
      );

      setState(() {
        selectedFiles.clear();
        titleController.clear();
        descriptionController.clear();
        redirectUrlController.clear();
        locationController.clear();
      });
    } catch (e) {
      _showError("Failed to publish ad: $e");
    }

    setState(() => isLoading = false);
  }

  void handleAutocompleteResult(dynamic data) {
    final decoded = jsonDecode(data as String);

    setState(() {
      placeSuggestions = decoded;
    });
  }

  void handlePlaceDetailResult(dynamic data) {
    final decoded = jsonDecode(data as String);

    if (decoded == null || decoded is! Map) return;

    final lat = decoded["geometry"]["location"]["lat"];
    final lng = decoded["geometry"]["location"]["lng"];
    final address = decoded["formatted_address"];

    setState(() {
      selectedLat = lat;
      selectedLng = lng;
      locationController.text = address;
      placeSuggestions = [];
    });
  }

  void fetchSuggestions(String input) {
    js.context.callMethod("getPlaceSuggestions", [
      input,
      "handleAutocompleteResult",
    ]);
  }

  void fetchPlaceDetail(String placeId) {
    js.context.callMethod("getPlaceDetails", [
      placeId,
      "handlePlaceDetailResult",
    ]);
  }

  @override
  void initState() {
    super.initState();

    // Register JS callbacks
    js.context["handleAutocompleteResult"] = handleAutocompleteResult;
    js.context["handlePlaceDetailResult"] = handlePlaceDetailResult;

    // Initialize Google JS services (defined in index.html)
    js.context.callMethod("initGoogleServices");

    loadAdminDetails();
    log("AUTH UID = ${FirebaseAuth.instance.currentUser?.uid}");
  }

  static const imageMaxSize = 10 * 1024 * 1024; // 10MB
  static const videoMaxSize = 30 * 1024 * 1024; // 30MB

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Advertisement")),
      body: Stack(
        children: [
          SingleChildScrollView(
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
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1.4,
                        ),
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
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children:
                          selectedFiles.map((file) {
                            final ext = file.extension?.toLowerCase();
                            final isImage = [
                              'jpg',
                              'jpeg',
                              'png',
                            ].contains(ext);

                            return Stack(
                              children: [
                                // Media Preview Box
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child:
                                        isImage
                                            ? Image.memory(
                                              file.bytes!,
                                              fit: BoxFit.cover,
                                            )
                                            : Container(
                                              color: Colors.black12,
                                              child: Center(
                                                child: Icon(
                                                  Icons.videocam_rounded,
                                                  size: 40,
                                                  color:
                                                      Colors.blueGrey.shade600,
                                                ),
                                              ),
                                            ),
                                  ),
                                ),

                                // ❌ Delete button
                                Positioned(
                                  right: 6,
                                  top: 6,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedFiles.remove(file);
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(
                                          alpha: 0.6,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                    ),
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: locationController,
                      onChanged: (value) => fetchSuggestions(value),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Search location",
                      ),
                    ),

                    if (placeSuggestions.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        constraints: const BoxConstraints(maxHeight: 250),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListView.builder(
                          itemCount: placeSuggestions.length,
                          itemBuilder: (context, index) {
                            final item = placeSuggestions[index];

                            return ListTile(
                              title: Text(item["description"]),
                              onTap: () {
                                fetchPlaceDetail(item["place_id"]);
                              },
                            );
                          },
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 30),

                // ------------------ PUBLISH BUTTON ------------------
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : publishAd,
                    child:
                        isLoading
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                            : const Text("Publish Ad"),
                  ),
                ),
              ],
            ),
          ),

          if (isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.4),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
