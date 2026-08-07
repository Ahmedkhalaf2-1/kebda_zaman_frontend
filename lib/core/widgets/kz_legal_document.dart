import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:kebda_zaman/core/legal/legal_config.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';

/// One heading + body paragraph within a legal document.
class KZLegalSection {
  final String titleKey;
  final String bodyKey;

  const KZLegalSection({required this.titleKey, required this.bodyKey});
}

/// Shared scaffold for the in-app Privacy Policy / Terms of Service screens:
/// a standard KZ form app bar, a "Last updated" date line driven by
/// [LegalConfig], and a scrollable list of headed sections. Both documents
/// use this so they stay visually identical.
class KZLegalDocumentScreen extends StatelessWidget {
  final String titleKey;
  final String introKey;
  final List<KZLegalSection> sections;

  const KZLegalDocumentScreen({
    super.key,
    required this.titleKey,
    required this.introKey,
    required this.sections,
  });

  @override
  Widget build(BuildContext context) {
    final languageCode = context.locale.languageCode;

    return Scaffold(
      backgroundColor: KZ.surface,
      appBar: KZ.formAppBar(context: context, title: titleKey.tr()),
      body: SafeArea(
        child: Scrollbar(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              KZ.screenPadding,
              KZ.sp16,
              KZ.screenPadding,
              KZ.sp32,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'legal.last_updated_label'.tr(
                    namedArgs: {
                      'date': LegalConfig.formattedDate(languageCode),
                    },
                  ),
                  style: KZ.caption,
                ),
                const SizedBox(height: KZ.sp16),
                Text(introKey.tr(), style: KZ.bodyLarge),
                const SizedBox(height: KZ.sp24),
                for (final section in sections) ...[
                  Text(section.titleKey.tr(), style: KZ.sectionTitle),
                  const SizedBox(height: KZ.sp8),
                  Text(section.bodyKey.tr(), style: KZ.body),
                  const SizedBox(height: KZ.sp24),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
