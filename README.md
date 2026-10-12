<div align="center">

# 📚 BookSpace

### Descubra histórias. Organize leituras. Compartilhe opiniões.

Um aplicativo mobile para explorar e organizar livros.

</div>

---

## 📖 Sobre o projeto

O **BookSpace** é um **projeto escolar** desenvolvido como parte do aprendizado de desenvolvimento de aplicativos móveis. A proposta é criar um espaço digital no qual usuários possam consultar livros, encontrar obras por meio de buscas e categorias e organizar seus favoritos.

> **Importante:** este é um projeto acadêmico, criado para fins de estudo e demonstração.

## ✨ Funcionalidades

A proposta do aplicativo inclui:

- 📚 **Catálogo de livros:** visualização de livros e informações sobre as obras.
- 🔎 **Busca e filtros:** pesquisa por título, autor ou categoria.
- 🗂️ **Categorias:** organização dos livros por temas, como Tecnologia, Ficção e Negócios.
- ❤️ **Favoritos:** acesso rápido aos livros selecionados.
- ⭐ **Avaliações:** possibilidade de avaliar livros.
- 💬 **Comentários:** espaço para compartilhar opiniões sobre as leituras.
- 👤 **Área de usuário:** recursos que dependem de autenticação.

*As funcionalidades disponíveis podem variar conforme o estágio atual de desenvolvimento do projeto.*

## 🧰 Tecnologias utilizadas

- **Flutter** — framework para desenvolvimento de interfaces e aplicativos multiplataforma.
- **Dart** — linguagem de programação utilizada pelo Flutter.
- **Provider** — gerenciamento de estado compartilhado entre componentes e telas.
- **Scrcpy** — ferramenta opcional para espelhar e controlar a tela de um dispositivo Android pelo computador durante o desenvolvimento.

## 🖥️ Pré-requisitos

Antes de executar o projeto, instale e configure:

1. **Git**, para obter o código-fonte.
2. **Flutter SDK**, incluindo o Dart.
3. **Android Studio** ou as ferramentas Android SDK necessárias para compilar e executar o aplicativo.
4. **Visual Studio Code** ou outra IDE de sua preferência.
5. Um dispositivo Android com cabo USB ou um emulador Android.

Para conferir se o ambiente Flutter está configurado, abra um terminal e execute:

```bash
flutter doctor
```

Siga as orientações exibidas para corrigir eventuais dependências ausentes.

## 🚀 Como executar o BookSpace

### 1. Obtenha o código do projeto

Clone o repositório e entre na pasta do projeto:

```bash
git clone https://github.com/mari-moreira/BookSpace.git
cd BookSpace
```

Se o nome da pasta local for diferente, entre na pasta que contém o arquivo `pubspec.yaml`.

### 2. Instale as dependências

Na raiz do projeto — a pasta que contém o arquivo `pubspec.yaml` — execute:

```bash
flutter pub get
```

Esse comando baixa as dependências declaradas no projeto.

### 3. Conecte o dispositivo Android

