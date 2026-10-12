class Usuario {
  final String nome;
  final String email;

  // Coisas que pertencem à usuária (ficam na memória, é um mock)
  final Set<int> favoritos = {}; // ids dos livros favoritados
  final Set<int> curtidas = {}; // ids dos comentários curtidos

  Usuario(this.nome, this.email);
}

// Comentários novos são públicos (todo mundo vê), por isso ficam fora do Usuario.
// Chave = id do livro; valor = lista de comentários feitos no app.
final Map<int, List<Map<String, dynamic>>> comentariosNovos = {};

// Se o id está no conjunto, remove; se não está, adiciona.
void alternar(Set<int> conjunto, int id) {
  if (!conjunto.remove(id)) conjunto.add(id);
}
