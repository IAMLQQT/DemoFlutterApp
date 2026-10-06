import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';

import '../../../../core/theme/app_text_styles.dart';

/// Renders the article HTML returned by `/news/content/{id}`.
class ServiceHtmlContent extends StatelessWidget {
  const ServiceHtmlContent({super.key, required this.html});

  final String html;

  @override
  Widget build(BuildContext context) {
    return HtmlWidget(
      html,
      textStyle: AppTextStyles.body,
      // Route <img> through the same disk cache as the rest of the app
      customWidgetBuilder: (element) {
        if (element.localName != 'img') return null;
        final String? src = element.attributes['src'];
        if (src == null || src.isEmpty) return null;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(imageUrl: src, fit: BoxFit.cover),
          ),
        );
      },
      // TODO: open links with url_launcher; returning false keeps the default (no-op)
      onTapUrl: (url) => false,
    );
  }
}