Você pode usar um emulador ou conectar um celular Android por USB. Para usar um celular físico, siga as instruções da seção [Preparar o Android para depuração USB](#-preparar-o-android-para-depuração-usb).

Verifique se o Flutter reconhece o dispositivo:

```bash
flutter devices
```

Se o celular aparecer na lista, continue. Caso não apareça, confira o cabo USB, o modo de conexão e se a depuração USB está autorizada.

### 4. Execute o aplicativo

Com o terminal aberto na pasta do projeto, execute:

```bash
flutter run
```

O Flutter compilará o aplicativo e tentará iniciá-lo no dispositivo selecionado. Se houver mais de um dispositivo conectado, informe o identificador desejado:

```bash
flutter run -d ID_DO_DISPOSITIVO
```

Para interromper a execução iniciada pelo terminal, pressione `q` ou `Ctrl + C`, conforme o terminal utilizado.

---

## 📱 Preparar o Android para depuração USB

Para executar o BookSpace diretamente no celular, é necessário habilitar as **Opções do desenvolvedor** e a **Depuração USB**. Os nomes dos menus podem variar de acordo com a marca e a versão do Android.

### 1. Ative as Opções do desenvolvedor

1. Abra **Configurações** no celular.
2. Entre em **Sobre o telefone**. Em alguns aparelhos, pode ser necessário abrir primeiro **Informações do software**.
3. Localize **Número da versão** (*Build number*).
4. Toque em **Número da versão sete vezes seguidas**.
5. Se solicitado, informe o PIN, padrão ou senha do aparelho.
6. Uma mensagem deverá indicar que as opções de desenvolvedor foram ativadas.

Em alguns modelos, o caminho pode ser diferente. Se não encontrar a opção, pesquise nas Configurações por “Número da versão”.

### 2. Ative a Depuração USB

1. Volte para **Configurações**.
2. Abra **Opções do desenvolvedor** — normalmente fica em Sistema ou Configurações adicionais.
3. Ative **Depuração USB**.
4. Leia e confirme o aviso apresentado pelo Android.

### 3. Conecte o celular ao computador

1. Conecte o aparelho usando um cabo USB que permita **transferência de dados**, não apenas carregamento.
2. Desbloqueie a tela do celular.
3. Quando aparecer a solicitação para permitir a depuração USB, confira a identificação do computador e toque em **Permitir**. Autorize apenas computadores confiáveis.
4. No terminal do projeto, execute:

```bash
flutter devices
```

Se o dispositivo for reconhecido, execute `flutter run`.

**Dica:** se o celular não aparecer, tente outra porta USB ou outro cabo e verifique se o Android SDK e os drivers USB do fabricante estão instalados quando necessários.

---

## 🪞 Como instalar e usar o Scrcpy

### O que é o Scrcpy?

O **scrcpy** (*screen copy*) é uma ferramenta gratuita e de código aberto que permite **espelhar a tela de um dispositivo Android no computador e interagir com ele usando o mouse e o teclado**.

Durante o desenvolvimento, ele facilita acompanhar a tela do celular no monitor e demonstrar o aplicativo sem precisar olhar continuamente para o aparelho.

O scrcpy não é um emulador e não substitui o Flutter: o aplicativo continua sendo executado no celular conectado. Ele se comunica com o dispositivo por meio do ADB (*Android Debug Bridge*).

Repositório oficial: https://github.com/Genymobile/scrcpy

### 🪟 Windows

A forma mais simples é instalar pelo **Windows Package Manager (winget)**:

1. Conecte o celular ao computador e habilite a Depuração USB seguindo a seção anterior.
2. Abra o **PowerShell** ou o **Terminal do Windows**.
3. Execute:

```powershell
winget install --exact Genymobile.scrcpy
```

4. Aguarde a conclusão da instalação.
5. Abra um novo terminal, se necessário, e execute:

```powershell
scrcpy
```

A tela do celular deverá abrir em uma janela no computador.

### 🐧 Linux

Em distribuições que utilizam o APT, como Ubuntu e Debian, abra o terminal e execute:

```bash
sudo apt update
sudo apt install scrcpy
```

Em seguida, conecte o celular com a Depuração USB ativada e execute:

```bash
scrcpy
```

**Observação:** a versão disponível pode variar conforme a distribuição e seus repositórios. Se o pacote não estiver disponível ou estiver muito desatualizado, consulte as instruções oficiais para outras formas de instalação: https://github.com/Genymobile/scrcpy

### Usando o Scrcpy com o BookSpace

Depois de instalar o Scrcpy:

1. Conecte o celular por USB e desbloqueie a tela.
2. Confirme a autorização de depuração USB no aparelho, caso seja solicitada.
3. Abra um terminal e execute `scrcpy`.
4. Em outro terminal, entre na pasta do projeto e execute:

```bash
flutter run
```

O **Flutter** compila e executa o BookSpace no celular. O **Scrcpy** espelha a tela e permite controlar o aparelho pelo computador. São ferramentas diferentes que funcionam em conjunto.

Se o Scrcpy não encontrar o dispositivo, verifique a conexão USB, a Depuração USB e a autorização do computador. Em instalações que incluem o ADB no PATH, você também pode verificar os dispositivos com:

```bash
adb devices
```

Para encerrar o espelhamento, feche a janela do Scrcpy ou interrompa o processo no terminal.

### 🔐 Segurança

A Depuração USB concede ao computador autorizado acesso de desenvolvimento ao dispositivo. Autorize apenas computadores confiáveis e desative a Depuração USB quando não precisar mais dela.

---

## 🗂️ Organização do projeto

A estrutura abaixo é ilustrativa e pode variar conforme a versão atual do código:

```text
BookSpace/
├── lib/
│   ├── components/   # Componentes reutilizáveis da interface
│   ├── core/         # Recursos compartilhados e gerenciamento de estado
│   └── screens/      # Telas do aplicativo
├── pubspec.yaml      # Configuração e dependências do Flutter
└── README.md         # Documentação do projeto
```

## 🧩 Comandos úteis

| Comando | Para que serve |
|---|---|
| `flutter doctor` | Verifica o ambiente de desenvolvimento. |
| `flutter pub get` | Instala as dependências do projeto. |
| `flutter devices` | Lista os dispositivos reconhecidos pelo Flutter. |
| `flutter run` | Compila e executa o aplicativo. |
| `flutter analyze` | Analisa o código em busca de problemas. |
| `flutter clean` | Remove arquivos de compilação gerados; pode ser necessário executar `flutter pub get` novamente. |
| `scrcpy` | Espelha e permite controlar a tela do Android pelo computador. |

---

<div align="center">

**BookSpace — um espaço para descobrir sua próxima leitura.** 📖<br>
by Mariana M.

</div>

