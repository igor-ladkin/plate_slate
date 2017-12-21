defmodule PlateSlateWeb.Schema.AccountsTypes do
  use Absinthe.Schema.Notation

  object :employee_session do
    field :token, :string
    field :employee, :employee
  end

  object :employee do
    field :name, :string
    field :email, :string
  end
end
