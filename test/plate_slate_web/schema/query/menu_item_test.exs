defmodule PlateSlateWeb.Schema.Query.MenuItemsTest do
  use PlateSlateWeb.ConnCase, async: true

  setup do
    Code.load_file("priv/repo/seeds.exs")
  end

  @query """
  {
    menuItems(filter: {}) {
      name
    }
  }
  """
  test "menuItems field returns menu items" do
    response = get build_conn(), "/api", query: @query
    assert json_response(response, 200) == %{
      "data" => %{
        "menuItems" => [
          %{"name" => "Bánh mì"},
          %{"name" => "Chocolate Milkshake"},
          %{"name" => "Croque Monsieur"},
          %{"name" => "French Fries"},
          %{"name" => "Lemonade"},
          %{"name" => "Masala Chai"},
          %{"name" => "Muffuletta"},
          %{"name" => "Papadum"},
          %{"name" => "Pasta Salad"},
          %{"name" => "Rueben"},
          %{"name" => "Soft Drink"},
          %{"name" => "Vada Pav"},
          %{"name" => "Vanilla Milkshake"},
          %{"name" => "Water"}
        ]
      }
    }
  end

  @query """
  query ($order: SortOrder!) {
    menuItems(order: $order, filter: {}) {
      name
    }
  }
  """
  @variables %{"order" => "DESC"}
  test "menuItems field returns manuItems descending when asked using literals" do
    response = get build_conn(), "/api", query: @query, variables: @variables
    assert %{
      "data" => %{"menuItems" => [%{"name" => "Water"} | _]}
    } = json_response(response, 200)
  end


  @query """
  {
    menuItems(filter: {category: "Sandwiches", tag: "Vegetarian"}) {
      name
    }
  }
  """
  test "menuItems field return menuItems, filtering with a literal" do
    response = get build_conn(), "/api", query: @query
    assert %{
      "data" => %{"menuItems" => [%{"name" => "Vada Pav"}]}
    } == json_response(response, 200)
  end

  @query """
  query ($filter: MenuItemFilter!) {
    menuItems(filter: $filter) {
      name
    }
  }
  """
  @variables %{filter: %{"tag" => "Vegetarian", "category" => "Sandwiches"}}
  test "menuItems field returns menuItems, filtering with a variable" do
    response = get build_conn(), "/api", query: @query, variables: @variables
    assert %{
      "data" => %{"menuItems" => [%{"name" => "Vada Pav"}]}
    } == json_response(response, 200)
  end

  @query """
  query ($filter: MenuItemFilter!) {
    menuItems(filter: $filter) {
      name
      addedOn
    }
  }
  """
  @variables %{filter: %{"addedBefore" => "2017-01-20", "category" => "Sides"}}
  test "menuItems filtered by date custom scalar" do
    sides = PlateSlate.Repo.get_by!(PlateSlate.Menu.Category, name: "Sides")
    %PlateSlate.Menu.Item{
      name: "Garlic Fries",
      added_on: ~D[2017-01-01],
      price: 2.50,
      category: sides
    } |> PlateSlate.Repo.insert!()

    response = get build_conn(), "/api", query: @query, variables: @variables
    assert %{
      "data" => %{
        "menuItems" => [%{"name" => "Garlic Fries", "addedOn" => "2017-01-01"}]
      }
    } == json_response(response, 200)
  end
end
