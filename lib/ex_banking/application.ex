defmodule ExBanking.Application do
  use Application

  def start(_type, _args) do
    children = [
      ExBanking.UserServer
    ]

    opts = [strategy: :one_for_one, name: ExBanking.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
