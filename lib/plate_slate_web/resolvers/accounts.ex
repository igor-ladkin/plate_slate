defmodule PlateSlateWeb.Resolvers.Accounts do
  alias PlateSlate.Accounts

  def login_employee(_, %{email: email, password: password}, _) do
    case Accounts.authenticate("employee", email, password) do
      {:ok, user} ->
        token = PlateSlateWeb.Authentication.sign(%{type: "employee", id: user.id})
        {:ok, %{token: token, employee: user}}
      _ ->
      {:error, "incorrect email or password"}
    end
  end
end
