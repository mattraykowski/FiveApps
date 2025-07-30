defmodule FiveAppsWeb.Layouts do
  @moduledoc """
  This module holds different layouts used by your application.

  See the `layouts` directory for all templates available.
  The "root" layout is a skeleton rendered as part of the
  application router. The "app" layout is rendered as component
  in regular views and live views.
  """
  use FiveAppsWeb, :html

  embed_templates "layouts/*"

  @doc """
  Renders the app layout

  ## Examples

      <Layouts.app flash={@flash}>
        <h1>Content</h1>
      </Layout.app>

  """
  attr :flash, :map, required: true, doc: "the map of flash messages"

  attr :current_scope, :map,
    default: nil,
    doc: "the current [scope](https://hexdocs.pm/phoenix/scopes.html)"

  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <.navbar class="px-4 sm:px-6 lg:px-8">
      <:navbar_start>
        <a href="/" class="flex-1 flex w-fit items-center gap-2">
          <img src={~p"/images/logo.svg"} width="36" />
          <span class="text-sm font-semibold">Five Apps Companion</span>
        </a>
      </:navbar_start>
      <:navbar_center>
        <span class="text-sm font-semibold">Phoenix Framework</span>
      </:navbar_center>
      <:navbar_end>
        <ul class="flex flex-column px-1 space-x-4 items-center">
          <li>
            <a href="https://phoenixframework.org/" class="btn btn-ghost">Website</a>
          </li>
          <li>
            <a href="https://github.com/phoenixframework/phoenix" class="btn btn-ghost">GitHub</a>
          </li>
          <li>
            <.theme_toggle />
          </li>
          <li></li>
        </ul>
        <.dropdown align="end">
          <div tabindex="0" class="m-1">
            <.avatar placeholder>
              <div class="bg-neutral text-neutral-content w-8 rounded-full">
                {friendly_user_letter(@current_user)}
              </div>
            </.avatar>
          </div>
          <ul class="menu dropdown-content bg-base-100 rounded-box z-[1] p-2 shadow">
            <%= if @current_user != nil do %>
              <li class="menu-title"><span class="text-sm font-bold">{@current_user.email}</span></li>
              <li><a href={~p"/admin"}>Admin</a></li>
              <li><a href={~p"/dev/mailbox"}>Mailbox</a></li>
              <li><a href={~p"/sign-out"}>Sign Out</a></li>
            <% else %>
              <li><a href={~p"/sign-in"}>Sign In</a></li>
              <li><a href={~p"/register"}>Sign Up</a></li>
            <% end %>
          </ul>
        </.dropdown>
      </:navbar_end>
    </.navbar>

    <main class="px-4 py-20 sm:px-6 lg:px-8">
      <div class="mx-auto max-w-2xl space-y-4">
        {render_slot(@inner_block)}
      </div>
    </main>

    <.flash_group flash={@flash} />
    """
  end

  @doc """
  Provides dark vs light theme toggle based on themes defined in app.css.

  See <head> in root.html.heex which applies the theme before page load.
  """
  def theme_toggle(assigns) do
    ~H"""
    <div class="card relative flex flex-row items-center border-2 border-base-300 bg-base-300 rounded-full">
      <div class="absolute w-1/3 h-full rounded-full border-1 border-base-200 bg-base-100 brightness-200 left-0 [[data-theme=light]_&]:left-1/3 [[data-theme=dark]_&]:left-2/3 transition-[left]" />

      <button
        phx-click={JS.dispatch("phx:set-theme", detail: %{theme: "system"})}
        class="flex p-2 cursor-pointer w-1/3"
      >
        <.icon name="hero-computer-desktop-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        phx-click={JS.dispatch("phx:set-theme", detail: %{theme: "light"})}
        class="flex p-2 cursor-pointer w-1/3"
      >
        <.icon name="hero-sun-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        phx-click={JS.dispatch("phx:set-theme", detail: %{theme: "dark"})}
        class="flex p-2 cursor-pointer w-1/3"
      >
        <.icon name="hero-moon-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>
    </div>
    """
  end

  def friendly_user_letter(nil), do: "?"

  def friendly_user_letter(user) do
    user.email
    |> Ash.CiString.value()
    |> String.capitalize()
    |> String.first()
  end
end
