# Monorepo Template

Nx monorepo template with a NestJS API, a React client, and shared libraries. Ready for Keycloak OIDC auth, PostgreSQL, and GitOps deployment.

## Technical Stack

| Layer        | Technology                         |
| :----------- | :--------------------------------- |
| **Monorepo** | Nx 22                              |
| **Backend**  | NestJS 11, Prisma 7, PostgreSQL 17 |
| **Frontend** | React 19, TailwindCSS, Radix UI    |
| **Auth**     | Keycloak 23 (OIDC)                 |
| **CI/CD**    | GitHub Actions, GitOps (Kustomize) |

## Architecture

```
apps/
  api/           -> NestJS API (port 3000, prefix /api)
  web/           -> React client (port 4200)
  api-e2e/       -> E2E Tests API (Jest)
  web-e2e/       -> E2E Tests Web (Playwright)

libs/
  api/core/      -> Global NestJS module (Prisma, Health, Logger, Auth, Throttler)
  shared-models/ -> Shared DTOs and Zod schemas
  shared-web/    -> Shared React utilities (React Query, Axios)
  i18n/          -> Internationalization (i18next)
```

## Prerequisites

- Node.js 24+
- Docker & Docker Compose
- npm

## New Project Setup

Use the provided setup script to initialize a new project from this template:

```bash
# 1. Create repo from template (GitHub UI or gh cli)
gh repo create my-project --template <template-repo-url>
cd my-project

# 2. Run the setup script
chmod +x setup.sh
./setup.sh
```

The script will:

- Ask for your project name
- Copy example configuration files (`.env`, `config.js`)
- Replace template placeholders with your project name
- Install dependencies
- Start infrastructure (PostgreSQL, Keycloak)
- Generate Prisma client and apply migrations

### Manual Setup

If you prefer to set up manually:

```bash
# 1. Clone and install
git clone <repo-url>
cd my-project
npm install

# 2. Environment
cp .env.example .env
# Edit .env with your values (database, Keycloak, etc.)
cp config/web/config.example.js apps/web/public/config.js
# Edit config.js to match your Keycloak realm/client

# 3. Start infrastructure
docker compose up -d

# 4. Generate Prisma client and apply migrations
npm run prisma:generate
npm run prisma:migrate:deploy

# 5. Start applications
npm run serve:api      # API: http://localhost:3000
npm run serve:web      # Web: http://localhost:4200
```

## Values to Update Per Project

When creating a new project from this template, update the following:

### Environment & Configuration

| File                        | Value to update            | Description              |
| :-------------------------- | :------------------------- | :----------------------- |
| `.env`                      | `DB_NAME`                  | Database name            |
| `.env`                      | `DATABASE_URL`             | Full connection string   |
| `.env`                      | `KEYCLOAK_CLIENT_ID`       | Keycloak client ID       |
| `.env`                      | `KEYCLOAK_ISSUER_URL`      | Keycloak realm URL       |
| `apps/web/public/config.js` | `realm`, `clientId`, `url` | Frontend Keycloak config |

### Docker & Infrastructure

| File                 | Value to update       | Description                              |
| :------------------- | :-------------------- | :--------------------------------------- |
| `docker-compose.yml` | `container_name` (x2) | `template_postgres`, `template_keycloak` |
| `docker-compose.yml` | Network name          | `template_network`                       |

### CI/CD (GitHub Repository Settings)

| Type     | Name                    | Description                                                    |
| :------- | :---------------------- | :------------------------------------------------------------- |
| Variable | `GITOPS_REPO`           | GitOps repository (e.g. `org/gitops`)                          |
| Variable | `DOCKER_MANUAL_ONLY`    | Set to `true` to restrict Docker builds to manual trigger only |
| Secret   | `GITOPS_PAT`            | Personal access token for GitOps repo                          |
| Secret   | `SLACK_WEBHOOK_URL`     | Slack incoming webhook for deploy notifications                |
| Secret   | `NX_CLOUD_ACCESS_TOKEN` | Nx Cloud access token (optional)                               |

### Nx Cloud

| File      | Value to update | Description                |
| :-------- | :-------------- | :------------------------- |
| `nx.json` | `nxCloudId`     | Your Nx Cloud workspace ID |

## Main Commands

### Development

```bash
docker compose up -d           # Start infrastructure (Postgres, Keycloak)
npm run serve:api              # Start API
npm run serve:web              # Start Web
```

### Build

```bash
npm run build:api              # Build API
npm run build:web              # Build Web
npm run build:all              # Build all
```

### Tests

```bash
npm run test:api               # API unit tests
npm run test:web               # Web unit tests
npm run test:all               # All unit tests

npm run e2e:api                # E2E tests API (Jest)
npm run e2e:web                # E2E tests Web (Playwright)
npm run e2e:web-ui             # E2E tests Web (Playwright UI mode)
```

### Lint & Format

```bash
npm run lint:api               # Lint API
npm run lint:web               # Lint Web
npm run lint:all               # Lint all
npm run format                 # Format code
```

### Database

```bash
npm run prisma:generate        # Generate Prisma client
npm run prisma:migrate:dev     # Create or apply migrations (dev)
npm run prisma:migrate:deploy  # Apply migrations (prod)
npm run prisma:studio          # Prisma Studio (DB GUI)
```

## Docker Infrastructure

| Service    | Port | Description        |
| :--------- | :--- | :----------------- |
| PostgreSQL | 5432 | Database           |
| Keycloak   | 8080 | OIDC/OAuth2 server |

## CI/CD

Two GitHub Actions workflows are included:

- **CI** (`ci.yml`): Runs lint, tests, typecheck and build on push to `main` and on pull requests.
- **Docker** (`docker.yml`): Builds and pushes Docker images to GHCR, then deploys via GitOps (Kustomize). Triggers on push to `main` (path-filtered), release, or manual dispatch. Set `DOCKER_MANUAL_ONLY=true` to restrict to manual trigger only.
