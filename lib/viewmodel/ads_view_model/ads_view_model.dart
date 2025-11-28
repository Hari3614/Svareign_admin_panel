import 'dart:convert';
import 'dart:js' as js;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class AdsViewModel extends ChangeNotifier {
  bool isLoading = false;
  bool isSearchingLocation = false;

  String adminUid = "";
  String adminName = "";
  String adminEmail = "";
  String? snackMessage;

  double? selectedLat;
  double? selectedLng;

  List<PlatformFile> selectedFiles = [];
  List<dynamic> placeSuggestions = [];

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final redirectUrlController = TextEditingController();
  final locationController = TextEditingController();

  static const imageMaxSize = 10 * 1024 * 1024;
  static const videoMaxSize = 30 * 1024 * 1024;

  AdsViewModel() {
    _initGoogleJS();
    loadAdminDetails();
  }

  // -------------------------------------------------
  // INIT JS CALLBACKS
  // -------------------------------------------------
  void _initGoogleJS() {
    js.context["handleAutocompleteResult"] = (data) {
      final decoded = jsonDecode(data as String);
      placeSuggestions = decoded;
      notifyListeners();
    };

    js.context["handlePlaceDetailResult"] = (data) {
      final decoded = jsonDecode(data as String);

      final lat = decoded["geometry"]["location"]["lat"];
      final lng = decoded["geometry"]["location"]["lng"];
      final address = decoded["formatted_address"];

      selectedLat = lat;
      selectedLng = lng;
      locationController.text = address;
      placeSuggestions = [];
      notifyListeners();
    };

    js.context.callMethod("initGoogleServices");
  }

  // -------------------------------------------------
  // GOOGLE AUTOCOMPLETE
  // -------------------------------------------------
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

  // -------------------------------------------------
  // ADMIN DETAILS
  // -------------------------------------------------
  Future<void> loadAdminDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

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

  // -------------------------------------------------
  // FILE PICKER
  // -------------------------------------------------
  Future<void> pickMedia(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'mp4', 'mov'],
      withData: true,
    );

    if (result != null) {
      List<PlatformFile> validFiles = [];

      for (var file in result.files) {
        final ext = file.extension?.toLowerCase();
        final isImage = ['jpg', 'jpeg', 'png'].contains(ext);
        final isVideo = ['mp4', 'mov'].contains(ext);

        if (isImage && file.size > imageMaxSize) {
          showMessage("${file.name} is larger than 10MB");
          continue;
        }
        if (isVideo && file.size > videoMaxSize) {
          showMessage("${file.name} is larger than 30MB");
          continue;
        }

        validFiles.add(file);
      }

      selectedFiles = validFiles;
      notifyListeners();
    }
  }

  // -------------------------------------------------
  // UPLOAD FILE
  // -------------------------------------------------
  Future<String> _uploadSingleFile(PlatformFile file) async {
    final ext = file.extension!.toLowerCase();
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

    final uploadTask = await ref.putData(file.bytes!, metadata);
    return await uploadTask.ref.getDownloadURL();
  }

  Future<List<String>> _uploadAllMedia() async {
    List<String> urls = [];

    for (var file in selectedFiles) {
      urls.add(await _uploadSingleFile(file));
    }

    return urls;
  }

  // -------------------------------------------------
  // PUBLISH AD
  // -------------------------------------------------
  Future<void> publishAd(BuildContext context) async {
    if (titleController.text.isEmpty) {
      showMessage("Please enter title");
      return;
    }

    if (selectedFiles.isEmpty) {
      showMessage("Please upload at least 1 media file");
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      final mediaUrls = await _uploadAllMedia();

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

      showMessage("Ad Published Successfully!");

      // Reset form
      selectedFiles.clear();
      titleController.clear();
      descriptionController.clear();
      redirectUrlController.clear();
      locationController.clear();
      selectedLat = null;
      selectedLng = null;
    } catch (e) {
      showMessage("Failed to publish ad: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  // -------------------------------------------------
  // SNACKBAR TRIGGER
  // -------------------------------------------------
  void showMessage(String msg) {
    snackMessage = msg;
    notifyListeners();
  }

  void removeSelectedFile(PlatformFile file) {
    selectedFiles.remove(file);
    notifyListeners();
  }
}
