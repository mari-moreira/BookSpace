import 'package:book_space/core/app_colors.dart';
import 'package:flutter/material.dart';

/// Card de um livro na vertical: capa em cima, textos embaixo.
class BookCard extends StatelessWidget {
  const BookCard({super.key, required this.book});

  // Um livro do JSON (um Map: chave -> valor)
  final Map<String, dynamic> book;

  @override
  Widget build(BuildContext context) {
    return Container(
      // clipBehavior corta a capa nas bordas arredondadas do card
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Capa: Expanded ocupa todo o espaço que sobrar no card
          Expanded(
            child: Image.network(
              book['capa_url'],
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: const Color(0xFFE3E8F3),
                child: const Center(
                  child: Icon(
                    Icons.menu_book_rounded,
                    size: 25,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),

          // Textos
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Altura fixa para o título ocupar sempre 2 linhas
                // e todos os cards ficarem iguais
                SizedBox(
                  height: 38,
                  child: Text(
                    book['titulo'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  book['autor'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 16,
                      color: AppColors.star,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${book['avaliacao_media']}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
