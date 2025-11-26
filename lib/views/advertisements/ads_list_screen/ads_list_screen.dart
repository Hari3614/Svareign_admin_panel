import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
        log("📌 Snapshot received");
        log("📌 Has data: ${snapshot.hasData}");
        log("📌 Docs count: ${snapshot.data?.docs.length}");
        log("📌 Error: ${snapshot.error}");

        if (snapshot.connectionState == ConnectionState.waiting) {
          log("📌 Waiting for data...");
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          log("❌ No documents found for UID: $uid");
          return const Center(child: Text("No ads uploaded yet"));
        }

        final ads = snapshot.data!.docs;
        log("✅ Loaded ${ads.length} ads");

        // your listview stays same...

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: ads.length,
          itemBuilder: (context, index) {
            final ad = ads[index];
            final media = ad["mediaUrls"][0]; // show first

            // ⭐ Log the media URL for debugging
            log("🖼️ Media for ad ${ad.id}: $media");

            return Card(
              margin: const EdgeInsets.only(bottom: 15),
              child: ListTile(
                leading:
                    media.endsWith(".mp4") || media.endsWith(".mov")
                        ? const Icon(Icons.videocam, size: 40)
                        : Image.network(
                          media,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            log("⚠️ Failed to load image: $media");

                            return Image.asset(
                              "assets/images/dummy_ad.png",
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                title: Text(ad["title"]),
                subtitle: Text(ad["description"]),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection("ads")
                        .doc(ad.id)
                        .delete();
                    if (!context.mounted) return;

                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text("Ad deleted")));
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
