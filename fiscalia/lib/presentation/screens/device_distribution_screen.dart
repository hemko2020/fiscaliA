import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/device_distribution_model.dart';
import '../providers/device_distribution_provider.dart';

class DeviceDistributionScreen extends ConsumerStatefulWidget {
  const DeviceDistributionScreen({super.key});

  @override
  ConsumerState<DeviceDistributionScreen> createState() =>
      _DeviceDistributionScreenState();
}

class _DeviceDistributionScreenState
    extends ConsumerState<DeviceDistributionScreen> {
  bool _showTimeSeries = false;

  @override
  Widget build(BuildContext context) {
    final devices = ref.watch(deviceDistributionProvider);
    final service = ref.watch(deviceDistributionServiceProvider);

    if (devices.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Répartition des dispositifs'),
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.pie_chart,
                size: 80,
                color: AppColors.primaryBlue.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 20),
              Text(
                'Aucun dispositif enregistré',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: AppColors.primaryBlue),
              ),
              const SizedBox(height: 10),
              Text(
                'Ajoutez des dispositifs pour voir leur répartition',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    final summaries = service.calculateDistributionSummary(devices);
    final details = service.calculateFullDistributionDetails(devices);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Répartition des dispositifs'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_showTimeSeries ? Icons.pie_chart : Icons.show_chart),
            onPressed: () {
              setState(() {
                _showTimeSeries = !_showTimeSeries;
              });
            },
            tooltip: _showTimeSeries ? 'Voir camembert' : 'Voir évolution',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCard(context, details),
            const SizedBox(height: 20),
            if (_showTimeSeries)
              _buildTimeSeriesCard(context, devices, service)
            else
              _buildDistributionCard(context, summaries, service),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, Map<String, dynamic> details) {
    return Card(
      color: AppColors.primaryBlue.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: AppColors.primaryBlue),
                const SizedBox(width: 12),
                Text(
                  'Vue d\'ensemble',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    label: 'Total',
                    value:
                        '${(details['totalAmount'] as double).toStringAsFixed(0)} €',
                    icon: Icons.euro,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    label: 'Dispositifs',
                    value: '${details['deviceCount'] as int}',
                    icon: Icons.devices,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    label: 'Catégories',
                    value: '${details['categoryCount'] as int}',
                    icon: Icons.category,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatItem(
              context,
              label: 'Moyenne par dispositif',
              value:
                  '${((details['averageAmount'] as double).toStringAsFixed(0))} €',
              icon: Icons.trending_up,
              isFullWidth: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    bool isFullWidth = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: AppColors.primaryBlue),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlue,
            ),
          ),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildDistributionCard(
    BuildContext context,
    List<DeviceDistributionSummary> summaries,
    DeviceDistributionService service,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.pie_chart, color: AppColors.accentGreen),
                const SizedBox(width: 12),
                Text(
                  'Répartition par catégorie',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.accentGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildPieChart(context, summaries),
            const SizedBox(height: 20),
            _buildCategoryList(context, summaries, service),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart(
    BuildContext context,
    List<DeviceDistributionSummary> summaries,
  ) {
    if (summaries.isEmpty) {
      return const SizedBox.shrink();
    }

    final colors = [
      AppColors.primaryBlue,
      AppColors.accentGreen,
      AppColors.accentOrange,
      AppColors.taxBracket30,
      AppColors.taxBracket11,
    ];

    return SizedBox(
      height: 250,
      child: Stack(
        children: [
          Center(
            child: SizedBox(
              width: 200,
              height: 200,
              child: CustomPaint(
                painter: PieChartPainter(summaries: summaries, colors: colors),
              ),
            ),
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${summaries.length}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  Text(
                    'catégories',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList(
    BuildContext context,
    List<DeviceDistributionSummary> summaries,
    DeviceDistributionService service,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.accentGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.lightbulb, color: AppColors.accentGreen, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  service.getDistributionInsight(summaries),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.accentGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(summaries.length, (i) {
          final summary = summaries[i];
          final colors = [
            AppColors.primaryBlue,
            AppColors.accentGreen,
            AppColors.accentOrange,
            AppColors.taxBracket30,
            AppColors.taxBracket11,
          ];
          final color = colors[i % colors.length];

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.2),
                child: Icon(Icons.category, color: color),
              ),
              title: Text(
                service.getCategoryDisplayName(summary.category),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('${summary.deviceCount} dispositifs'),
              trailing: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${summary.totalAmount.toStringAsFixed(0)} €',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '${summary.percentage.toStringAsFixed(1)}%',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTimeSeriesCard(
    BuildContext context,
    List<DeviceDistributionModel> devices,
    DeviceDistributionService service,
  ) {
    final timeSeries = service.getDeviceTimeSeries(devices);

    if (timeSeries.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.show_chart, color: AppColors.accentOrange),
                const SizedBox(width: 12),
                Text(
                  'Évolution dans le temps',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.accentOrange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 300,
              child: CustomPaint(
                painter: TimeSeriesPainter(timeSeries: timeSeries),
              ),
            ),
            const SizedBox(height: 20),
            _buildTimeSeriesList(context, timeSeries),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSeriesList(
    BuildContext context,
    List<Map<String, dynamic>> timeSeries,
  ) {
    return Column(
      children: timeSeries.take(10).map((entry) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Icon(Icons.calendar_today, color: AppColors.accentOrange),
            title: Text(entry['deviceName'] as String),
            subtitle: Text(
              '${(entry['date'] as DateTime).day}/${(entry['date'] as DateTime).month}/${(entry['date'] as DateTime).year}',
            ),
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${(entry['amount'] as double).toStringAsFixed(0)} €',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.accentOrange,
                  ),
                ),
                Text(
                  'Cumul: ${(entry['cumulativeTotal'] as double).toStringAsFixed(0)} €',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class PieChartPainter extends CustomPainter {
  final List<DeviceDistributionSummary> summaries;
  final List<Color> colors;

  PieChartPainter({required this.summaries, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    if (summaries.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    final total = summaries.fold<double>(0, (sum, s) => s.totalAmount);

    double startAngle = -math.pi / 2;

    for (int i = 0; i < summaries.length; i++) {
      final summary = summaries[i];
      final sweepAngle = (summary.totalAmount / total) * 2 * math.pi;
      final color = colors[i % colors.length];

      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(PieChartPainter oldDelegate) {
    return oldDelegate.summaries != summaries;
  }
}

class TimeSeriesPainter extends CustomPainter {
  final List<Map<String, dynamic>> timeSeries;

  TimeSeriesPainter({required this.timeSeries});

  @override
  void paint(Canvas canvas, Size size) {
    if (timeSeries.isEmpty) return;

    final padding = 40.0;
    final chartWidth = size.width - padding * 2;
    final chartHeight = size.height - padding * 2;

    final maxAmount = timeSeries
        .map((e) => e['cumulativeTotal'] as double)
        .reduce((a, b) => a > b ? a : b);

    final path = Path();
    final paint = Paint()
      ..color = AppColors.accentOrange
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < timeSeries.length; i++) {
      final entry = timeSeries[i];
      final x = padding + (i / (timeSeries.length - 1)) * chartWidth;
      final y =
          padding +
          chartHeight -
          ((entry['cumulativeTotal'] as double) / maxAmount) * chartHeight;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }

      final dotPaint = Paint()
        ..color = AppColors.accentOrange
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), 4, dotPaint);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(TimeSeriesPainter oldDelegate) {
    return oldDelegate.timeSeries != timeSeries;
  }
}
