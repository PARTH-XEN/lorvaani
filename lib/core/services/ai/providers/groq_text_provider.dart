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
    this.model = 'openai/gpt-oss-120b',
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

    final languageInstruction = options.language.toLowerCase() == 'english'
        ? 'Language: English.'
        : '''
CRITICAL LANGUAGE REQUIREMENT:
The user selected the language: "${options.language}".
You MUST write ALL human-readable content strictly in ${options.language}!
This includes: storyTitle, shortIntroduction, storySetting, panelTitle, panelDescription, narration, ALL dialogue text, character roles, keyConcepts (term & definition), analogies (everydayAnalogy & whyItWorks), summary, and quizQuestions (question, options, and explanation).
Do NOT write in English when ${options.language} is requested!
''';

    final genreInstruction = '''
GENRE & COMIC TROPES:
The comic genre is strictly "${options.visualStyle.label}".
Adapt characters, dialogue tone, humor, and plot pacing to embody this genre:
- If "Anime-inspired": Use passionate Shonen manga tropes, dramatic declarations, mentor/student rivalry, battle-cry technique names (e.g., "Chloroplast Solar Flash!"), expressive anime reactions ("Nani?!").
- If "Classic Comic": Use 90s superhero tropes (Marvel/DC style), superhero alias names, heroic battle framing (e.g. Captain Photon vs Dr. Entropy), comic sound effects (ZAP, BAM, POW).
- If "Cartoon": Use playful, lighthearted slapstick cartoon logic, goofy inventions, bouncy metaphors, and humorous character banter.
- If "Storybook": Use gentle enchanted fairy-tale wonder, poetic storytelling, magical glowing nature analogies, and cozy bedtime-story warmth.
- If "Cinematic Comic": Use gritty, high-stakes tactical mission tone, classified briefing format, atmospheric tension, and intense cinematic pacing.
''';

    final systemPrompt = '''
You are the master educational comic book storyteller for LORVANI.
Your mission is to transform dry study notes into an exciting, illustrated graphic novel adventure that teaches the topic step-by-step.

$languageInstruction

$genreInstruction

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

Generate exactly ${options.panelCount} progressive panels.
Each panel must depict a different step in the learning adventure with unique dialogue and unique narration.
Output strictly valid JSON without any markdown formatting or code blocks.
''';

    final candidateModels = [model, 'qwen/qwen3.8-27b', 'openai/gpt-oss-20b'];

    for (final candidateModel in candidateModels) {
      final requestBody = {
        'model': candidateModel,
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

        // If model not found (404), try next candidate model
        if (response.statusCode == 404 && candidateModel != candidateModels.last) {
          continue;
        }

        if (response.statusCode != 200) {
          throw AiProviderException(
            message:
                'Groq API error (HTTP ${response.statusCode}): ${response.body}',
            provider: providerType,
            statusCode: response.statusCode,
          );
        }

        // Decode UTF-8 correctly for Hindi, French, German, Spanish
        final decodedBody = utf8.decode(response.bodyBytes);
        final Map<String, dynamic> responseJson = jsonDecode(decodedBody);
        final choices = responseJson['choices'] as List?;
        if (choices == null || choices.isEmpty) {
          throw AiMalformedResponseException(
            message: 'Groq returned no choices in response.',
            provider: providerType,
            rawResponse: decodedBody,
          );
        }

        final message = choices[0]['message'];
        final content = message['content'] as String;
        final parsedJson = _cleanAndParseJson(content);

        stopwatch.stop();

        return AiTextResponse(
          rawText: content,
          json: parsedJson,
          provider: providerType,
          modelName: candidateModel,
          latencyMs: stopwatch.elapsedMilliseconds,
        );
      } catch (e) {
        if (e is AiProviderException) rethrow;
        if (candidateModel == candidateModels.last) {
          throw AiNetworkException(
            message: 'Network or parsing failure calling Groq: $e',
            provider: providerType,
            originalError: e,
          );
        }
      }
    }

    throw const AiProviderException(
      message: 'Failed to generate story with available Groq models.',
      provider: AiProviderType.groq,
    );
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
