import 'dart:convert';
import '../ai_provider_types.dart';
import '../ai_text_provider.dart';

/// Offline & Development Mock Text Provider
/// Generates rich, educational, narrative-driven comic stories that explain
/// concepts step-by-step through character dialogue, analogies, and narrative progression.
class MockTextProvider implements AiTextProvider {
  final bool shouldSimulateRateLimit;
  final bool shouldSimulateFailure;
  final int simulatedDelayMs;

  const MockTextProvider({
    this.shouldSimulateRateLimit = false,
    this.shouldSimulateFailure = false,
    this.simulatedDelayMs = 150,
  });

  @override
  AiProviderType get providerType => AiProviderType.mock;

  @override
  String get defaultModel => 'lorvani-mock-story-engine-v2';

  @override
  bool get isConfigured => true;

  @override
  Future<AiTextResponse> generateStory({
    required String prompt,
    required StoryGenerationOptions options,
  }) async {
    if (simulatedDelayMs > 0) {
      await Future.delayed(Duration(milliseconds: simulatedDelayMs));
    }

    if (shouldSimulateRateLimit) {
      throw const AiRateLimitException(
        message: 'Mock simulated 429: Rate limit reached',
        provider: AiProviderType.mock,
      );
    }

    if (shouldSimulateFailure) {
      throw const AiProviderException(
        message: 'Mock simulated 500: Server error',
        provider: AiProviderType.mock,
        statusCode: 500,
      );
    }

    final topic = _extractCleanTopic(prompt);
    final jsonResponse = _generateEducationalStoryJson(topic, options);
    final rawText = jsonEncode(jsonResponse);

    return AiTextResponse(
      rawText: rawText,
      json: jsonResponse,
      provider: providerType,
      modelName: defaultModel,
      latencyMs: simulatedDelayMs,
    );
  }

  @override
  Future<AiTextResponse> generateAnalogy({
    required String concept,
    required LearningLevel level,
  }) async {
    if (simulatedDelayMs > 0) {
      await Future.delayed(Duration(milliseconds: simulatedDelayMs));
    }

    final jsonResponse = {
      'concept': concept,
      'level': level.label,
      'analogy':
          '$concept is like a high-speed express train delivery network: energy packets are transferred sequentially without losing cargo along the rails.',
      'explanation':
          'Just as train cars stay coupled on the tracks, the fundamental reactions maintain balance throughout the chemical transformation.',
    };

    return AiTextResponse(
      rawText: jsonEncode(jsonResponse),
      json: jsonResponse,
      provider: providerType,
      modelName: defaultModel,
      latencyMs: simulatedDelayMs,
    );
  }

  String _extractCleanTopic(String prompt) {
    var clean = prompt.trim();
    if (clean.isEmpty) return 'Photosynthesis & Solar Energy';

    // Extract after "TOPIC:" or "TOPIC TITLE:" if prompt was formatted by StoryPromptBuilder
    final topicMatch = RegExp(r'(?:TOPIC(?:\s+TITLE)?:\s*)([^\n\r]+)', caseSensitive: false).firstMatch(clean);
    if (topicMatch != null) {
      clean = topicMatch.group(1)?.trim() ?? clean;
    } else {
      // Take first non-empty line
      clean = clean.split('\n').first.trim();
    }

    // Clean leading punctuation/markdown
    clean = clean.replaceAll(RegExp(r'^[#*\-•\s]+'), '').trim();
    return clean.isEmpty ? 'Photosynthesis & Solar Energy' : clean;
  }

