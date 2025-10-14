# Project: Five Apps

## Project Overview

Five Apps is a companion application for the tabletop games "Five Parsecs From Home" and "Five Leagues From the Borderlands". It is built with the Elixir language, the Phoenix framework, and the Ash framework. It uses Tailwind CSS and DaisyUI for styling.

## Building and Running

To get the application running, you'll need to have Elixir and Erlang installed. Then, follow these steps:

1.  **Install dependencies:**
    ```bash
    mix setup
    ```
2.  **Start the Phoenix server:**
    ```bash
    mix phx.server
    ```

The application will be available at `http://localhost:4000`.

### Testing

To run the test suite, use the following command:

```bash
mix test
```

## Development Conventions

### Coding Style

*   Follow Phoenix Formatter best practices.
*   For LiveView Views, prefer to put the rendered view into a `.html.heex` file.
*   For LiveView Components, prefer to keep the whole definition including view in the `.ex` file.

### Ash Framework

The project makes heavy use of the Ash framework. The `USAGE_RULES.md` file contains detailed information on how to use the various Ash packages. Here are some key takeaways:

*   **`ash`**: The core Ash framework. Use it for creating resources, actions, and policies.
*   **`ash_postgres`**: The PostgreSQL data layer for Ash. Use it for configuring tables, indexes, and migrations.
*   **`ash_authentication`**: The authentication extension for Ash. Use it for managing users, passwords, and OAuth2.
*   **`ash_admin`**: The admin UI for Ash. Use it for creating a simple admin interface for your resources.
*   **`ash_graphql`**: The GraphQL extension for Ash. Use it for building GraphQL APIs with Ash.
*   **`ash_json_api`**: The JSON:API extension for Ash. Use it for building JSON:API compliant APIs with Ash.
*   **`ash_phoenix`**: Utilities for integrating Ash and Phoenix. Use it for creating forms and LiveViews.
*   **`ash_ai`**: Integrated LLM features for your Ash application. Use it for vectorization, AI tools, and prompt-backed actions.

### Igniter

The project uses `igniter` for code generation and project patching. See the `USAGE_RULES.md` file for more information on how to use it.
