import 'package:flutter_test/flutter_test.dart';
import 'package:lorevaani/core/services/ai/ai_provider_types.dart';
import 'package:lorevaani/core/services/ai/mock/mock_image_provider.dart';
import 'package:lorevaani/core/services/ai/mock/mock_text_provider.dart';
import 'package:lorevaani/core/services/ai/orchestrator/ai_orchestrator.dart';
import 'package:lorevaani/core/services/ai/providers/pollinations_image_provider.dart';

void main() {
  group('AI Provider Foundation & Mock Tests', () {
    test('MockTextProvider generates valid schema-compliant educational story', () async {
      const provider = MockTextProvider(simulatedDelayMs: 10);
      const options = StoryGenerationOptions(
        learningLevel: LearningLevel.intermediate,
        visualStyle: ComicVisualStyle.classicComic,
        panelCount: 6,
      );

      final response = await provider.generateStory(
        prompt: 'How do solar panels work?',
        options: options,
      );

      expect(response.provider, AiProviderType.mock);
      expect(response.json['storyTitle'], contains('solar panels'));
      expect(response.json['learningLevel'], 'Intermediate');
      expect(response.json['visualStyle'], 'Classic Comic');

      final panels = response.json['panels'] as List;
      expect(panels.length, 6);

      final firstPanel = panels[0] as Map<String, dynamic>;
      expect(firstPanel['panelNumber'], 1);
      expect(firstPanel['narration'], isNotEmpty);
      expect(firstPanel['dialogue'], isNotEmpty);

      final quizzes = response.json['quizQuestions'] as List;
      expect(quizzes.isNotEmpty, isTrue);
      expect(quizzes[0]['correctAnswerIndex'], inInclusiveRange(0, 3));
    });

    test('MockTextProvider generates progressive distinct panels without identical repetition', () async {
      const provider = MockTextProvider(simulatedDelayMs: 0);
      const options = StoryGenerationOptions(
        learningLevel: LearningLevel.intermediate,
        visualStyle: ComicVisualStyle.classicComic,
        panelCount: 6,
      );

      final response = await provider.generateStory(
        prompt: 'Photosynthesis',
        options: options,
      );

      final panels = response.json['panels'] as List;
      final titles = panels.map((p) => p['panelTitle']).toSet();
      final descriptions = panels.map((p) => p['panelDescription']).toSet();
      final narrations = panels.map((p) => p['narration']).toSet();

      // Ensure every single panel has unique narrative content
      expect(titles.length, panels.length);
      expect(descriptions.length, panels.length);
      expect(narrations.length, panels.length);
    });

    test('MockTextProvider generates conceptual analogies', () async {
      const provider = MockTextProvider(simulatedDelayMs: 10);
      final response = await provider.generateAnalogy(
        concept: 'Cellular Respiration',
        level: LearningLevel.beginner,
      );

      expect(response.json['analogy'], contains('Cellular Respiration'));
      expect(response.json['level'], 'Beginner');
    });

    test('MockImageProvider generates fallback illustration with seed', () async {
      const provider = MockImageProvider(simulatedDelayMs: 10);
      final response = await provider.generatePanelIllustration(
        panelDescription: 'Professor Quantum inspecting glowing chlorophyll',
        visualStyle: ComicVisualStyle.animeInspired,
        characterConsistencyPrompt: 'purple coat, silver hair',
        seed: 42,
      );

      expect(response.isFallback, isTrue);
      expect(response.seed, 42);
      expect(response.imageUrl, contains('pollinations.ai'));
      expect(response.imageUrl, contains('seed=42'));
    });

    test('PollinationsImageProvider builds formatted comic URL with character continuity', () async {
      final provider = PollinationsImageProvider(model: 'flux');
      final response = await provider.generatePanelIllustration(
        panelDescription: 'Aria looking through a cosmic portal',
        visualStyle: ComicVisualStyle.cinematicComic,
        characterConsistencyPrompt: 'teal utility jacket, curly hair',
        seed: 999,
      );

      expect(response.provider, AiProviderType.pollinations);
      expect(response.seed, 999);
      expect(response.imageUrl, contains('pollinations.ai'));
      expect(response.prompt, contains('comic panel masterpiece'));
      expect(response.prompt, contains('teal utility jacket'));
    });
  });

  group('AiOrchestrator Fallback & Resilience Tests', () {
    test('Orchestrator falls over to secondary provider when primary fails with 500', () async {
      const failingPrimary = MockTextProvider(
        shouldSimulateFailure: true,
        simulatedDelayMs: 5,
      );
      const workingSecondary = MockTextProvider(
        shouldSimulateFailure: false,
        simulatedDelayMs: 5,
      );

      final orchestrator = AiOrchestrator(
        textProviders: [failingPrimary, workingSecondary],
        maxRetriesPerProvider: 1,
        baseBackoff: const Duration(milliseconds: 10),
      );

      final response = await orchestrator.generateStory(
        prompt: 'Mitosis',
        options: const StoryGenerationOptions(panelCount: 4),
      );

      expect(response.json['storyTitle'], contains('Mitosis'));
      expect(orchestrator.executionLogs.any((l) => l.contains('Failing over')), isTrue);
    });

    test('Orchestrator immediately fails over on 429 RateLimit without wasting retries', () async {
      const rateLimitedPrimary = MockTextProvider(
        shouldSimulateRateLimit: true,
        simulatedDelayMs: 5,
      );
      const backupProvider = MockTextProvider(
        shouldSimulateRateLimit: false,
        simulatedDelayMs: 5,
      );

      final orchestrator = AiOrchestrator(
        textProviders: [rateLimitedPrimary, backupProvider],
        maxRetriesPerProvider: 3, // Would retry 3 times if it didn't immediately fail over
        baseBackoff: const Duration(milliseconds: 10),
      );

      final response = await orchestrator.generateStory(
        prompt: 'Gravity Waves',
        options: const StoryGenerationOptions(panelCount: 4),
      );

      expect(response.json['storyTitle'], contains('Gravity Waves'));
      expect(
        orchestrator.executionLogs.any((l) => l.contains('Immediate failover triggered')),
        isTrue,
      );
    });

    test('Orchestrator caches successful response and returns isFromCache: true', () async {
      const workingProvider = MockTextProvider(simulatedDelayMs: 15);
      final orchestrator = AiOrchestrator(
        textProviders: [workingProvider],
      );

      // First call (cache miss)
      final first = await orchestrator.generateStory(
        prompt: 'Thermodynamics',
        options: const StoryGenerationOptions(panelCount: 4),
      );
      expect(first.isFromCache, isFalse);

      // Second call (cache hit)
      final second = await orchestrator.generateStory(
        prompt: 'Thermodynamics',
        options: const StoryGenerationOptions(panelCount: 4),
      );
      expect(second.isFromCache, isTrue);
      expect(second.latencyMs, 0);

      // Bypass cache
      final third = await orchestrator.generateStory(
        prompt: 'Thermodynamics',
        options: const StoryGenerationOptions(panelCount: 4),
        bypassCache: true,
      );
      expect(third.isFromCache, isFalse);
    });

    test('Orchestrator throws AiProviderException when all providers fail', () async {
      const failing1 = MockTextProvider(shouldSimulateFailure: true, simulatedDelayMs: 5);
      const failing2 = MockTextProvider(shouldSimulateFailure: true, simulatedDelayMs: 5);

      final orchestrator = AiOrchestrator(
        textProviders: [failing1, failing2],
        maxRetriesPerProvider: 0,
      );

      expect(
        () => orchestrator.generateStory(
          prompt: 'Black Holes',
          options: const StoryGenerationOptions(),
        ),
        throwsA(isA<AiProviderException>()),
      );
    });
  });
}

