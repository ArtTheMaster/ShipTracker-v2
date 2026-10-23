import 'package:flutter/material.dart';

class SyncBadge extends StatelessWidget {
  final bool hasPendingWrites;

  const SyncBadge({super.key, required this.hasPendingWrites});

  @override
  Widget build(BuildContext context) {
    if (hasPendingWrites) {
      return const Tooltip(
        message: 'Saved locally. Waiting for internet to sync.',
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_upload_outlined, color: Colors.orange, size: 14),
            SizedBox(width: 4),
            Text('Pending Sync', style: TextStyle(fontSize: 10, color: Colors.orange, fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }
    
    return const Tooltip(
      message: 'Synced to Cloud',
      child: Icon(Icons.cloud_done_outlined, color: Colors.green, size: 16),
    );
  }
}