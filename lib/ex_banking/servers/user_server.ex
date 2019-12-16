defmodule ExBanking.UserServer do
  use DynamicSupervisor

  @user_server __MODULE__

  def start_link(init_arg) do
    DynamicSupervisor.start_link(@user_server, init_arg, name: @user_server)
  end

  def init(_args) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def create_user(user) do
    DynamicSupervisor.start_child(@user_server, {ExBanking.BankServer, String.to_atom(user)})
    |> case do
      {:ok, _pid} -> :ok
      {:error, {:already_started, _pid}} -> {:error, :user_already_exists}
      {:error, error} -> {:error, error}
    end
  end
end
