defmodule PlateSlateWeb.Schema.Mutation.LoginEmployeeTest do
  use PlateSlateWeb.ConnCase, async: true

  alias PlateSlate.{Accounts, Repo}

  setup do
    user =
      %Accounts.User{}
      |> Accounts.User.changeset(%{
        role: "employee",
        name: "Bob",
        email: "bob@foo.com",
        password: "password"
      })
      |> Repo.insert!()

    {:ok, user: user}
  end

  @query """
  mutation {
    loginEmployee(email: "bob@foo.com", password: "password") {
      token,
      employee { name }
    }
  }
  """
  test "creating an employee session", %{user: user} do
    response = post(build_conn(), "/api", query: @query)

    assert %{"data" => %{"loginEmployee" => %{"token" => token}}} = json_response(response, 200)
    assert {:ok, %{type: "employee", id: user.id}} == PlateSlateWeb.Authentication.verify(token)
  end

end
