# Neuroly - Cognitive Evolution Hub

## 🎯 Objetivo do Projeto
O **Neuroly** é uma plataforma interativa e gamificada projetada para aprimorar as funções cognitivas dos usuários (como memória, atenção, agilidade mental e reconhecimento de padrões) através de mini-jogos diários. O aplicativo busca oferecer uma experiência premium, imersiva e visualmente sofisticada ("Cyber-Cognitive"), utilizando técnicas modernas de design como **Glassmorphism** e animações fluidas.

---

## 🛠 Tecnologias e Dependências
* **Framework:** Flutter
* **Linguagem:** Dart
* **Animações:** `flutter_animate` (para transições, fades, slides e micro-interações).
* **Ícones:** `lucide_icons` e `cupertino_icons` (design moderno e minimalista).
* **Tipografia:** `google_fonts`
* **Gerenciador de Assets:** `flutter_launcher_icons` (utilizado para gerar os ícones responsivos e flat com cor de fundo para Android, iOS e Web).

---

## 🏛 Arquitetura
O projeto segue uma arquitetura orientada a funcionalidades (**Feature-First** / **Clean Architecture Simplificada**). O código está organizado para facilitar a escalabilidade e a manutenção:

```
lib/
├── core/
│   ├── theme/            # Definição de cores globais (app_colors.dart), temas
│   └── widgets/          # Widgets reutilizáveis (MainLayoutScreen, GlassContainer)
├── features/
│   ├── auth/             # Fluxo de login e autenticação
│   ├── game/             # Mini-jogos cognitivos (Memória, Atenção, Sequência)
│   ├── home/             # Tela inicial (Dashboard, Missões diárias)
│   ├── modules/          # Biblioteca de rotinas e aprendizado
│   ├── profile/          # Gestão de usuário, foto de perfil, dados de conta
│   ├── ranking/          # Leaderboard nacional e pódio
│   └── stats/            # Gráficos e acompanhamento de evolução
└── main.dart             # Entry-point, configuração de rotas globais animadas
```

### Roteamento Global (Routing)
A navegação não utiliza o padrão seco do Flutter. Foi configurado um `onGenerateRoute` no `main.dart` utilizando `PageRouteBuilder`. Toda transição de página no app (ex: entrar ou sair de um jogo) possui uma animação cinematográfica unificada de **Slide (deslizamento lateral) + Fade (transparência)**. As trocas de aba no menu inferior utilizam `AnimatedSwitcher`.

---

## 🎨 Design System e Identidade Visual

O Neuroly adota um **Dark Theme Premium**. As cores são mapeadas de forma semântica no arquivo `app_colors.dart`.

### Paleta de Cores
* **Background (`#0F0930`):** Fundo Principal (Deep Night/Space). Usar no fundo de todas as telas.
* **Surface (`#28187B`):** Containers & Cards (usar na base dos cards com transparência para o efeito Glassmorphism).
* **Surface Bright (`#4C4FA2`):** Realce sobre o surface (útil para hover e destaques de input).
* **Primary (`#9048D6`):** Roxo Identidade (Primary Brand). Usar em destaques de marca, barras de progresso principal e avatares.
* **Primary Dim (`#B37EE6`):** Roxo Suave (Destaques secundários).
* **Secondary (`#1EA9FE`):** Azul Elétrico (High-Contrast Accent). Usar para chamadas de ação (CTAs), botões de jogo, contadores de "Neuro-créditos" e picos do gráfico.
* **Cyan (`#1EA9FE`):** Ciano Tech (Acertos rápidos, highlights de pontuação).
* **Text High (`#FFFFFF`):** Texto & Ícones (Usar para máxima legibilidade sobre o fundo escuro).
* **Text Medium (`#B0B3DE`):** Texto de suporte, legendas, placeholders.
* **Outline (`#4C4FA2`):** Elementos Secundários & Bordas (usar em bordas sutis, botões inativos e divisores de seção).

### Estilo
* **Glassmorphism:** Utilizado em menus e cards, criado combinando bordas translúcidas (`AppColors.outline`), fundos semi-transparentes ou gradientes sutis (via `GlassContainer`), emulando vidro escuro moderno.
* **Animações Staggered:** Elementos entram na tela em formato "cascata", guiando a atenção do usuário de cima para baixo.

---

## 📱 Mapa de Telas (Pages)

1. **LoginScreen:** Ponto de entrada com o logotipo. Possui validações visuais simples.
2. **MainLayoutScreen:** Estrutura base após o login. Controla o menu inferior (`BottomNavigationBar`) com transições elegantes (Cross-Fade) entre as abas.
3. **HomeScreen:** Dashboard que exibe "Estatística Cognitiva", missões diárias e os atalhos rápidos para iniciar os módulos de treinamento diário.
4. **StatsScreen:** Central de desempenho, onde gráficos expõem a curva de melhora do usuário (foco, memória, reflexo).
5. **ModulesScreen:** Biblioteca de módulos de treinamento focados e rotinas que o usuário pode seguir para desbloquear novos patamares cerebrais.
6. **RankingScreen:** Tela competitiva Nacional. Exibe os "Top 3" com uma animação de pódio (coroa animada para o 1º lugar) e uma lista com efeito cascata para os demais do Top 10. O usuário ("Você") sempre fica em evidência.
7. **ProfileScreen:** Visão pessoal. Permite editar nome, e-mail e ver as estatísticas resumidas, ostentando a foto do avatar escolhido localmente.

### 🎮 Mini-Jogos Cognitivos (Game Features)
* **MemoryGame (Jogo da Memória):** Cartas com ícones embaralhados. O usuário precisa encontrar os pares em uma grade com animações de _Flip 3D_ e _Scale_ para os acertos.
* **AttentionGame (Jogo da Atenção):** Alvo central flutuante que deve ser clicado no menor tempo possível. Cliques fora da área geram uma animação de _Shake_ (tremor) como feedback visual de erro.
* **SequenceGame (Jogo da Sequência):** Desafio de memória operacional (estilo Simon Says). Itens piscam na tela em uma sequência lógica e o usuário deve repeti-la.

---

## 🚀 Próximos Passos (Roadmap)
- Conexão do `StatsScreen` com a pontuação real vinda dos jogos (`game_screen`).
- Implementar armazenamento em `shared_preferences` ou `hive` para persistir estado localmente.
- Implementação de um fluxo de backend real (ex: Supabase / Firebase) para Login e sincronização do Leaderboard Nacional e dados cruzados.
