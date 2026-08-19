import 'package:flutter/material.dart';

import '../../core/network/api_client.dart';
import '../../models/transaction.dart';
import '../../models/user.dart';
import '../../models/vehicle.dart';
import '../about/about_screen.dart';
import '../claim/claim_screen.dart';
import '../history/history_screen.dart';
import '../login/login_screen.dart';
import '../vehicle/vehicle_screen.dart';

class HomeScreen extends StatefulWidget {
  final AppUser user;

  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiClient _api = ApiClient();

  int _currentIndex = 0;

  List<UserVehicle> _vehicles = [];

  List<UserTransaction> _transactions = [];

  bool _loading = true;

  String? _error;

  @override
  void initState() {
    super.initState();

    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // Load vehicles first so a history/API problem cannot hide the user's
      // main dashboard data.
      final vehicles = await _api.vehicles();

      List<UserTransaction> transactions = [];
      try {
        transactions = await _api.history();
      } catch (_) {
        // History is secondary; keep the dashboard usable when it fails.
      }

      if (!mounted) return;

      setState(() {
        _vehicles = vehicles;
        _transactions = transactions;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    await _api.logout();

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  String _fuelLabel(String type) {
    switch (type) {
      case 'petrol_92':
        return 'Petrol 92';

      case 'petrol_95':
        return 'Petrol 95';

      case 'diesel':
        return 'Diesel';

      default:
        return type;
    }
  }

  String _formatDate(DateTime? value) {
    if (value == null) {
      return '-';
    }

    final local = value.toLocal();

    final day = local.day.toString().padLeft(2, '0');

    final month = local.month.toString().padLeft(2, '0');

    final hour =
        local.hour == 0
            ? 12
            : local.hour > 12
            ? local.hour - 12
            : local.hour;

    final minute = local.minute.toString().padLeft(2, '0');

    final period = local.hour >= 12 ? 'PM' : 'AM';

    return '$day/$month '
        '$hour:$minute $period';
  }

  Widget _buildHomePage() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Fuel Pass'),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboard,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Hello, ${widget.user.name}',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              widget.user.nationalId,
              style: const TextStyle(color: Colors.black54),
            ),

            const SizedBox(height: 24),

            if (_loading)
              const Padding(
                padding: EdgeInsets.all(50),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(_error!, textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: _loadDashboard,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              _buildVehicleSection(),
              const SizedBox(height: 26),
              _buildRecentTransactions(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'My Vehicles',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            TextButton(
              onPressed: () async {
                final changed = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(builder: (_) => const ClaimScreen()),
                );

                if (changed == true) {
                  await _loadDashboard();
                }
              },
              child: const Text('Register'),
            ),
          ],
        ),
        const SizedBox(height: 10),

        if (_vehicles.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(Icons.directions_car_outlined, size: 56),
                  const SizedBox(height: 10),
                  const Text(
                    'No vehicle registered yet',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () async {
                      final changed = await Navigator.of(context).push<bool>(
                        MaterialPageRoute(builder: (_) => const ClaimScreen()),
                      );

                      if (changed == true) {
                        await _loadDashboard();
                      }
                    },
                    child: const Text('Register Vehicle'),
                  ),
                ],
              ),
            ),
          )
        else
          ..._vehicles.map(
            (vehicle) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.directions_car_filled_outlined),
                ),
                title: Text(
                  vehicle.plateNumber,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Text(
                  '${vehicle.vehicleType} • '
                  '${_fuelLabel(vehicle.fuelType)}\n'
                  'Remaining: '
                  '${vehicle.remaining.toStringAsFixed(2)} L',
                ),
                isThreeLine: true,
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => VehicleScreen(vehicle: vehicle),
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRecentTransactions() {
    final recent = _transactions.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Recent Transactions',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            if (_transactions.isNotEmpty)
              TextButton(
                onPressed: () {
                  setState(() {
                    _currentIndex = 2;
                  });
                },
                child: const Text('View All'),
              ),
          ],
        ),
        const SizedBox(height: 10),

        if (recent.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: const [
                  Icon(Icons.receipt_long_outlined, color: Colors.black45),
                  SizedBox(width: 12),
                  Expanded(child: Text('No fuel transactions yet.')),
                ],
              ),
            ),
          )
        else
          ...recent.map(
            (tx) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.local_gas_station_outlined),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tx.stationName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                tx.plateNumber,
                                style: const TextStyle(color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${tx.amount.toStringAsFixed(0)} MMK',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),

                    const Divider(height: 22),

                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${tx.liters.toStringAsFixed(2)} L • '
                            '${_fuelLabel(tx.fuelType)}',
                          ),
                        ),
                        Text(
                          _formatDate(tx.pumpedAt),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomePage(),
          const AboutScreen(),
          const HistoryScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.info_outline),
            selectedIcon: Icon(Icons.info),
            label: 'About',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'History',
          ),
        ],
      ),
    );
  }
}
