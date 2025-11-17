import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Change this to your backend URL
  final String baseUrl = 'http://localhost:8000';
  
  ApiService() {
    print('[API] ApiService initialized with baseUrl: $baseUrl');
  }

  /// Generate animation from user prompt
  Future<AnimationResponse> generateAnimation(String prompt) async {
    print('[API] Sending generate request...');
    print('[API] Prompt: "$prompt"');
    
    final url = Uri.parse('$baseUrl/generate');
    print('[API] URL: $url');
    
    try {
      print('[API] Making POST request...');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'prompt': prompt,
        }),
      );
      
      print('[API] Response status: ${response.statusCode}');
      print('[API] Response body length: ${response.body.length} chars');
      
      if (response.statusCode == 200) {
        print('[API] ✓ Success! Parsing response...');
        final data = jsonDecode(response.body);
        final result = AnimationResponse.fromJson(data);
        
        print('[API] Status: ${result.status}');
        print('[API] Message: ${result.message}');
        print('[API] Video URL from backend: ${result.videoUrl}');
        print('[API] Attempts: ${result.attempts}');
        
        return result;
      } else {
        print('[API] ❌ Error response: ${response.body}');
        throw Exception('Failed to generate animation: ${response.body}');
      }
    } catch (e) {
      print('[API] ❌ Exception: $e');
      rethrow;
    }
  }

  /// Build complete video URL
  String getVideoUrl(String videoPath) {
    String fullUrl;
    
    // Video path from backend already includes timestamp
    if (videoPath.startsWith('http')) {
      fullUrl = videoPath;
    } else if (videoPath.startsWith('/')) {
      fullUrl = '$baseUrl$videoPath';
    } else {
      fullUrl = '$baseUrl/video/$videoPath';
    }
    
    print('[API] Full video URL: $fullUrl');
    return fullUrl;
  }
}

/// Animation response model
class AnimationResponse {
  final String status;
  final String message;
  final String? code;
  final String? videoUrl;
  final int attempts;

  AnimationResponse({
    required this.status,
    required this.message,
    this.code,
    this.videoUrl,
    required this.attempts,
  });

  factory AnimationResponse.fromJson(Map<String, dynamic> json) {
    print('[API] Parsing AnimationResponse from JSON');
    return AnimationResponse(
      status: json['status'] as String,
      message: json['message'] as String,
      code: json['code'] as String?,
      videoUrl: json['video_url'] as String?,
      attempts: json['attempts'] as int,
    );
  }
}