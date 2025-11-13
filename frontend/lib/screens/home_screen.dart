import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../widgets/animation_player.dart';
import '../widgets/llm_response_display.dart';
import '../widgets/prompt_input.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? videoUrl;
  String? responseMessage;
  String? generatedCode;
  int attempts = 0;
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    print('[HOME] HomeScreen initialized');
  }

  Future<void> _handlePromptSubmit(String prompt) async {
    print('[HOME] Prompt submitted: "$prompt"');
    
    setState(() {
      isLoading = true;
      errorMessage = null;
      videoUrl = null;
      responseMessage = 'Generating animation...';
      print('[HOME] State updated: loading = true');
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      print('[HOME] Calling API service...');
      
      final response = await apiService.generateAnimation(prompt);
      
      print('[HOME] ✓ Response received');
      print('[HOME] Status: ${response.status}');
      
      setState(() {
        isLoading = false;
        responseMessage = response.message;
        generatedCode = response.code;
        attempts = response.attempts;
        
        if (response.videoUrl != null) {
          videoUrl = apiService.getVideoUrl(response.videoUrl!);
          print('[HOME] Video URL set: $videoUrl');
        }
        
        print('[HOME] State updated: loading = false, video ready');
      });
      
    } catch (e) {
      print('[HOME] ❌ Error: $e');
      
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
        responseMessage = 'Error: $e';
        print('[HOME] State updated: error occurred');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print('[HOME] Building HomeScreen widget');
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'BlackboardAI',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 2,
      ),
      body: Column(
        children: [
          // TOP: Animation Player (40% height)
          Expanded(
            flex: 4,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black87,
                border: Border(
                  bottom: BorderSide(color: Colors.grey[300]!, width: 2),
                ),
              ),
              child: AnimationPlayer(
                videoUrl: videoUrl,
                isLoading: isLoading,
              ),
            ),
          ),
          
          // MIDDLE: LLM Response Display (40% height)
          Expanded(
            flex: 4,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Colors.grey[300]!, width: 2),
                ),
              ),
              child: LlmResponseDisplay(
                message: responseMessage,
                code: generatedCode,
                attempts: attempts,
                isLoading: isLoading,
                error: errorMessage,
              ),
            ),
          ),
          
          // BOTTOM: Prompt Input (20% height)
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              color: Colors.grey[100],
              child: PromptInput(
                onSubmit: _handlePromptSubmit,
                isLoading: isLoading,
              ),
            ),
          ),
        ],
      ),
    );
  }
}