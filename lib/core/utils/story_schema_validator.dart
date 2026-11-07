/// Exception thrown when generated LLM JSON violates required schema
class StorySchemaValidationException implements Exception {
  final String message;
  final String? missingField;

  const StorySchemaValidationException(this.message, {this.missingField});

  @override
  String toString() =>
      'StorySchemaValidationException: $message (field: $missingField)';
}

/// Strict validator ensuring generated story JSON adheres to Lorvani standards
class StorySchemaValidator {
  const StorySchemaValidator();

  /// Validates raw JSON map structure before constructing [ComicStory]
  void validate(Map<String, dynamic> json) {
    _requireString(json, 'storyTitle');
    _requireString(json, 'originalTopic', allowEmpty: true);
    _requireString(json, 'shortIntroduction');
    _requireString(json, 'storySetting');

    // Validate characters
    if (!json.containsKey('characters') || json['characters'] is! List) {
      throw const StorySchemaValidationException(
        'Missing or invalid "characters" list.',
        missingField: 'characters',
      );
    }
    final characters = json['characters'] as List;
    if (characters.isEmpty) {
      throw const StorySchemaValidationException(
        'Story must include at least one character.',
        missingField: 'characters',
      );
    }
    for (int i = 0; i < characters.length; i++) {
      final char = characters[i];
      if (char is! Map) {
        throw StorySchemaValidationException(
          'Character at index $i is not a valid object.',
          missingField: 'characters[$i]',
        );
      }
      _requireString(char, 'name', parent: 'characters[$i]');
      _requireString(char, 'visualDescription', parent: 'characters[$i]');
    }

    // Validate panels
    if (!json.containsKey('panels') || json['panels'] is! List) {
      throw const StorySchemaValidationException(
        'Missing or invalid "panels" list.',
        missingField: 'panels',
      );
    }
    final panels = json['panels'] as List;
    if (panels.length < 2) {
      throw StorySchemaValidationException(
        'Story must include at least 2 comic panels, found ${panels.length}.',
        missingField: 'panels',
      );
    }
    for (int i = 0; i < panels.length; i++) {
      final p = panels[i];
      if (p is! Map) {
        throw StorySchemaValidationException(
          'Panel at index $i is not a valid object.',
          missingField: 'panels[$i]',
        );
      }
      _requireString(p, 'panelDescription', parent: 'panels[$i]');
      _requireString(p, 'narration', parent: 'panels[$i]');
      if (!p.containsKey('dialogue') || p['dialogue'] is! List) {
        throw StorySchemaValidationException(
          'Panel at index $i is missing "dialogue" array.',
          missingField: 'panels[$i].dialogue',
        );
      }
    }

    // Validate key concepts
    if (json.containsKey('keyConcepts') && json['keyConcepts'] is List) {
      final concepts = json['keyConcepts'] as List;
      for (int i = 0; i < concepts.length; i++) {
        final c = concepts[i];
        if (c is Map) {
          _requireString(c, 'term', parent: 'keyConcepts[$i]');
          _requireString(c, 'definition', parent: 'keyConcepts[$i]');
        }
      }
    }

    // Validate analogies
    if (json.containsKey('analogies') && json['analogies'] is List) {
      final analogies = json['analogies'] as List;
      for (int i = 0; i < analogies.length; i++) {
        final a = analogies[i];
        if (a is Map) {
          _requireString(a, 'targetConcept', parent: 'analogies[$i]');
          _requireString(a, 'everydayAnalogy', parent: 'analogies[$i]');
        }
      }
    }

    // Validate quizzes
    if (json.containsKey('quizQuestions') && json['quizQuestions'] is List) {
      final quizzes = json['quizQuestions'] as List;
      for (int i = 0; i < quizzes.length; i++) {
        final q = quizzes[i];
        if (q is Map) {
          _requireString(q, 'question', parent: 'quizQuestions[$i]');
          if (!q.containsKey('options') || q['options'] is! List) {
            throw StorySchemaValidationException(
              'Quiz at index $i is missing "options" array.',
              missingField: 'quizQuestions[$i].options',
            );
          }
          final opts = q['options'] as List;
          if (opts.length < 2) {
            throw StorySchemaValidationException(
              'Quiz at index $i must have at least 2 options.',
              missingField: 'quizQuestions[$i].options',
            );
          }
          final answerIdx = q['correctAnswerIndex'];
          if (answerIdx is! int || answerIdx < 0 || answerIdx >= opts.length) {
            throw StorySchemaValidationException(
              'Quiz at index $i has invalid correctAnswerIndex: $answerIdx',
              missingField: 'quizQuestions[$i].correctAnswerIndex',
            );
          }
        }
      }
    }
  }

  void _requireString(
    Map map,
    String key, {
    String? parent,
    bool allowEmpty = false,
  }) {
    final prefix = parent != null ? '$parent.$key' : key;
    if (!map.containsKey(key)) {
      throw StorySchemaValidationException(
        'Missing required field "$prefix".',
        missingField: prefix,
      );
    }
    final val = map[key];
    if (val is! String) {
      throw StorySchemaValidationException(
        'Field "$prefix" must be a string, got ${val.runtimeType}.',
        missingField: prefix,
      );
    }
    if (!allowEmpty && val.trim().isEmpty) {
      throw StorySchemaValidationException(
        'Field "$prefix" cannot be empty.',
        missingField: prefix,
      );
    }
  }
}

