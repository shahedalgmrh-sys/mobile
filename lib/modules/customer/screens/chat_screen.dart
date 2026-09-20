import 'package:flutter/material.dart';
import '../../../shared/theme/sahel_colors.dart';

class ChatScreen extends StatelessWidget {
  final String threadId;

  const ChatScreen({
    super.key,
    required this.threadId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(child: Text('م')),
          title: Text('محمد الفني', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          subtitle: Text('متصل الآن', style: TextStyle(fontSize: 11, color: SahelColors.green600)),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _bubble('أهلاً بك، تم قبول الحجز و سأكون في الموعد المحدد.', false, '10:02'),
                _bubble('شكراً لك، في أي طريق أنت الآن؟', true, '10:03'),
                _bubble('أنا في شارع حيلة، على بعد 5 دقائق.', false, '10:04'),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: SahelColors.slate200)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(onPressed: () {}, icon: const Icon(Icons.attach_file, color: SahelColors.muted)),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'اكتب رسالتك...',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        filled: true,
                        fillColor: SahelColors.slate50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(999),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: SahelColors.primary600,
                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.send, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bubble(String text, bool me, String time) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8, left: me ? 60 : 0, right: me ? 0 : 60),
      child: Column(
        crossAxisAlignment: me ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: me ? SahelColors.primary600 : SahelColors.slate100,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(14),
                topRight: const Radius.circular(14),
                bottomLeft: Radius.circular(me ? 14 : 4),
                bottomRight: Radius.circular(me ? 4 : 14),
              ),
            ),
            child: Text(text, style: TextStyle(color: me ? Colors.white : SahelColors.text, height: 1.4)),
          ),
          const SizedBox(height: 4),
          Text(time, style: const TextStyle(fontSize: 10, color: SahelColors.muted)),
        ],
      ),
    );
  }
}
