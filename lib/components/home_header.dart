import 'package:book_space/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Cabeçalho da Tela 1.
/// Normal: logo à esquerda e lupa à direita.
/// Buscando: campo de texto no lugar da logo e um X no lugar da lupa.
class HomeHeader extends StatelessWidget implements PreferredSizeWidget {
  const HomeHeader({
    super.key,
    this.isSearching = false,
    this.onSearchTap,
    this.onSearchClose,
    this.onSearchChanged,
  });

  final bool isSearching; // true = campo de busca aberto
  final VoidCallback? onSearchTap; // tocou na lupa
  final VoidCallback? onSearchClose; // tocou no X
  final ValueChanged<String>? onSearchChanged; // o texto digitado mudou

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      systemOverlayStyle:
          SystemUiOverlayStyle.light, // ícones da barra de status brancos
      automaticallyImplyLeading: false,
      titleSpacing: 20,
      title: isSearching ? _buildSearchField() : _buildLogo(),
      actions: [
        IconButton(
          icon: Icon(
            isSearching ? Icons.close : Icons.search,
            color: AppColors.third,
          ),
          tooltip: isSearching ? 'Fechar busca' : 'Pesquisar',
          onPressed: isSearching ? onSearchClose : onSearchTap,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildLogo() {
    return Image.asset(
      'assets/images/logo_white.png',
      height: 32,
      // Se a imagem não for encontrada, mostra o nome em texto em vez de quebrar o app
      errorBuilder: (context, error, stackTrace) => const Text(
        'BookSpace',
        style: TextStyle(
          color: AppColors.surface,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      autofocus: true, // já abre com o teclado pronto para digitar
      onChanged: onSearchChanged,
      cursorColor: AppColors.surface,
      style: const TextStyle(color: AppColors.surface, fontSize: 16),
      decoration: const InputDecoration(
        hintText: 'Título, autor ou categoria',
        hintStyle: TextStyle(color: Colors.white54),
        border: InputBorder.none,
      ),
    );
  }
}
