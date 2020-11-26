import 'package:flutter/painting.dart';

///Summarizes various String Extensions
extension TextHelpers on String {
  ///Returns number of Lines needed to paint whole text on the screen.
  ///
  /// Method is usable to understand if string will fit into Text.maxLines
  /// [style] - text style used for text painting
  /// [maxWidth] - maximum width of the area for text painting
  int numberOfTextLinesToDisplay({TextStyle style, double maxWidth}) {
    final textSpan = TextSpan(text: this, style: style);
    final textPainter =
        TextPainter(text: textSpan, textDirection: TextDirection.ltr);
    textPainter.layout(maxWidth: maxWidth ?? double.infinity);
    final lineMetrics = textPainter.computeLineMetrics();
    return lineMetrics.length;
  }
}
