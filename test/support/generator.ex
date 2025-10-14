defmodule FiveApps.Generator do
  use Ash.Generator

  def user(opts \\ []) do
    changeset_generator(
      FiveApps.Accounts.User,
      :register_with_password,
      defaults: [
        email: sequence(:user_email, &"user#{&1}@example.com"),
        password: "password",
        password_confirmation: "password"
      ],
      overrides: opts
      # Keeping this for when we bring roles into play.
      # after_action: fn user ->
      #   role = opts[:role] || :user
      #   FiveApps.Accounts.set_user_role!(user, role, authorize?: false)
      # end
    )
  end

  def campaign(opts \\ []) do
    actor =
      opts[:actor] ||
        once(:default_actor, fn ->
          generate(user())
        end)

    changeset_generator(
      FiveApps.Campaigns.Campaign,
      :create,
      defaults: [
        name: sequence(:campaign_name, &"Campaign #{&1}"),
        description: "A test campaign"
      ],
      overrides: opts,
      actor: actor
    )
  end
end
