import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../l10n/app_localizations.dart';

class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final currentLocale = ref.watch(localeProvider);

    final options = [
      _LangOption(
        label: l10n.languageRussian,
        locale: const Locale('ru'),
        flag: '🇷🇺',
      ),
      _LangOption(
        label: l10n.languageKazakh,
        locale: const Locale('kk'),
        flag: '🇰🇿',
      ),
      _LangOption(
        label: l10n.languageEnglish,
        locale: const Locale('en'),
        flag: '🇬🇧',
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: const BackButton(color: AppColors.neutral900),
        title: Text(
          l10n.languageTitle,
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
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: AppColors.elevation1,
            ),
            child: Column(
              children: [
                for (int i = 0; i < options.length; i++) ...[
                  _LanguageTile(
                    option: options[i],
                    isSelected: currentLocale?.languageCode ==
                        options[i].locale.languageCode,
                    onTap: () {
                      ref.read(localeProvider.notifier).state =
                          options[i].locale;
                    },
                  ),
                  if (i < options.length - 1)
                    const Divider(
                      height: 1,
                      indent: AppSpacing.lg,
                      endIndent: AppSpacing.lg,
                      color: AppColors.neutral200,
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LangOption {
  const _LangOption({
    required this.label,
    required this.locale,
    required this.flag,
  });
  final String label;
  final Locale locale;
  final String flag;
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  final _LangOption option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Text(option.flag, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  option.label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.neutral900,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_rounded,
                    color: AppColors.primary, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
