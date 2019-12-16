defmodule ExBanking do
  @moduledoc """
  ExBanking - Simple banking application  
    - Create User
    - Credit amount to the user account
    - Debit amount from user account
    - Transfer money from one account to another
    - Retreive user account balance
  """

  @doc """
  Create new user with minimum balance of 0.
  """
  def create_user(user) when is_binary(user) do
    ExBanking.UserServer.create_user(user)
  end

  def create_user(_user), do: {:error, :wrong_arguments}
  def create_user(), do: {:error, :wrong_arguments}

  @doc """
  Credit money to the user account.
  """
  def deposit(user, amount, currency)
      when is_binary(user) and (is_float(amount) or is_integer(amount)) and is_binary(currency) and
             amount > 0 do
    ExBanking.BankServer.deposite(user, amount, currency)
  end

  def deposit(_user, _amount, _currency), do: {:error, :wrong_arguments}
  def deposit(_user, _amount), do: {:error, :wrong_arguments}
  def deposit(_user), do: {:error, :wrong_arguments}
  def deposit(), do: {:error, :wrong_arguments}

  @doc """
  Debit money from the user account.
  """
  def withdraw(user, amount, currency)
      when is_binary(user) and (is_float(amount) or is_integer(amount)) and is_binary(currency) and
             amount > 0 do
    ExBanking.BankServer.withdraw(user, amount, currency)
  end

  def withdraw(_user, _amount, _currency), do: {:error, :wrong_arguments}
  def withdraw(_user, _amount), do: {:error, :wrong_arguments}
  def withdraw(_user), do: {:error, :wrong_arguments}
  def withdraw(), do: {:error, :wrong_arguments}

  @doc """
  Get the current balance of the user account.
  """
  def get_balance(user, currency) when is_binary(user) and is_binary(currency) do
    ExBanking.BankServer.get_balance(user, currency)
  end

  def get_balance(_user, _currency), do: {:error, :wrong_arguments}
  def get_balance(_user), do: {:error, :wrong_arguments}
  def get_balance(), do: {:error, :wrong_arguments}

  @doc """
  Transfer money from user account to another user.
  """
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
