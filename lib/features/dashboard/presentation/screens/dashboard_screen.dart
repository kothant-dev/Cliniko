import 'package:cliniko/core/theme/app_theme.dart';
import 'package:cliniko/core/widgets/glass_card.dart';
import 'package:cliniko/features/appointments/presentation/screens/calendar_screen.dart';
import 'package:cliniko/features/inventory/presentation/screens/inventory_list_screen.dart';
import 'package:cliniko/features/patients/presentation/screens/patient_list_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patientCountAsync = ref.watch(patientCountProvider);
    final appointmentCountAsync = ref.watch(appointmentCountProvider);
    final lowStockCountAsync = ref.watch(lowStockCountProvider);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.space24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Clinic Overview',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ).animate().fade(duration: 400.ms).slideX(begin: -0.1),
            const SizedBox(height: AppTheme.space24),
            
            // KPI Row
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth > 1200 ? 4 : (constraints.maxWidth > 800 ? 2 : 1);
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: AppTheme.space16,
                  mainAxisSpacing: AppTheme.space16,
                  childAspectRatio: 2.5,
                  children: [
                    _KPICard(
                      title: 'Total Patients',
                      value: patientCountAsync.when(data: (d) => d.toString(), loading: () => '...', error: (_, __) => '0'),
                      icon: LucideIcons.users,
                      color: Colors.blue,
                    ),
                    _KPICard(
                      title: 'Appointments',
                      value: appointmentCountAsync.when(data: (d) => d.toString(), loading: () => '...', error: (_, __) => '0'),
                      icon: LucideIcons.calendar,
                      color: Colors.purple,
                    ),
                    _KPICard(
                      title: 'Low Stock',
                      value: lowStockCountAsync.when(data: (d) => d.toString(), loading: () => '...', error: (_, __) => '0'),
                      icon: LucideIcons.package,
                      color: Colors.orange,
                    ),
                    const _KPICard(
                      title: 'Revenue (MTD)',
                      value: '\$1,240', // Placeholder for now
                      icon: LucideIcons.dollarSign,
                      color: Colors.green,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: AppTheme.space32),

            // Charts Section
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: _buildRevenueChart(context),
                ),
                const SizedBox(width: AppTheme.space24),
                Expanded(
                  child: _buildRecentActivity(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueChart(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppTheme.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Revenue Trends', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: AppTheme.space32),
          SizedBox(
            height: 300,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 3),
                      FlSpot(2.6, 2),
                      FlSpot(4.9, 5),
                      FlSpot(6.8, 3.1),
                      FlSpot(8, 4),
                      FlSpot(9.5, 3),
                      FlSpot(11, 4),
                    ],
                    isCurved: true,
                    color: Theme.of(context).colorScheme.primary,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fade(delay: 200.ms).slideY(begin: 0.1);
  }

  Widget _buildRecentActivity(BuildContext context) {
    return const GlassCard(
      padding: EdgeInsets.all(AppTheme.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recent Activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: AppTheme.space16),
          _ActivityItem(icon: LucideIcons.userPlus, title: 'New Patient', subtitle: 'John Doe added', time: '2h ago'),
          _ActivityItem(icon: LucideIcons.calendarCheck, title: 'Appointment', subtitle: 'Jane Smith confirmed', time: '4h ago'),
          _ActivityItem(icon: LucideIcons.packageCheck, title: 'Stock Update', subtitle: 'Paracetamol restocked', time: '5h ago'),
          _ActivityItem(icon: LucideIcons.dollarSign, title: 'Payment', subtitle: 'Invoiced \$120.00', time: '1d ago'),
        ],
      ),
    ).animate().fade(delay: 400.ms).slideX(begin: 0.1);
  }
}

class _KPICard extends StatelessWidget {
  const _KPICard({required this.title, required this.value, required this.icon, required this.color});

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.space8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: AppTheme.space16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: TextStyle(color: Theme.of(context).disabledColor, fontSize: 12)),
                Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  const _ActivityItem({required this.icon, required this.title, required this.subtitle, required this.time});

  final IconData icon;
  final String title;
  final String subtitle;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.space16),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Theme.of(context).disabledColor),
          const SizedBox(width: AppTheme.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                Text(subtitle, style: TextStyle(color: Theme.of(context).disabledColor, fontSize: 11)),
              ],
            ),
          ),
          Text(time, style: TextStyle(color: Theme.of(context).disabledColor, fontSize: 10)),
        ],
      ),
    );
  }
}
