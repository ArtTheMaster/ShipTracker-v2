import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/offline_banner.dart';
import 'customer_home_screen.dart';
import 'order_request_form_screen.dart';
import 'customer_my_orders_screen.dart';
import 'customer_support_screen.dart';
import 'customer_profile_screen.dart';
import '../../chatbot/presentation/chatbot_screen.dart';

class CustomerShell extends ConsumerStatefulWidget {
  const CustomerShell({super.key});

  @override
  ConsumerState<CustomerShell> createState() => _CustomerShellState();
}

class _CustomerShellState extends ConsumerState<CustomerShell> {
  int _currentIndex = 0;

  void _onTabChanged(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      CustomerHomeScreen(
        onNavigateToRequest: () => _onTabChanged(1),
        onNavigateToOrders: () => _onTabChanged(2),
        onNavigateToSupport: () => _onTabChanged(3),
      ),
      OrderRequestFormScreen(
        onOrderSubmitted: () => _onTabChanged(2), 
      ),
      const CustomerMyOrdersScreen(),
      const CustomerSupportScreen(),
      const CustomerProfileScreen(),
    ];

    return Scaffold(
      // FIXED: Added the Offline Banner wrapper above the IndexedStack
      body: Column(
        children: [
          const SafeArea(bottom: false, child: OfflineBanner()),
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: screens,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.smart_toy_rounded, color: Colors.white),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatbotScreen()));
        },
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onTabChanged,
        backgroundColor: Colors.white,
        elevation: 2,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: Colors.indigo),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle, color: Colors.indigo),
            label: 'New Plate',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2, color: Colors.indigo),
            label: 'My Orders',
          ),
          NavigationDestination(
            icon: Icon(Icons.support_agent_outlined),
            selectedIcon: Icon(Icons.support_agent, color: Colors.indigo),
            label: 'Support',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded, color: Colors.indigo),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}