import 'package:flutter/material.dart';
import 'package:svareignadmin/views/adspostingscreen/ads_posting_screen.dart';
import 'package:svareignadmin/views/bookingscreen/booking_screen.dart';
import 'package:svareignadmin/views/earningscreen/earning_screen.dart';
import 'package:svareignadmin/views/homescreen/widgets.dart';
import 'package:svareignadmin/views/serviceproviderscreen/provider_screen.dart';
import 'package:svareignadmin/views/userscreen/user_screen.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  int selectedIndex = 0;

  final List<Widget> pages = [
    const DashboardPage(), // ✅ Dashboard as index 0
    const UsersPage(),
    const ProvidersPage(),
    const BookingsPage(),
    const AdsPage(),
    const EarningsPage(),
  ];

  void onSidebarItemTap(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 220,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 40),
                const Text(
                  "SVAREIGN PANEL",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00E69F),
                  ),
                ),
                const SizedBox(height: 30),

                SidebarItem(
                  icon: Icons.dashboard,
                  label: "Dashboard",
                  isSelected: selectedIndex == 0,
                  voidcallback: () => onSidebarItemTap(0),
                ),
                SidebarItem(
                  icon: Icons.person,
                  label: "Users",
                  isSelected: selectedIndex == 1,
                  voidcallback: () => onSidebarItemTap(1),
                ),
                SidebarItem(
                  icon: Icons.handyman,
                  label: "Providers",
                  isSelected: selectedIndex == 2,
                  voidcallback: () => onSidebarItemTap(2),
                ),
                SidebarItem(
                  icon: Icons.book_online,
                  label: "Bookings",
                  isSelected: selectedIndex == 3,
                  voidcallback: () => onSidebarItemTap(3),
                ),
                SidebarItem(
                  icon: Icons.campaign,
                  label: "Advertisements",
                  isSelected: selectedIndex == 4,
                  voidcallback: () => onSidebarItemTap(4),
                ),
                SidebarItem(
                  icon: Icons.attach_money,
                  label: "Earnings",
                  isSelected: selectedIndex == 5,
                  voidcallback: () => onSidebarItemTap(5),
                ),
              ],
            ),
          ),

          // ✅ SHOW SELECTED PAGE
          Expanded(child: pages[selectedIndex]),
        ],
      ),
    );
  }
}

// ✅ Create DashboardPage widget (was your previous static dashboard)
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Admin Dashboard',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 5 / 2,
                children: [
                  StatsCard(
                    icon: Icons.person,
                    title: 'Total Users',
                    value: '1240',
                    color: Colors.blue.shade50,
                  ),
                  StatsCard(
                    icon: Icons.calendar_today,
                    title: 'Total Bookings',
                    value: '320',
                    color: Colors.indigo.shade50,
                  ),
                  StatsCard(
                    icon: Icons.currency_rupee,
                    title: 'Total Earnings',
                    value: '₹45,600',
                    color: Colors.green.shade50,
                  ),
                  StatsCard(
                    icon: Icons.campaign,
                    title: 'Ads Posted',
                    value: '15',
                    color: Colors.orange.shade50,
                  ),
                ],
              ),

              const SizedBox(height: 30),
              const Text(
                'Monthly Earnings',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),

              Container(
                height: 220,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 6,
                      color: Colors.grey.shade300,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    EarningsBar(label: 'Jan', heightFactor: 40),
                    EarningsBar(label: 'Feb', heightFactor: 45),
                    EarningsBar(label: 'Mar', heightFactor: 30),
                    EarningsBar(label: 'Apr', heightFactor: 45),
                    EarningsBar(label: 'May', heightFactor: 28),
                    EarningsBar(label: 'Jun', heightFactor: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
