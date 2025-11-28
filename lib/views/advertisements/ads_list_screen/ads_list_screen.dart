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
                leading:
                    media.endsWith(".mp4") || media.endsWith(".mov")
                        ? const Icon(Icons.videocam, size: 40)
                        : ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.network(
                            media,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),

                title: Text(ad["title"]),
                subtitle: Text(
                  ad["description"],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 👁 View Button
                    IconButton(
                      icon: const Icon(
                        Icons.remove_red_eye,
                        color: Colors.blue,
                      ),
                      onPressed: () {
                        _showAdDetailsPopup(context, ad);
                      },
                    ),

                    // ❌ Delete Button (with confirmation)
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _confirmDelete(context, ad.id);
                      },
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

  String formatDateTime(DateTime? date) {
    if (date == null) return "Unknown";
    return DateFormat("dd MMM yyyy, hh:mm a").format(date);
  }

  // -----------------------------------------------
  // DELETE CONFIRMATION DIALOG
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

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Ad deleted successfully")),
                    );
                  }
                },
              ),
            ],
          ),
    );
  }

  // -----------------------------------------------
  // AD DETAILS POPUP (WITH IMAGE + DETAILS)
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
                    // ⭐ Media Preview Large
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child:
                          isVideo
                              ? Container(
                                color: Colors.black12,
                                height: 250,
                                child: const Center(
                                  child: Icon(
                                    Icons.videocam,
                                    size: 80,
                                    color: Colors.grey,
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

                    // LOCATION
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
                        "Lat: ${ad["location"]["lat"]}, Lng: ${ad["location"]["lng"]}",
                      ),
                    const SizedBox(height: 16),

                    // CREATED AT
                    const Text(
                      "Created At:",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Text(createdAt != null ? createdAt.toString() : "Unknown"),
                    Text(formatDateTime(createdAt)),
                    const SizedBox(height: 16),

                    // CREATED BY
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

// import 'dart:developer';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class AdsListScreen extends StatelessWidget {
//   const AdsListScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final uid = FirebaseAuth.instance.currentUser!.uid;

//     return StreamBuilder(
//       stream:
//           FirebaseFirestore.instance
//               .collection("ads")
//               .where("createdByUid", isEqualTo: uid)
//               .orderBy("createdAt", descending: true)
//               .snapshots(),
//       builder: (context, snapshot) {
//         log("📌 Snapshot received");
//         log("📌 Has data: ${snapshot.hasData}");
//         log("📌 Docs count: ${snapshot.data?.docs.length}");
//         log("📌 Error: ${snapshot.error}");

//         if (snapshot.connectionState == ConnectionState.waiting) {
//           log("📌 Waiting for data...");
//           return const Center(child: CircularProgressIndicator());
//         }

//         if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//           log("❌ No documents found for UID: $uid");
//           return const Center(child: Text("No ads uploaded yet"));
//         }

//         final ads = snapshot.data!.docs;
//         log("✅ Loaded ${ads.length} ads");

//         // your listview stays same...

//         return ListView.builder(
//           padding: const EdgeInsets.all(16),
//           itemCount: ads.length,
//           itemBuilder: (context, index) {
//             final ad = ads[index];
//             final media = ad["mediaUrls"][0]; // show first

//             // ⭐ Log the media URL for debugging
//             log("🖼️ Media for ad ${ad.id}: $media");

//             return Card(
//               margin: const EdgeInsets.only(bottom: 15),
//               child: ListTile(
//                 leading:
//                     media.endsWith(".mp4") || media.endsWith(".mov")
//                         ? const Icon(Icons.videocam, size: 40)
//                         : Image.network(
//                           media,
//                           width: 60,
//                           height: 60,
//                           fit: BoxFit.cover,
//                           errorBuilder: (context, error, stackTrace) {
//                             log("⚠️ Failed to load image: $media");

//                             return Image.asset(
//                               "assets/images/dummy_ad.png",
//                               width: 60,
//                               height: 60,
//                               fit: BoxFit.cover,
//                             );
//                           },
//                         ),
//                 title: Text(ad["title"]),
//                 subtitle: Text(ad["description"]),
//                 trailing: IconButton(
//                   icon: const Icon(Icons.delete, color: Colors.red),
//                   onPressed: () async {
//                     await FirebaseFirestore.instance
//                         .collection("ads")
//                         .doc(ad.id)
//                         .delete();
//                     if (!context.mounted) return;

//                     ScaffoldMessenger.of(
//                       context,
//                     ).showSnackBar(const SnackBar(content: Text("Ad deleted")));
//                   },
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
// }
