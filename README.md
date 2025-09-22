# ⚡ Eletrocast - Plataforma de Podcast e Notícias

[![Deployed on Vercel](https://img.shields.io/badge/Deployed%20on-Vercel-black?style=for-the-badge&logo=vercel)](https://vercel.com)
[![Built with Next.js](https://img.shields.io/badge/Built%20with-Next.js-black?style=for-the-badge&logo=next.js)](https://nextjs.org)
[![Powered by Supabase](https://img.shields.io/badge/Powered%20by-Supabase-green?style=for-the-badge&logo=supabase)](https://supabase.com)

Uma plataforma moderna e completa para podcasts de tecnologia, com integração ao YouTube, sistema de notícias, painel administrativo e recursos avançados de engajamento.

## 🎯 Visão Geral

O Eletrocast é uma aplicação web full-stack construída com Next.js 14, que oferece:

- **Integração YouTube**: Detecção automática de lives, premieres e últimos vídeos
- **Sistema de Notícias**: CMS completo com tags, comentários e newsletter
- **Painel Admin**: Interface administrativa protegida para gerenciamento de conteúdo
- **PWA**: Aplicativo instalável para dispositivos móveis
- **Dark Mode**: Tema escuro/claro com detecção automática
- **Notificações**: E-mail e Discord webhooks para engajamento

## 🚀 Funcionalidades Principais

### 🏠 Página Inicial
- ✅ Detecção de live streams ativas
- ✅ Countdown para vídeos com premiere
- ✅ Exibição do último vídeo publicado
- ✅ Player YouTube incorporado
- ✅ Design responsivo e animado

### 📰 Sistema de Notícias
- ✅ Lista paginada de notícias
- ✅ Sistema de tags visuais
- ✅ Busca inteligente por título, conteúdo e tags
- ✅ Páginas individuais com SEO otimizado
- ✅ Sistema de comentários com moderação
- ✅ Botões de compartilhamento social

### 🎧 Página de Podcast
- ✅ Grid de episódios com thumbnails
- ✅ Links diretos para YouTube
- ✅ Informações detalhadas de cada episódio

### 🔐 Painel Administrativo
- ✅ Autenticação via Supabase Auth
- ✅ CRUD completo de notícias
- ✅ Sistema de tags interativo
- ✅ Upload de imagens via URL
- ✅ Validação de formulários com Zod
- ✅ Auditoria de ações (created_by, updated_by)

### 🌟 Recursos Avançados
- ✅ PWA instalável
- ✅ Dark mode automático/manual
- ✅ Skeleton loaders
- ✅ Animações com Framer Motion
- ✅ Newsletter integrada
- ✅ Notificações por e-mail (Resend)
- ✅ Webhooks Discord
- ✅ Cache inteligente com ISR

## 🛠️ Stack Tecnológica

### Frontend
- **Next.js 14** - Framework React com App Router
- **TypeScript** - Tipagem estática
- **Tailwind CSS** - Framework de estilização
- **Framer Motion** - Animações e transições
- **React Hook Form + Zod** - Formulários e validação
- **next-themes** - Gerenciamento de temas

### Backend & Database
- **Supabase** - Backend-as-a-Service
  - PostgreSQL Database
  - Authentication
  - Row Level Security (RLS)
  - Storage para imagens
- **YouTube Data API v3** - Integração com YouTube

### Serviços Externos
- **Resend** - Envio de e-mails
- **Discord Webhooks** - Notificações da comunidade
- **Vercel Analytics** - Métricas de uso

### DevOps & Deploy
- **Vercel** - Hospedagem e deploy
- **Git** - Controle de versão
- **ESLint + Prettier** - Qualidade de código

## 📦 Instalação e Configuração

### Pré-requisitos
- Node.js 18+ 
- npm ou yarn
- Conta no Supabase
- YouTube Data API Key
- Conta no Resend (opcional)
- Discord Webhook (opcional)

### 1. Clone o repositório
```bash
git clone https://github.com/zwlucas/eletrocast.git
cd eletrocast
```

### 2. Instale as dependências
```bash
npm install
```

### 3. Configure as variáveis de ambiente
Copie o arquivo `.env.example` para `.env.local`:

```bash
cp .env.example .env.local
```

Configure as seguintes variáveis:

```env
# Supabase
NEXT_PUBLIC_SUPABASE_URL=sua_url_do_supabase
NEXT_PUBLIC_SUPABASE_ANON_KEY=sua_chave_anonima_do_supabase

# YouTube Data API v3
YOUTUBE_API_KEY=sua_chave_da_youtube_api
YOUTUBE_CHANNEL_ID=id_do_seu_canal

# Site URL
NEXT_PUBLIC_SITE_URL=https://seusite.com

# Notificações (opcionais)
RESEND_API_KEY=sua_chave_do_resend
DISCORD_WEBHOOK_URL=sua_url_do_webhook_discord
```

### 4. Configure o banco de dados
Execute os scripts SQL na seguinte ordem no Supabase:

```bash
# 1. Criar tabelas básicas
scripts/01-create-tables.sql

# 2. Inserir dados de exemplo
scripts/02-seed-data.sql

# 3. Adicionar tags e auditoria
scripts/03-add-tags-and-audit.sql

# 4. Adicionar comentários
scripts/04-comments.sql
```

### 5. Execute o projeto
```bash
npm run dev
```

Acesse `http://localhost:3000` para ver o projeto rodando.

## 🔧 Scripts Disponíveis

```bash
# Desenvolvimento
npm run dev          # Inicia o servidor de desenvolvimento

# Build e produção
npm run build        # Gera build de produção
npm run start        # Inicia servidor de produção

# Qualidade de código
npm run lint         # Executa ESLint
npm run type-check   # Verifica tipos TypeScript
```

## 📁 Estrutura do Projeto

```
eletrocast/
├── app/                    # App Router do Next.js
│   ├── admin/             # Painel administrativo
│   ├── api/               # API routes
│   ├── noticias/          # Páginas de notícias
│   ├── podcast/           # Página de podcast
│   ├── sobre/             # Página sobre
│   ├── globals.css        # Estilos globais
│   ├── layout.tsx         # Layout principal
│   └── page.tsx           # Página inicial
├── components/            # Componentes React
│   ├── ui/               # Componentes shadcn/ui
│   ├── AnimatedComponents.tsx
│   ├── Comments.tsx
│   ├── Header.tsx
│   └── ...
├── lib/                  # Utilitários e configurações
│   ├── supabase.ts       # Cliente Supabase
│   ├── youtube.ts        # API YouTube
│   └── notifications.ts  # Sistema de notificações
├── scripts/              # Scripts SQL
├── public/               # Arquivos estáticos
└── README.md
```

## 🎨 Design System

### Paleta de Cores
- **Branco**: `#FFFFFF` - Fundo principal
- **Azul**: `#1D4ED8` - Elementos principais, links
- **Amarelo**: `#FACC15` - Destaques, botões, datas
- **Cinza**: Variações para textos e backgrounds

### Tipografia
- **Fonte**: Inter (Google Fonts)
- **Pesos**: 400 (regular), 500 (medium), 600 (semibold), 700 (bold)

### Componentes
- Cantos arredondados: `8px`
- Sombras suaves para cards
- Animações de hover e transições
- Design mobile-first

## 🔐 Segurança

### Autenticação
- Supabase Auth para login administrativo
- Sessões seguras com JWT
- Logout automático por inatividade

### Autorização
- Row Level Security (RLS) no Supabase
- Políticas específicas por tabela
- Validação de permissões no frontend e backend

### Validação
- Validação de entrada com Zod
- Sanitização de dados
- Proteção contra XSS e SQL Injection

## 🚀 Deploy

### Vercel (Recomendado)
1. Conecte seu repositório ao Vercel
2. Configure as variáveis de ambiente
3. Deploy automático a cada push

### Outras Plataformas
O projeto é compatível com qualquer plataforma que suporte Next.js:
- Netlify
- Railway
- DigitalOcean App Platform

## 🤝 Contribuição

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

### Padrões de Código
- Use TypeScript para tipagem
- Siga as convenções do ESLint
- Escreva commits descritivos
- Documente funções complexas

## 📝 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

## 🆘 Suporte

- **Issues**: [GitHub Issues](https://github.com/zwlucas/eletrocast/issues)
- **Discussões**: [GitHub Discussions](https://github.com/zwlucas/eletrocast/discussions)
- **E-mail**: contato@eletrocast.com

## 🙏 Agradecimentos

- [Next.js](https://nextjs.org) - Framework React
- [Supabase](https://supabase.com) - Backend-as-a-Service
- [Tailwind CSS](https://tailwindcss.com) - Framework CSS
- [Framer Motion](https://framer.com/motion) - Animações
- [Lucide](https://lucide.dev) - Ícones
- [Vercel](https://vercel.com) - Hospedagem

---

**Feito com ❤️ por [@lucas.fariamo](https://instagram.com/lucas.fariamo)**
