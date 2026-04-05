import 'package:another_telephony/telephony.dart';
import 'package:flutter/material.dart';

/// Grouped list of senders with per-sender message count.
/// Sorted by message count descending — heaviest senders (usually banks) first.
class SenderList extends StatelessWidget {
  const SenderList({
    super.key,
    required this.grouped,
    required this.onTap,
  });

  final Map<String, List<SmsMessage>> grouped;
  final void Function(String sender, List<SmsMessage> messages) onTap;

  @override
  Widget build(BuildContext context) {
    final entries = grouped.entries.toList()
      ..sort((a, b) => b.value.length.compareTo(a.value.length));

    return ListView.separated(
      itemCount: entries.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final e = entries[i];
        final count = e.value.length;
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Text(
              e.key.isNotEmpty ? e.key[0].toUpperCase() : '?',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(e.key, style: const TextStyle(fontWeight: FontWeight.w500)),
          subtitle: Text('$count message${count == 1 ? '' : 's'}'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => onTap(e.key, e.value),
        );
      },
    );
  }
}
