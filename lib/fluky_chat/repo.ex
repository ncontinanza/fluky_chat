defmodule FlukyChat.Repo do
  use Ecto.Repo,
    otp_app: :fluky_chat,
    adapter: Ecto.Adapters.Postgres
end
