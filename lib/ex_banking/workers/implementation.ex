defmodule ExBanking.Implementation do
  def deposit(user_transaction, currency, amount) do
    user_transaction =
      case user_transaction[currency] do
        nil -> Map.put(user_transaction, currency, amount)
        balance -> %{user_transaction | currency => balance + amount}
      end

    user_transaction
  end

  def withdraw(user_transaction, currency, amount) do
    user_transaction =
      case user_transaction[currency] do
        nil ->
          {:not_enough_money, user_transaction}

        balance when balance < amount ->
          {:not_enough_money, user_transaction}

        balance ->
          update_transaction = %{user_transaction | currency => balance - amount}
          {:ok, update_transaction}
      end

    user_transaction
  end

  def get_balance(user_transaction, currency) do
    user_transaction =
      case user_transaction[currency] do
        nil -> {:ok, 0}
        balance -> {:ok, Float.floor(balance / 1, 2)}
      end

    user_transaction
  end
end
