defmodule FiveAppsWeb.Campaigns.Index do
  use FiveAppsWeb, :live_view

  on_mount {FiveAppsWeb.LiveUserAuth, :live_user_required}

  alias FiveApps.Campaigns

  def mount(_params, _session, socket) do
    campaigns = Campaigns.list_campaigns!()

    form =
      Campaigns.form_to_create_campaign(actor: socket.assigns.current_user)
      |> AshPhoenix.Form.ensure_can_submit!()

    socket =
      socket
      |> assign(campaigns: campaigns)
      |> assign(form: to_form(form))

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
      {:ok, campaign} ->
        {:noreply,
         socket
         |> put_flash(:info, "Campaign created successfully")
         |> push_navigate(to: ~p"/campaigns/#{campaign.id}")}

      {:error, form} ->
        IO.inspect(form, label: "Form submission error")

        {:noreply,
         socket |> assign(:form, form) |> put_flash(:error, "Failed to create campaign")}
    end
  end

  def handle_event("delete", %{"id" => id}, socket) do
    campaign = Campaigns.get_campaign!(id)
    Campaigns.delete_campaign!(campaign, actor: socket.assigns.current_user)

    {:noreply,
     socket
     |> put_flash(:info, "Campaign deleted successfully")
     |> assign(campaigns: Campaigns.list_campaigns!())}
  end
end
