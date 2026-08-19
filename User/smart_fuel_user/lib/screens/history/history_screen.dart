import 'package:flutter/material.dart';

import '../../core/network/api_client.dart';
import '../../models/transaction.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final ApiClient _api = ApiClient();

  List<UserTransaction> _items = [];

  bool _loading = true;

  String? _error;

  @override
  void initState() {
    super.initState();

    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final items = await _api.history();

      if (!mounted) return;

      setState(() {
        _items = items;
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

  String _formatDate(DateTime? value) {
    if (value == null) {
      return '-';
    }

    final local = value.toLocal();

    final day = local.day.toString().padLeft(2, '0');

    final month = local.month.toString().padLeft(2, '0');

    final year = local.year;

    final hour =
        local.hour == 0
            ? 12
            : local.hour > 12
            ? local.hour - 12
            : local.hour;

    final minute = local.minute.toString().padLeft(2, '0');

    final period = local.hour >= 12 ? 'PM' : 'AM';

    return '$day/$month/$year  '
        '$hour:$minute $period';
  }

  String _fuelLabel(String fuelType) {
    switch (fuelType) {
      case 'petrol_92':
        return 'Petrol 92';

      case 'petrol_95':
        return 'Petrol 95';

      case 'diesel':
        return 'Diesel';

      default:
        return fuelType;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fuel History')),
      body: RefreshIndicator(
        onRefresh: _load,
        child:
            _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? ListView(
                  children: [
                    const SizedBox(height: 120),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(_error!, textAlign: TextAlign.center),
                      ),
                    ),
                  ],
                )
                : _items.isEmpty
                ? ListView(
                  children: const [
                    SizedBox(height: 140),
                    Center(
                      child: Column(
                        children: [
                          Icon(Icons.history, size: 64, color: Colors.black26),
                          SizedBox(height: 12),
                          Text('No fueling history yet.'),
                        ],
                      ),
                    ),
                  ],
                )
                : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, index) {
                    final tx = _items[index];

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 46,
                                  height: 46,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary.withOpacity(0.10),
                                  ),
                                  child: Icon(
                                    Icons.local_gas_station_outlined,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        tx.stationName,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        tx.plateNumber,
                                        style: const TextStyle(
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${tx.amount.toStringAsFixed(0)} MMK',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),

                            const Divider(height: 24),

                            Row(
                              children: [
                                Expanded(
                                  child: _InfoItem(
                                    icon: Icons.local_gas_station_outlined,
                                    label: 'Fuel',
                                    value: _fuelLabel(tx.fuelType),
                                  ),
                                ),
                                Expanded(
                                  child: _InfoItem(
                                    icon: Icons.water_drop_outlined,
                                    label: 'Quantity',
                                    value: '${tx.liters.toStringAsFixed(2)} L',
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            Row(
                              children: [
                                Expanded(
                                  child: _InfoItem(
                                    icon: Icons.schedule_outlined,
                                    label: 'Date & Time',
                                    value: _formatDate(tx.pumpedAt),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                _StatusChip(status: tx.status),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.black45),
        const SizedBox(width: 7),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.black45),
              ),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();

    final success =
        normalized == 'online' ||
        normalized == 'success' ||
        normalized == 'completed';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color:
            success
                ? Colors.green.withOpacity(0.10)
                : Colors.orange.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        success ? 'Completed' : status,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: success ? Colors.green.shade700 : Colors.orange.shade700,
        ),
      ),
    );
  }
}
