import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class AdsListScreen extends StatelessWidget {
  const AdsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder(
      stream:
          FirebaseFirestore.instance
              .collection("ads")
              .where("createdByUid", isEqualTo: uid)
              .orderBy("createdAt", descending: true)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No ads uploaded yet"));
        }

        final ads = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: ads.length,
          itemBuilder: (context, index) {
            final ad = ads[index];
            final media = ad["mediaUrls"][0];

            return Card(
              margin: const EdgeInsets.only(bottom: 15),
              elevation: 2,
              child: ListTile(
                leading: _buildMediaThumbnail(media),
                title: Text(ad["title"]),
                subtitle: Text(
                  ad["description"],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /// VIEW BUTTON
                    IconButton(
                      icon: const Icon(
                        Icons.remove_red_eye,
                        color: Colors.grey,
                      ),
                      onPressed: () => _showAdDetailsPopup(context, ad),
                    ),

                    /// DELETE BUTTON
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmDelete(context, ad.id),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // -----------------------------------------------
  // MEDIA THUMBNAIL
  // -----------------------------------------------
  Widget _buildMediaThumbnail(String mediaUrl) {
    final isVideo = mediaUrl.endsWith(".mp4") || mediaUrl.endsWith(".mov");

    if (isVideo) {
      return const Icon(Icons.videocam, size: 40);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Image.network(
        mediaUrl,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 40),
      ),
    );
  }

  // -----------------------------------------------
  // DELETE CONFIRMATION POP-UP
  // -----------------------------------------------
  void _confirmDelete(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Delete Ad"),
            content: const Text("Are you sure you want to delete this ad?"),
            actions: [
              TextButton(
                child: const Text("Cancel"),
                onPressed: () => Navigator.pop(context),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text("Delete"),
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection("ads")
                      .doc(docId)
                      .delete();

                  if (!context.mounted) return;

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Ad deleted successfully")),
                  );
                },
              ),
            ],
          ),
    );
  }

  // -----------------------------------------------
  // AD DETAILS POPUP
  // -----------------------------------------------
  void _showAdDetailsPopup(BuildContext context, DocumentSnapshot ad) {
    final media = ad["mediaUrls"][0];
    final isVideo = media.endsWith(".mp4") || media.endsWith(".mov");

    final createdAt =
        ad["createdAt"] != null
            ? (ad["createdAt"] as Timestamp).toDate()
            : null;

    showDialog(
      context: context,
      builder:
          (_) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              width: 500,
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Media Preview Large
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child:
                          isVideo
                              ? Container(
                                height: 250,
                                color: Colors.black26,
                                child: const Center(
                                  child: Icon(
                                    Icons.videocam,
                                    size: 80,
                                    color: Colors.white70,
                                  ),
                                ),
                              )
                              : Image.network(
                                media,
                                height: 250,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      ad["title"],
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Text(
                      ad["description"],
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      "Location:",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(ad["location"]["address"] ?? "Not provided"),
                    if (ad["location"]["lat"] != 0)
                      Text(
                        "Lat: ${ad["location"]["lat"]},  Lng: ${ad["location"]["lng"]}",
                      ),

                    const SizedBox(height: 16),

                    const Text(
                      "Created At:",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      createdAt != null
                          ? DateFormat("dd MMM yyyy, hh:mm a").format(createdAt)
                          : "Unknown",
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      "Created By:",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(ad["createdByName"]),
                    Text(ad["createdByEmail"]),

                    const SizedBox(height: 20),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        child: const Text("Close"),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }
}