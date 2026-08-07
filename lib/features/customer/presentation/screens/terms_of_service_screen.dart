import 'package:flutter/material.dart';
import 'package:kebda_zaman/core/widgets/kz_legal_document.dart';

/// In-app Terms of Service — a local, scrollable document (never a WebView
/// or an external URL). Content is an owner-review draft describing the
/// app's actual current behavior, not externally approved legal advice.
class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const KZLegalDocumentScreen(
      titleKey: 'legal.terms_title',
      introKey: 'legal.terms_intro',
      sections: [
        KZLegalSection(
          titleKey: 'legal.terms_section_account_title',
          bodyKey: 'legal.terms_section_account_body',
        ),
        KZLegalSection(
          titleKey: 'legal.terms_section_guest_title',
          bodyKey: 'legal.terms_section_guest_body',
        ),
        KZLegalSection(
          titleKey: 'legal.terms_section_orders_title',
          bodyKey: 'legal.terms_section_orders_body',
        ),
        KZLegalSection(
          titleKey: 'legal.terms_section_pricing_title',
          bodyKey: 'legal.terms_section_pricing_body',
        ),
        KZLegalSection(
          titleKey: 'legal.terms_section_payment_title',
          bodyKey: 'legal.terms_section_payment_body',
        ),
        KZLegalSection(
          titleKey: 'legal.terms_section_cancellation_title',
          bodyKey: 'legal.terms_section_cancellation_body',
        ),
        KZLegalSection(
          titleKey: 'legal.terms_section_address_title',
          bodyKey: 'legal.terms_section_address_body',
        ),
        KZLegalSection(
          titleKey: 'legal.terms_section_loyalty_title',
          bodyKey: 'legal.terms_section_loyalty_body',
        ),
        KZLegalSection(
          titleKey: 'legal.terms_section_prohibited_title',
          bodyKey: 'legal.terms_section_prohibited_body',
        ),
        KZLegalSection(
          titleKey: 'legal.terms_section_suspension_title',
          bodyKey: 'legal.terms_section_suspension_body',
        ),
        KZLegalSection(
          titleKey: 'legal.terms_section_liability_title',
          bodyKey: 'legal.terms_section_liability_body',
        ),
        KZLegalSection(
          titleKey: 'legal.terms_section_changes_title',
          bodyKey: 'legal.terms_section_changes_body',
        ),
        KZLegalSection(
          titleKey: 'legal.terms_section_contact_title',
          bodyKey: 'legal.terms_section_contact_body',
        ),
      ],
    );
  }
}
