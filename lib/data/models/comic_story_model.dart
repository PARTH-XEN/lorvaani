/// Dialogue line inside a comic panel
class ComicDialogue {
  final String speaker;
  final String text;

  const ComicDialogue({
    required this.speaker,
    required this.text,
  });

  factory ComicDialogue.fromJson(Map<String, dynamic> json) {
    return ComicDialogue(
      speaker: json['speaker'] as String? ?? 'Narrator',
      text: json['text'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'speaker': speaker,
      'text': text,
    };
  }
}

/// Individual illustrated comic panel model
class ComicPanelModel {
  final int panelNumber;
  final String panelTitle;
  final String panelDescription;
  final String narration;
  final List<ComicDialogue> dialogue;
  final String keyVisualCue;
  final String? imageUrl;

  const ComicPanelModel({
    required this.panelNumber,
    required this.panelTitle,
    required this.panelDescription,
    required this.narration,
    required this.dialogue,
    required this.keyVisualCue,
    this.imageUrl,
  });

  factory ComicPanelModel.fromJson(Map<String, dynamic> json) {
    final rawDialogue = json['dialogue'] as List? ?? [];
    return ComicPanelModel(
      panelNumber: json['panelNumber'] as int? ?? 1,
      panelTitle: json['panelTitle'] as String? ?? 'Panel',
      panelDescription: json['panelDescription'] as String? ?? '',
      narration: json['narration'] as String? ?? '',
      dialogue: rawDialogue
          .map((d) => ComicDialogue.fromJson(Map<String, dynamic>.from(d as Map)))
          .toList(),
      keyVisualCue: json['keyVisualCue'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'panelNumber': panelNumber,
      'panelTitle': panelTitle,
      'panelDescription': panelDescription,
      'narration': narration,
      'dialogue': dialogue.map((d) => d.toJson()).toList(),
      'keyVisualCue': keyVisualCue,
      'imageUrl': imageUrl,
    };
  }

  ComicPanelModel copyWith({String? imageUrl}) {
    return ComicPanelModel(
      panelNumber: panelNumber,
      panelTitle: panelTitle,
      panelDescription: panelDescription,
      narration: narration,
      dialogue: dialogue,
      keyVisualCue: keyVisualCue,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

/// Character description for consistent narrative and image prompts
class ComicCharacter {
  final String name;
  final String role;
  final String visualDescription;

  const ComicCharacter({
    required this.name,
    required this.role,
    required this.visualDescription,
  });

  factory ComicCharacter.fromJson(Map<String, dynamic> json) {
    return ComicCharacter(
      name: json['name'] as String? ?? 'Character',
      role: json['role'] as String? ?? 'Guide',
      visualDescription: json['visualDescription'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'role': role,
      'visualDescription': visualDescription,
    };
  }
}

/// Key educational concept and definition
class ComicKeyConcept {
  final String term;
  final String definition;

  const ComicKeyConcept({
    required this.term,
    required this.definition,
  });

  factory ComicKeyConcept.fromJson(Map<String, dynamic> json) {
    return ComicKeyConcept(
      term: json['term'] as String? ?? '',
      definition: json['definition'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'term': term,
      'definition': definition,
    };
  }
}

/// Everyday analogy explaining complex educational theories
class ComicAnalogy {
  final String targetConcept;
  final String everydayAnalogy;
  final String whyItWorks;

  const ComicAnalogy({
    required this.targetConcept,
    required this.everydayAnalogy,
    required this.whyItWorks,
  });

  factory ComicAnalogy.fromJson(Map<String, dynamic> json) {
    return ComicAnalogy(
      targetConcept: json['targetConcept'] as String? ?? '',
      everydayAnalogy: json['everydayAnalogy'] as String? ?? '',
      whyItWorks: json['whyItWorks'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'targetConcept': targetConcept,
      'everydayAnalogy': everydayAnalogy,
      'whyItWorks': whyItWorks,
    };
  }
}

/// Interactive quiz question
class ComicQuizQuestion {
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanation;

  const ComicQuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
  });

  factory ComicQuizQuestion.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options'] as List? ?? [];
    return ComicQuizQuestion(
      question: json['question'] as String? ?? '',
      options: rawOptions.map((o) => o.toString()).toList(),
      correctAnswerIndex: json['correctAnswerIndex'] as int? ?? 0,
      explanation: json['explanation'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'options': options,
      'correctAnswerIndex': correctAnswerIndex,
      'explanation': explanation,
    };
  }
}

/// Complete Lorvani Comic Story Root Model
class ComicStory {
  final String id;
  final String storyTitle;
  final String originalTopic;
  final String learningLevel;
  final String visualStyle;
  final String language;
  final String shortIntroduction;
  final String storySetting;
  final List<ComicCharacter> characters;
  final List<ComicPanelModel> panels;
  final List<ComicKeyConcept> keyConcepts;
  final List<ComicAnalogy> analogies;
  final String summary;
  final List<ComicQuizQuestion> quizQuestions;
  final DateTime createdAt;
  final bool isSaved;

  const ComicStory({
    required this.id,
    required this.storyTitle,
    required this.originalTopic,
    required this.learningLevel,
    required this.visualStyle,
    required this.language,
    required this.shortIntroduction,
    required this.storySetting,
    required this.characters,
    required this.panels,
    required this.keyConcepts,
    required this.analogies,
    required this.summary,
    required this.quizQuestions,
    required this.createdAt,
    this.isSaved = false,
  });

  factory ComicStory.fromJson(Map<String, dynamic> json, {String? id}) {
    final rawChars = json['characters'] as List? ?? [];
    final rawPanels = json['panels'] as List? ?? [];
    final rawConcepts = json['keyConcepts'] as List? ?? [];
    final rawAnalogies = json['analogies'] as List? ?? [];
    final rawQuizzes = json['quizQuestions'] as List? ?? [];

    return ComicStory(
      id: id ?? json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      storyTitle: json['storyTitle'] as String? ?? 'Untitled Story',
      originalTopic: json['originalTopic'] as String? ?? '',
      learningLevel: json['learningLevel'] as String? ?? 'Intermediate',
      visualStyle: json['visualStyle'] as String? ?? 'Cinematic Comic',
      language: json['language'] as String? ?? 'English',
      shortIntroduction: json['shortIntroduction'] as String? ?? '',
      storySetting: json['storySetting'] as String? ?? '',
      characters: rawChars
          .map((c) => ComicCharacter.fromJson(Map<String, dynamic>.from(c as Map)))
          .toList(),
      panels: rawPanels
          .map((p) => ComicPanelModel.fromJson(Map<String, dynamic>.from(p as Map)))
          .toList(),
      keyConcepts: rawConcepts
          .map((k) => ComicKeyConcept.fromJson(Map<String, dynamic>.from(k as Map)))
          .toList(),
      analogies: rawAnalogies
          .map((a) => ComicAnalogy.fromJson(Map<String, dynamic>.from(a as Map)))
          .toList(),
      summary: json['summary'] as String? ?? '',
      quizQuestions: rawQuizzes
          .map((q) => ComicQuizQuestion.fromJson(Map<String, dynamic>.from(q as Map)))
          .toList(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      isSaved: json['isSaved'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'storyTitle': storyTitle,
      'originalTopic': originalTopic,
      'learningLevel': learningLevel,
      'visualStyle': visualStyle,
      'language': language,
      'shortIntroduction': shortIntroduction,
      'storySetting': storySetting,
      'characters': characters.map((c) => c.toJson()).toList(),
      'panels': panels.map((p) => p.toJson()).toList(),
      'keyConcepts': keyConcepts.map((k) => k.toJson()).toList(),
      'analogies': analogies.map((a) => a.toJson()).toList(),
      'summary': summary,
      'quizQuestions': quizQuestions.map((q) => q.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'isSaved': isSaved,
    };
  }

  ComicStory copyWith({
    List<ComicPanelModel>? panels,
    bool? isSaved,
  }) {
    return ComicStory(
      id: id,
      storyTitle: storyTitle,
      originalTopic: originalTopic,
      learningLevel: learningLevel,
      visualStyle: visualStyle,
      language: language,
      shortIntroduction: shortIntroduction,
      storySetting: storySetting,
      characters: characters,
      panels: panels ?? this.panels,
      keyConcepts: keyConcepts,
      analogies: analogies,
      summary: summary,
      quizQuestions: quizQuestions,
      createdAt: createdAt,
      isSaved: isSaved ?? this.isSaved,
    );
  }
}

