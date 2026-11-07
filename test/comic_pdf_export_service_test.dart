import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorevaani/core/services/export/comic_pdf_export_service.dart';
import 'package:lorevaani/data/models/comic_story_model.dart';

void main() {
  group('ComicPdfExportService Tests', () {
    const pdfService = ComicPdfExportService();

    final sampleStory = ComicStory(
      id: 'story_photosynthesis_pdf',
      storyTitle: 'Photosynthesis & Solar Power',
      originalTopic: 'Biology: Botany',
      learningLevel: 'Intermediate',
      visualStyle: 'Classic Comic',
      language: 'English',
      shortIntroduction: 'How leaves convert solar rays into sugar.',
      storySetting: 'Inside an emerald chloroplast',
      characters: const [
        ComicCharacter(
          name: 'Chlora',
          role: 'Chloroplast Chief',
          visualDescription: 'green explorer suit with light sensors',
        ),
      ],
      panels: const [
        ComicPanelModel(
          panelNumber: 1,
          panelTitle: 'Sunlight Hits Leaf',
          panelDescription: 'Solar beam strikes the cuticle layer.',
          narration: 'Photons enter the plant tissue.',
          dialogue: [
            ComicDialogue(speaker: 'Chlora', text: 'Incoming photons at 450 nanometers!'),
          ],
          keyVisualCue: 'Sunbeam prism breaking into leaf cells',
        ),
        ComicPanelModel(
          panelNumber: 2,
          panelTitle: 'Water Molecule Splitting',
          panelDescription: 'Enzymes split water into hydrogen and oxygen.',
          narration: 'Oxygen is released as a vital byproduct.',
          dialogue: [
            ComicDialogue(speaker: 'Chlora', text: 'Splitting H2O! Oxygen gas ready.'),
          ],
          keyVisualCue: 'Sparkling oxygen gas bubbles rising',
        ),
      ],
      keyConcepts: const [
        ComicKeyConcept(
          term: 'Thylakoid',
          definition: 'Membrane-bound compartment inside chloroplasts where light reactions take place.',
        ),
      ],
      analogies: const [
        ComicAnalogy(
          targetConcept: 'Photosynthesis',
          everydayAnalogy: 'Solar panels connected to a sugar bakery.',
          whyItWorks: 'Converts electromagnetic radiation directly into chemical fuel.',
        ),
      ],
      summary: 'Plants power Earth by turning sunlight, water, and CO2 into glucose.',
      quizQuestions: const [
        ComicQuizQuestion(
          question: 'What gas is released during the photolysis of water?',
          options: ['Carbon Dioxide', 'Oxygen', 'Nitrogen', 'Methane'],
          correctAnswerIndex: 1,
          explanation: 'Water molecules split to release diatomic oxygen (O2).',
        ),
      ],
      createdAt: DateTime.now(),
    );

    test('generates valid printable PDF byte stream', () {
      final bytes = pdfService.generateComicPdfBytes(sampleStory);

      expect(bytes, isNotEmpty);
      expect(bytes.length, greaterThan(1500)); // Minimum PDF structure size

      // Verify PDF file signature '%PDF-'
      final header = ascii.decode(bytes.sublist(0, 5));
      expect(header, equals('%PDF-'));
    });
  });
}

