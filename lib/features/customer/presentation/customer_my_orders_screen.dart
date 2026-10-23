import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'customer_portal_providers.dart'; // Imports the secure, shared stream

class CustomerMyOrdersScreen extends ConsumerStatefulWidget {
  const CustomerMyOrdersScreen({super.key});

  @override
  ConsumerState<CustomerMyOrdersScreen> createState() => _CustomerMyOrdersScreenState();
}

class _CustomerMyOrdersScreenState extends ConsumerState<CustomerMyOrdersScreen> {
  String _selectedFilter = 'All';

  final List<String> _filters = ['All', 'pending', 'in_production', 'dispatched', 'delivered'];

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(customerOrdersStreamProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text('My Custom Plate Orders', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters.map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: isSelected,
                      label: Text(
                        filter == 'All' ? 'All Orders' : filter.replaceAll('_', ' ').toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : const Color(0xFF334155),
                        ),
                      ),
                      selectedColor: Colors.indigo,
                      backgroundColor: const Color(0xFFF1F5F9),
                      onSelected: (selected) {
                        setState(() => _selectedFilter = filter);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            child: ordersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: Text('Error loading orders: $err', style: const TextStyle(color: Colors.red)),
              ),
              data: (orders) {
                final filtered = orders.where((order) {
                  if (_selectedFilter == 'All') return true;
                  final status = (order['status'] as String?)?.toLowerCase() ?? '';
                  return status == _selectedFilter.toLowerCase();
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        const Text(
                          'No orders match this filter',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return _buildOrderCard(filtered[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final status = (order['status'] as String?) ?? 'PENDING';
    final statusColor = _getStatusColor(status);
    final finalAmount = order['finalAmount'];
    final tracking = (order['trackingNumber'] as String?) ?? '';

    return InkWell(
      onTap: () => _showOrderDetailSheet(order),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFF94A3B8), width: 1.5),
                  ),
                  child: Text(
                    order['plateNumber'] ?? 'N/A',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status.replaceAll('_', ' ').toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              order['plateStyle'] ?? 'Custom Plate',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF64748B)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    order['deliveryAddress'] ?? 'No Address',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order Date: ${_formatDate(order['createdAt'] as Timestamp?)}',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                ),
                if (tracking.isNotEmpty)
                  Text(
                    'Track: $tracking',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.indigo),
                  )
                else
                  Text(
                    finalAmount != null ? '₱${finalAmount.toStringAsFixed(2)}' : 'Pending Quote',
                    style: TextStyle(
                      fontWeight: FontWeight.bold, 
                      color: finalAmount != null ? const Color(0xFF0F172A) : Colors.orange
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showOrderDetailSheet(Map<String, dynamic> order) {
    final tracking = (order['trackingNumber'] as String?) ?? '';
    final notes = (order['specialNotes'] as String?) ?? '';
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Order Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const Divider(),
              _buildDetailRow('Plate Text:', order['plateNumber'] ?? 'N/A'),
              _buildDetailRow('Style:', order['plateStyle'] ?? 'N/A'),
              _buildDetailRow('Specs:', '${order['region'] ?? ''} - ${order['brandMake'] ?? ''}'),
              _buildDetailRow('Status:', (order['status'] as String?)?.toUpperCase() ?? 'PENDING'),
              _buildDetailRow('Recipient:', order['customerName'] ?? 'N/A'),
              _buildDetailRow('Phone:', order['contactNumber'] ?? 'N/A'),
              _buildDetailRow('Delivery Address:', order['deliveryAddress'] ?? 'N/A'),
              if (tracking.isNotEmpty)
                _buildDetailRow('Dispatch Tracking:', tracking),
              if (notes.isNotEmpty)
                _buildDetailRow('Special Notes:', notes),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF64748B))),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B))),
          ),
        ],
      ),
    );
  }

  String _formatDate(Timestamp? dt) {
    if (dt == null) return 'Unknown Date';
    final date = dt.toDate();
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'approved':
      case 'in_production':
        return Colors.blue;
      case 'dispatched':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}