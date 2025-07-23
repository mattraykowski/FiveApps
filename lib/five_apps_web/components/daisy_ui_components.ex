defmodule FiveAppsWeb.DaisyUIComponents do
  @doc false
  def live_component do
    quote do
      use Phoenix.LiveComponent

      unquote(helpers())
    end
  end

  @doc false
  def component do
    quote do
      use Phoenix.Component

      unquote(helpers())
    end
  end

  defp helpers() do
    quote do
      import FiveAppsWeb.DaisyUIComponents.Utils
      import FiveAppsWeb.DaisyUIComponents.JSHelpers

      alias Phoenix.LiveView.JS
    end
  end

  @doc """
  Used for functional or live components
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end

  defmacro __using__(_) do
    quote do
      import FiveAppsWeb.DaisyUIComponents.Alert
      import FiveAppsWeb.DaisyUIComponents.Avatar
      import FiveAppsWeb.DaisyUIComponents.Back
      import FiveAppsWeb.DaisyUIComponents.Badge
      import FiveAppsWeb.DaisyUIComponents.Breadcrumbs
      import FiveAppsWeb.DaisyUIComponents.Button
      import FiveAppsWeb.DaisyUIComponents.Card
      import FiveAppsWeb.DaisyUIComponents.Checkbox
      import FiveAppsWeb.DaisyUIComponents.Drawer
      import FiveAppsWeb.DaisyUIComponents.Dropdown
      import FiveAppsWeb.DaisyUIComponents.Fieldset
      import FiveAppsWeb.DaisyUIComponents.Footer
      import FiveAppsWeb.DaisyUIComponents.Form
      import FiveAppsWeb.DaisyUIComponents.Header
      import FiveAppsWeb.DaisyUIComponents.Hero
      import FiveAppsWeb.DaisyUIComponents.Icon
      import FiveAppsWeb.DaisyUIComponents.Indicator
      import FiveAppsWeb.DaisyUIComponents.Input
      import FiveAppsWeb.DaisyUIComponents.JSHelpers
      import FiveAppsWeb.DaisyUIComponents.Join
      import FiveAppsWeb.DaisyUIComponents.Label
      import FiveAppsWeb.DaisyUIComponents.List
      import FiveAppsWeb.DaisyUIComponents.Loading
      import FiveAppsWeb.DaisyUIComponents.Menu
      import FiveAppsWeb.DaisyUIComponents.Modal
      import FiveAppsWeb.DaisyUIComponents.Navbar
      import FiveAppsWeb.DaisyUIComponents.Pagination
      import FiveAppsWeb.DaisyUIComponents.Progress
      import FiveAppsWeb.DaisyUIComponents.Radio
      import FiveAppsWeb.DaisyUIComponents.Range
      import FiveAppsWeb.DaisyUIComponents.Select
      import FiveAppsWeb.DaisyUIComponents.Stat
      import FiveAppsWeb.DaisyUIComponents.Swap
      import FiveAppsWeb.DaisyUIComponents.Table
      import FiveAppsWeb.DaisyUIComponents.Tabs
      import FiveAppsWeb.DaisyUIComponents.TextInput
      import FiveAppsWeb.DaisyUIComponents.Textarea
      import FiveAppsWeb.DaisyUIComponents.Toggle
      import FiveAppsWeb.DaisyUIComponents.Tooltip
    end
  end
end
