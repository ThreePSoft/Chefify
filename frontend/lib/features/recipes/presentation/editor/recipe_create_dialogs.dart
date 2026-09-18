part of '../pages/recipe_create_page.dart';

class _RecipeCategoryDialog extends StatefulWidget {
  const _RecipeCategoryDialog({required this.selected});

  final CategoryModel? selected;

  @override
  State<_RecipeCategoryDialog> createState() => _RecipeCategoryDialogState();
}

class _RecipeCategoryDialogState extends State<_RecipeCategoryDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final strings = AppStrings.of(context);
    final query = RecipeFormOptions.slug(_controller.text);
    final categories = RecipeFormOptions.categories
        .where((category) {
          if (query.isEmpty) {
            return true;
          }

          return category.id.contains(query) ||
              category.title.toLowerCase().contains(query.replaceAll('-', ' '));
        })
        .toList(growable: false);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(AppSpacing.lg),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: AppCard(
          padding: const EdgeInsets.all(AppSpacing.xl),
          backgroundColor: palette.cardsSurface,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                strings.category,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                key: const ValueKey('recipe-create-category-search'),
                controller: _controller,
                decoration: InputDecoration(hintText: strings.searchCategory),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: AppSpacing.md),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 320),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      for (final category in categories)
                        _RecipeCategoryOption(
                          category: category,
                          selected: widget.selected?.id == category.id,
                          onSelected: () => Navigator.of(context).pop(category),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecipeCategoryOption extends StatelessWidget {
  const _RecipeCategoryOption({
    required this.category,
    required this.selected,
    required this.onSelected,
  });

  final CategoryModel category;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Material(
        color: selected
            ? palette.primaryButtons.withValues(alpha: 0.16)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          leading: Icon(
            category.icon,
            color: selected ? palette.primaryButtons : palette.icons,
          ),
          title: Text(category.title),
          subtitle: Text(category.description),
          trailing: selected ? const Icon(Icons.check_rounded) : null,
          onTap: onSelected,
        ),
      ),
    );
  }
}

class _RecipeDifficultyDialog extends StatelessWidget {
  const _RecipeDifficultyDialog({required this.selected});

  static const List<String> _options = ['Easy', 'Medium', 'Hard'];

  final String selected;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final strings = AppStrings.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(AppSpacing.lg),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: AppCard(
          padding: const EdgeInsets.all(AppSpacing.xl),
          backgroundColor: palette.cardsSurface,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                strings.difficulty,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.lg),
              for (final option in _options)
                _RecipeDifficultyOption(
                  label: option,
                  selected: selected == option,
                  onSelected: () => Navigator.of(context).pop(option),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecipeDifficultyOption extends StatelessWidget {
  const _RecipeDifficultyOption({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Material(
        color: selected
            ? palette.primaryButtons.withValues(alpha: 0.16)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          leading: Icon(
            Icons.local_fire_department_rounded,
            color: selected ? palette.primaryButtons : palette.icons,
          ),
          title: Text(label),
          trailing: selected ? const Icon(Icons.check_rounded) : null,
          onTap: onSelected,
        ),
      ),
    );
  }
}

class _RecipeDurationPickerDialog extends StatefulWidget {
  const _RecipeDurationPickerDialog({required this.initial});

  final _RecipeDurationValue initial;

  @override
  State<_RecipeDurationPickerDialog> createState() =>
      _RecipeDurationPickerDialogState();
}

class _RecipeDurationPickerDialogState
    extends State<_RecipeDurationPickerDialog> {
  late _RecipeDurationValue _value = widget.initial;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final strings = AppStrings.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(AppSpacing.lg),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: AppCard(
          padding: const EdgeInsets.all(AppSpacing.xl),
          backgroundColor: palette.cardsSurface,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                strings.setCookingTime,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.lg),
              LayoutBuilder(
                builder: (context, constraints) {
                  final stacked = constraints.maxWidth < 380;
                  final steppers = [
                    _RecipeDurationStepper(
                      label: strings.days,
                      value: _value.days,
                      onIncrement: () =>
                          _setDays(_nextCyclic(_value.days, 0, 30)),
                      onDecrement: () =>
                          _setDays(_previousCyclic(_value.days, 0, 30)),
                    ),
                    _RecipeDurationStepper(
                      label: strings.hours,
                      value: _value.hours,
                      onIncrement: () =>
                          _setHours(_nextCyclic(_value.hours, 0, 23)),
                      onDecrement: () =>
                          _setHours(_previousCyclic(_value.hours, 0, 23)),
                    ),
                    _RecipeDurationStepper(
                      label: strings.minutes,
                      value: _value.minutes,
                      onIncrement: () => _setMinutes(
                        _nextCyclic(_value.minutes, 0, 55, step: 5),
                      ),
                      onDecrement: () => _setMinutes(
                        _previousCyclic(_value.minutes, 0, 55, step: 5),
                      ),
                    ),
                  ];

                  if (stacked) {
                    return Column(
                      children: [
                        for (
                          var index = 0;
                          index < steppers.length;
                          index++
                        ) ...[
                          if (index > 0) const SizedBox(height: AppSpacing.sm),
                          steppers[index],
                        ],
                      ],
                    );
                  }

                  return Row(
                    children: [
                      for (var index = 0; index < steppers.length; index++) ...[
                        if (index > 0) const SizedBox(width: AppSpacing.sm),
                        Expanded(child: steppers[index]),
                      ],
                    ],
                  );
                },
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(strings.cancel),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(_value),
                    child: Text(strings.apply),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _setDays(int days) {
    setState(() {
      _value = _value.copyWith(days: days);
    });
  }

  void _setHours(int hours) {
    setState(() {
      _value = _value.copyWith(hours: hours);
    });
  }

  void _setMinutes(int minutes) {
    setState(() {
      _value = _value.copyWith(minutes: minutes);
    });
  }

  int _nextCyclic(int value, int min, int max, {int step = 1}) {
    final next = value + step;
    return next > max ? min : next;
  }

  int _previousCyclic(int value, int min, int max, {int step = 1}) {
    final previous = value - step;
    return previous < min ? max : previous;
  }
}

class _RecipeDurationStepper extends StatelessWidget {
  const _RecipeDurationStepper({
    required this.label,
    required this.value,
    required this.onIncrement,
    required this.onDecrement,
  });

  final String label;
  final int value;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final strings = AppStrings.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: palette.searchBarBackground.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: palette.borders.withValues(alpha: 0.7)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: palette.secondaryText,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: strings.decrease(label),
                onPressed: onDecrement,
                icon: const Icon(Icons.remove_rounded),
                iconSize: 18,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(
                  width: 30,
                  height: 30,
                ),
                visualDensity: VisualDensity.compact,
              ),
              SizedBox(
                width: 38,
                child: Text(
                  value.toString().padLeft(2, '0'),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              IconButton(
                tooltip: strings.increase(label),
                onPressed: onIncrement,
                icon: const Icon(Icons.add_rounded),
                iconSize: 18,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(
                  width: 30,
                  height: 30,
                ),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
