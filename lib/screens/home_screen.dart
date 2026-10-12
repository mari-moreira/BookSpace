import 'dart:convert';

import 'package:book_space/components/app_bottom_nav.dart';
import 'package:book_space/components/book_card.dart';
import 'package:book_space/components/category_filter.dart';
import 'package:book_space/components/home_header.dart';
import 'package:book_space/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:book_space/screens/book_detail_screen.dart';
import 'package:book_space/core/autenticador.dart';
import 'package:book_space/core/usuario.dart';
import 'package:book_space/screens/favorites_screen.dart';

/// Tela 1: cabeçalho + filtros de categoria + grade de livros + rodapé.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //usuário
  Usuario? usuario;
  // Todos os livros do JSON
  List<dynamic> books = [];

  // true enquanto o JSON está sendo lido
  bool isLoading = true;

  // Guarda a mensagem de erro
  String? errorMessage;

  // Categoria escolhida no filtro
  String selectedCategory = 'Todos';

  // Estado da busca
  bool isSearching = false;
  String searchText = '';

  /// Categorias montadas a partir do JSON, sem repetição.
  List<String> get categories {
    final genres = books.map((book) => book['genero'] as String).toSet();

    return ['Todos', ...genres];
  }

  /// Filtra os livros por categoria e texto da busca.
  List<dynamic> get filteredBooks {
    final query = normalize(searchText.trim());

    return books.where((book) {
      final matchesCategory =
          selectedCategory == 'Todos' || book['genero'] == selectedCategory;

      final matchesSearch =
          query.isEmpty ||
          normalize(book['titulo'].toString()).contains(query) ||
          normalize(book['autor'].toString()).contains(query) ||
          normalize(book['genero'].toString()).contains(query);

      return matchesCategory && matchesSearch;
    }).toList();
  }

  /// Deixa o texto em minúsculas e remove os acentos mais comuns.
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
    carregarUsuario();
    loadBooks();
  }

  /// Carrega os livros do arquivo JSON.
  Future<void> loadBooks() async {
    try {
      final text = await rootBundle.loadString('resources/jsons/books.json');

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

  //CARREGAR USUÁRIO
  Future<void> carregarUsuario() async {
    final u = await Autenticador.recuperarUsuario();
    if (!mounted) return;
    setState(() => usuario = u);
  }

  Future<void> onLoginTap() async {
    if (usuario == null) {
      final u = await Autenticador.login();
      if (!mounted) return;
      setState(() => usuario = u);
      aviso('Olá, ${u!.nome}!');
    } else {
      await Autenticador.logout();
      if (!mounted) return;
      setState(() => usuario = null);
      aviso('Você saiu da conta.');
    }
  }

  void aviso(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,

      appBar: HomeHeader(
        isSearching: isSearching,

        // Abre o campo de busca.
        onSearchTap: () {
          setState(() {
            isSearching = true;
          });
        },

        // Fecha a busca e limpa o texto.
        onSearchClose: () {
          setState(() {
            isSearching = false;
            searchText = '';
          });
        },

        // Atualiza o texto da busca.
        onSearchChanged: (text) {
          setState(() {
            searchText = text;
          });
        },

        // NOVO: entrega o usuário e a função do ícone de login
        usuario: usuario,
        onLoginTap: onLoginTap,
      ),

      body: buildContent(),

      bottomNavigationBar: AppBottomNav(
        currentIndex: isSearching ? 1 : 0,

        onTap: (index) {
          if (index == 0) {
            // Início
            setState(() {
              isSearching = false;
              searchText = '';
            });
          } else if (index == 1) {
            // Busca
            setState(() {
              isSearching = true;
            });
          } else if (index == 2) {
            // NOVO: Favoritos (só para quem está logada)
            if (usuario == null) {
              aviso('Faça login para ver seus favoritos.');
              return;
            }
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FavoritesScreen()),
            );
          } else {
            // Perfil ainda não existe.
            aviso('Tela em breve!');
          }
        },
      ),
    );
  }

  /// Decide o que mostrar: carregamento, erro ou grade de livros.
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

        // Grade de livros ou mensagem de lista vazia
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

                  itemBuilder: (context, index) {
                    final book = filteredBooks[index];

                    return BookCard(
                      book: book,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                BookDetailScreen(bookId: book['id']),
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}
