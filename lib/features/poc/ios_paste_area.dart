import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// iOS cannot read the SMS inbox. User pastes messages, the app splits them
/// by blank line into blocks and shows the count + list.
class IosPasteArea extends StatefulWidget {
  const IosPasteArea({super.key});

  @override
  State<IosPasteArea> createState() => _IosPasteAreaState();
}

class _IosPasteAreaState extends State<IosPasteArea> {
  final _controller = TextEditingController();
  List<String> _blocks = [];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _parseBlocks() {
    final text = _controller.text;
    // Split on one or more blank lines (a line containing only whitespace counts).
    final blocks = text
        .split(RegExp(r'\n\s*\n'))
        .map((b) => b.trim())
        .where((b) => b.isNotEmpty)
        .toList();
    setState(() => _blocks = blocks);
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) {
      _controller.text = data!.text!;
      _parseBlocks();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _blocks.isEmpty ? 'Messages' : 'Messages  (${_blocks.length})',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.content_paste),
            onPressed: _pasteFromClipboard,
            tooltip: 'Paste from clipboard',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Theme.of(context).colorScheme.primaryContainer,
            padding: const EdgeInsets.all(12),
            width: double.infinity,
            child: Text(
              'iOS cannot read SMS automatically. Paste messages below, '
              'separated by blank lines. Android reads them directly.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontSize: 13,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _controller,
              maxLines: 6,
              decoration: InputDecoration(
                hintText:
                    'Paste one or more SMS messages here.\n\nSeparate each message with a blank line.',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: _parseBlocks,
                  tooltip: 'Parse',
                ),
              ),
              onChanged: (_) => _parseBlocks(),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _blocks.isEmpty
                ? const Center(
                    child: Text(
                      'No messages yet.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.separated(
                    itemCount: _blocks.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) => ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            Theme.of(context).colorScheme.primaryContainer,
                        child: Text('${i + 1}'),
                      ),
                      title: Text(_blocks[i]),
                      isThreeLine: _blocks[i].length > 60,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
