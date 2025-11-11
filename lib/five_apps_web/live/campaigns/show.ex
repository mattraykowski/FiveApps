defmodule FiveAppsWeb.Campaigns.Show do
  use FiveAppsWeb, :live_view

  alias FiveApps.Campaigns

  def mount(%{"id" => id}, _session, socket) do
    campaign = Campaigns.get_campaign!(id, load: [:ship, :stash, crew_members: [:weapons]])

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

    crew_member_form =
      AshPhoenix.Form.for_create(FiveApps.Campaigns.CrewMember, :create,
        actor: socket.assigns.current_user
      )
      |> to_form()

    socket =
      socket
      |> assign(:active_tab, "general")
      |> assign(:show_kia, false)
      |> assign(:show_sick_bay, true)
      |> assign(:show_crew_modal, false)
      |> assign(:show_edit_modal, false)
      |> assign(:show_delete_modal, false)
      |> assign(:show_weapon_modal, false)
      |> assign(:crew_member_to_delete, nil)
      |> assign(:crew_member_to_edit, nil)
      |> assign(:crew_member_for_weapon, nil)
      |> assign(:weapon_to_edit, nil)
      |> assign(:campaign, campaign)
      |> assign(:form, to_form(form))
      |> assign(:crew_member_form, crew_member_form)
      |> assign(:edit_crew_member_form, nil)
      |> assign(:weapon_form, nil)

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

  def handle_event("open_crew_modal", _params, socket) do
    crew_member_form =
      AshPhoenix.Form.for_create(FiveApps.Campaigns.CrewMember, :create,
        actor: socket.assigns.current_user
      )
      |> to_form()

    {:noreply, assign(socket, show_crew_modal: true, crew_member_form: crew_member_form)}
  end

  def handle_event("close_crew_modal", _params, socket) do
    {:noreply, assign(socket, show_crew_modal: false)}
  end

  def handle_event("validate_crew_member", %{"form" => form_data}, socket) do
    crew_member_form = AshPhoenix.Form.validate(socket.assigns.crew_member_form, form_data)
    {:noreply, assign(socket, crew_member_form: crew_member_form)}
  end

  def handle_event("save_crew_member", %{"form" => form_data}, socket) do
    form_data_with_campaign = Map.put(form_data, "campaign_id", socket.assigns.campaign.id)

    case AshPhoenix.Form.submit(socket.assigns.crew_member_form, params: form_data_with_campaign) do
      {:ok, _crew_member} ->
        # Reload the campaign with updated crew members
        campaign =
          Campaigns.get_campaign!(socket.assigns.campaign.id,
            load: [:ship, :stash, crew_members: [:weapons]]
          )

        {:noreply,
         socket
         |> assign(:campaign, campaign)
         |> assign(:show_crew_modal, false)
         |> put_flash(:info, "Crew member added successfully")}

      {:error, form} ->
        {:noreply,
         socket
         |> assign(:crew_member_form, form)
         |> put_flash(:error, "Failed to add crew member")}
    end
  end

  def handle_event("open_delete_modal", %{"crew_member_id" => crew_member_id}, socket) do
    crew_member = Enum.find(socket.assigns.campaign.crew_members, &(&1.id == crew_member_id))

    {:noreply, assign(socket, show_delete_modal: true, crew_member_to_delete: crew_member)}
  end

  def handle_event("close_delete_modal", _params, socket) do
    {:noreply, assign(socket, show_delete_modal: false, crew_member_to_delete: nil)}
  end

  def handle_event("confirm_delete_crew_member", _params, socket) do
    crew_member = socket.assigns.crew_member_to_delete

    case Campaigns.delete_crew_member!(crew_member.id, actor: socket.assigns.current_user) do
      :ok ->
        # Reload the campaign with updated crew members
        campaign =
          Campaigns.get_campaign!(socket.assigns.campaign.id,
            load: [:ship, :stash, crew_members: [:weapons]]
          )

        {:noreply,
         socket
         |> assign(:campaign, campaign)
         |> assign(:show_delete_modal, false)
         |> assign(:crew_member_to_delete, nil)
         |> put_flash(:info, "Crew member deleted successfully")}

      _error ->
        {:noreply,
         socket
         |> assign(:show_delete_modal, false)
         |> assign(:crew_member_to_delete, nil)
         |> put_flash(:error, "Failed to delete crew member")}
    end
  end

  def handle_event("open_edit_modal", %{"crew_member_id" => crew_member_id}, socket) do
    crew_member = Enum.find(socket.assigns.campaign.crew_members, &(&1.id == crew_member_id))

    edit_form =
      AshPhoenix.Form.for_update(crew_member, :update, actor: socket.assigns.current_user)
      |> to_form()

    {:noreply,
     assign(socket,
       show_edit_modal: true,
       crew_member_to_edit: crew_member,
       edit_crew_member_form: edit_form
     )}
  end

  def handle_event("close_edit_modal", _params, socket) do
    {:noreply,
     assign(socket, show_edit_modal: false, crew_member_to_edit: nil, edit_crew_member_form: nil)}
  end

  def handle_event("validate_edit_crew_member", %{"form" => form_data}, socket) do
    edit_form = AshPhoenix.Form.validate(socket.assigns.edit_crew_member_form, form_data)
    {:noreply, assign(socket, edit_crew_member_form: edit_form)}
  end

  def handle_event("save_edit_crew_member", %{"form" => form_data}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.edit_crew_member_form, params: form_data) do
      {:ok, _crew_member} ->
        # Reload the campaign with updated crew members
        campaign =
          Campaigns.get_campaign!(socket.assigns.campaign.id,
            load: [:ship, :stash, crew_members: [:weapons]]
          )

        {:noreply,
         socket
         |> assign(:campaign, campaign)
         |> assign(:show_edit_modal, false)
         |> assign(:crew_member_to_edit, nil)
         |> assign(:edit_crew_member_form, nil)
         |> put_flash(:info, "Crew member updated successfully")}

      {:error, form} ->
        {:noreply,
         socket
         |> assign(:edit_crew_member_form, form)
         |> put_flash(:error, "Failed to update crew member")}
    end
  end

  # Weapon Management Event Handlers

  def handle_event("open_weapon_modal", %{"crew_member_id" => crew_member_id}, socket) do
    crew_member = Enum.find(socket.assigns.campaign.crew_members, &(&1.id == crew_member_id))

    weapon_form =
      AshPhoenix.Form.for_create(FiveApps.Campaigns.Weapon, :create,
        actor: socket.assigns.current_user
      )
      |> to_form()

    {:noreply,
     assign(socket,
       show_weapon_modal: true,
       crew_member_for_weapon: crew_member,
       weapon_to_edit: nil,
       weapon_form: weapon_form
     )}
  end

  def handle_event("close_weapon_modal", _params, socket) do
    {:noreply,
     assign(socket,
       show_weapon_modal: false,
       crew_member_for_weapon: nil,
       weapon_to_edit: nil,
       weapon_form: nil
     )}
  end

  def handle_event("validate_weapon", %{"form" => form_data}, socket) do
    weapon_form = AshPhoenix.Form.validate(socket.assigns.weapon_form, form_data)
    {:noreply, assign(socket, weapon_form: weapon_form)}
  end

  def handle_event("save_weapon", %{"form" => form_data}, socket) do
    crew_member = socket.assigns.crew_member_for_weapon
    form_data_with_crew_member = Map.put(form_data, "crew_member_id", crew_member.id)

    case AshPhoenix.Form.submit(socket.assigns.weapon_form, params: form_data_with_crew_member) do
      {:ok, _weapon} ->
        campaign =
          Campaigns.get_campaign!(socket.assigns.campaign.id,
            load: [:ship, :stash, crew_members: [:weapons]]
          )

        {:noreply,
         socket
         |> assign(:campaign, campaign)
         |> assign(:show_weapon_modal, false)
         |> assign(:crew_member_for_weapon, nil)
         |> assign(:weapon_form, nil)
         |> put_flash(:info, "Weapon added successfully")}

      {:error, form} ->
        {:noreply,
         socket
         |> assign(:weapon_form, form)
         |> put_flash(:error, "Failed to add weapon")}
    end
  end

  def handle_event(
        "open_edit_weapon_modal",
        %{"weapon_id" => weapon_id, "crew_member_id" => crew_member_id},
        socket
      ) do
    crew_member = Enum.find(socket.assigns.campaign.crew_members, &(&1.id == crew_member_id))
    weapon = Enum.find(crew_member.weapons, &(&1.id == weapon_id))

    weapon_form =
      AshPhoenix.Form.for_update(weapon, :update, actor: socket.assigns.current_user)
      |> to_form()

    {:noreply,
     assign(socket,
       show_weapon_modal: true,
       crew_member_for_weapon: crew_member,
       weapon_to_edit: weapon,
       weapon_form: weapon_form
     )}
  end

  def handle_event(
        "delete_weapon",
        %{"weapon_id" => weapon_id, "crew_member_id" => _crew_member_id},
        socket
      ) do
    case Campaigns.delete_weapon(weapon_id, actor: socket.assigns.current_user) do
      :ok ->
        campaign =
          Campaigns.get_campaign!(socket.assigns.campaign.id,
            load: [:ship, :stash, crew_members: [:weapons]]
          )

        {:noreply,
         socket
         |> assign(:campaign, campaign)
         |> put_flash(:info, "Weapon deleted successfully")}

      {:error, _error} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to delete weapon")}
    end
  end

  # Leader Management Event Handler
  def handle_event(
        "toggle_leader",
        %{"crew_member_id" => id, "is_leader" => is_leader_str} = params,
        socket
      ) do
    is_leader = is_leader_str == "true"
    crew_member = Enum.find(socket.assigns.campaign.crew_members, &(&1.id == id))

    case Campaigns.set_crew_member_leader(
           crew_member,
           %{is_leader: is_leader},
           actor: socket.assigns.current_user
         ) do
      {:ok, _updated} ->
        # Reload campaign with updated crew
        campaign =
          Campaigns.get_campaign!(socket.assigns.campaign.id,
            load: [:ship, :stash, crew_members: [:weapons]]
          )

        {:noreply,
         socket
         |> assign(:campaign, campaign)
         |> put_flash(:info, "Leader updated")}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to update leader")}
    end
  end
end
