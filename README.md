# Condomínio Dunnas — Sistema de Chamados

Aplicação web em **Ruby on Rails 7** para gestão de chamados de condomínio, com foco em fluxo operacional entre **moradores**, **colaboradores** e **administradores**.

> O sistema permite abrir chamados por unidade, acompanhar status, registrar comentários, anexar imagens e notificar automaticamente os envolvidos.

---

## 📌 Visão geral

Este projeto resolve o fluxo de manutenção/ocorrências em condomínio com:

- abertura e acompanhamento de chamados por moradores;
- atendimento operacional por colaboradores (por tipo de chamado);
- gestão administrativa de usuários, blocos, unidades, tipos e status;
- trilha de histórico por comentários;
- notificações internas por alteração de status e novos comentários.

---

## 🧱 Stack e tecnologias

### Backend
- Ruby **3.2.2**
- Rails **7.2.3.x**
- PostgreSQL **16**

### Frontend
- ERB + Hotwire (Turbo + Stimulus)
- Tailwind CSS
- Importmap

### Autenticação e autorização
- **Devise** (autenticação)
- **CanCanCan** (controle de permissões)

### Recursos adicionais
- Active Storage (anexos de imagem)
- I18n com `rails-i18n`
- Docker / Docker Compose para ambiente de desenvolvimento

---

## 🧩 Domínio do negócio

### Entidades principais

- **User**
  - papéis: `resident`, `collaborator`, `administrator`
  - administradores podem gerir todo o sistema
  - colaboradores atendem chamados de tipos atribuídos
  - moradores visualizam/abrem chamados das suas unidades

- **Block**
  - representa um bloco do condomínio
  - ao criar, gera automaticamente as unidades com base em:
    - `floors_count`
    - `apartments_per_floor`

- **Unit**
  - unidade (apartamento), vinculada a um bloco

- **UserUnit**
  - vínculo entre morador e unidade

- **Ticket**
  - chamado principal
  - pertence a: usuário, unidade, tipo e status
  - possui comentários, notificações e anexo(s)

- **TicketType**
  - categoria do chamado (ex.: elétrica, hidráulica)
  - contém `sla_hours`
  - colaboradores são vinculados via `UserTicketType`

- **TicketStatus**
  - controla fluxo do chamado
  - status padrão e status final configuráveis

- **Comment**
  - histórico de mensagens por chamado

- **Notification**
  - notificações internas para usuários impactados

---

## 🔐 Regras de permissão (resumo)

As regras são implementadas em `app/models/ability.rb`.

### Administrador
- acesso total (`manage :all`)
- gerencia usuários, blocos, tipos, status e vínculos
- pode reabrir chamados concluídos

### Colaborador
- lê tipos e status
- lê e atualiza chamados apenas dos tipos atribuídos
- adiciona comentários nesses chamados

### Morador
- lê suas unidades
- abre chamados para unidades vinculadas
- visualiza chamados do seu escopo
- comenta chamados do seu escopo

---

## 🔄 Fluxo de chamados

### Status esperados (seed padrão)
- Aberto (padrão)
- Em andamento
- Concluído (final)
- Reaberto

### Transições aplicadas no modelo `Ticket`
- **Aberto** → Em andamento (colaborador/admin)
- **Aberto** → Concluído (admin)
- **Em andamento** → Concluído
- **Concluído** → Reaberto (somente admin + motivo obrigatório)
- **Reaberto** → Em andamento (colaborador/admin)
- **Reaberto** → Concluído (admin)

### Validações importantes
- morador só pode abrir chamado para unidade vinculada;
- parecer de conclusão é obrigatório ao concluir;
- motivo é obrigatório ao reabrir;
- `resolved_at` só existe em status final;
- anexos:
  - máximo de **1 arquivo** por chamado;
  - apenas imagens (`png`, `jpeg`, `webp`, `gif`, `heic`, `heif`);
  - limite de **5 MB**.

---

## 🔔 Notificações

Serviço: `app/services/ticket_notification_service.rb`

Eventos notificados:
- novo comentário no chamado;
- alteração de status.

Destinatários calculados automaticamente:
- administradores;
- colaboradores vinculados ao tipo do chamado;
- moradores da unidade;
- usuário criador do chamado;
- exclui quem realizou a ação (ator).

---

## 🗺️ Rotas principais

- `devise_for :users` (sem registro e sem recuperação de senha pública)
- `resources :tickets` (com comentários aninhados)
- `resources :ticket_statuses`
- `resources :ticket_types`
- `resources :blocks`
- `resources :notifications` + `mark_all_as_read`
- namespace `admin`:
  - `users`
  - `user_units`
  - `units#index` (endpoint de busca para formulário)

Raiz da aplicação:
- autenticado: `blocks#index`
- não autenticado: tela de login Devise

---

## ⚙️ Setup de ambiente

## 1) Pré-requisitos

- Docker + Docker Compose **ou**
- Ruby 3.2.2 + PostgreSQL 16 (execução local sem container)

## 2) Variáveis de ambiente

Crie um arquivo `.env` na raiz (se ainda não existir):

```env
POSTGRES_HOST=db
POSTGRES_USER=postgres
POSTGRES_PASSWORD=senha_dummy
POSTGRES_DB=desafio_dunnas_development
RAILS_MAX_THREADS=5
ADMIN_EMAIL=admin@admin.com
ADMIN_PASSWORD=123456
```

> `ADMIN_EMAIL` e `ADMIN_PASSWORD` são usados no seed inicial para criar o primeiro administrador (se não existir).

---

## 🐳 Executando com Docker (recomendado)

```bash
docker compose up --build
```

O serviço `web` já executa automaticamente:
- instalação de gems (`bundle check || bundle install`)
- `db:prepare`
- `db:seed`
- `bin/dev` (Rails + Tailwind watcher)

Acesse: `http://localhost:3000`

---

## 💻 Executando sem Docker

Instale dependências e prepare o banco:

```bash
bundle install
bin/rails db:prepare
bin/rails db:seed
```

Suba a aplicação em modo desenvolvimento:

```bash
bin/dev
```

Acesse: `http://localhost:3000`

---

## 👤 Acesso inicial

Após `db:seed`, caso não exista administrador no banco:

- email: valor de `ADMIN_EMAIL` (padrão `admin@admin.com`)
- senha: valor de `ADMIN_PASSWORD` (padrão `123456`)

---

## 🧪 Testes e qualidade

Executar suíte de testes:

```bash
bin/rails test
```

Ferramentas disponíveis no projeto:

```bash
bin/brakeman
bin/rubocop
```

---

## 📁 Estrutura relevante

```text
app/
  controllers/
    admin/
  models/
  services/
  views/
config/
db/
  migrate/
  schema.rb
  seeds.rb
docker-compose.yml
Dockerfile.dev
```

---

## 🚀 Deploy e operação

Pontos de atenção para produção:

- configurar credenciais/segredos (`RAILS_MASTER_KEY`, variáveis sensíveis);
- configurar serviço de storage para Active Storage (S3, GCS etc.);
- configurar banco PostgreSQL de produção (`POSTGRES_*`);
- revisar política de atualização de senha e recuperação de conta (se necessário);
- habilitar monitoramento de erros e observabilidade.

---

## 🔮 Melhorias futuras sugeridas

- SLA com alertas automáticos por vencimento;
- paginação e ordenação avançada de chamados;
- exportação de relatórios (CSV/PDF);
- dashboard com indicadores por bloco/tipo/status;
- webhook/e-mail/push para notificações externas.

---

## 📄 Licença

Defina aqui a licença do projeto (ex.: MIT, proprietária, interna da empresa etc.).
