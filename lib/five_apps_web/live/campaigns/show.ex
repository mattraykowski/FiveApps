defmodule FiveAppsWeb.Campaigns.Show do
  use FiveAppsWeb, :live_view

  alias FiveApps.Campaigns

  def mount(%{"id" => id}, _session, socket) do
    campaign = Campaigns.get_campaign!(id, load: [:ship, :stash])

    form =
      Campaigns.form_to_update_campaign(campaign,
        actor: socket.assigns.current_user,
        forms: [
          ship: [
            type: :single,
            resource: FiveApps.Campaigns.Ship,
            create_action: :create,
            update_action: :update,
            data: campaign.ship
          ],
          stash: [
            resource: FiveApps.Campaigns.Stash,
            create_action: :create,
            update_action: :update,
            data: campaign.stash
          ]
        ]
      )
      |> AshPhoenix.Form.ensure_can_submit!()

    socket =
      socket
      |> assign(:active_tab, "general")
      |> assign(:show_kia, false)
      |> assign(:show_sick_bay, true)
      |> assign(:campaign, campaign)
      |> assign(:form, to_form(form))

    {:ok, socket}
  end

  def handle_event("validate", %{"form" => form_data}, socket) do
    socket =
      update(socket, :form, fn form ->
        AshPhoenix.Form.validate(form, form_data)
      end)

    {:noreply, socket}
  end

  def handle_event("save", %{"form" => form_data}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: form_data) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Campaign updated successfully")}

      {:error, form} ->
        {:noreply,
         socket |> assign(:form, form) |> put_flash(:error, "Failed to update campaign")}
    end
  end

  def handle_event("toggle_tab", %{"tab" => tab}, socket) do
    socket = socket |> assign(:active_tab, tab)
    {:noreply, socket}
  end

  def handle_event("toggle_crew_filter", %{"crew" => toggle_filter}, socket) do
    show_kia = socket.assigns.show_kia
    show_sick_bay = socket.assigns.show_sick_bay

    {show_kia, show_sick_bay} =
      case toggle_filter do
        "kia" -> {not show_kia, show_sick_bay}
        "sick_bay" -> {show_kia, not show_sick_bay}
        _ -> {show_kia, show_sick_bay}
      end

    {:noreply, assign(socket, show_kia: show_kia, show_sick_bay: show_sick_bay)}
  end

  def handle_event("generate_ship_name", _params, socket) do
    new_name = FiveApps.Helpers.NameGenerator.generate_ship_name()

    form =
      AshPhoenix.Form.update_form(socket.assigns.form, [:ship], fn ship_form ->
        params = Map.merge(ship_form.params || %{}, %{"name" => new_name})
        AshPhoenix.Form.validate(ship_form, params)
      end)

    {:noreply, assign(socket, :form, form)}
  end
end
