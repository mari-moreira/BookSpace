import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:book_space/components/home_header.dart';
import 'package:book_space/core/app_colors.dart';
import 'package:book_space/core/autenticador.dart';
import 'package:book_space/core/usuario.dart';
import 'package:book_space/components/app_bottom_nav.dart';
import 'package:book_space/screens/favorites_screen.dart';

/// Guarda os comentários adicionados durante a execução do aplicativo.
/// Eles ficam em memória e não são persistidos ao fechar o app.
final Map<int, List<Map<String, dynamic>>> comentariosNovos = {};

/// Tela de detalhes do livro.
///
/// Recebe o ID do livro e busca as informações completas
/// no arquivo resources/jsons/detalhes_books.json.
class BookDetailScreen extends StatefulWidget {
  final int bookId;

  const BookDetailScreen({super.key, required this.bookId});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  // ---------- ESTADO DA TELA ----------

  Map<String, dynamic>? book;

  bool isLoading = true;
  String? errorMessage;

  // Usuário autenticado. Null significa que ninguém está logado.
  Usuario? usuario;

  // Estado da busca exibida no HomeHeader.
  bool isSearching = false;
  String searchText = '';

  // Controlador do campo de comentários.
  final TextEditingController commentController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Carrega os dados do livro e o usuário atual.
    loadBook();
    carregarUsuario();
  }

  @override
  void dispose() {
    // Libera os recursos utilizados pelo campo de comentários.
    commentController.dispose();
    super.dispose();
  }

  // ---------- USUÁRIO E AUTENTICAÇÃO ----------

  /// Recupera o usuário que já está autenticado.
  Future<void> carregarUsuario() async {
    final u = await Autenticador.recuperarUsuario();

    if (!mounted) return;

    setState(() {
      usuario = u;
    });
  }

  /// Permite entrar ou sair da conta pelo ícone do HomeHeader.
  Future<void> onLoginTap() async {
    if (usuario == null) {
      // Se não há usuário, inicia o login.
      final u = await Autenticador.login();

      if (!mounted) return;

      // Se o login não retornou usuário, não altera o estado.
      if (u == null) return;

      setState(() {
        usuario = u;
      });

      aviso('Olá, ${u.nome}!');
    } else {
      // Se já existe usuário, encerra a sessão.
      await Autenticador.logout();

      if (!mounted) return;

      setState(() {
        usuario = null;
      });

      aviso('Você saiu da conta.');
    }
  }

  /// Exibe mensagens para o usuário.
  void aviso(String mensagem) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(mensagem)));
  }

  /// Verifica se o usuário pode interagir com o livro.
  bool podeInteragir() {
    if (usuario != null) return true;

    aviso(
      'Faça login pelo ícone no topo para favoritar, '
      'curtir e comentar.',
    );

    return false;
  }

  // ---------- FAVORITOS E CURTIDAS ----------

  /// Adiciona ou remove um ID de uma coleção.
  ///
  /// Funciona com coleções que oferecem contains, add e remove,
  /// como List e Set.
  void alternar(dynamic colecao, int id) {
    if (colecao.contains(id)) {
      colecao.remove(id);
    } else {
      colecao.add(id);
    }
  }

  /// Adiciona ou remove o livro dos favoritos.
  void onFavoriteTap() {
    if (!podeInteragir()) return;

    setState(() {
      alternar(usuario!.favoritos, widget.bookId);
    });
  }

  /// Adiciona ou remove uma curtida de um comentário.
  void onLikeTap(int commentId) {
    if (!podeInteragir()) return;

    setState(() {
      alternar(usuario!.curtidas, commentId);
    });
  }

  // ---------- COMENTÁRIOS ----------

  /// Publica um comentário local para o livro atual.
  void onSendComment() {
    final text = commentController.text.trim();

    // Não publica comentários vazios ou sem login.
    if (text.isEmpty || !podeInteragir()) return;

    setState(() {
      comentariosNovos.putIfAbsent(widget.bookId, () => []).insert(0, {
        'id_comentario': DateTime.now().millisecondsSinceEpoch,
        'usuario': {
          'nome': usuario!.nome,
          'avatar_url':
              'https://ui-avatars.com/api/?name='
              '${Uri.encodeComponent(usuario!.nome)}'
              '&background=random&color=fff',
        },
        'nota': 0,
        'data_publicacao': DateTime.now().toUtc().toIso8601String(),
        'texto': text,
        'curtidas': 0,
      });
    });

    // Limpa o campo e fecha o teclado.
    commentController.clear();
    FocusScope.of(context).unfocus();
  }

  // ---------- CARREGAMENTO DO LIVRO ----------

  /// Lê o JSON e localiza o livro pelo ID recebido na tela.
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

      if (!mounted) return;

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

  // ---------- FUNÇÕES AUXILIARES ----------

  /// Converte uma data ISO para o formato brasileiro.
  String formatDate(String iso) {
    final d = DateTime.parse(iso).toLocal();

    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');

    return '$dd/$mm/${d.year}';
  }

  /// Desenha até cinco estrelas conforme a avaliação.
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

  // ---------- CABEÇALHO PRINCIPAL ----------

  @override
  Widget build(BuildContext context) {
    // Verifica se o livro está nos favoritos.
    final fav = usuario?.favoritos.contains(widget.bookId) ?? false;

    return Scaffold(
      backgroundColor: AppColors.third,

      // Primeiro menu: logo, busca e login.
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

        // Guarda o texto digitado na busca.
        onSearchChanged: (text) {
          setState(() {
            searchText = text;
          });
        },

        // Mantém o estado de autenticação atualizado.
        usuario: usuario,
        onLoginTap: onLoginTap,
      ),

      // O corpo contém o segundo menu e o conteúdo do livro.
      body: Column(
        children: [
          // Segundo menu: voltar e favoritar.
          menuDetalhes(fav),

          // O conteúdo ocupa todo o espaço restante.
          Expanded(child: buildContent()),
        ],
      ),
      //Menu inferior de navegação
      bottomNavigationBar: AppBottomNav(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            Navigator.popUntil(context, (route) => route.isFirst);
          } else if (index == 1) {
            setState(() {
              isSearching = true;
            });
          } else if (index == 2) {
            if (usuario == null) {
              aviso('Faça login para ver seus favoritos');
              return;
            }
            //abre a tela de favoritos
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FavoritesScreen()),
            );
          } else if (index == 3) {
            //Botão de perfil
            if (usuario == null) {
              aviso('Faça login para acessar seu perfil');
              return;
            }
            aviso('Tela de perfil em breve!');
          }
        },
      ),
    );
  }

  /// Menu secundário exibido logo abaixo do HomeHeader.
  Widget menuDetalhes(bool fav) {
    return Container(
      width: double.infinity,
      color: AppColors.third,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Volta para a tela anterior.
          IconButton(
            tooltip: 'Voltar',
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back),
            color: AppColors.primary,
          ),

          // Alterna entre favoritado e não favoritado.
          IconButton(
            tooltip: fav ? 'Remover dos favoritos' : 'Adicionar aos favoritos',
            onPressed: onFavoriteTap,
            icon: Icon(
              fav ? Icons.favorite : Icons.favorite_border,
              color: fav ? Colors.red : AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  // ---------- CONTEÚDO DA TELA ----------

  Widget buildContent() {
    // Enquanto o JSON está sendo carregado.
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    // Exibe o erro se o livro não for encontrado.
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

    final fav = usuario?.favoritos.contains(widget.bookId) ?? false;

    final rating = (b['avaliacao_media'] as num).toDouble();

    final stats = b['estatisticas_rapidas'] as Map<String, dynamic>;

    final tech = b['detalhes_tecnicos'] as Map<String, dynamic>;

    final tags = (b['tags'] as List<dynamic>).cast<String>();

    // Os comentários novos aparecem antes dos comentários do JSON.
    final List<Map<String, dynamic>> comments = [
      ...(comentariosNovos[widget.bookId] ?? <Map<String, dynamic>>[]),
      ...(b['comentarios'] as List<dynamic>).cast<Map<String, dynamic>>(),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Capa, título, autor, categoria e avaliação.
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
                    errorBuilder: (_, __, ___) {
                      return Container(
                        color: const Color(0xFFE3E8F3),
                        child: const Icon(
                          Icons.menu_book,
                          color: AppColors.primary,
                          size: 36,
                        ),
                      );
                    },
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
                          color: Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      '${b['ano_publicacao']} • '
                      '${stats['paginas']} páginas',
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

          // 2. Sinopse.
          const SizedBox(height: 20),

          Text(b['sinopse'], style: const TextStyle(fontSize: 14, height: 1.5)),

          // 3. Botão para adicionar ou remover dos favoritos.
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onFavoriteTap,
              icon: Icon(fav ? Icons.favorite : Icons.favorite_border),
              label: Text(
                fav ? 'Remover dos favoritos' : 'Adicionar aos favoritos',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),

          // 4. Tags relacionadas ao livro.
          const SizedBox(height: 16),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags.map((t) {
              return Chip(
                label: Text(t, style: const TextStyle(fontSize: 12)),
                backgroundColor: AppColors.surface,
                side: const BorderSide(color: Color(0xFFD5DBE8)),
                shape: const StadiumBorder(),
              );
            }).toList(),
          ),

          // 5. Informações técnicas.
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

          // 6. Avaliação média.
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

          // 7. Lista de comentários.
          const SizedBox(height: 24),

          sectionTitle('Comentários (${comments.length})'),

          buildCommentBox(),

          ...comments.map(buildComment),
        ],
      ),
    );
  }

  // ---------- CAMPO PARA COMENTAR ----------

  /// Exibe o campo de comentário para usuários logados.
  /// Para visitantes, mostra uma mensagem solicitando login.
  Widget buildCommentBox() {
    if (usuario == null) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'Faça login pelo ícone no topo para comentar, '
          'curtir e favoritar.',
          style: TextStyle(fontSize: 13),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: commentController,
              minLines: 1,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Comentar como ${usuario!.nome}...',
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          IconButton.filled(
            onPressed: onSendComment,
            icon: const Icon(Icons.send),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ---------- COMPONENTES AUXILIARES ----------

  /// Título das seções da página.
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

  /// Linha com o nome e o valor de uma informação.
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

  /// Card de um comentário, com autor, data, texto e curtidas.
  Widget buildComment(Map<String, dynamic> c) {
    final user = c['usuario'] as Map<String, dynamic>;
    final name = user['nome'] as String;
    final commentId = c['id_comentario'] as int;

    final liked = usuario?.curtidas.contains(commentId) ?? false;

    final totalLikes = (c['curtidas'] as int) + (liked ? 1 : 0);

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
          // Autor, avatar, data e eventual nota.
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary,
                foregroundImage: NetworkImage(user['avatar_url']),
                onForegroundImageError: (_, __) {},
                child: Text(
                  name.isNotEmpty ? name[0] : '?',
                  style: const TextStyle(color: Colors.white),
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

              if ((c['nota'] as num) > 0)
                buildStars((c['nota'] as num).toDouble(), size: 14),
            ],
          ),

          // Texto do comentário.
          const SizedBox(height: 8),

          Text(c['texto'], style: const TextStyle(fontSize: 13, height: 1.4)),

          // Botão para curtir o comentário.
          const SizedBox(height: 8),

          InkWell(
            onTap: () => onLikeTap(commentId),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    liked ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                    size: 16,
                    color: liked ? AppColors.primary : AppColors.secondary,
                  ),

                  const SizedBox(width: 4),

                  Text(
                    '$totalLikes',
                    style: TextStyle(
                      fontSize: 12,
                      color: liked ? AppColors.primary : AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