  Map<String, dynamic> _generateEducationalStoryJson(
    String topic,
    StoryGenerationOptions options,
  ) {
    final style = options.visualStyle.label;
    final level = options.learningLevel.label;

    // Narrative arcs for up to 8 progressive panels
    final narrativePhases = [
      {
        'title': 'The Everyday Mystery',
        'desc': 'Professor Quantum and Aria observe a real-world demonstration of $topic, noticing a puzzling phenomenon that textbook formulas cannot explain.',
        'narration': 'Every scientific revolution begins with a simple question: how does $topic quietly govern the universe right under our noses?',
        'dialogue': [
          {'speaker': 'Aria', 'text': 'Professor! If $topic is happening all around us, why can’t we see the engine running?'},
          {'speaker': 'Professor Quantum', 'text': 'Because nature builds its greatest machines at the nanoscale, Aria! Activate the Dimension Flip!'},
        ],
        'cue': 'Dimension Flip vortex spiraling downward to microscopic scale',
      },
      {
        'title': 'Descent into the Engine',
        'desc': 'Shrunk down into the core microscopic structure, Professor Quantum and Aria stand before giant biological and physical machinery humming with potential.',
        'narration': 'At atomic dimensions, $topic resembles a futuristic power grid. Raw ingredients flow along invisible electrostatic conveyor belts.',
        'dialogue': [
          {'speaker': 'Aria', 'text': 'Look at the concentration gradient! Millions of raw reactants are lining up in perfect lock-and-key order!'},
          {'speaker': 'Professor Quantum', 'text': 'Precision engineering! Without this exact alignment, the initial activation barrier can never be crossed.'},
        ],
        'cue': 'Glowing reactant molecules locking into catalytic docks',
      },
      {
        'title': 'The Spark of Activation',
        'desc': 'A dazzling surge of energy strikes the central chamber, exciting outer-shell electrons and breaking high-energy bonds in a flash of cyan light.',
        'narration': 'Energy cannot be created or destroyed—only transferred. An incoming excitation wave shatters the old molecular bonds to trigger $topic.',
        'dialogue': [
          {'speaker': 'Professor Quantum', 'text': 'Brace yourself, Aria! The activation threshold has been reached! Watch the valence electrons!'},
          {'speaker': 'Aria', 'text': 'They\'re jumping to higher energy orbits! The reaction kinetics are skyrocketing!'},
        ],
        'cue': 'Shockwave of radiant cyan photons breaking chemical bonds',
      },
      {
        'title': 'The Catalyst Transformation',
        'desc': 'At the peak turning point, energized intermediate particles rapidly rearrange into entirely new structural configurations.',
        'narration': 'This is the climax of $topic: the pivotal transformation where chaotic inputs are synthesized into purposeful, life-giving matter.',
        'dialogue': [
          {'speaker': 'Aria', 'text': 'The old structures disassembled completely—and now they are locking into a brand new crystal matrix!'},
          {'speaker': 'Professor Quantum', 'text': 'Eureka! That is the core breakthrough of $topic! What seemed impossible in theory just happened in milliseconds!'},
        ],
        'cue': 'Swirling golden vortex forming brand new molecular bonds',
      },
      {
        'title': 'The Balancing Cascade',
        'desc': 'Secondary regulatory pathways and molecular pumps engage to stabilize pressure and prevent system overheating.',
        'narration': 'Unchecked power would destroy the host. Immediate negative feedback loops balance the output rate to preserve equilibrium.',
        'dialogue': [
          {'speaker': 'Aria', 'text': 'The feedback inhibitors are engaging! The reaction rate is leveling out to prevent a thermal spike.'},
          {'speaker': 'Professor Quantum', 'text': 'Homeostasis in action! A true cosmic system doesn\'t just produce energy—it protects itself.'},
        ],
        'cue': 'Emerald feedback shields glowing as equilibrium locks into place',
      },
      {
        'title': 'The Essential Harvest',
        'desc': 'Glorious canisters of pure output fuel surge outward into the cellular bloodstream, illuminating surrounding tissue with life-giving energy.',
        'narration': 'The core mission succeeds: $topic delivers its vital outputs, fueling metabolism, mechanical work, and growth across the organism.',
        'dialogue': [
          {'speaker': 'Aria', 'text': 'Look at the yield! Clean, high-density stored fuel ready to power living cells!'},
          {'speaker': 'Professor Quantum', 'text': 'From simple raw notes to pure biological fuel. That is the genius of $topic!'},
        ],
        'cue': 'Radiant golden energy capsules dispersing into circulation',
      },
      {
        'title': 'The Global Symphony',
        'desc': 'Holographic projection zooms out from the single cell to reveal how this microscopic process sustains planetary balance and food chains.',
        'narration': 'No reaction occurs in isolation. Billions of these microscopic events synchronize every second to sustain our global biosphere.',
        'dialogue': [
          {'speaker': 'Aria', 'text': 'A single reaction here ripples across entire forests, oceans, and living ecosystems!'},
          {'speaker': 'Professor Quantum', 'text': 'Indeed, Aria. Master the micro, and the universe reveals its grand blueprint!'},
        ],
        'cue': 'Planetary holographic sphere pulsating in sync with atomic reactions',
      },
      {
        'title': 'The Comic Epiphany',
        'desc': 'Professor Quantum and Aria materialize back in their laboratory, high-fiving surrounded by holographic notes and comic diagrams.',
        'narration': 'The comic adventure concludes. What once looked like dry textbook jargon is now an unforgettable illustrated memory.',
        'dialogue': [
          {'speaker': 'Aria', 'text': 'I get it now, Professor! It’s not just memorizing formulas—it’s an epic survival story!'},
          {'speaker': 'Professor Quantum', 'text': 'You have officially conquered $topic, young scholar! Onward to the next cosmic issue!'},
        ],
        'cue': 'Burst of comic stars and eureka badges celebrating mastery',
      },
    ];

    // Build panels from phases matching requested count
    final panelCount = options.panelCount.clamp(4, 8);
    final selectedPanels = <Map<String, dynamic>>[];

    for (int i = 0; i < panelCount; i++) {
      // Map index proportionally across the phases
      final phaseIndex = (i * (narrativePhases.length - 1) / (panelCount - 1)).round();
      final phase = narrativePhases[phaseIndex];

      selectedPanels.add({
        'panelNumber': i + 1,
        'panelTitle': 'Act ${i + 1}: ${phase['title']}',
        'panelDescription':
            '${phase['desc']} Rendered in dramatic graphic novel style: $style with vivid lighting, crisp line-art, and expressive character poses.',
        'narration': phase['narration'],
        'dialogue': phase['dialogue'],
        'keyVisualCue': phase['cue'],
      });
    }

    return {
      'storyTitle': 'The Epic Chronicle of $topic',
      'originalTopic': topic,
      'learningLevel': level,
      'visualStyle': style,
      'shortIntroduction':
          'Join Professor Quantum and Aria on an illustrated high-stakes voyage into the inner workings of $topic. Discover how hidden forces transform matter, power systems, and shape the world around us!',
      'characters': [
        {
          'name': 'Professor Quantum',
          'role': 'Eccentric mentor scientist with dimension-folding goggles',
          'visualDescription':
              'Silver-haired scholar in comic purple coat, cybernetic brass monocle, and enthusiastic demeanor.',
        },
        {
          'name': 'Aria',
          'role': 'Curious high school explorer & analytical questioner',
          'visualDescription':
              'Teenager with curly hair, cyan utility jacket, holographic notebook, and quick wit.',
        },
      ],
      'storySetting':
          'From the research laboratory into the microscopic realm of $topic',
      'panels': selectedPanels,
      'keyConcepts': [
        {
          'term': '$topic Mechanism',
          'definition':
              'The fundamental biological or physical cascade that converts raw inputs into usable outputs.',
        },
        {
          'term': 'Activation Energy Barrier',
          'definition':
              'The threshold energy required for reactants to undergo chemical or physical transformation.',
        },
        {
          'term': 'Homeostatic Equilibrium',
          'definition':
              'The self-regulating feedback system that preserves stability and prevents system collapse.',
        },
      ],
      'analogies': [
        {
          'targetConcept': topic,
          'everydayAnalogy':
              'Think of $topic like a high-tech solar bakery: sunlight delivers the energy, water and air provide the dough, and sugar is the fresh baked bread fueling life.',
          'whyItWorks':
              'Both systems take diffuse external inputs, concentrate them through an organized engine, and output dense usable sustenance.',
        },
        {
          'targetConcept': 'Activation Energy in $topic',
          'everydayAnalogy':
              'Like pushing a heavy boulder just over the crest of a hill: once you invest the initial push, gravity carries it down freely.',
          'whyItWorks':
              'It explains why energy must first be invested before the greater payoff reaction can spontaneously cascade.',
        },
      ],
      'summary':
          'Through this comic adventure, $topic transforms from abstract notes into an intuitive visual story of energy transfer, molecular assembly, and planetary balance.',
      'quizQuestions': [
        {
          'question': 'In our story, what triggers the initial transformation of $topic?',
          'options': [
            'An excitation wave that breaks existing bonds and overcomes activation energy',
            'Passive cooling that freezes the molecular components in place',
            'Friction generated by shaking the container at high velocity',
            'Complete random destruction without any conservation of energy',
          ],
          'correctAnswerIndex': 0,
          'explanation':
              'Activation energy must be supplied to excite particles before new molecular bonds can form.',
        },
        {
          'question': 'Why do secondary regulatory pathways activate during the reaction?',
          'options': [
            'To maintain homeostatic equilibrium and prevent system overload',
            'To immediately shut down the entire cell permanently',
            'To destroy all newly synthesized molecules for fun',
            'To reverse the direction of time inside the laboratory',
          ],
          'correctAnswerIndex': 0,
          'explanation':
              'Feedback loops ensure reactions proceed safely at sustainable rates without damaging living structures.',
        },
        {
          'question': 'What is the grand takeaway that Aria and Professor Quantum discovered?',
          'options': [
            '$topic powers systems from microscopic cells up to global biospheres',
            '$topic only works inside blackboards and has no real-world application',
            'Energy can be created out of nothing whenever needed',
            'Complex science can never be understood through visual storytelling',
          ],
          'correctAnswerIndex': 0,
          'explanation':
              'The microscopic mechanisms of $topic connect directly to macro-level life, technology, and natural ecosystems.',
        },
      ],
    };
  }
}
