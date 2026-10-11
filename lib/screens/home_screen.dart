import 'dart:convert';

import 'package:book_space/components/app_bottom_nav.dart';
import 'package:book_space/components/book_card.dart';
import 'package:book_space/components/category_filter.dart';
import 'package:book_space/components/home_header.dart';
import 'package:book_space/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Tela 1: cabeçalho + filtros de categoria + grade de livros + rodapé.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Todos os livros do JSON
  List<dynamic> books = [];

  // true enquanto o JSON está sendo lido
  bool isLoading = true;

  // guarda a mensagem de erro, se algo der errado (null = tudo certo)
  String? errorMessage;

  // categoria escolhida no filtro
  String selectedCategory = 'Todos';

  // busca: campo aberto? e o que foi digitado
  bool isSearching = false;
  String searchText = '';

  /// Categorias montadas a partir do JSON (sem repetir), com "Todos" na frente.
  List<String> get categories {
    final genres = books.map((book) => book['genero'] as String).toSet();
    return ['Todos', ...genres];
  }

  /// Livros que aparecem na tela: respeitam a categoria E o texto da busca.
  List<dynamic> get filteredBooks {
    final query = normalize(searchText.trim());

    return books.where((book) {
      final matchesCategory =
          selectedCategory == 'Todos' || book['genero'] == selectedCategory;

      final matchesSearch =
          query.isEmpty ||
          normalize(book['titulo']).contains(query) ||
          normalize(book['autor']).contains(query) ||
          normalize(book['genero']).contains(query);

      return matchesCategory && matchesSearch;
    }).toList();
  }

  /// Deixa o texto em minúsculas e sem acento, para "habito" achar "Hábito".
  String normalize(String text) {
    const from = 'áàâãäéèêëíìîïóòôõöúùûüç';
    const to = 'aaaaaeeeeiiiiooooouuuuc';
    var result = text.toLowerCase();
    for (var i = 0; i < from.length; i++) {
      result = result.replaceAll(from[i], to[i]);
    }
    return result;
  }

  @override
  void initState() {
    super.initState();
    loadBooks(); // roda uma vez quando a tela nasce
  }

  Future<void> loadBooks() async {
    try {
      // 1. Lê o arquivo como texto
      final text = await rootBundle.loadString('resources/jsons/books.json');
      // (Só para testar a bolinha: tire o // da linha abaixo para simular demora)
      // await Future.delayed(const Duration(seconds: 2));

      // 2. Converte o texto em lista
      final data = jsonDecode(text);

      setState(() {
        books = data;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Erro ao carregar livros: $e');
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: HomeHeader(
        isSearching: isSearching,
        // Tocou na lupa: abre o campo de busca
        onSearchTap: () {
          setState(() {
            isSearching = true;
          });
        },
        // Tocou no X: fecha o campo e limpa o texto
        onSearchClose: () {
          setState(() {
            isSearching = false;
            searchText = '';
          });
        },
        // Digitou algo: guarda o texto e a lista se atualiza
        onSearchChanged: (text) {
          setState(() {
            searchText = text;
          });
        },
      ),
      body: buildContent(),
      bottomNavigationBar: AppBottomNav(
        // Busca fica destacada enquanto o campo de busca está aberto
        currentIndex: isSearching ? 1 : 0,
        onTap: (index) {
          if (index == 0) {
            // Início: fecha a busca e limpa o texto
            setState(() {
              isSearching = false;
              searchText = '';
            });
          } else if (index == 1) {
            // Busca: abre o campo de busca (igual à lupa)
            setState(() {
              isSearching = true;
            });
          } else {
            // Favoritos e Perfil ainda não existem
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('Tela em breve!')));
          }
        },
      ),
    );
  }

  /// Decide o que mostrar: bolinha, erro ou (filtros + grade).
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
          child: Text('Não foi possível carregar os livros.\n\n$errorMessage'),
        ),
      );
    }

    return Column(
      children: [
        const SizedBox(height: 12),

        // Filtros de categoria
        CategoryFilter(
          categories: categories,
          selected: selectedCategory,
          onSelected: (category) {
            setState(() {
              selectedCategory = category;
            });
          },
        ),

        // Grade de livros (já filtrados) ou aviso de "nada encontrado"
        Expanded(
          child: filteredBooks.isEmpty
              ? const Center(
                  child: Text(
                    'Nenhum livro encontrado.',
                    style: TextStyle(color: AppColors.secondary),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredBooks.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.65,
                  ),
                  itemBuilder: (context, index) =>
                      BookCard(book: filteredBooks[index]),
                ),
        ),
      ],
    );
  }
}
