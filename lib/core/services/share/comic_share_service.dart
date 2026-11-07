// ignore_for_file: deprecated_member_use
import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';
import '../../../data/models/comic_story_model.dart';

/// Social and document sharing service for comic stories and PDF exports
class ComicShareService {
  final bool isTestMode;
  String? lastSharedText;
  String? lastSharedSubject;

  ComicShareService({this.isTestMode = false});

  /// Shares a rich educational text summary of the comic story
  Future<bool> shareStorySummary(ComicStory story) async {
    final buffer = StringBuffer()
      ..writeln('📖 ${story.storyTitle}')
      ..writeln('Topic: ${story.originalTopic} (${story.learningLevel})')
      ..writeln()
      ..writeln('Overview:')
      ..writeln(story.shortIntroduction)
      ..writeln()
      ..writeln('Summary:')
      ..writeln(story.summary)
      ..writeln()
      ..writeln('Created with Lorvani — Turn Notes into Comics!');

    final text = buffer.toString();
    lastSharedText = text;
    lastSharedSubject = story.storyTitle;

    if (isTestMode) return true;

    try {
      final result = await Share.share(
        text,
        subject: story.storyTitle,
      );
      return result.status == ShareResultStatus.success;
    } catch (e) {
      debugPrint('ComicShareService share error: $e');
      return false;
    }
  }

  /// Shares an individual comic panel scene and dialogue
  Future<bool> shareComicPanel({
    required ComicStory story,
    required ComicPanelModel panel,
  }) async {
    final buffer = StringBuffer()
      ..writeln('⚡ ${story.storyTitle} — Panel ${panel.panelNumber}: ${panel.panelTitle}')
      ..writeln()
      ..writeln(panel.narration);

    if (panel.dialogue.isNotEmpty) {
      buffer.writeln();
      for (final d in panel.dialogue) {
        buffer.writeln('${d.speaker}: "${d.text}"');
      }
    }

    buffer.writeln('\nRead in Lorvani AI Comic Learning!');

    final text = buffer.toString();
    lastSharedText = text;
    lastSharedSubject = panel.panelTitle;

    if (isTestMode) return true;

    try {
      final result = await Share.share(text);
      return result.status == ShareResultStatus.success;
    } catch (e) {
      debugPrint('ComicShareService panel share error: $e');
      return false;
    }
  }

  /// Shares the generated printable comic book PDF document
  Future<bool> sharePdfComicBook({
    required ComicStory story,
    required List<int> pdfBytes,
  }) async {
    final fileName = '${story.storyTitle.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}.pdf';
    lastSharedSubject = fileName;

    if (isTestMode) return true;

    try {
      final xFile = XFile.fromData(
        Uint8List.fromList(pdfBytes),
        name: fileName,
        mimeType: 'application/pdf',
      );
      final result = await Share.shareXFiles(
        [xFile],
        text: 'Printable Comic Book: ${story.storyTitle}',
        subject: story.storyTitle,
      );
      return result.status == ShareResultStatus.success;
    } catch (e) {
      debugPrint('ComicShareService PDF share error: $e');
      return false;
    }
  }
}
