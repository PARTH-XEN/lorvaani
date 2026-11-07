import 'dart:convert';
import '../ai_provider_types.dart';
import '../ai_text_provider.dart';

/// Offline & Development Mock Text Provider
/// Generates rich, educational, narrative-driven comic stories tailored to
/// the selected visual genre (Anime, Classic Comic, Cartoon, Storybook, Cinematic)
/// and language (Hindi, Spanish, French, German, English).
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
  String get defaultModel => 'lorvani-mock-story-engine-v3';

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
    final jsonResponse = _generateGenreAndLanguageStory(topic, options);
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

    final topicMatch = RegExp(r'(?:TOPIC(?:\s+TITLE)?:\s*)([^\n\r]+)', caseSensitive: false).firstMatch(clean);
    if (topicMatch != null) {
      clean = topicMatch.group(1)?.trim() ?? clean;
    } else {
      clean = clean.split('\n').first.trim();
    }

    clean = clean.replaceAll(RegExp(r'^[#*\-•\s]+'), '').trim();
    return clean.isEmpty ? 'Photosynthesis & Solar Energy' : clean;
  }

  Map<String, dynamic> _generateGenreAndLanguageStory(
    String topic,
    StoryGenerationOptions options,
  ) {
    final lang = options.language.trim().toLowerCase();
    final style = options.visualStyle;
    final level = options.learningLevel.label;

    // 1. Determine Character Cast based on Genre
    final characters = _getGenreCharacters(style, lang);
    final char1 = characters[0]['name']!;
    final char2 = characters[1]['name']!;

    // 2. Build 8 Narrative Phases adapted to Language & Genre
    final phases = _buildLocalizedPhases(topic, style, lang, char1, char2);

    final panelCount = options.panelCount.clamp(4, 8);
    final selectedPanels = <Map<String, dynamic>>[];

    for (int i = 0; i < panelCount; i++) {
      final phaseIndex = (i * (phases.length - 1) / (panelCount - 1)).round();
      final phase = phases[phaseIndex];

      final actPrefix = _getActPrefix(lang, i + 1);

      selectedPanels.add({
        'panelNumber': i + 1,
        'panelTitle': '$actPrefix: ${phase['title']}',
        'panelDescription':
            '${phase['desc']} ${style.promptStyleModifier}, rich dramatic lighting, expressive character poses, comic panel masterpiece.',
        'narration': phase['narration'],
        'dialogue': phase['dialogue'],
        'keyVisualCue': phase['cue'],
      });
    }

    final metadata = _getLocalizedMetadata(topic, lang, style.label, level);

    return {
      'storyTitle': metadata['storyTitle'],
      'originalTopic': topic,
      'learningLevel': level,
      'visualStyle': style.label,
      'shortIntroduction': metadata['shortIntroduction'],
      'characters': characters,
      'storySetting': metadata['storySetting'],
      'panels': selectedPanels,
      'keyConcepts': metadata['keyConcepts'],
      'analogies': metadata['analogies'],
      'summary': metadata['summary'],
      'quizQuestions': metadata['quizQuestions'],
    };
  }

  String _getActPrefix(String lang, int number) {
    switch (lang) {
      case 'hindi':
        return 'दृश्य $number';
      case 'spanish':
        return 'Acto $number';
      case 'french':
        return 'Acte $number';
      case 'german':
        return 'Akt $number';
      default:
        return 'Act $number';
    }
  }

  List<Map<String, String>> _getGenreCharacters(ComicVisualStyle style, String lang) {
    final isHindi = lang == 'hindi';

    switch (style) {
      case ComicVisualStyle.animeInspired:
        return [
          {
            'name': isHindi ? 'उस्ताद रयू' : 'Master Ryu',
            'role': isHindi
                ? 'उत्साही मेंटर वैज्ञानिक, जिसके पास डायमेंशन-फोल्डिंग गॉगल्स हैं'
                : 'Passionate martial science mentor with fiery aura & dimensional coat',
            'visualDescription':
                'Anime master with spiky silver hair, purple flame coat, and expressive eyes.',
          },
          {
            'name': isHindi ? 'केन्जी' : 'Kenji',
            'role': isHindi
                ? 'जिज्ञासु युवा छात्र अन्वेषक'
                : 'Eager high school shonen student determined to unlock truth',
            'visualDescription':
                'Teenager with cyan headband, utility vest, and glowing analytical scanner.',
          },
        ];
      case ComicVisualStyle.classicComic:
        return [
          {
            'name': isHindi ? 'कैप्टन फोटॉन' : 'Captain Photon',
            'role': isHindi
                ? 'सुपरहीरो वैज्ञानिक और ब्रह्मांडीय रक्षक'
                : 'Golden-age cosmic superhero defending the laws of physics',
            'visualDescription':
                'Classic 90s hero in purple & gold power armor with flowing cape.',
          },
          {
            'name': isHindi ? 'डायनेमो' : 'Dynamo',
            'role': isHindi
                ? 'तेजतर्रार युवा सुपर-अन्वेषक'
                : 'Acrobatic sidekick equipped with quantum particle gauntlets',
            'visualDescription':
                'Young superhero in sleek cyan suit with high-tech visor.',
          },
        ];
      case ComicVisualStyle.cartoon:
        return [
          {
            'name': isHindi ? 'प्रोफेसर बीकर' : 'Professor Beaker',
            'role': isHindi
                ? 'मजेदार और अनोखे कार्टून वैज्ञानिक'
                : 'Wacky, hilarious cartoon genius with wild inventive ideas',
            'visualDescription':
                'Round cartoon scholar with wild frizzy hair, big round spectacles, and lab coat.',
          },
          {
            'name': isHindi ? 'स्पार्की' : 'Sparky',
            'role': isHindi
                ? 'शरारती और चंचल रोबोट साथी'
                : 'Bouncy robot companion with expressive antenna & screen eyes',
            'visualDescription':
                'Floating turquoise spherical robot with smiling digital face.',
          },
        ];
      case ComicVisualStyle.storybook:
        return [
          {
            'name': isHindi ? 'गुरु विलो' : 'Elder Willow',
            'role': isHindi
                ? 'प्रकृति के रहस्यों के प्राचीन वन संरक्षक'
                : 'Gentle nature guardian carrying ancient enchanted wooden staff',
            'visualDescription':
                'Wise elder draped in leaf-woven cloak with soft glowing lantern.',
          },
          {
            'name': isHindi ? 'लिली' : 'Lily',
            'role': isHindi
                ? 'जिज्ञासु प्रकृति प्रेमी परी-अन्वेषक'
                : 'Curious child explorer with an affinity for magical seeds',
            'visualDescription':
                'Young girl with flower crown, embroidered satchel, and wide wondrous eyes.',
          },
        ];
      case ComicVisualStyle.cinematicComic:
        return [
          {
            'name': isHindi ? 'प्रोफेसर क्वांटम' : 'Professor Quantum',
            'role': isHindi
                ? 'अनोखे वैज्ञानिक और मेंटर'
                : 'Eccentric mentor scientist with cybernetic monocle',
            'visualDescription':
                'Silver-haired scholar in purple trench coat and cybernetic eyepiece.',
          },
          {
            'name': isHindi ? 'आर्या' : 'Aria',
            'role': isHindi
                ? 'होशियार अन्वेषक छात्रा'
                : 'Curious high school explorer & analytical researcher',
            'visualDescription':
                'Teenager with curly hair, cyan utility jacket, and digital notebook.',
          },
        ];
    }
  }

  List<Map<String, dynamic>> _buildLocalizedPhases(
    String topic,
    ComicVisualStyle style,
    String lang,
    String c1,
    String c2,
  ) {
    if (lang == 'hindi') {
      return [
        {
          'title': 'दैनिक जीवन का रहस्य',
          'desc': '$c1 और $c2 $topic के एक रहस्यमयी प्रयोग को देखते हैं, जो साधारण किताबों से परे है।',
          'narration': 'हर बड़ा वैज्ञानिक चमत्कार एक सवाल से शुरू होता है: $topic हमारी दुनिया को अंदर से कैसे चलाता है?',
          'dialogue': [
            {'speaker': c2, 'text': '$c1! अगर $topic हमारे चारों ओर हो रहा है, तो इसका असली इंजन कहाँ छिपा है?'},
            {'speaker': c1, 'text': 'क्योंकि कुदरत अपनी सबसे ताकतवर मशीनें सूक्ष्म स्तर पर बनाती है! डायमेंशन फ्लिप चालू करो!'},
          ],
          'cue': 'माइक्रो-दुनिया की ओर घूमता हुआ जादुई पोर्टल',
        },
        {
          'title': 'आणविक इंजन में प्रवेश',
          'desc': '$c1 और $c2 सूक्ष्म स्तर पर पहुँचकर विशाल जैविक और भौतिक मशीनों को ऊर्जा से गूँजते हुए देखते हैं।',
          'narration': 'परमाणु स्तर पर $topic एक अद्भुत बिजलीघर की तरह काम करता है। कच्चे कण कतार में लग रहे हैं।',
          'dialogue': [
            {'speaker': c2, 'text': 'कणों की कतार देखिए! सारे घटक सटीक सांचे में फिट हो रहे हैं!'},
            {'speaker': c1, 'text': 'बिल्कुल सही! बिना इस सही तालमेल के असली रासायनिक प्रक्रिया शुरू नहीं हो सकती।'},
          ],
          'cue': 'चमकते हुए अणु एक-दूसरे से जुड़ते हुए',
        },
        {
          'title': 'ऊर्जा का विस्फोट',
          'desc': 'एक चमकदार ऊर्जा तरंग केंद्र पर टकराती है, इलेक्ट्रॉनों को उत्तेजित करती है और पुराने बंधनों को तोड़ती है।',
          'narration': 'ऊर्जा को न तो बनाया जा सकता है न नष्ट—केवल बदला जा सकता है। आने वाली रोशनी पुराने बंधनों को तोड़ती है।',
          'dialogue': [
            {'speaker': c1, 'text': 'संभलकर $c2! सक्रियण ऊर्जा की सीमा पार हो चुकी है! इलेक्ट्रॉनों को देखो!'},
            {'speaker': c2, 'text': 'अद्भुत! वे ऊंची कक्षा में छलांग लगा रहे हैं! प्रतिक्रिया की रफ्तार आसमान छू रही है!'},
          ],
          'cue': 'नीली और सुनहरी रोशनी का शक्तिशाली शॉकवेव',
        },
        {
          'title': 'मुख्य रूपांतरण',
          'desc': 'प्रतिक्रिया के चरम पर सभी कण तेजी से नए आकार और संरचना में पुनर्गठित होते हैं।',
          'narration': 'यह $topic का सबसे महत्वपूर्ण मोड़ है: जहां बिखरे हुए घटक मिलकर नया जीवनदायी रूप लेते हैं।',
          'dialogue': [
            {'speaker': c2, 'text': 'पुराने रूप टूट गए! और अब वे बिल्कुल नए क्रिस्टल नेटवर्क में बदल रहे हैं!'},
            {'speaker': c1, 'text': 'यही $topic का असली चमत्कार है! जो पहले नामुमकिन लगता था, वह पलक झपकते ही हो गया!'},
          ],
          'cue': 'सुनहरे भंवर में नए मजबूत अणुओं का निर्माण',
        },
        {
          'title': 'संतुलन का चक्र',
          'desc': 'सिस्टम को ज्यादा गर्म होने से बचाने के लिए सुरक्षा फीडबैक चक्र तुरंत सक्रिय हो जाते हैं।',
          'narration': 'बेकाबू ताकत नुकसान पहुंचा सकती है। कुदरती संतुलन बनाए रखने के लिए तंत्र तुरंत काम में जुट जाता है।',
          'dialogue': [
            {'speaker': c2, 'text': 'सुरक्षा चक्र चालू हो गए हैं! ऊर्जा का दबाव बिल्कुल नियंत्रित हो गया है।'},
            {'speaker': c1, 'text': 'संतुलन ही जीवन है! असली प्रणाली सिर्फ ऊर्जा पैदा नहीं करती, बल्कि खुद की रक्षा भी करती है।'},
          ],
          'cue': 'पन्ना जैसी हरी ढाल चारों ओर संतुलन बनाती हुई',
        },
        {
          'title': 'अमृत तुल्य उत्पादन',
          'desc': 'शुद्ध ऊर्जा और उपयोगी उत्पाद चारों ओर फैलकर सजीव कोशिकाओं को नया जीवन प्रदान करते हैं।',
          'narration': 'मिशन सफल हुआ: $topic ने अपने आवश्यक उत्पाद तैयार कर दिए हैं, जो सजीवों को जीवित रखते हैं।',
          'dialogue': [
            {'speaker': c2, 'text': 'उत्पादन देखिए! शुद्ध, उच्च ऊर्जा तैयार है जो जीवन को दौड़ाएगी!'},
            {'speaker': c1, 'text': 'साधारण कच्चे तत्वों से शुद्ध जीवनदायी ईंधन। यही तो $topic की असली शक्ति है!'},
          ],
          'cue': 'सुनहरी ऊर्जा की बूंदें संचार में फैलती हुई',
        },
        {
          'title': 'सृष्टि का तालमेल',
          'desc': 'होलोग्राफिक दृश्य से दिखता है कि कैसे यह नन्हा सूक्ष्म कण पूरी पृथ्वी के पारिस्थितिकी तंत्र को चला रहा है।',
          'narration': 'कोई भी घटना अकेले नहीं होती। ऐसे खरबों सूक्ष्म चक्र मिलकर हमारे पूरे ग्रह को जिंदा रखते हैं।',
          'dialogue': [
            {'speaker': c2, 'text': 'एक नन्हा सा रासायनिक कण पूरी धरती के जंगलों और जीवन को संभाले हुए है!'},
            {'speaker': c1, 'text': 'सही कहा $c2! छोटे कण को समझ लो, तो पूरी कायनात का रहस्य समझ आ जाता है!'},
          ],
          'cue': 'पृथ्वी का होलोग्राफिक ग्लोब धड़कता हुआ',
        },
        {
          'title': 'कॉमिक ज्ञान की विजय',
          'desc': '$c1 और $c2 अपनी प्रयोगशाला में लौटकर ज्ञान की जीत का जश्न मनाते हैं।',
          'narration': 'कॉमिक रोमांच पूरा हुआ। जो पहले शुष्क किताबी विषय था, अब वह एक अविस्मरणीय सचित्र कहानी बन गया।',
          'dialogue': [
            {'speaker': c2, 'text': 'मुझे अब सब समझ आ गया! यह सिर्फ रटना नहीं, बल्कि जीवन की सबसे रोमांचक जंग है!'},
            {'speaker': c1, 'text': 'शाबाश अन्वेषक! तुमने $topic पर पूरी तरह महारत हासिल कर ली है!'},
          ],
          'cue': 'युरेका बैज और कॉमिक सितारों की आतिशबाजी',
        },
      ];
    }

    // Default English Phases with Genre-specific flavor
    final isAnime = style == ComicVisualStyle.animeInspired;
    final isClassic = style == ComicVisualStyle.classicComic;
    final isCartoon = style == ComicVisualStyle.cartoon;
    final isStorybook = style == ComicVisualStyle.storybook;

    return [
      {
        'title': isAnime ? 'The Awakening Call' : isStorybook ? 'The Whispering Mystery' : 'The Everyday Mystery',
        'desc': '$c1 and $c2 witness a real-world demonstration of $topic that defies conventional textbook wisdom.',
        'narration': 'Every scientific journey starts with a daring question: how does $topic quietly govern our world from within?',
        'dialogue': [
          {'speaker': c2, 'text': isAnime ? 'Master $c1! Can human eyes truly grasp the hidden power of $topic?!' : '$c1! If $topic is everywhere, where is its hidden engine?'},
          {'speaker': c1, 'text': isAnime ? 'Open your eyes, $c2! True power begins at the atomic realm! Dimension Flip, ENGAGE!' : isClassic ? 'By the stars! Time to shrink down and investigate! Dimension Flip activated!' : 'Because nature builds its greatest wonders at the nanoscale! Let’s dive in!'},
        ],
        'cue': 'Dimension Flip vortex spiraling downward to microscopic scale',
      },
      {
        'title': isAnime ? 'Entering the Core Domain' : isClassic ? 'Inside the Atomic Stronghold' : 'Descent into the Engine',
        'desc': 'Shrunk down into the core structure, $c1 and $c2 marvel as raw reactant particles assemble like clockwork.',
        'narration': 'At nanoscale dimensions, $topic resembles a precision factory. Incoming building blocks align in electrostatic formation.',
        'dialogue': [
          {'speaker': c2, 'text': isCartoon ? 'Whoa! Look at those bouncy particles queuing up like hungry shoppers!' : 'Look at the concentration gradient! Millions of reactants locking into key positions!'},
          {'speaker': c1, 'text': isAnime ? 'Stay focused, $c2! Without exact alignment, the activation barrier can never be shattered!' : 'Precision engineering! The reaction setup is primed and ready!'},
        ],
        'cue': 'Glowing reactant molecules locking into catalytic docks',
      },
      {
        'title': isAnime ? 'The Solar Burst Strike' : isClassic ? 'ZAP! The High-Voltage Spark' : 'The Spark of Activation',
        'desc': 'A dazzling surge of energy strikes the reaction chamber, exciting electrons and breaking existing chemical bonds.',
        'narration': 'Energy cannot be created or destroyed—only transferred. An incoming excitation wave shatters the old bonds to ignite $topic.',
        'dialogue': [
          {'speaker': c1, 'text': isAnime ? 'Brace yourself! The threshold has broken! Witness the Ultimate Excitation!' : isClassic ? 'ZAP! The activation threshold is breached! Hold on to your gauntlets!' : 'Hold tight, $c2! The bonds are splitting wide open!'},
          {'speaker': c2, 'text': isAnime ? 'NANI?! The valence electrons are leaping to higher orbits at hyper-speed!' : 'Unbelievable! Reaction kinetics are skyrocketing!'},
        ],
        'cue': 'Shockwave of radiant cyan photons breaking chemical bonds',
      },
      {
        'title': isAnime ? 'The Ultimate Fusion Synthesis' : isClassic ? 'The Heroic Transformation' : 'The Catalyst Transformation',
        'desc': 'At the turning point, energized intermediates rapidly lock together to form brand new, high-energy structures.',
        'narration': 'This is the climax of $topic: chaotic raw materials are synthesized into structured, life-giving compounds.',
        'dialogue': [
          {'speaker': c2, 'text': 'The old structures disassembled completely—and now they are locking into a brand new matrix!'},
          {'speaker': c1, 'text': isAnime ? 'EUREKA! That is the secret technique of $topic! What seemed impossible is conquered!' : 'Eureka! What textbook theory called complex just happened in milliseconds!'},
        ],
        'cue': 'Swirling golden vortex forming brand new molecular bonds',
      },
      {
        'title': 'The Balancing Cascade',
        'desc': 'Regulatory feedback loops and molecular pumps engage to stabilize pressure and prevent system overload.',
        'narration': 'Unchecked power would destroy the host. Negative feedback loops immediately regulate output to preserve homeostatic equilibrium.',
        'dialogue': [
          {'speaker': c2, 'text': 'The feedback inhibitors are engaging! The thermal output is leveling off into perfect harmony.'},
          {'speaker': c1, 'text': 'Homeostasis in action! A true cosmic system doesn\'t just generate energy—it protects itself.'},
        ],
        'cue': 'Emerald feedback shields glowing as equilibrium locks into place',
      },
      {
        'title': isStorybook ? 'The Golden Harvest' : 'The Essential Harvest',
        'desc': 'Luminous canisters of pure output fuel surge outward into circulation, ready to power living tissues.',
        'narration': 'The mission succeeds: $topic yields clean, high-density outputs that sustain life, work, and growth across the organism.',
        'dialogue': [
          {'speaker': c2, 'text': 'Look at the yield! Clean, high-density stored fuel ready to power living cells!'},
          {'speaker': c1, 'text': 'From raw incoming elements to life-giving fuel. That is the true wonder of $topic!'},
        ],
        'cue': 'Radiant golden energy capsules dispersing into circulation',
      },
      {
        'title': 'The Global Symphony',
        'desc': 'Holographic projection zooms out from the microscopic cell to reveal how this reaction sustains planetary ecosystems.',
        'narration': 'No reaction occurs in isolation. Billions of these microscopic events synchronize every second to sustain our global biosphere.',
        'dialogue': [
          {'speaker': c2, 'text': 'A single atomic reaction here ripples outward across oceans, forests, and planetary atmosphere!'},
          {'speaker': c1, 'text': 'Indeed, $c2. Master the small, and the universe reveals its grandest blueprint!'},
        ],
        'cue': 'Planetary holographic sphere pulsating in sync with atomic reactions',
      },
      {
        'title': isAnime ? 'Victory: Scholar Ascended!' : 'The Comic Epiphany',
        'desc': '$c1 and $c2 return to full scale in their laboratory, celebrating their complete mastery of $topic.',
        'narration': 'The comic adventure concludes. What once looked like dry textbook jargon is now an unforgettable illustrated memory.',
        'dialogue': [
          {'speaker': c2, 'text': isAnime ? 'I understand now, Master! It\'s not just rote memorization—it\'s an epic battle for balance!' : 'I get it now, $c1! It’s not just abstract formulas—it’s an epic survival story!'},
          {'speaker': c1, 'text': 'You have officially conquered $topic, explorer! Onward to the next cosmic issue!'},
        ],
        'cue': 'Burst of comic stars and eureka badges celebrating mastery',
      },
    ];
  }

  Map<String, dynamic> _getLocalizedMetadata(
    String topic,
    String lang,
    String style,
    String level,
  ) {
    if (lang == 'hindi') {
      return {
        'storyTitle': '$topic का महाकाव्य कॉमिक सफर',
        'shortIntroduction':
            '$topic की आंतरिक दुनिया में एक सचित्र, रोमांचक यात्रा! जानिए कैसे प्रकृति के गुप्त नियम ऊर्जा का रूपांतरण करते हैं और जीवन को शक्ति प्रदान करते हैं।',
        'storySetting': 'प्रयोगशाला से $topic के सूक्ष्म आणविक संसार तक',
        'keyConcepts': [
          {
            'term': '$topic प्रक्रिया',
            'definition': 'मुख्य जैविक या भौतिक श्रृंखला जो कच्चे तत्वों को उपयोगी ऊर्जा और उत्पादों में बदलती है।',
          },
          {
            'term': 'सक्रियण ऊर्जा सीमा',
            'definition': 'वह न्यूनतम प्रारंभिक ऊर्जा जो अणुओं के बीच नए बंधन बनाने के लिए आवश्यक होती है।',
          },
          {
            'term': 'संतुलन चक्र (होमियोस्टैसिस)',
            'definition': 'स्वयं-नियंत्रित सुरक्षा प्रणाली जो प्रतिक्रिया को सुरक्षित दर पर बनाए रखती है।',
          },
        ],
        'analogies': [
          {
            'targetConcept': topic,
            'everydayAnalogy':
                'यह एक सौर ऊर्जा से चलने वाली बेकरी की तरह है: धूप ऊर्जा देती है, पानी और हवा आटा बनते हैं, और ताजा रोटी जीवन को शक्ति देती है।',
            'whyItWorks':
                'दोनों ही बिखरी हुई बाहरी ऊर्जा को समेटकर सघन, उपयोगी पोषण में बदल देते हैं।',
          },
        ],
        'summary':
            'इस कॉमिक कहानी के जरिए $topic अमूर्त सूत्रों से निकलकर ऊर्जा और जीवन के जीवंत सचित्र अनुभव में बदल जाता है।',
        'quizQuestions': [
          {
            'question': 'कहानी में $topic की शुरुआत किस ऊर्जा से होती है?',
            'options': [
              'सक्रियण ऊर्जा जो पुराने बंधनों को तोड़कर इलेक्ट्रॉनों को उत्तेजित करती है',
              'शीतलन जो अणुओं को जमा देता है',
              'पात्र को जोर से हिलाने पर उत्पन्न घर्षण',
              'बिना किसी नियम के अचानक हुआ कोई संयोग',
            ],
            'correctAnswerIndex': 0,
            'explanation':
                'सक्रियण ऊर्जा मिलने पर ही अणु सक्रिय होते हैं और नए रासायनिक बंधन बन पाते हैं।',
          },
          {
            'question': 'प्रतिक्रिया के दौरान सुरक्षा चक्र क्यों सक्रिय होते हैं?',
            'options': [
              'संतुलन बनाए रखने और अत्यधिक दबाव या गर्मी को रोकने के लिए',
              'कोशिका को हमेशा के लिए बंद करने के लिए',
              'नए बने अणुओं को नष्ट करने के लिए',
              'समय को पीछे ले जाने के लिए',
            ],
            'correctAnswerIndex': 0,
            'explanation':
                'फीडबैक चक्र यह सुनिश्चित करते हैं कि प्रतिक्रिया सुरक्षित और नियंत्रित गति से चले।',
          },
        ],
      };
    }

    return {
      'storyTitle': 'The Epic Chronicle of $topic',
      'shortIntroduction':
          'An illustrated high-stakes voyage into the inner workings of $topic. Discover how microscopic forces transform matter, balance systems, and shape the world around us!',
      'storySetting': 'From the research laboratory into the microscopic realm of $topic',
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
              'Think of $topic like a high-tech solar bakery: sunlight delivers the energy, water and air provide the dough, and fresh-baked nutrients fuel life.',
          'whyItWorks':
              'Both systems take diffuse external inputs, concentrate them through an organized engine, and output dense usable sustenance.',
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
      ],
    };
  }
}
