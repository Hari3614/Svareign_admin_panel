import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:svareignadmin/viewmodel/user_view_model/user_view_model.dart';
import 'package:svareignadmin/model/user_model/user_model.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final TextEditingController _searchController = TextEditingController();
  final String _sortBy = 'Name';
  List<UserModel> filteredUsers = [];

  @override
  void initState() {
    super.initState();
    final vm = context.read<UserViewModel>();
    Future.microtask(() => vm.loadUsers());

    _searchController.addListener(() {
      setState(() {
        final query = _searchController.text.toLowerCase();
        filteredUsers =
            vm.users
                .where(
                  (user) =>
                      user.name.toLowerCase().contains(query) ||
                      user.email.toLowerCase().contains(query) ||
                      user.phone.contains(query),
                )
                .toList();
        _sortUsers();
      });
    });
  }

  void _sortUsers() {
    List<UserModel> listToSort =
        filteredUsers.isNotEmpty
            ? filteredUsers
            : context.read<UserViewModel>().users;

    switch (_sortBy) {
      case 'Name':
        listToSort.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'Email':
        listToSort.sort((a, b) => a.email.compareTo(b.email));
        break;
      case 'Phone':
        listToSort.sort((a, b) => a.phone.compareTo(b.phone));
        break;
    }
  }

  int _calculateCrossAxisCount(double width) {
    if (width >= 900) return 3; // Medium desktop
    if (width >= 600) return 2; // Tablet
    return 1; // Mobile
  }

  double _getResponsiveFontSize(double width, double defaultSize) {
    if (width >= 1200) return defaultSize; // Large desktop
    if (width >= 900) return defaultSize * 0.9; // Medium desktop
    if (width >= 600) return defaultSize * 0.85; // Tablet
    return defaultSize * 0.7; // Mobile / small screens
  }

  void _showUserIdCard(BuildContext context, UserModel user) {
    final size = MediaQuery.of(context).size;

    showDialog(
      context: context,
      builder:
          (_) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(20),
            child: Center(
              child: Container(
                width: size.width < 600 ? size.width * 0.9 : 400,
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Colors.purpleAccent, Colors.deepPurple],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const CircleAvatar(
                        radius: 50,
                        backgroundImage: AssetImage(
                          'assets/images/dummy_user.jpg',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          width: 24,
                          child: Icon(
                            Icons.email,
                            size: 18,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            user.email,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          width: 24,
                          child: Icon(
                            Icons.phone,
                            size: 18,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            user.phone,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          width: 24,
                          child: Icon(
                            Icons.location_on,
                            size: 18,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            user.place,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Role Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color:
                            user.role.toLowerCase() == 'admin'
                                ? Colors.redAccent
                                : Colors.blueAccent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        user.role.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Close Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 24,
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        "Close",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<UserViewModel>();
    final size = MediaQuery.of(context).size;
    final usersToShow =
        filteredUsers.isNotEmpty || _searchController.text.isNotEmpty
            ? filteredUsers
            : vm.users;

    return Scaffold(
      appBar: AppBar(
        title: const Text("All Users"),
        backgroundColor: Colors.grey.shade100,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // Search Field
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by name, email, or phone',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // User Grid
          Expanded(
            child:
                vm.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : usersToShow.isEmpty
                    ? const Center(child: Text('No users found'))
                    : Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: _calculateCrossAxisCount(size.width),
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          mainAxisExtent: 110,
                        ),

                        itemCount: usersToShow.length,
                        itemBuilder: (context, index) {
                          final user = usersToShow[index];
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 6,
                            shadowColor: Colors.grey.withValues(alpha: 0.4),
                            child: Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    children: [
                                      // Profile Image
                                      const CircleAvatar(
                                        radius: 30,
                                        backgroundImage:
                                            AssetImage(
                                                  'assets/images/dummy_user.jpg',
                                                )
                                                as ImageProvider,
                                      ),
                                      const SizedBox(width: 16),

                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Flexible(
                                              child: Text(
                                                user.name,
                                                style: TextStyle(
                                                  fontSize:
                                                      _getResponsiveFontSize(
                                                        size.width,
                                                        16,
                                                      ),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Flexible(
                                              child: Text(
                                                user.email,
                                                style: TextStyle(
                                                  fontSize:
                                                      _getResponsiveFontSize(
                                                        size.width,
                                                        14,
                                                      ),
                                                  color: Colors.grey[700],
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Flexible(
                                              child: Text(
                                                user.phone,
                                                style: TextStyle(
                                                  fontSize:
                                                      _getResponsiveFontSize(
                                                        size.width,
                                                        14,
                                                      ),
                                                  color: Colors.grey[700],
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),

                                      // Role Badge
                                      Flexible(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 6,
                                            horizontal: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                user.role.toLowerCase() ==
                                                        'admin'
                                                    ? Colors.redAccent
                                                    : Colors.blueAccent,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: FittedBox(
                                            child: Text(
                                              user.role.toUpperCase(),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // View Button at Top Right
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.more_horiz,
                                      color: Colors.deepPurple,
                                    ),
                                    tooltip: 'View Details',
                                    onPressed: () {
                                      _showUserIdCard(context, user);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}
