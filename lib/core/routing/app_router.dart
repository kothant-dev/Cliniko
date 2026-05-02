import 'package:cliniko/features/appointments/presentation/screens/calendar_screen.dart';
import 'package:cliniko/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:cliniko/features/dashboard/presentation/screens/transaction_list_screen.dart';
import 'package:cliniko/features/inventory/presentation/screens/inventory_list_screen.dart';
import 'package:cliniko/features/patients/presentation/screens/patient_list_screen.dart';
import 'package:cliniko/features/settings/presentation/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

class AppRouter {
  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/dashboard',
    routes: [
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return AppShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/patients',
            builder: (context, state) => const PatientListScreen(),
          ),
          GoRoute(
            path: '/appointments',
            builder: (context, state) => const CalendarScreen(),
          ),
          GoRoute(
            path: '/inventory',
            builder: (context, state) => const InventoryListScreen(),
          ),
          GoRoute(
            path: '/revenue',
            builder: (context, state) => const TransactionListScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
}

class AppShell extends StatelessWidget {
  const AppShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      body: Row(
        children: [
          if (isDesktop)
            const Sidebar(),
          Expanded(
            child: Column(
              children: [
                const TopBar(),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: isDesktop ? null : const MobileNavBar(),
    );
  }
}

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: const Column(
        children: [
          DrawerHeader(child: Center(child: Text('Cliniko', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)))),
          _SidebarItem(icon: LucideIcons.layoutDashboard, label: 'Dashboard', path: '/dashboard'),
          _SidebarItem(icon: LucideIcons.users, label: 'Patients', path: '/patients'),
          _SidebarItem(icon: LucideIcons.calendar, label: 'Appointments', path: '/appointments'),
          _SidebarItem(icon: LucideIcons.package, label: 'Inventory', path: '/inventory'),
          _SidebarItem(icon: LucideIcons.dollarSign, label: 'Revenue', path: '/revenue'),
          Spacer(),
          _SidebarItem(icon: LucideIcons.settings, label: 'Settings', path: '/settings'),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({required this.icon, required this.label, required this.path});

  final IconData icon;
  final String label;
  final String path;

  @override
  Widget build(BuildContext context) {
    final isSelected = GoRouterState.of(context).uri.path == path;
    return ListTile(
      leading: Icon(icon, color: isSelected ? Theme.of(context).colorScheme.primary : null),
      title: Text(label, style: TextStyle(color: isSelected ? Theme.of(context).colorScheme.primary : null, fontWeight: isSelected ? FontWeight.bold : null)),
      onTap: () => context.go(path),
    );
  }
}

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.1))),
      ),
      child: Row(
        children: [
          Text(
            _getTitle(GoRouterState.of(context).uri.path),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          IconButton(icon: const Icon(LucideIcons.bell), onPressed: () {}),
          const SizedBox(width: 10),
          const CircleAvatar(radius: 15, child: Icon(LucideIcons.user, size: 15)),
        ],
      ),
    );
  }

  String _getTitle(String path) {
    switch (path) {
      case '/dashboard': return 'Dashboard';
      case '/patients': return 'Patients';
      case '/appointments': return 'Appointments';
      case '/inventory': return 'Inventory';
      case '/revenue': return 'Revenue';
      case '/settings': return 'Settings';
      default: return 'Cliniko';
    }
  }
}

class MobileNavBar extends StatelessWidget {
  const MobileNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final currentIndex = _getIndex(GoRouterState.of(context).uri.path);
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) {
        final paths = ['/dashboard', '/patients', '/appointments', '/inventory', '/revenue', '/settings'];
        context.go(paths[index]);
      },
      destinations: const [
        NavigationDestination(icon: Icon(LucideIcons.layoutDashboard), label: 'Dash'),
        NavigationDestination(icon: Icon(LucideIcons.users), label: 'Patients'),
        NavigationDestination(icon: Icon(LucideIcons.calendar), label: 'Appts'),
        NavigationDestination(icon: Icon(LucideIcons.package), label: 'Inv'),
        NavigationDestination(icon: Icon(LucideIcons.dollarSign), label: 'Rev'),
        NavigationDestination(icon: Icon(LucideIcons.settings), label: 'Settings'),
      ],
    );
  }

  int _getIndex(String path) {
    final paths = ['/dashboard', '/patients', '/appointments', '/inventory', '/revenue', '/settings'];
    return paths.indexOf(path).clamp(0, 5);
  }
}
