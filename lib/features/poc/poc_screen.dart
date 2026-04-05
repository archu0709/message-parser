import 'dart:io' show Platform;

import 'package:another_telephony/telephony.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'ios_paste_area.dart';
import 'message_list.dart';
import 'sender_list.dart';

/// Root POC screen. Branches on platform:
/// - Android: reads the real SMS inbox and groups messages by sender.
/// - iOS: shows a paste area because the SMS inbox is not accessible.
class PocScreen extends StatefulWidget {
  const PocScreen({super.key});

  @override
  State<PocScreen> createState() => _PocScreenState();
}

class _PocScreenState extends State<PocScreen> {
  /// Map of sender address -> list of raw message bodies (newest first).
  Map<String, List<SmsMessage>> _bySender = {};
  bool _loading = false;
  PermissionStatus? _permissionStatus;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      _loadAndroidMessages();
    }
  }

  Future<void> _loadAndroidMessages() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final status = await Permission.sms.request();
      _permissionStatus = status;

      if (!status.isGranted) {
        setState(() => _loading = false);
        return;
      }

      final telephony = Telephony.instance;
      final messages = await telephony.getInboxSms(
        columns: [
          SmsColumn.ADDRESS,
          SmsColumn.BODY,
          SmsColumn.DATE,
        ],
        sortOrder: [
          OrderBy(SmsColumn.DATE, sort: Sort.DESC),
        ],
      );

      final grouped = <String, List<SmsMessage>>{};
      for (final m in messages) {
        final sender = (m.address ?? 'Unknown').trim();
        grouped.putIfAbsent(sender, () => []).add(m);
      }

      setState(() {
        _bySender = grouped;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to read SMS inbox: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return const IosPasteArea();
    }
    return _buildAndroidScaffold();
  }

  Widget _buildAndroidScaffold() {
    final totalMessages =
        _bySender.values.fold<int>(0, (sum, list) => sum + list.length);
    final senderCount = _bySender.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(_loading
            ? 'Messages'
            : 'Messages  ($totalMessages  ·  $senderCount senders)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _loadAndroidMessages,
            tooltip: 'Reload',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return _ErrorState(message: _errorMessage!, onRetry: _loadAndroidMessages);
    }
    if (_permissionStatus != null && !_permissionStatus!.isGranted) {
      return _PermissionRequired(
        status: _permissionStatus!,
        onRetry: _loadAndroidMessages,
      );
    }
    if (_bySender.isEmpty) {
      return const Center(
        child: Text('No SMS messages found in inbox.'),
      );
    }
    return SenderList(
      grouped: _bySender,
      onTap: (sender, messages) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => MessageList(sender: sender, messages: messages),
          ),
        );
      },
    );
  }
}

class _PermissionRequired extends StatelessWidget {
  const _PermissionRequired({required this.status, required this.onRetry});

  final PermissionStatus status;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final isPermanent = status.isPermanentlyDenied;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.sms_failed, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'SMS permission required',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              isPermanent
                  ? 'Permission was permanently denied. Open system settings to grant it.'
                  : 'We need READ_SMS to list your inbox. No data leaves your device.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: isPermanent ? openAppSettings : onRetry,
              child: Text(isPermanent ? 'Open Settings' : 'Grant Permission'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
