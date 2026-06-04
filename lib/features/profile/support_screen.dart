import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../l10n/app_localizations.dart';

// ---------------------------------------------------------------------------
// Support contact constants — update when org details are confirmed.
// ---------------------------------------------------------------------------
const _kPhone = '+77001234567';
const _kWhatsApp = 'https://wa.me/77001234567';
const _kEmail = 'support@autofleet.kz';
const _kAddress = 'г. Алматы, ул. Абая 10, офис 201';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  Future<void> _launch(String url, BuildContext context) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open link')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    final faqs = [
      (q: l10n.supportFaqDeliveryQ, a: l10n.supportFaqDeliveryA),
      (q: l10n.supportFaqDepositQ, a: l10n.supportFaqDepositA),
      (q: l10n.supportFaqFuelQ, a: l10n.supportFaqFuelA),
      (q: l10n.supportFaqDamageQ, a: l10n.supportFaqDamageA),
      (q: l10n.supportFaqFinesQ, a: l10n.supportFaqFinesA),
    ];

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: const BackButton(color: AppColors.neutral900),
        title: Text(
          l10n.supportTitle,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.neutral900,
          ),
        ),
        centerTitle: false,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          MediaQuery.paddingOf(context).bottom + AppSpacing.xl,
        ),
        children: [
          // Phone card
          _SectionCard(
            icon: Icons.phone_outlined,
            title: l10n.supportCall,
            subtitle: _kPhone,
            actions: [
              _ActionButton(
                label: l10n.supportCall,
                icon: Icons.phone,
                onTap: () => _launch('tel:$_kPhone', context),
              ),
              const SizedBox(width: AppSpacing.sm),
              _ActionButton(
                label: l10n.supportWhatsapp,
                icon: Icons.chat_outlined,
                onTap: () => _launch(_kWhatsApp, context),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Email card
          _SectionCard(
            icon: Icons.email_outlined,
            title: l10n.supportEmail,
            subtitle: _kEmail,
            actions: [
              _ActionButton(
                label: l10n.supportEmail,
                icon: Icons.send_outlined,
                onTap: () =>
                    _launch('mailto:$_kEmail', context),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Address card
          _SectionCard(
            icon: Icons.location_on_outlined,
            title: l10n.supportAddress,
            subtitle: _kAddress,
            actions: const [],
          ),
          const SizedBox(height: AppSpacing.xl),
          // FAQ section
          Text(
            l10n.supportFaqTitle,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.neutral900,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: AppColors.elevation1,
            ),
            child: Column(
              children: faqs
                  .map(
                    (faq) => ExpansionTile(
                      title: Text(
                        faq.q,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.neutral900,
                        ),
                      ),
                      expandedCrossAxisAlignment: CrossAxisAlignment.start,
                      childrenPadding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        0,
                        AppSpacing.lg,
                        AppSpacing.md,
                      ),
                      children: [
                        Text(
                          faq.a,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.neutral700,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actions,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppColors.elevation1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: AppSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.neutral500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.neutral900,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (actions.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Row(children: actions),
          ],
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: AppColors.primary, size: 16),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
