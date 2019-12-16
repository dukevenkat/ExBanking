defmodule ExBanking do
  @moduledoc """
  ExBanking - Simple banking application  
    - User Account.
    - Deposit : Credit amount of type currency to user account.
    - Withdraw: Debit amount of type from user account.
    - Transfer: transfer amount of type between accounts.
    - Retrieve: Amount of type of the user.
  """
  @type banking_error ::
          {:error,
           :wrong_arguments
           | :user_already_exists
           | :user_does_not_exist
           | :not_enough_money
           | :sender_does_not_exist
           | :receiver_does_not_exist
           | :too_many_requests_to_user
           | :too_many_requests_to_sender
           | :too_many_requests_to_receiver}

  @spec create_user(user :: String.t()) :: :ok | banking_error
  def create_user(user) when is_binary(user) do
    ExBanking.UserServer.create_user(user)
  end

  def create_user(_user), do: {:error, :wrong_arguments}
  def create_user(), do: {:error, :wrong_arguments}

  @spec deposit(user :: String.t(), amount :: number, currency :: String.t()) ::
          {:ok, new_balance :: number} | banking_error
  def deposit(user, amount, currency)
      when is_binary(user) and (is_float(amount) or is_integer(amount)) and is_binary(currency) and
             amount > 0 do
    ExBanking.BankServer.deposite(user, amount, currency)
  end

  def deposit(_user, _amount, _currency), do: {:error, :wrong_arguments}
  def deposit(_user, _amount), do: {:error, :wrong_arguments}
  def deposit(_user), do: {:error, :wrong_arguments}
  def deposit(), do: {:error, :wrong_arguments}

  @spec withdraw(user :: String.t(), amount :: number, currency :: String.t()) ::
          {:ok, new_balance :: number} | banking_error
  def withdraw(user, amount, currency)
      when is_binary(user) and (is_float(amount) or is_integer(amount)) and is_binary(currency) and
             amount > 0 do
    ExBanking.BankServer.withdraw(user, amount, currency)
  end

  def withdraw(_user, _amount, _currency), do: {:error, :wrong_arguments}
  def withdraw(_user, _amount), do: {:error, :wrong_arguments}
  def withdraw(_user), do: {:error, :wrong_arguments}
  def withdraw(), do: {:error, :wrong_arguments}

  @spec get_balance(user :: String.t(), currency :: String.t()) ::
          {:ok, balance :: number} | banking_error
  def get_balance(user, currency) when is_binary(user) and is_binary(currency) do
    ExBanking.BankServer.get_balance(user, currency)
  end

  def get_balance(_user, _currency), do: {:error, :wrong_arguments}
  def get_balance(_user), do: {:error, :wrong_arguments}
  def get_balance(), do: {:error, :wrong_arguments}

  @spec send(
          from_user :: String.t(),
          to_user :: String.t(),
          amount :: number,
          currency :: String.t()
        ) :: {:ok, from_user_balance :: number, to_user_balance :: number} | banking_error
  def send(from_user, to_user, amount, currency)
      when is_binary(from_user) and is_binary(to_user) and
             (is_float(amount) or is_integer(amount)) and
             is_binary(currency) and amount > 0 and from_user != to_user do
    ExBanking.BankServer.send(from_user, to_user, amount, currency)
  end

  def send(_from_user, _to_user, _amount, _currency), do: {:error, :wrong_arguments}
  def send(_from_user, _to_user, _amount), do: {:error, :wrong_arguments}
  def send(_from_user, _to_user), do: {:error, :wrong_arguments}
  def send(_from_user), do: {:error, :wrong_arguments}
  def send(), do: {:error, :wrong_arguments}
end
