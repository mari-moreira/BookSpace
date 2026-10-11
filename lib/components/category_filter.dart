import 'package:book_space/core/app_colors.dart';
import 'package:flutter/material.dart';

/// Linha de filtros de categoria (Todos, Tecnologia, ...) com rolagem horizontal.
class CategoryFilter extends StatelessWidget {
  const CategoryFilter({
    super.key,
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  final List<String> categories; // todas as categorias
  final String selected; // a categoria escolhida agora
  final ValueChanged<String> onSelected; // chamada quando o usuário toca em uma

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal, // rola para o lado
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selected;

          return ChoiceChip(
            label: Text(category),
            selected: isSelected,
            onSelected: (_) => onSelected(category),
            showCheckmark: false,
            selectedColor: AppColors.primary,
            backgroundColor: AppColors.surface,
            side: BorderSide(
              color: isSelected ? AppColors.surface : const Color(0xFFD5DBE8),
            ),
            shape: const StadiumBorder(),
            labelStyle: TextStyle(
              color: isSelected ? AppColors.surface : AppColors.primary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          );
        },
      ),
    );
  }
}
