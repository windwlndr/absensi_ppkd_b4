// pubspec.yaml dependencies:
//   url_launcher: ^6.1.7   # sesuaikan versi terbaru di pub.dev

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CopyrightWidget extends StatelessWidget {
  final String companyName;
  final int? startYear; // jika null -> hanya tampilkan current year
  final TextStyle? textStyle;
  final Widget? leadingIcon;
  final String? linkUrl; // jika tidak null, teks menjadi tappable
  final TextAlign textAlign;
  final EdgeInsetsGeometry padding;
  final bool showCopyrightSymbol;

  const CopyrightWidget({
    Key? key,
    required this.companyName,
    this.startYear,
    this.textStyle,
    this.leadingIcon,
    this.linkUrl,
    this.textAlign = TextAlign.center,
    this.padding = const EdgeInsets.symmetric(vertical: 8.0),
    this.showCopyrightSymbol = true,
  }) : super(key: key);

  String _yearText() {
    final current = DateTime.now().year;
    if (startYear == null) return '$current';
    if (startYear! >= current) return '$current';
    return '${startYear!}–$current';
  }

  TextSpan _buildTextSpan(BuildContext context) {
    final baseStyle =
        textStyle ??
        Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12) ??
        const TextStyle(fontSize: 12, color: Colors.grey);

    final yearText = _yearText();
    final copyright = showCopyrightSymbol ? '© ' : '';

    if (linkUrl == null || linkUrl!.trim().isEmpty) {
      return TextSpan(
        text: '$copyright$yearText $companyName',
        style: baseStyle,
      );
    } else {
      // buat sebagian text tappable (nama company)
      return TextSpan(
        style: baseStyle,
        children: [
          TextSpan(text: '$copyright$yearText '),
          TextSpan(
            text: companyName,
            style: baseStyle.copyWith(decoration: TextDecoration.underline),
            recognizer: TapGestureRecognizer()
              ..onTap = () async {
                final uri = Uri.tryParse(linkUrl!);
                if (uri != null) {
                  if (!await launchUrl(
                    uri,
                    mode: LaunchMode.externalApplication,
                  )) {
                    // fallback: do nothing (atau kamu bisa tunjukkan snackbar)
                  }
                }
              },
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textSpan = _buildTextSpan(context);

    final rowChildren = <Widget>[];
    if (leadingIcon != null) {
      rowChildren.add(
        Padding(
          padding: const EdgeInsets.only(right: 6.0),
          child: SizedBox(height: 16, width: 16, child: leadingIcon),
        ),
      );
    }

    rowChildren.add(
      Expanded(
        child: RichText(
          textAlign: textAlign,
          text: textSpan,
          textScaleFactor: MediaQuery.textScaleFactorOf(context),
        ),
      ),
    );

    return Semantics(
      label: 'Copyright $companyName ${_yearText()}',
      child: Padding(
        padding: padding,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: _rowAlignmentFromTextAlign(textAlign),
          children: rowChildren,
        ),
      ),
    );
  }

  MainAxisAlignment _rowAlignmentFromTextAlign(TextAlign align) {
    switch (align) {
      case TextAlign.left:
      case TextAlign.start:
        return MainAxisAlignment.start;
      case TextAlign.right:
      case TextAlign.end:
        return MainAxisAlignment.end;
      case TextAlign.center:
      default:
        return MainAxisAlignment.center;
    }
  }
}
