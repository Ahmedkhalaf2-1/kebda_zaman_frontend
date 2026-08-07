import 'package:flutter/material.dart';
import 'package:kebda_zaman/core/widgets/kz_legal_document.dart';

/// In-app Privacy Policy — a local, scrollable document (never a WebView or
/// an external URL). Content is an owner-review draft describing the app's
/// actual current data handling, not externally approved legal advice.
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const KZLegalDocumentScreen(
      titleKey: 'legal.privacy_title',
      introKey: 'legal.privacy_intro',
      sections: [
        KZLegalSection(
          titleKey: 'legal.privacy_section_account_title',
          bodyKey: 'legal.privacy_section_account_body',
        ),
        KZLegalSection(
          titleKey: 'legal.privacy_section_location_title',
          bodyKey: 'legal.privacy_section_location_body',
        ),
        KZLegalSection(
          titleKey: 'legal.privacy_section_orders_title',
          bodyKey: 'legal.privacy_section_orders_body',
        ),
        KZLegalSection(
          titleKey: 'legal.privacy_section_device_title',
          bodyKey: 'legal.privacy_section_device_body',
        ),
        KZLegalSection(
          titleKey: 'legal.privacy_section_firebase_title',
          bodyKey: 'legal.privacy_section_firebase_body',
        ),
        KZLegalSection(
          titleKey: 'legal.privacy_section_why_title',
          bodyKey: 'legal.privacy_section_why_body',
        ),
        KZLegalSection(
          titleKey: 'legal.privacy_section_retention_title',
          bodyKey: 'legal.privacy_section_retention_body',
        ),
        KZLegalSection(
          titleKey: 'legal.privacy_section_deletion_title',
          bodyKey: 'legal.privacy_section_deletion_body',
        ),
        KZLegalSection(
          titleKey: 'legal.privacy_section_security_title',
          bodyKey: 'legal.privacy_section_security_body',
        ),
        KZLegalSection(
          titleKey: 'legal.privacy_section_children_title',
          bodyKey: 'legal.privacy_section_children_body',
        ),
        KZLegalSection(
          titleKey: 'legal.privacy_section_updates_title',
          bodyKey: 'legal.privacy_section_updates_body',
        ),
        KZLegalSection(
          titleKey: 'legal.privacy_section_contact_title',
          bodyKey: 'legal.privacy_section_contact_body',
        ),
      ],
    );
  }
}
