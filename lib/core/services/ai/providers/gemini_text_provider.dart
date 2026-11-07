import 'dart:convert';
import 'package:http/http.dart' as http;
import '../ai_provider_types.dart';
import '../ai_text_provider.dart';

/// Google Gemini API Provider Implementation
class GeminiTextProvider implements AiTextProvider {
  final String? apiKey;
  final String model;
  final http.Client _client;

  GeminiTextProvider({
    this.apiKey,
    this.model = 'gemini-1.5-flash',
    http.Client? client,
  }) : _client = client ?? http.Client();

  @override
  AiProviderType get providerType => AiProviderType.gemini;

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
        message: 'Gemini API Key is not configured in environment or settings.',
        provider: AiProviderType.gemini,
      );
    }

    final stopwatch = Stopwatch()..start();
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey',
    );

    final systemPrompt = '''
You are the master educational comic book storyteller for LORVANI.
Your task is to transform the provided study notes into an exciting, illustrated comic-book narrative.
You MUST output ONLY a valid JSON object matching this exact schema:
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
      "panelDescription": string (detailed scene for image generation),
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
      "correctAnswerIndex": integer (0 to 3),
      "explanation": string
    }
  ]
}
Number of panels must be: ${options.panelCount}.
Language must be: ${options.language}.
Do NOT invent false educational facts. Output raw JSON only with no markdown formatting.
''';

    final requestBody = {
      'contents': [
        {
          'parts': [
            {'text': prompt},
          ],
        },
      ],
      'systemInstruction': {
        'parts': [
          {'text': systemPrompt},
        ],
      },
      'generationConfig': {
        'temperature': 0.7,
        'responseMimeType': 'application/json',
      },
    };

    try {
      final response = await _client
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 45));

      stopwatch.stop();

      if (response.statusCode == 429) {
        throw AiRateLimitException(
          message:
              'Gemini API rate limit exceeded (HTTP 429). Resource exhausted.',
          provider: providerType,
        );
      }

      if (response.statusCode == 401 || response.statusCode == 403) {
        throw AiQuotaExceededException(
          message:
              'Gemini authentication failed or quota reached (HTTP ${response.statusCode}).',
          provider: providerType,
          statusCode: response.statusCode,
        );
      }

      if (response.statusCode != 200) {
        throw AiProviderException(
          message:
              'Gemini API error (HTTP ${response.statusCode}): ${response.body}',
          provider: providerType,
          statusCode: response.statusCode,
        );
      }

      final Map<String, dynamic> responseJson = jsonDecode(response.body);
      final candidates = responseJson['candidates'] as List?;
      if (candidates == null || candidates.isEmpty) {
        throw AiMalformedResponseException(
          message: 'Gemini returned no candidates in response.',
          provider: providerType,
          rawResponse: response.body,
        );
      }

      final content = candidates[0]['content'];
      final parts = content['parts'] as List?;
      if (parts == null || parts.isEmpty) {
        throw AiMalformedResponseException(
          message: 'Gemini candidate contains no parts.',
          provider: providerType,
          rawResponse: response.body,
        );
      }

      final text = parts[0]['text'] as String;
      final parsedJson = _cleanAndParseJson(text);

      return AiTextResponse(
        rawText: text,
        json: parsedJson,
        provider: providerType,
        modelName: model,
        latencyMs: stopwatch.elapsedMilliseconds,
      );
    } catch (e) {
      if (e is AiProviderException) rethrow;
      throw AiNetworkException(
        message: 'Network or parsing failure calling Gemini: $e',
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
      prompt: 'Explain the concept "$concept" with an everyday analogy.',
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

