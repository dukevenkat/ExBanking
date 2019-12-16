defmodule ExBanking.BankServer do
  use GenServer, restart: :transient
  @bank_server __MODULE__

  @rate_limit 10

  def start_link(user_account) do
    GenServer.start_link(@bank_server, [], name: user_account)
  end

  def deposite(user, amount, currency) do
    case overlimit_reached(user) do
      :user_does_not_exist ->
        {:error, :user_does_not_exist}

      queue_limit when queue_limit > @rate_limit ->
        {:error, :too_many_requests_to_user}

      _queue_limit ->
        GenServer.call(String.to_atom(user), {:deposit, String.to_atom(currency), amount})
    end
  end

  def withdraw(user, amount, currency) do
    case overlimit_reached(user) do
      :user_does_not_exist ->
        {:error, :user_does_not_exist}

      queue_limit when queue_limit > @rate_limit ->
        {:error, :too_many_requests_to_user}

      _queue_limit ->
        GenServer.call(String.to_atom(user), {:withdraw, String.to_atom(currency), amount})
    end
  end

  def get_balance(user, currency) do
    case overlimit_reached(user) do
      :user_does_not_exist ->
        {:error, :user_does_not_exist}

      queue_limit when queue_limit > @rate_limit ->
        {:error, :too_many_requests_to_user}

      _queue_limit ->
        GenServer.call(String.to_atom(user), {:get_balance, String.to_atom(currency)})
    end
  end

  def send(from_user, to_user, amount, currency) do
    case overlimit_reached(from_user) do
      :user_does_not_exist ->
        {:error, :sender_does_not_exist}

      queue_limit when queue_limit > @rate_limit ->
        {:error, :too_many_requests_to_sender}

      _queue_limit ->
        case overlimit_reached(to_user) do
          :user_does_not_exist ->
            {:error, :receiver_does_not_exist}

          queue_limit when queue_limit > @rate_limit ->
            {:error, :too_many_requests_to_receiver}

          _queue_limit ->
            transfer(from_user, to_user, amount, currency)
        end
    end
  end

  def overlimit_reached(user) do
    try do
      {:status, pid, _, _} = :sys.get_status(String.to_atom(user))
      {:message_queue_len, messages} = :erlang.process_info(pid, :message_queue_len)
      messages
    catch
      :exit, _ -> :user_does_not_exist
    end
  end

  def get_pid(user) when is_binary(user) do
    {:status, pid, _, _} = :sys.get_status(String.to_atom(user))
    [{pid}]
  end

  def get_pid(_), do: {:error, :wrong_arguments}

  defp transfer(from_user, to_user, amount, currency) do
    case GenServer.call(String.to_atom(from_user), {:withdraw, String.to_atom(currency), amount}) do
      :not_enough_money ->
        {:error, :not_enough_money}

      {:error, :not_enough_money} ->
        {:error, :not_enough_money}

      {:ok, from_user_balance} ->
        {:ok, to_user_balance} =
          GenServer.call(String.to_atom(to_user), {:deposit, String.to_atom(currency), amount})

        {:ok, from_user_balance, to_user_balance}
    end
  end

  def init(_args) do
    {:ok, %{}}
  end

  def handle_call({:create_user, _user_info}, _from, user_state) do
    {:reply, user_state, user_state}
  end

  def handle_call({:deposit, currency, amount}, _from, user_state) do
    updated_state = ExBanking.Implementation.deposit(user_state, currency, amount)
    {:reply, {:ok, Float.floor(updated_state[currency] / 1, 2)}, updated_state}
  end

  def handle_call({:withdraw, currency, amount}, _from, user_state) do
    updated_state = ExBanking.Implementation.withdraw(user_state, currency, amount)

    case updated_state do
      {:not_enough_money, _} ->
        {:reply, {:error, :not_enough_money}, user_state}

      {:ok, current_transaction} ->
        {:reply, {:ok, Float.floor(current_transaction[currency] / 1, 2)}, current_transaction}
    end
  end

  def handle_call({:get_balance, currency}, _from, user_state) do
    updated_state = ExBanking.Implementation.get_balance(user_state, currency)

    case updated_state do
      {:wrong_arguments, _} ->
        {:reply, :wrong_arguments, user_state}

      {:ok, balance} ->
        {:reply, {:ok, balance}, user_state}
    end
  end

  def handle_call(_msg, _from, state) do
    {:reply, :ok, state}
  end

  def handle_cast(_msg, state) do
    {:noreply, state}
  end
end
