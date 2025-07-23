defmodule FiveApps.Secrets do
  use AshAuthentication.Secret

  def secret_for(
        [:authentication, :tokens, :signing_secret],
        FiveApps.Accounts.User,
        _opts,
        _context
      ) do
    Application.fetch_env(:five_apps, :token_signing_secret)
  end
end
