import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/app_constants.dart';
import '../domain/forecast_models.dart';
import 'forecasting_provider.dart';

class ForecastingScreen extends ConsumerStatefulWidget {
  const ForecastingScreen({super.key});

  @override
  ConsumerState<ForecastingScreen> createState() => _ForecastingScreenState();
}

class _ForecastingScreenState extends ConsumerState<ForecastingScreen> {
  bool _isGeneratingSimulation = false;

  Future<void> _inject14MonthData() async {
    setState(() => _isGeneratingSimulation = true);
    final scaffold = ScaffoldMessenger.of(context);

    try {
      final batch = FirebaseFirestore.instance.batch();
      final now = DateTime.now();
      final random = Random();
      final platforms = [
        AppConstants.platformShopee,
        AppConstants.platformLazada,
        'TikTok',
        'Direct',
      ];
      final couriers = ['J&T Express', 'SPX Express', 'Flash Express'];

      int idCounter = 1;
      for (int m = 13; m >= 0; m--) {
        final monthDate = DateTime(now.year, now.month - m, 1);
        final count = 5 + random.nextInt(3);
        final growthFactor = 1.0 + ((13 - m) * 0.05);

        for (int p = 0; p < count; p++) {
          final day = min(28, (p * 5) + 2);
          final date = DateTime(monthDate.year, monthDate.month, day, 10, 30);
          final id = 'SMPL-${monthDate.year}${monthDate.month.toString().padLeft(2, '0')}-$idCounter';
          final baseAmt = (random.nextInt(20) + 12) * 100.0;
          final amount = double.parse((baseAmt * growthFactor).toStringAsFixed(2));

          final ref = FirebaseFirestore.instance.collection(AppConstants.collectionParcels).doc(id);
          batch.set(ref, {
            'trackingNumber': id,
            'platform': platforms[p % platforms.length],
            'courier': couriers[random.nextInt(couriers.length)],
            'customerName': 'Store Client $idCounter',
            'amount': amount,
            'totalPrice': amount,
            'status': AppConstants.statusDelivered,
            'isSample': true,
            'createdAt': Timestamp.fromDate(date),
            'dispatchedAt': Timestamp.fromDate(date),
            'dateShipped': Timestamp.fromDate(date),
          });
          idCounter++;
        }
      }

      await batch.commit();
      ref.invalidate(historicalSalesProvider);

      if (mounted) {
        scaffold.showSnackBar(
          const SnackBar(
            content: Text('Injected 14 months of historical shipments! All forecast horizons unlocked.'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        scaffold.showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isGeneratingSimulation = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedHorizon = ref.watch(selectedHorizonProvider);
    final selectedPlatform = ref.watch(selectedPlatformProvider);
    final forecastResult = ref.watch(forecastResultProvider);
    final historyAsync = ref.watch(historicalSalesProvider);
    final currencyFmt = NumberFormat.currency(locale: 'en_PH', symbol: '₱', decimalDigits: 2);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Predictive Sales Forecasting',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        actions: [
          IconButton(
            tooltip: 'Refresh Data',
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(historicalSalesProvider),
          ),
        ],
      ),
      body: historyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (_) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Horizon & Channel Selectors
                _buildFilterCard(selectedHorizon, selectedPlatform),
                const SizedBox(height: 14),

                // 2. Either Render Insufficient Warning OR Full Forecast
                if (!forecastResult.hasSufficientData) ...[
                  _buildInsufficientDataCard(forecastResult, selectedHorizon),
                ] else ...[
                  _buildTotalProjections(forecastResult, selectedHorizon, currencyFmt),
                  const SizedBox(height: 16),
                  _buildMonthlyBreakdown(forecastResult, currencyFmt),
                  const SizedBox(height: 16),
                  _buildInsightCard(forecastResult),
                ],
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterCard(ForecastHorizon activeHorizon, String activePlatform) {
    const platforms = ['All', 'Shopee', 'Lazada', 'TikTok'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Forecast Horizon',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
          ),
          const SizedBox(height: 10),
          Row(
            children: ForecastHorizon.values.map((horizon) {
              final isSelected = horizon == activeHorizon;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: InkWell(
                    onTap: () => ref.read(selectedHorizonProvider.notifier).state = horizon,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isSelected) ...[
                            const Icon(Icons.check, size: 12, color: Colors.white),
                            const SizedBox(width: 3),
                          ],
                          Text(
                            horizon.label,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          const Text(
            'Sales Channel',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
          ),
          const SizedBox(height: 10),
          Row(
            children: platforms.map((plat) {
              final isSelected = plat == activePlatform;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: InkWell(
                    onTap: () => ref.read(selectedPlatformProvider.notifier).state = plat,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isSelected) ...[
                            const Icon(Icons.check, size: 12, color: Colors.white),
                            const SizedBox(width: 3),
                          ],
                          Text(
                            plat,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInsufficientDataCard(ForecastResult result, ForecastHorizon currentHorizon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: Color(0xFFD97706), size: 22),
              const SizedBox(width: 8),
              const Text(
                'Insufficient Historical Shipments',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFFB45309)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            result.insightSummary,
            style: const TextStyle(fontSize: 13, color: Color(0xFF78350F), height: 1.4),
          ),
          const SizedBox(height: 16),
          if (currentHorizon != ForecastHorizon.oneMonth)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEA580C),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  ref.read(selectedHorizonProvider.notifier).state = ForecastHorizon.oneMonth;
                },
                icon: const Icon(Icons.tune_rounded, size: 18),
                label: const Text('Switch to 1-Month Forecast', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF2563EB),
                side: const BorderSide(color: Color(0xFF2563EB)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: _isGeneratingSimulation ? null : _inject14MonthData,
              icon: _isGeneratingSimulation
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_graph_rounded, size: 18),
              label: const Text('Simulate 14-Month History (Instant Fix)', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalProjections(
    ForecastResult result,
    ForecastHorizon horizon,
    NumberFormat currencyFmt,
  ) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.trending_up_rounded, size: 16, color: Color(0xFF2563EB)),
                    ),
                    const SizedBox(width: 8),
                    const Text('Projected Sales', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  currencyFmt.format(result.totalProjectedRevenue),
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${horizon.fullTitle} Total',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.local_shipping_outlined, size: 16, color: Color(0xFF10B981)),
                    ),
                    const SizedBox(width: 8),
                    const Text('Est. Volume', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '${NumberFormat('#,##0').format(result.totalProjectedParcels)} pkgs',
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${result.growthRatePercent >= 0 ? '+' : ''}${result.growthRatePercent.toStringAsFixed(1)}% trajectory',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: result.growthRatePercent >= 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyBreakdown(ForecastResult result, NumberFormat currencyFmt) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Monthly Projections',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  result.confidence.title,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...result.forecastPoints.map((pt) {
            final monthName = DateFormat('MMMM yyyy').format(DateTime(pt.year, pt.month));
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFF1F5F9)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        monthName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B)),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Estimated: ${pt.projectedParcels} dispatched orders',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                  Text(
                    currencyFmt.format(pt.projectedRevenue),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF2563EB)),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildInsightCard(ForecastResult result) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_outline_rounded, color: Color(0xFF2563EB), size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Operational Forecast Strategy',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
                ),
                const SizedBox(height: 4),
                Text(
                  result.insightSummary,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF1E40AF), height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}