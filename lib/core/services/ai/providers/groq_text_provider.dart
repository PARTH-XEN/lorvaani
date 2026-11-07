import 'dart:convert';
import 'package:http/http.dart' as http;
import '../ai_provider_types.dart';
import '../ai_text_provider.dart';

/// Groq LPU API Provider Implementation (OpenAI-compatible)
class GroqTextProvider implements AiTextProvider {
  final String? apiKey;
  final String model;
  final http.Client _client;

  GroqTextProvider({
    this.apiKey,
    this.model = 'llama-3.3-70b-versatile',
    http.Client? client,
  }) : _client = client ?? http.Client();

  @override
  AiProviderType get providerType => AiProviderType.groq;

  @override
  String get defaultModel => model;

  @override
  bool get isConfigured => apiKey != null && apiKey!.trim().isNotEmpty;

  @override
  Future<AiTextResponse> generateStory({
    required String prompt,
    required StoryGenerationOptions options,
  }) async {
    if (!isConfigured) {
      throw const AiAuthException(
        message: 'Groq API Key is not configured in environment or settings.',
        provider: AiProviderType.groq,
      );
    }

    final stopwatch = Stopwatch()..start();
    final url = Uri.parse('https://api.groq.com/openai/v1/chat/completions');

    final systemPrompt = '''
You are the master educational comic book storyteller for LORVANI.
Transform study notes into an exciting comic book narrative.
You MUST output ONLY a valid JSON object matching this schema:
{
  "storyTitle": string,
  "originalTopic": string,
  "learningLevel": "${options.learningLevel.label}",
  "visualStyle": "${options.visualStyle.label}",
  "shortIntroduction": string,
  "characters": [
    {"name": string, "role": string, "visualDescription": string}
  ],
  "storySetting": string,
  "panels": [
    {
      "panelNumber": integer,
      "panelTitle": string,
      "panelDescription": string (detailed visual prompt for illustration),
      "narration": string,
      "dialogue": [{"speaker": string, "text": string}],
      "keyVisualCue": string
    }
  ],
  "keyConcepts": [
    {"term": string, "definition": string}
  ],
  "analogies": [
    {"targetConcept": string, "everydayAnalogy": string, "whyItWorks": string}
  ],
  "summary": string,
  "quizQuestions": [
    {
      "question": string,
      "options": [string, string, string, string],
      "correctAnswerIndex": integer,
      "explanation": string
    }
  ]
}
Generate exactly ${options.panelCount} panels. Language: ${options.language}.
Do NOT invent false facts. Output strictly valid JSON.
''';

    final requestBody = {
      'model': model,
      'messages': [
        {'role': 'system', 'content': systemPrompt},
        {'role': 'user', 'content': prompt},
      ],
      'response_format': {'type': 'json_object'},
      'temperature': 0.7,
    };

    try {
      final response = await _client
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $apiKey',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 45));

      stopwatch.stop();

      if (response.statusCode == 429) {
        throw AiRateLimitException(
          message: 'Groq API rate limit reached (HTTP 429). TPM or RPM cap hit.',
          provider: providerType,
        );
      }

      if (response.statusCode == 401 || response.statusCode == 403) {
        throw AiAuthException(
          message: 'Groq authentication failed (HTTP ${response.statusCode}).',
          provider: providerType,
          statusCode: response.statusCode,
        );
      }

      if (response.statusCode != 200) {
        throw AiProviderException(
          message:
              'Groq API error (HTTP ${response.statusCode}): ${response.body}',
          provider: providerType,
          statusCode: response.statusCode,
        );
      }

      final Map<String, dynamic> responseJson = jsonDecode(response.body);
      final choices = responseJson['choices'] as List?;
      if (choices == null || choices.isEmpty) {
        throw AiMalformedResponseException(
          message: 'Groq returned no choices in response.',
          provider: providerType,
          rawResponse: response.body,
        );
      }

      final message = choices[0]['message'];
      final content = message['content'] as String;
      final parsedJson = _cleanAndParseJson(content);

      return AiTextResponse(
        rawText: content,
        json: parsedJson,
        provider: providerType,
        modelName: model,
        latencyMs: stopwatch.elapsedMilliseconds,
      );
    } catch (e) {
      if (e is AiProviderException) rethrow;
      throw AiNetworkException(
        message: 'Network or parsing failure calling Groq: $e',
        provider: providerType,
        originalError: e,
      );
    }
  }

  @override
  Future<AiTextResponse> generateAnalogy({
    required String concept,
    required LearningLevel level,
  }) async {
    return generateStory(
      prompt: 'Explain "$concept" with a vivid everyday analogy.',
      options: StoryGenerationOptions(
        learningLevel: level,
        panelCount: 3,
      ),
    );
  }

  Map<String, dynamic> _cleanAndParseJson(String rawText) {
    String cleaned = rawText.trim();
    if (cleaned.startsWith('```json')) {
      cleaned = cleaned.substring(7);
    } else if (cleaned.startsWith('```')) {
      cleaned = cleaned.substring(3);
    }
    if (cleaned.endsWith('```')) {
      cleaned = cleaned.substring(0, cleaned.length - 3);
    }
    cleaned = cleaned.trim();
    return jsonDecode(cleaned) as Map<String, dynamic>;
  }
}

