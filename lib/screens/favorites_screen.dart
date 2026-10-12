import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:book_space/components/book_card.dart';
import 'package:book_space/core/app_colors.dart';
import 'package:book_space/core/autenticador.dart';
import 'package:book_space/core/usuario.dart';
import 'package:book_space/screens/book_detail_screen.dart';

/// Mostra só os livros que a usuária logada favoritou.
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  Usuario? usuario;
  List<Map<String, dynamic>> books = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadBooks();
  }

  Future<void> loadBooks() async {
    try {
      final text = await rootBundle.loadString('resources/jsons/books.json');
      final List<dynamic> data = jsonDecode(text);
      final u = await Autenticador.recuperarUsuario();
      if (!mounted) return;
      setState(() {
        books = data.cast<Map<String, dynamic>>();
        usuario = u;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Erro ao carregar favoritos: $e');
      if (!mounted) return;
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.third,
      appBar: AppBar(
        backgroundColor: AppColors.third,
        foregroundColor: AppColors.primary,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Favoritos',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
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
      return Center(child: Text('Não foi possível carregar.\n$errorMessage'));
    }

    final favorites = books
        .where((b) => usuario?.favoritos.contains(b['id']) ?? false)
        .toList();

    if (favorites.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Você ainda não favoritou nenhum livro.\n'
            'Toque no coração dentro de um livro para salvá-lo aqui.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: favorites.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.65,
      ),
      itemBuilder: (context, index) {
        final book = favorites[index];
        return BookCard(
          book: book,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BookDetailScreen(bookId: book['id']),
              ),
            ).then((_) => setState(() {})); // atualiza ao voltar
          },
        );
      },
    );
  }
}
