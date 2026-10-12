import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:book_space/components/app_bottom_nav.dart';
import 'package:book_space/components/book_card.dart';
import 'package:book_space/components/home_header.dart';

import 'package:book_space/core/app_colors.dart';
import 'package:book_space/core/autenticador.dart';
import 'package:book_space/core/usuario.dart';

import 'package:book_space/screens/book_detail_screen.dart';

/// Mostra os livros favoritados pelo usuário logado.
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  // Usuário atualmente logado.
  Usuario? usuario;

  // Lista de todos os livros carregados do JSON.
  List<Map<String, dynamic>> books = [];

  // Controla o carregamento da tela.
  bool isLoading = true;

  // Guarda uma possível mensagem de erro.
  String? errorMessage;

  // Controla se o campo de busca está aberto.
  bool isSearching = false;

  // Guarda o texto digitado na lupa.
  String searchText = '';

  @override
  void initState() {
    super.initState();
    loadBooks();
  }

  /// Carrega os livros e recupera o usuário logado.
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

  /// Exibe uma mensagem na parte inferior da tela.
  void aviso(String mensagem) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensagem)));
  }

  /// Abre o login ou encerra a sessão, conforme o estado atual.
  ///
  /// Esta implementação utiliza os métodos já usados no projeto.
  Future<void> onLoginTap() async {
    try {
      if (usuario == null) {
        await Autenticador.login();

        final u = await Autenticador.recuperarUsuario();

        if (!mounted) return;

        setState(() {
          usuario = u;
        });

        if (u != null) {
          aviso('Login realizado com sucesso!');
        }
      } else {
        await Autenticador.logout();

        if (!mounted) return;

        setState(() {
          usuario = null;
        });

        aviso('Você saiu da sua conta.');
      }
    } catch (e) {
      debugPrint('Erro na autenticação: $e');
      if (mounted) {
        aviso('Não foi possível realizar a operação.');
      }
    }
  }

  /// Volta para a primeira tela da navegação, normalmente a Home.
  void irParaInicio() {
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.third,

      // Header reutilizado: logo, busca e login.
      appBar: HomeHeader(
        isSearching: isSearching,

        // Abre a busca.
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

        // Atualiza o texto digitado na busca.
        onSearchChanged: (value) {
          setState(() {
            searchText = value;
          });
        },

        // Usuário exibido pelo Header.
        usuario: usuario,

        // Login/logout.
        onLoginTap: onLoginTap,
      ),

      // Conteúdo principal da página.
      body: buildContent(),

      // Menu inferior reutilizado.
      bottomNavigationBar: AppBottomNav(
        currentIndex: 2, // Favoritos está selecionado.
        onTap: (index) {
          if (index == 0) {
            // Início: retorna à primeira rota.
            irParaInicio();
          } else if (index == 1) {
            // Busca: retorna à Home e abre a busca
            // na própria tela de favoritos.
            //
            // Para abrir a busca da Home automaticamente,
            // será necessário compartilhar o estado de navegação.
            irParaInicio();
          } else if (index == 2) {
            // Já estamos na tela de favoritos.
          } else if (index == 3) {
            // Perfil: substitua por sua tela de perfil
            // quando ela estiver implementada.
            aviso('Tela de perfil em breve!');
          }
        },
      ),
    );
  }

  /// Monta o conteúdo da página de favoritos.
  Widget buildContent() {
    // Enquanto os livros estão sendo carregados.
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    // Se ocorreu um erro no carregamento.
    if (errorMessage != null) {
      return Center(
        child: Text(
          'Não foi possível carregar os favoritos.\n$errorMessage',
          textAlign: TextAlign.center,
        ),
      );
    }

    // Filtra os livros favoritados e aplica a busca.
    final favorites = books.where((book) {
      // Verifica se o livro está na lista de favoritos do usuário.
      final isFavorite = usuario?.favoritos.contains(book['id']) ?? false;

      if (!isFavorite) return false;

      // Se não existe texto de busca, mostra todos os favoritos.
      final query = searchText.trim().toLowerCase();

      if (query.isEmpty) return true;

      // Pesquisa pelo título, autor ou gênero.
      final title = (book['titulo'] ?? '').toString().toLowerCase();

      final author = (book['autor'] ?? '').toString().toLowerCase();

      final genre = (book['genero'] ?? '').toString().toLowerCase();

      return title.contains(query) ||
          author.contains(query) ||
          genre.contains(query);
    }).toList();

    // Mensagem quando não há favoritos ou nenhum resultado.
    if (favorites.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            searchText.trim().isNotEmpty
                ? 'Nenhum favorito encontrado para "$searchText".'
                : 'Você ainda não favoritou nenhum livro.\n'
                      'Toque no coração dentro de um livro para salvá-lo aqui.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // Exibe os livros em uma grade de duas colunas.
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

          // Abre os detalhes do livro selecionado.
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BookDetailScreen(bookId: book['id']),
              ),
            ).then((_) {
              // Atualiza os favoritos ao retornar dos detalhes.
              loadBooks();
            });
          },
        );
      },
    );
  }
}
