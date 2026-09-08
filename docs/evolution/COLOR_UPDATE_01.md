# Atualização da Paleta de Cores (Deep Space Theme)

Este documento registra a mudança na paleta de cores padrão do Neuroly para atender aos novos requisitos visuais de design.

## Arquivos Alterados
1. `lib/core/theme/app_colors.dart`: Substituição direta das variáveis de cores da classe `AppColors`.
2. `docs/PROJECT_OVERVIEW.md`: Atualização da documentação da sessão "Paleta de Cores" para refletir as novas diretrizes.

## Tabela de Comparação

| Elemento (AppColors) | Cor Antiga | Nova Cor | Descrição do Novo Uso |
| :--- | :--- | :--- | :--- |
| **background** | `#13121B` | `#0F0930` | Fundo Principal (Deep Night/Space). Fundo de todas as telas. |
| **surface** | `#1F1F28` | `#28187B` | Containers & Cards. Base com transparência para o efeito Glassmorphism. |
| **surfaceBright** | `#393842` | `#4C4FA2` | Realces e efeitos de brilho/hover sobre o surface. |
| **primary** | `#4F46E5` | `#9048D6` | Roxo Identidade (Primary Brand). Destaques, barras de progresso, avatares. |
| **primaryDim** | `#C3C0FF` | `#B37EE6` | Roxo Suave (Destaques secundários / variação primária). |
| **secondary** | `#22C55E` | `#1EA9FE` | Azul Elétrico (High-Contrast Accent). CTAs, botões, contadores de créditos, picos de gráfico. |
| **cyan** | `#06B6D4` | `#1EA9FE` | (Mesmo que secundário) Utilizado para highlights de pontuação. |
| **textHigh** | `#F8FAFC` | `#FFFFFF` | Texto Principal & Ícones para máxima legibilidade no fundo escuro. |
| **textMedium** | `#C7C4D8` | `#B0B3DE` | Textos de suporte, legendas e placeholders. |
| **outline** | `#464555` | `#4C4FA2` | Elementos Secundários & Bordas sutis, botões inativos, divisores. |
