import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/auth_state.dart';
import '../theme/app_theme.dart';
import 'home/home_screen.dart';
import 'providers/providers_screen.dart';
import 'requests/my_requests_screen.dart';
import 'usta/usta_panel_screen.dart';

/// components/app-shell.tsx dosyasının karşılığı: üstte marka başlığı +
/// çıkış butonu, altta 4 sekmeli navigasyon.
class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  void _goToTab(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              height: 32,
              width: 32,
              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(9)),
              child: const Icon(Icons.handyman_rounded, color: AppColors.primaryForeground, size: 18),
            ),
            const SizedBox(width: 8),
            const Text('Ustam', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          ],
        ),
        actions: [
          if (auth.displayName != null)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Center(
                child: Text(
                  'Merhaba, ${auth.displayName!.split(' ').first}',
                  style: const TextStyle(fontSize: 13, color: AppColors.mutedForeground),
                ),
              ),
            ),
          IconButton(
            tooltip: 'Çıkış yap',
            onPressed: () => context.read<AuthState>().signOut(),
            icon: const Icon(Icons.logout_rounded, size: 20),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: IndexedStack(index: _index, children: [
          HomeScreenWrapper(onNavigateToTab: _goToTab),
          const ProvidersScreen(),
          const MyRequestsScreen(),
          const UstaPanelScreen(),
        ]),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _goToTab,
        backgroundColor: AppColors.background,
        indicatorColor: AppColors.primary.withOpacity(0.12),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Anasayfa'),
          NavigationDestination(icon: Icon(Icons.people_outline_rounded), selectedIcon: Icon(Icons.people_alt_rounded), label: 'Ustalar'),
          NavigationDestination(icon: Icon(Icons.assignment_outlined), selectedIcon: Icon(Icons.assignment_rounded), label: 'Taleplerim'),
          NavigationDestination(icon: Icon(Icons.construction_outlined), selectedIcon: Icon(Icons.construction_rounded), label: 'Usta Paneli'),
        ],
      ),
    );
  }
}

/// Anasayfanın "Ustalara göz at" / kategori linklerinin diğer sekmelere
/// geçebilmesi için ince bir sarmalayıcı.
class HomeScreenWrapper extends StatelessWidget {
  final void Function(int index) onNavigateToTab;
  const HomeScreenWrapper({super.key, required this.onNavigateToTab});

  @override
  Widget build(BuildContext context) {
    return HomeScreen(onGoToProviders: () => onNavigateToTab(1), onGoToRequests: () => onNavigateToTab(2));
  }
}
