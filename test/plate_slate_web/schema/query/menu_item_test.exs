defmodule PlateSlateWeb.Schema.Query.MenuItemsTest do
  use PlateSlateWeb.ConnCase, async: true

  setup do
    Code.load_file("priv/repo/seeds.exs")
  end

  @query """
  {
    menuItems {
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
  query ($term: String) {
    menuItems(matching: $term) {
      name
    }
  }
  """
  @variables %{"term" => "rue"}
  test "menuItems field returns menu items filtered by name" do
    response = get build_conn(), "/api", query: @query, variables: @variables
    assert json_response(response, 200) == %{
      "data" => %{
        "menuItems" => [
          %{"name" => "Rueben"},
        ]
      }
    }
  end

  @query """
  {
    menuItems(order: DESC) {
      name
    }
  }
  """
  test "menuItems field returns manuItems descending when asked using literals" do
    response = get build_conn(), "/api", query: @query
    assert %{
      "data" => %{"menuItems" => [%{"name" => "Water"} | _]}
    } = json_response(response, 200)
  end

  @query """
  query ($term: String) {
    menuItems(matching: $term) {
      name
    }
  }
  """
  @variables %{"term" => 123}
  test "menuItems field returns errors when using a bad value" do
    response = get build_conn(), "/api", query: @query, variables: @variables
    assert %{"errors" => [
      %{"message" => message}
    ]} = json_response(response, 400)

    assert message =~ "Argument \"matching\" has invalid value"
  end
end
