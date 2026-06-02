import 'package:flutter/material.dart';

class AiAnalyticsScreen extends StatefulWidget {
  const AiAnalyticsScreen({super.key});

  @override
  State<AiAnalyticsScreen> createState() => _AiAnalyticsScreenState();
}

class _AiAnalyticsScreenState extends State<AiAnalyticsScreen> {
  final _promptController = TextEditingController();
  bool _isLoading = false;
  String? _aiResponse;

  final List<String> _suggestions = [
    "Show low stock products",
    "Give me my top customers",
    "Summarize today's sales",
    "What products should I restock?"
  ];

  void _askAi(String question) async {
    setState(() {
      _promptController.text = question;
      _isLoading = true;
      _aiResponse = null;
    });

    // Simulate API call to Gemini Service
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
      _aiResponse = "**Analysis Result:**\n\nBased on your current inventory and sales data:\n\n1. You have 3 items running low on stock.\n2. Your top customer today is 'Walk-in Customer'.\n3. Total sales have increased by 15% compared to yesterday.\n\n*Suggestion:* Consider restocking 'Apple iPhone' immediately.";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('AI Analytics', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Ask anything about your inventory & sales',
              style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _suggestions.map((s) => ActionChip(
                label: Text(s),
                backgroundColor: Colors.blue.shade50,
                onPressed: () => _askAi(s),
              )).toList(),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _promptController,
                    decoration: InputDecoration(
                      hintText: 'Type your question...',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.blue.shade700,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _isLoading ? null : () {
                      if (_promptController.text.isNotEmpty) {
                        _askAi(_promptController.text);
                      }
                    },
                  ),
                )
              ],
            ),
            const SizedBox(height: 32),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_aiResponse != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue.shade100),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.auto_awesome, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        const Text('AI Insight', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Divider(height: 24),
                    Text(
                      _aiResponse!,
                      style: const TextStyle(fontSize: 16, height: 1.5),
                    ),
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }
}
