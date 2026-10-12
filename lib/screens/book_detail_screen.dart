import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:book_space/core/app_colors.dart';

/// Tela de detalhes do livro (Tela 4 do mockup).
/// Recebe apenas o id do livro e busca o "cadastro completo"
/// em resource/jsons/detalhes_books.json.
class BookDetailScreen extends StatefulWidget {
  final int bookId;

  const BookDetailScreen({super.key, required this.bookId});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  Map<String, dynamic>? book;
  bool isLoading = true;
  String? errorMessage;
  bool isFavorite = false; // por enquanto só visual (não salva em lugar nenhum)

  @override
  void initState() {
    super.initState();
    loadBook();
  }

  Future<void> loadBook() async {
    try {
      final text = await rootBundle.loadString(
        'resources/jsons/detalhes_books.json',
      );
      final List<dynamic> data = jsonDecode(text);

      final found = data
          .cast<Map<String, dynamic>>()
          .where((b) => b['id'] == widget.bookId)
          .toList();

      if (!mounted) return; // a tela pode ter sido fechada durante a leitura

      if (found.isEmpty) {
        setState(() {
          errorMessage = 'Livro não encontrado (id ${widget.bookId}).';
          isLoading = false;
        });
        return;
      }

      setState(() {
        book = found.first;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Erro ao carregar detalhes: $e');
      if (!mounted) return;
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  // ---------- helpers ----------

  String formatDate(String iso) {
    final d = DateTime.parse(iso).toLocal();
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd/$mm/${d.year}';
  }

  Widget buildStars(double rating, {double size = 18}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        IconData icon;
        if (rating >= i + 1) {
          icon = Icons.star;
        } else if (rating >= i + 0.5) {
          icon = Icons.star_half;
        } else {
          icon = Icons.star_border;
        }
        return Icon(icon, size: size, color: AppColors.star);
      }),
    );
  }

  // ---------- build ----------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.primary,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : AppColors.primary,
            ),
            onPressed: () => setState(() => isFavorite = !isFavorite),
          ),
        ],
      ),
      body: buildContent(),
    );
  }

  Widget buildContent() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Não foi possível carregar o livro.\n$errorMessage',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final b = book!;
    final rating = (b['avaliacao_media'] as num).toDouble();
    final stats = b['estatisticas_rapidas'] as Map<String, dynamic>;
    final tech = b['detalhes_tecnicos'] as Map<String, dynamic>;
    final tags = (b['tags'] as List<dynamic>).cast<String>();
    final comments = (b['comentarios'] as List<dynamic>)
        .cast<Map<String, dynamic>>();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1) Capa + resumo
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 110,
                  height: 165,
                  child: Image.network(
                    b['capa_url'],
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFFE3E8F3),
                      child: const Icon(
                        Icons.menu_book,
                        color: AppColors.secondary,
                        size: 36,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      b['titulo'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      b['autor'],
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        b['genero'],
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.third,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${b['ano_publicacao']} • ${stats['paginas']} páginas',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        buildStars(rating, size: 16),
                        const SizedBox(width: 6),
                        Text('($rating)', style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // 2) Sinopse
          const SizedBox(height: 20),
          Text(b['sinopse'], style: const TextStyle(fontSize: 14, height: 1.5)),

          // 3) Botão de favoritos
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => setState(() => isFavorite = !isFavorite),
              icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
              label: Text(
                isFavorite
                    ? 'Remover dos favoritos'
                    : 'Adicionar aos favoritos',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.third,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),

          // 4) Tags
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags
                .map(
                  (t) => Chip(
                    label: Text(t, style: const TextStyle(fontSize: 12)),
                    backgroundColor: AppColors.surface,
                    side: const BorderSide(color: Color(0xFFD5DBE8)),
                    shape: const StadiumBorder(),
                  ),
                )
                .toList(),
          ),

          // 5) Informações
          const SizedBox(height: 24),
          sectionTitle('Informações'),
          infoRow('Autor', b['autor']),
          infoRow('Categoria', b['genero']),
          infoRow('Ano de publicação', '${b['ano_publicacao']}'),
          infoRow('Páginas', '${stats['paginas']}'),
          infoRow('Tempo de leitura', '${stats['tempo_leitura_estimado']}'),
          infoRow('Editora', '${tech['editora']}'),
          infoRow('Idioma', '${tech['idioma']}'),
          infoRow('ISBN-13', '${tech['isbn_13']}'),
          infoRow('Formato', '${tech['formato']}'),

          // 6) Avaliação
          const SizedBox(height: 24),
          sectionTitle('Avaliação'),
          Row(
            children: [
              buildStars(rating, size: 22),
              const SizedBox(width: 8),
              Text(
                '$rating (${b['total_avaliacoes']} avaliações)',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),

          // 7) Comentários
          const SizedBox(height: 24),
          sectionTitle('Comentários (${comments.length})'),
          ...comments.map(buildComment),
        ],
      ),
    );
  }

  Widget sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: AppColors.secondary),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  Widget buildComment(Map<String, dynamic> c) {
    final user = c['usuario'] as Map<String, dynamic>;
    final name = user['nome'] as String;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Se a imagem falhar, aparece a inicial do nome (child).
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary,
                foregroundImage: NetworkImage(user['avatar_url']),
                onForegroundImageError: (_, __) {},
                child: Text(
                  name[0],
                  style: const TextStyle(color: AppColors.primary),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      formatDate(c['data_publicacao']),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ),
              buildStars((c['nota'] as num).toDouble(), size: 14),
            ],
          ),
          const SizedBox(height: 8),
          Text(c['texto'], style: const TextStyle(fontSize: 13, height: 1.4)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.thumb_up_alt_outlined,
                size: 14,
                color: AppColors.secondary,
              ),
              const SizedBox(width: 4),
              Text(
                '${c['curtidas']}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
