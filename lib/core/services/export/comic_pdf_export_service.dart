import 'dart:ui';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../../../data/models/comic_story_model.dart';

/// Service generating multi-page printable comic book PDF documents
class ComicPdfExportService {
  const ComicPdfExportService();

  /// Generates printable graphic novel PDF bytes from a ComicStory
  List<int> generateComicPdfBytes(ComicStory story) {
    final document = PdfDocument();
    document.pageSettings.margins.all = 36; // 0.5 inch margins

    try {
      _buildCoverPage(document, story);
      _buildComicPanelPages(document, story);
      _buildEducationalAppendixPage(document, story);

      final bytes = document.saveSync();
      return bytes;
    } finally {
      document.dispose();
    }
  }

  void _buildCoverPage(PdfDocument document, ComicStory story) {
    final page = document.pages.add();
    final graphics = page.graphics;
    final size = page.getClientSize();

    final titleFont = PdfStandardFont(PdfFontFamily.helvetica, 24, style: PdfFontStyle.bold);
    final headerFont = PdfStandardFont(PdfFontFamily.helvetica, 14, style: PdfFontStyle.bold);
    final bodyFont = PdfStandardFont(PdfFontFamily.helvetica, 10);
    final captionFont = PdfStandardFont(PdfFontFamily.helvetica, 9, style: PdfFontStyle.italic);

    // Top Brand Bar
    final brandBrush = PdfSolidBrush(PdfColor(128, 84, 233)); // Comic Purple #8054E9
    graphics.drawRectangle(
      brush: brandBrush,
      bounds: Rect.fromLTWH(0, 0, size.width, 36),
    );

    final whiteBrush = PdfSolidBrush(PdfColor(255, 255, 255));
    graphics.drawString(
      'LORVANI — AI COMIC LEARNING UNIVERSE',
      PdfStandardFont(PdfFontFamily.helvetica, 11, style: PdfFontStyle.bold),
      brush: whiteBrush,
      bounds: Rect.fromLTWH(12, 10, size.width - 24, 20),
    );

    double currentY = 54;

    // Story Title
    final darkBrush = PdfSolidBrush(PdfColor(23, 21, 31)); // Deep Charcoal
    graphics.drawString(
      story.storyTitle,
      titleFont,
      brush: darkBrush,
      bounds: Rect.fromLTWH(0, currentY, size.width, 32),
    );
    currentY += 36;

    // Topic & Metadata Subheader
    final metaText =
        'Topic: ${story.originalTopic}  •  Style: ${story.visualStyle}  •  Level: ${story.learningLevel}';
    graphics.drawString(
      metaText,
      headerFont,
      brush: PdfSolidBrush(PdfColor(244, 108, 168)), // Comic Pink
      bounds: Rect.fromLTWH(0, currentY, size.width, 20),
    );
    currentY += 28;

    // Separator line
    graphics.drawLine(
      PdfPen(PdfColor(200, 200, 200), width: 1.5),
      Offset(0, currentY),
      Offset(size.width, currentY),
    );
    currentY += 16;

    // Introduction Callout Box
    if (story.shortIntroduction.isNotEmpty) {
      final introBoxBrush = PdfSolidBrush(PdfColor(245, 243, 255));
      graphics.drawRectangle(
        brush: introBoxBrush,
        pen: PdfPen(PdfColor(128, 84, 233), width: 1),
        bounds: Rect.fromLTWH(0, currentY, size.width, 54),
      );

      graphics.drawString(
        'MISSION BRIEF:',
        PdfStandardFont(PdfFontFamily.helvetica, 9, style: PdfFontStyle.bold),
        brush: PdfSolidBrush(PdfColor(128, 84, 233)),
        bounds: Rect.fromLTWH(12, currentY + 8, size.width - 24, 14),
      );

      graphics.drawString(
        story.shortIntroduction,
        bodyFont,
        brush: darkBrush,
        bounds: Rect.fromLTWH(12, currentY + 24, size.width - 24, 24),
      );
      currentY += 68;
    }

    // Setting Context
    if (story.storySetting.isNotEmpty) {
      graphics.drawString(
        'Story Setting: ${story.storySetting}',
        captionFont,
        brush: PdfSolidBrush(PdfColor(100, 100, 100)),
        bounds: Rect.fromLTWH(0, currentY, size.width, 16),
      );
      currentY += 24;
    }

    // Cast of Characters Section
    if (story.characters.isNotEmpty) {
      graphics.drawString(
        'CAST OF CHARACTERS',
        PdfStandardFont(PdfFontFamily.helvetica, 12, style: PdfFontStyle.bold),
        brush: PdfSolidBrush(PdfColor(72, 201, 232)), // Sky Cyan #48C9E8
        bounds: Rect.fromLTWH(0, currentY, size.width, 20),
      );
      currentY += 22;

      for (final char in story.characters) {
        final charHeader = '${char.name} (${char.role})';
        graphics.drawString(
          '• $charHeader: ${char.visualDescription}',
          bodyFont,
          brush: darkBrush,
          bounds: Rect.fromLTWH(8, currentY, size.width - 16, 16),
        );
        currentY += 18;
      }
      currentY += 14;
    }

    // Summary Section
    if (story.summary.isNotEmpty) {
      graphics.drawString(
        'STORY SUMMARY',
        PdfStandardFont(PdfFontFamily.helvetica, 12, style: PdfFontStyle.bold),
        brush: darkBrush,
        bounds: Rect.fromLTWH(0, currentY, size.width, 20),
      );
      currentY += 22;

      graphics.drawString(
        story.summary,
        bodyFont,
        brush: darkBrush,
        bounds: Rect.fromLTWH(0, currentY, size.width, 60),
      );
    }
  }

