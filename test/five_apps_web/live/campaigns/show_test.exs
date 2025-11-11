defmodule FiveAppsWeb.Campaigns.ShowTest do
  use FiveAppsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import FiveApps.Generator
  alias FiveApps.Campaigns

  describe "crew member leader toggle" do
    setup %{conn: conn} do
      # Create user and log them in
      user = generate(user())

      conn =
        conn
        |> log_in_user(user)

      # Create campaign with crew members
      {:ok, campaign} =
        Campaigns.create_campaign(%{name: "Test Campaign"}, actor: user)

      {:ok, crew_a} =
        Campaigns.create_crew_member(
          %{
            name: "Alice",
            species: "Human",
            campaign_id: campaign.id
          },
          actor: user
        )

      {:ok, crew_b} =
        Campaigns.create_crew_member(
          %{
            name: "Bob",
            species: "Alien",
            campaign_id: campaign.id
          },
          actor: user
        )

      %{conn: conn, user: user, campaign: campaign, crew_a: crew_a, crew_b: crew_b}
    end

    # T018: Test toggle click sets leader
    test "toggle sets crew member as leader", %{
      conn: conn,
      campaign: campaign,
      crew_a: crew
    } do
      {:ok, view, _html} = live(conn, ~p"/campaigns/#{campaign.id}")

      # Navigate to crew tab
      view
      |> element("a", "Crew Members")
      |> render_click()

      # Click toggle on crew member
      view
      |> element("[phx-click='toggle_leader'][phx-value-crew_member_id='#{crew.id}']")
      |> render_click(%{"crew_member_id" => crew.id, "is_leader" => "true"})

      # Should see success message
      assert render(view) =~ "Leader updated"

      # Verify crew member is leader
      updated = Campaigns.get_crew_member!(crew.id)
      assert updated.is_leader == true
    end

    # T019: Test toggle shows success flash
    test "toggle shows success flash message", %{
      conn: conn,
      campaign: campaign,
      crew_a: crew
    } do
      {:ok, view, _html} = live(conn, ~p"/campaigns/#{campaign.id}")

      # Navigate to crew tab
      view
      |> element("a", "Crew Members")
      |> render_click()

      # Click toggle
      view
      |> element("[phx-click='toggle_leader'][phx-value-crew_member_id='#{crew.id}']")
      |> render_click(%{"crew_member_id" => crew.id, "is_leader" => "true"})

      # Verify flash message appears
      assert view
             |> element("#flash-info")
             |> render() =~ "Leader updated"
    end
  end

  # Helper function to log in user
  defp log_in_user(conn, user) do
    # Use AshAuthentication to generate a valid token
    {:ok, %{__metadata__: %{token: token}}} =
      FiveApps.Accounts.User
      |> Ash.Query.for_read(:sign_in_with_password, %{
        email: user.email,
        password: "password"
      })
      |> Ash.read_one()

    conn
    |> Phoenix.ConnTest.init_test_session(%{})
    |> Plug.Conn.put_session(:user_token, token)
  end
end
