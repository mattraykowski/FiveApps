# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Five Apps is a Phoenix/LiveView companion application for the Five Parsecs and Five Leagues tabletop games. The application uses the Ash Framework for resource management and business logic, with AshPostgres for data persistence.

## Technology Stack

- **Framework**: Phoenix 1.8 with LiveView 1.0.9
- **Language**: Elixir 1.18
- **Data Layer**: AshPostgres with PostgreSQL
- **CSS**: Tailwind CSS with DaisyUI components
- **Authentication**: AshAuthentication (password, magic link, confirmation)
- **APIs**: AshJsonApi, AshGraphql, Absinthe
- **Admin Interface**: AshAdmin
- **Testing**: ExUnit with Test-Driven Development approach

## Architecture

### Ash Domains

The application is organized into two primary Ash domains:

1. **FiveApps.Accounts** - User authentication and authorization
   - `User` - User accounts with password, magic link, and API key authentication
   - `Token` - JWT tokens for authentication
   - `ApiKey` - API keys for programmatic access

2. **FiveApps.Campaigns** - Campaign management for Five Parsecs game
   - `Campaign` - Main campaign entity with status, difficulty, story progression
   - `CrewMember` - Individual crew members in a campaign
   - `Ship` - Player's ship with optional name
   - `Stash` - Campaign inventory/resources
   - `Weapon` - Weapons associated with campaigns

### Key Relationships

- `Campaign` belongs to `User` (owner)
- `Campaign` has one `Ship` and one `Stash`
- `Campaign` has many `CrewMembers`
- Ship and Stash are cascade-deleted when Campaign is destroyed

### Web Layer Structure

- **Router**: `FiveAppsWeb.Router` with multiple pipelines:
  - `:browser` - Standard Phoenix browser pipeline with AshAuthentication
  - `:api` - JSON API with optional API key authentication
  - `:graphql` - GraphQL API with bearer token authentication
  - `:mcp` - Model Context Protocol with required API key authentication

- **LiveViews**:
  - `Home.Index` - Landing page
  - `Campaigns.Index` - Campaign listing
  - `Campaigns.Show` - Individual campaign details

- **Components**:
  - DaisyUI components in `FiveAppsWeb.Components.DaisyUiComponents`
  - Core Phoenix components in `FiveAppsWeb.Components.CoreComponents`
  - Layouts in `FiveAppsWeb.Components.Layouts`

### Helper Modules

Name generation utilities in `lib/five_apps/helpers/`:
- `NameGenerator` - Base name generation logic
- `CrewMemberNameGenerator` - Generate crew member names
- `CrewNameGenerator` - Generate crew names
- `ShipNameGenerator` - Generate ship names

## Development Commands

### Setup and Migration
```bash
mix setup                    # Install deps, run migrations, build assets, seed data
mix ash.setup               # Run setup tasks for all Ash extensions
mix ash.migrate             # Run pending migrations
mix ash.codegen [name]      # Generate migrations for resource changes
mix ash.codegen --dev       # Generate dev migrations for iterative development
mix ash.reset               # Tear down and reset all Ash resources
```

### Development Server
```bash
mix phx.server              # Start Phoenix server
iex -S mix phx.server       # Start server with IEx console
```

### Testing
```bash
mix test                           # Run all tests
mix test path/to/test.exs         # Run specific test file
mix test path/to/test.exs:123     # Run test at specific line
mix test --max-failures n         # Limit failed tests
```

### Code Quality
```bash
mix credo                   # Run Credo static analysis
mix format                  # Format code
```

### Assets
```bash
mix assets.setup            # Install Tailwind and esbuild
mix assets.build            # Build assets for development
mix assets.deploy           # Build and minify assets for production
```

## Development Workflow

### Migration Workflow
When making resource changes, use the iterative dev workflow:
1. Make changes to resources
2. Run `mix ash.codegen --dev` to generate and apply dev migrations
3. Continue iterating with `mix ash.codegen --dev`
4. When feature is complete, run `mix ash.codegen feature_name` to generate final named migration
5. The dev migrations will be rolled back and squashed into the final migration

### LiveView Structure
- Put LiveView rendering in `.html.heex` files (not inline in `.ex` files)
- Keep LiveView components self-contained in `.ex` files
- Use `on_mount {FiveAppsWeb.LiveUserAuth, :live_user_required}` for authenticated routes
- Use `on_mount {FiveAppsWeb.LiveUserAuth, :live_user_optional}` for optional auth
- Use `on_mount {FiveAppsWeb.LiveUserAuth, :live_no_user}` for public-only routes

### Code Interface Pattern
Always use domain code interfaces instead of direct Ash module calls:
```elixir
# GOOD - Use domain code interfaces
FiveApps.Campaigns.get_campaign!(id, load: [:ship, :stash, :crew_members])

# AVOID - Direct Ash calls in web layer
Ash.get!(Campaign, id) |> Ash.load!([:ship, :stash])
```

### Authentication
- Campaigns are owned by users via `relate_actor(:owner)` change on create
- API endpoints support both bearer tokens and API keys
- MCP endpoint requires API key authentication
- Use `authorize?: false` only for administrative operations in tests

## API Endpoints

### JSON API
- Base URL: `/api/json`
- Swagger UI: `/api/json/swaggerui`
- Campaign routes: `/api/json/campaigns`
- User routes: `/api/json/users/register`, `/api/json/users/sign-in`

### GraphQL
- Endpoint: `/gql`
- Playground: `/gql/playground`
- Uses bearer token authentication

### MCP (Model Context Protocol)
- Endpoint: `/mcp`
- Requires API key authentication
- Configure tools in router at line 70

## Development Tools

- **Admin Interface**: `/admin` (dev only)
- **LiveDashboard**: `/dev/dashboard` (dev only)
- **Mailbox Preview**: `/dev/mailbox` (dev only)

## Important Notes

- Follow USAGE_RULES.md for detailed Ash Framework usage patterns
- Use Test-Driven Development approach
- Campaign cascade deletion is handled via `cascade_destroy` changes
- Ship name is optional (`allow_nil?: true`)
- All campaigns track: status, difficulty, turn_number, story_points, victory condition, notes
