import 'package:flutter/material.dart';

class PromptInput extends StatefulWidget {
  final Function(String) onSubmit;
  final bool isLoading;

  const PromptInput({
    super.key,
    required this.onSubmit,
    required this.isLoading,
  });

  @override
  State<PromptInput> createState() => _PromptInputState();
}

class _PromptInputState extends State<PromptInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    print('[INPUT] PromptInput initialized');
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final text = _controller.text.trim();
    print('[INPUT] Submit button pressed');
    print('[INPUT] Text: "$text"');
    
    if (text.isEmpty) {
      print('[INPUT] ❌ Empty prompt, ignoring');
      return;
    }

    if (widget.isLoading) {
      print('[INPUT] ❌ Already loading, ignoring');
      return;
    }

    print('[INPUT] ✓ Submitting prompt');
    widget.onSubmit(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    print('[INPUT] Building PromptInput widget');
    
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Text input field
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              enabled: !widget.isLoading,
              decoration: InputDecoration(
                hintText: 'Describe the animation you want (e.g., "Draw a circle and square")',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                prefixIcon: Icon(
                  Icons.create,
                  color: Colors.grey[600],
                ),
              ),
              style: const TextStyle(fontSize: 16),
              maxLines: 1,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _handleSubmit(),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Submit button
          SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: widget.isLoading ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: widget.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      children: const [
                        Icon(Icons.send, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Generate',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
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
}