  void _buildComicPanelPages(PdfDocument document, ComicStory story) {
    const panelsPerPage = 2;
    final totalPages = (story.panels.length / panelsPerPage).ceil();

    for (int pageIdx = 0; pageIdx < totalPages; pageIdx++) {
      final page = document.pages.add();
      final graphics = page.graphics;
      final size = page.getClientSize();

      final startIndex = pageIdx * panelsPerPage;
      final pagePanels = story.panels.skip(startIndex).take(panelsPerPage).toList();

      final panelHeight = (size.height - 20) / panelsPerPage;

      for (int i = 0; i < pagePanels.length; i++) {
        final panel = pagePanels[i];
        final panelY = i * (panelHeight + 16);
        _drawSingleComicPanel(graphics, panel, 0, panelY, size.width, panelHeight);
      }
    }
  }

  void _drawSingleComicPanel(
    PdfGraphics graphics,
    ComicPanelModel panel,
    double x,
    double y,
    double width,
    double height,
  ) {
    // Outer Panel Box
    final panelPen = PdfPen(PdfColor(23, 21, 31), width: 2);
    final panelBg = PdfSolidBrush(PdfColor(250, 250, 252));
    graphics.drawRectangle(pen: panelPen, brush: panelBg, bounds: Rect.fromLTWH(x, y, width, height));

    // Panel Header Banner
    final headerBrush = PdfSolidBrush(PdfColor(255, 145, 77)); // Vibrant Orange #FF914D
    graphics.drawRectangle(
      brush: headerBrush,
      bounds: Rect.fromLTWH(x, y, width, 24),
    );

    final titleFont = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.bold);
    graphics.drawString(
      'PANEL ${panel.panelNumber}: ${panel.panelTitle.toUpperCase()}',
      titleFont,
      brush: PdfSolidBrush(PdfColor(0, 0, 0)),
      bounds: Rect.fromLTWH(x + 10, y + 6, width - 20, 16),
    );

    double currentY = y + 32;

    // Visual Cue Callout
    if (panel.keyVisualCue.isNotEmpty) {
      final cueFont = PdfStandardFont(PdfFontFamily.helvetica, 9, style: PdfFontStyle.bold);
      graphics.drawString(
        'Scene Focal Point: ${panel.keyVisualCue}',
        cueFont,
        brush: PdfSolidBrush(PdfColor(72, 201, 232)),
        bounds: Rect.fromLTWH(x + 12, currentY, width - 24, 14),
      );
      currentY += 18;
    }

