import 'package:flutter/material.dart';
import 'package:svareignadmin/views/advertisements/ads_list_screen/ads_list_screen.dart';
import 'package:svareignadmin/views/advertisements/create_ads_screen/create_ads_screen.dart';

class AdsTabScreen extends StatelessWidget {
  const AdsTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Manage Advertisements"),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.list), text: "My Ads"),
              Tab(icon: Icon(Icons.upload), text: "Create Ad"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            AdsListScreen(),
            CreateAdsScreen(),
          ],
        ),
      ),
    );
  }
}
