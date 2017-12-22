defmodule PlateSlateWeb.Schema.OrderingTypes do
  use Absinthe.Schema.Notation

  input_object :order_item_input do
    field :menu_item_id, non_null(:id)
    field :quantity, non_null(:integer)
  end

  input_object :place_order_input do
    field :customer_number, non_null(:integer)
    field :items, non_null(list_of(non_null(:order_item_input)))
  end

  object :order_result do
    field :order, :order
    field :errors, list_of(:input_error)
  end

  object :order do
    field :id, :id
    field :customer_number, :integer
    field :items, list_of(:order_item)
    field :state, :string
  end

  object :order_item do
    field :name, :string
    field :quantity, :integer
  end

  object :customer do
    field :name, :string
    field :email, :string do
      resolve fn %{id: customer_id} = customer, _, %{context: context} ->
        case Map.get(context, :current_user) do
          %{role: "employee"} ->
            {:ok, Map.get(customer, :email)}
          %{id: ^customer_id} ->
            {:ok, Map.get(customer, :email)}
          _ ->
            {:error, "You are not authorized to view this email address"}
        end
      end
    end
    field :orders, list_of(:order) do
      resolve &PlateSlateWeb.Resolvers.Ordering.orders/3
    end
  end

  object :customer_session do
    field :token, :string
    field :customer, :customer
  end
end
