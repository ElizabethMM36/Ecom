import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/aura_theme.dart';

// ─── Section label (uppercase small text like HTML) ─────────────────────────
class AuraFieldLabel extends StatelessWidget {
  final String text;
  const AuraFieldLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6),
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.lexend(
          color: AuraTheme.secondary,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

// ─── Standard text field ─────────────────────────────────────────────────────
class AuraTextField extends StatelessWidget {
  final String placeholder;
  final TextEditingController? controller;
  final int maxLines;
  final TextInputType keyboardType;
  final Widget? prefixIcon;
  final String? prefixText;

  const AuraTextField({
    super.key,
    required this.placeholder,
    this.controller,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.prefixText,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: GoogleFonts.lexend(
        color: AuraTheme.onSurface,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      decoration: InputDecoration(
        hintText: placeholder,
        hintStyle: GoogleFonts.lexend(color: AuraTheme.outline, fontSize: 14),
        prefixIcon: prefixIcon,
        prefixText: prefixText,
        prefixStyle: GoogleFonts.lexend(
          color: AuraTheme.secondary,
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: AuraTheme.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AuraTheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AuraTheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AuraTheme.primary, width: 1.5),
        ),
      ),
    );
  }
}

// ─── Condition segmented control ─────────────────────────────────────────────
class AuraConditionSelector extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  static const labels = ['New', 'Like New', 'Used', 'Fair'];

  const AuraConditionSelector({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AuraTheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: List.generate(labels.length, (i) {
          final selected = i == selectedIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: selected ? AuraTheme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: AuraTheme.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Text(
                  labels[i],
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lexend(
                    color: selected ? Colors.white : AuraTheme.secondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─── Category dropdown ────────────────────────────────────────────────────────
class AuraCategoryDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;

  static const categories = [
    'Electronics',
    'Smartphones',
    'Computers',
    'Home Goods',
    'Clothing',
    'Books',
    'Furniture',
    'Bicycle',
    'Vehicles',
  ];

  const AuraCategoryDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      dropdownColor: AuraTheme.surfaceContainerLow,
      style: GoogleFonts.lexend(color: AuraTheme.onSurface, fontSize: 14),
      decoration: InputDecoration(
        filled: true,
        fillColor: AuraTheme.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AuraTheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AuraTheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AuraTheme.primary, width: 1.5),
        ),
      ),
      items: categories
          .map(
            (c) => DropdownMenuItem(
              value: c,
              child: Text(c, style: GoogleFonts.lexend(fontSize: 14)),
            ),
          )
          .toList(),
    );
  }
}
