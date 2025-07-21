import 'package:flutter/material.dart';
import 'package:svareignadmin/views/homescreen/widgets.dart';

class Homescreen extends StatelessWidget {
  const Homescreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 200,
            color: Colors.grey.shade200,
            child: Column(
              children: [
                SidebarItem(
                  icon: Icons.person,
                  label: "Users",
                  voidcallback: () {},
                ),
                SidebarItem(
                  icon: Icons.handyman,
                  label: "Providers",
                  voidcallback: () {},
                ),
                SidebarItem(
                  icon: Icons.book_online,
                  label: "Bookings",
                  voidcallback: () {},
                ),
                SidebarItem(
                  icon: Icons.campaign,
                  label: "Advertisements",
                  voidcallback: () {},
                ),
                SidebarItem(
                  icon: Icons.attach_money,
                  label: "Earnings",
                  voidcallback: () {},
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      'Admin Dashboard',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: 5 / 2,
                      children: [
                        StatsCard(
                          icon: Icons.person,
                          title: 'Total Users',
                          value: '1240',
                          color: Colors.blue.shade100,
                        ),
                        StatsCard(
                          icon: Icons.calendar_today,
                          title: 'Total Bookings',
                          value: '320',
                          color: Colors.indigo.shade100,
                        ),
                        StatsCard(
                          icon: Icons.currency_rupee,
                          title: 'Total Earnings',
                          value: '₹45,600',
                          color: Colors.green.shade100,
                        ),
                        StatsCard(
                          icon: Icons.campaign,
                          title: 'Ads Posted',
                          value: '15',
                          color: Colors.orange.shade100,
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),
                    const Text(
                      'Monthly Earnings',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),

                    Container(
                      height: 200,
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
          ),
        ],
      ),
    );
  }
}
