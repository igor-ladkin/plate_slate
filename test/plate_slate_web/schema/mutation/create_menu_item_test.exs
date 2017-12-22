defmodule PlateSlateWeb.Schema.Mutation.CreateMenuItemTest do
  use PlateSlateWeb.ConnCase, async: true
  alias PlateSlate.{Repo, Menu}

  import Ecto.Query
  import PlateSlateWeb.ConnCase, only: [auth_user: 2]

  setup do
    Code.load_file("priv/repo/seeds.exs")

    category_id =
      from(t in Menu.Category, where: t.name == "Sandwiches")
      |> Repo.one!
      |> Map.fetch!(:id)
      |> to_string()

    {:ok, category_id: category_id}
  end

  @query """
  mutation ($menuItem: MenuItemInput!) {
    createMenuItem(input: $menuItem) {
      errors { key message }
      menuItem{
        name
        description
        price
      }
    }
  }
  """
  test "createMenuItem field creates a menuItem", %{category_id: category_id} do
    menu_item = %{
      "name" => "French Dip",
      "description" => "Roast beef, caramelized onions, horseradish, ...",
      "price" => "5.75",
      "categoryId" => category_id
    }
    user = Factory.create_user("employee")
    conn = build_conn() |> auth_user(user)

    response = post conn, "/api", query: @query, variables: %{"menuItem" => menu_item}
    assert json_response(response, 200) == %{
      "data" => %{
        "createMenuItem" => %{
          "errors" => nil,
          "menuItem" => %{
            "name" => menu_item["name"],
            "description" => menu_item["description"],
            "price" => menu_item["price"]
          }
        }
      }
    }
  end

  test "creating a menu item with an existing name fails", %{category_id: category_id} do
    menu_item = %{
      "name" => "Rueben",
      "description" => "Roast beef, caramelized onions, horseradish, ...",
      "price" => "5.75",
      "categoryId" => category_id
    }
    user = Factory.create_user("employee")
    conn = build_conn() |> auth_user(user)

    response = post conn, "/api", query: @query, variables: %{"menuItem" => menu_item}
    assert json_response(response, 200) == %{
      "data" => %{
        "createMenuItem" => %{
          "menuItem" => nil,
          "errors" => [
            %{
              "message" => "has already been taken",
              "key" => "name",
            }
          ]
        }
      }
    }
  end

  test "must be authorized as an employee to do menu item creataion", %{category_id: category_id} do
    menu_item = %{
      "name" => "Rueben",
      "description" => "Roast beef, caramelized onions, horseradish, ...",
      "price" => "5.75",
      "categoryId" => category_id
    }
    user = Factory.create_user("customer")
    conn = build_conn() |> auth_user(user)

    response = post conn, "/api", query: @query, variables: %{"menuItem" => menu_item}
    assert json_response(response, 200) == %{
      "data" => %{"createMenuItem" => nil},
      "errors" => [%{
        "locations" => [%{"column" => 0, "line" => 2}],
        "message" => "unauthorized",
        "path" => ["createMenuItem"],
      }]
    }
  end
end
