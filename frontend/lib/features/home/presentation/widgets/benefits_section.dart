import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_spacing.dart';
import 'package:frontend/core/localization/app_strings.dart';
import 'package:frontend/core/widgets/responsive_wrap_grid.dart';
import 'package:frontend/core/widgets/section_header.dart';
import 'package:frontend/features/home/presentation/widgets/benefit_card.dart';
import 'package:frontend/shared/models/home_models.dart';

class BenefitsSection extends StatelessWidget {
  const BenefitsSection({super.key, required this.benefits});

  final List<BenefitModel> benefits;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.sectionInsets(context),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppSpacing.contentMaxWidth,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                eyebrow: AppStrings.of(context).whyChefify,
                title: AppStrings.of(context).benefitsTitle,
                subtitle: AppStrings.of(context).benefitsSubtitle,
              ),
              const SizedBox(height: AppSpacing.lg),
              ResponsiveWrapGrid<BenefitModel>(
                items: benefits,
                minItemWidth: 280,
                maxColumns: 3,
                itemBuilder: (context, benefit) {
                  return BenefitCard(benefit: benefit);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
