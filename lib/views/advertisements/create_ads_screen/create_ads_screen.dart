import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:svareignadmin/viewmodel/ads_view_model/ads_view_model.dart';

class CreateAdsScreen extends StatelessWidget {
  const CreateAdsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AdsViewModel>(
      builder: (context, vm, child) {
        if (vm.snackMessage != null && context.mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(vm.snackMessage!)));
            vm.snackMessage = null;
          });
        }

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
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),

                    Center(
                      child: InkWell(
                        onTap: () => vm.pickMedia(context),
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
                              colors: [
                                Colors.grey.shade50,
                                Colors.grey.shade200,
                              ],
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

                    if (vm.selectedFiles.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children:
                              vm.selectedFiles.map((file) {
                                final ext = file.extension?.toLowerCase();
                                final isImage = [
                                  'jpg',
                                  'jpeg',
                                  'png',
                                ].contains(ext);

                                return Stack(
                                  children: [
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
                                                          Colors
                                                              .blueGrey
                                                              .shade600,
                                                    ),
                                                  ),
                                                ),
                                      ),
                                    ),

                                    Positioned(
                                      right: 6,
                                      top: 6,
                                      child: GestureDetector(
                                        onTap:
                                            () => vm.removeSelectedFile(file),
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
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: vm.titleController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Enter ad title",
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ------------------ DESCRIPTION ------------------
                    const Text(
                      "Description",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: vm.descriptionController,
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
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: vm.redirectUrlController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "https://example.com/offer-page",
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ------------------ LOCATION ------------------
                    const Text(
                      "Location",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: vm.locationController,
                          onChanged: (value) => vm.fetchSuggestions(value),
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "Search location",
                          ),
                        ),

                        if (vm.placeSuggestions.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            constraints: const BoxConstraints(maxHeight: 250),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListView.builder(
                              itemCount: vm.placeSuggestions.length,
                              itemBuilder: (context, index) {
                                final item = vm.placeSuggestions[index];
                                return ListTile(
                                  title: Text(item["description"]),
                                  onTap:
                                      () =>
                                          vm.fetchPlaceDetail(item["place_id"]),
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
                        onPressed:
                            vm.isLoading ? null : () => vm.publishAd(context),
                        child:
                            vm.isLoading
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

              if (vm.isLoading)
                Container(
                  color: Colors.black.withValues(alpha: 0.4),
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        );
      },
    );
  }
}