    // Narration Box
    if (panel.narration.isNotEmpty) {
      final narrBox = Rect.fromLTWH(x + 12, currentY, width - 24, 38);
      graphics.drawRectangle(
        brush: PdfSolidBrush(PdfColor(255, 249, 214)), // Electric Yellow light tint
        pen: PdfPen(PdfColor(255, 216, 77), width: 1),
        bounds: narrBox,
      );

      final narrFont = PdfStandardFont(PdfFontFamily.helvetica, 9, style: PdfFontStyle.italic);
      graphics.drawString(
        panel.narration,
        narrFont,
        brush: PdfSolidBrush(PdfColor(23, 21, 31)),
        bounds: Rect.fromLTWH(x + 18, currentY + 6, width - 36, 26),
      );
      currentY += 46;
    }

    // Dialogue Lines
    if (panel.dialogue.isNotEmpty) {
      final dialFont = PdfStandardFont(PdfFontFamily.helvetica, 9);
      for (final d in panel.dialogue) {
        final dialText = '${d.speaker.toUpperCase()}: "${d.text}"';
        graphics.drawString(
          dialText,
          dialFont,
          brush: PdfSolidBrush(PdfColor(40, 40, 40)),
          bounds: Rect.fromLTWH(x + 16, currentY, width - 32, 14),
        );
        currentY += 16;
      }
    }
  }

  void _buildEducationalAppendixPage(PdfDocument document, ComicStory story) {
    final page = document.pages.add();
    final graphics = page.graphics;
    final size = page.getClientSize();

    final sectionFont = PdfStandardFont(PdfFontFamily.helvetica, 14, style: PdfFontStyle.bold);
    final itemFont = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.bold);
    final descFont = PdfStandardFont(PdfFontFamily.helvetica, 9);
    final darkBrush = PdfSolidBrush(PdfColor(23, 21, 31));

    double currentY = 10;

    // Key Concepts
    if (story.keyConcepts.isNotEmpty) {
      graphics.drawString(
        'KEY EDUCATIONAL CONCEPTS',
        sectionFont,
        brush: PdfSolidBrush(PdfColor(128, 84, 233)),
        bounds: Rect.fromLTWH(0, currentY, size.width, 22),
      );
      currentY += 24;

      for (final concept in story.keyConcepts) {
        graphics.drawString('• ${concept.term}', itemFont, brush: darkBrush, bounds: Rect.fromLTWH(6, currentY, size.width, 14));
        currentY += 14;
        graphics.drawString(concept.definition, descFont, brush: darkBrush, bounds: Rect.fromLTWH(18, currentY, size.width - 24, 16));
        currentY += 20;
      }
      currentY += 12;
    }

    // Everyday Analogies
    if (story.analogies.isNotEmpty) {
      graphics.drawString(
        'EVERYDAY ANALOGIES',
        sectionFont,
        brush: PdfSolidBrush(PdfColor(255, 145, 77)),
        bounds: Rect.fromLTWH(0, currentY, size.width, 22),
      );
      currentY += 24;

      for (final analogy in story.analogies) {
        graphics.drawString('• Concept: ${analogy.targetConcept}', itemFont, brush: darkBrush, bounds: Rect.fromLTWH(6, currentY, size.width, 14));
        currentY += 14;
        graphics.drawString('Analogy: ${analogy.everydayAnalogy} (Why: ${analogy.whyItWorks})', descFont, brush: darkBrush, bounds: Rect.fromLTWH(18, currentY, size.width - 24, 24));
        currentY += 28;
      }
      currentY += 12;
    }

    // Quiz Questions & Answer Key
    if (story.quizQuestions.isNotEmpty) {
      graphics.drawString(
        'QUIZ & ANSWER KEY',
        sectionFont,
        brush: PdfSolidBrush(PdfColor(72, 201, 232)),
        bounds: Rect.fromLTWH(0, currentY, size.width, 22),
      );
      currentY += 24;

      for (int i = 0; i < story.quizQuestions.length; i++) {
        final q = story.quizQuestions[i];
        final correctOption = q.correctAnswerIndex < q.options.length ? q.options[q.correctAnswerIndex] : '';
        graphics.drawString(
          'Q${i + 1}: ${q.question}',
          itemFont,
          brush: darkBrush,
          bounds: Rect.fromLTWH(6, currentY, size.width, 14),
        );
        currentY += 14;
        graphics.drawString(
          'Answer: $correctOption — ${q.explanation}',
          descFont,
          brush: PdfSolidBrush(PdfColor(16, 185, 129)), // Green
          bounds: Rect.fromLTWH(18, currentY, size.width - 24, 16),
        );
        currentY += 20;
      }
    }
  }
}
