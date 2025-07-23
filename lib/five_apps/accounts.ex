defmodule FiveApps.Accounts do
  use Ash.Domain, otp_app: :five_apps, extensions: [AshJsonApi.Domain, AshAdmin.Domain]

  admin do
    show? true
  end

  json_api do
    routes do
      base_route "/users", FiveApps.Accounts.User do
        post :register_with_password, route: "/register"

        post :sign_in_with_password do
          route "/sign-in"

          metadata fn _subject, user, _request ->
            %{token: user.__metadata__.token}
          end
        end
      end
    end
  end

  resources do
    resource FiveApps.Accounts.Token
    resource FiveApps.Accounts.User
    resource FiveApps.Accounts.ApiKey
  end
end
