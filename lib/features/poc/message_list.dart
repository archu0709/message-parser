import 'package:another_telephony/telephony.dart';
import 'package:flutter/material.dart';

/// Flat list of raw messages for a single sender.
class MessageList extends StatelessWidget {
  const MessageList({
    super.key,
    required this.sender,
    required this.messages,
  });

  final String sender;
  final List<SmsMessage> messages;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$sender  (${messages.length})'),
      ),
      body: ListView.separated(
        itemCount: messages.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final m = messages[i];
          final date = m.date != null
              ? DateTime.fromMillisecondsSinceEpoch(m.date!)
              : null;
          return ListTile(
            title: Text(m.body ?? '(empty)'),
            subtitle: date != null ? Text(_formatDate(date)) : null,
            isThreeLine: true,
          );
        },
      ),
    );
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '${d.day} ${months[d.month - 1]} ${d.year}  ·  $h:$m';
  }
}
