defmodule Exchange.DefaultSerializer do
  def serialize(%Exchange.Event{
        side: :ask,
        price_level_index: index,
        price: price,
        quantity: quantity
      }) do

    {index, %{ask_price: price, ask_quantity: quantity}}
  end

  def serialize(%Exchange.Event{
        side: :bid,
        price_level_index: index,
        price: price,
        quantity: quantity
      }) do

    {index, %{bid_price: price, bid_quantity: quantity}}
  end

  def serialize_response(input), do: do_serialize_response(input, [])

  defp do_serialize_response([], acc), do: acc
  defp do_serialize_response([head | tail], acc) do
    do_serialize_response(tail, [merge(head) | acc])
  end

  defp merge({{_ask_index, ask_data}, nil}) do
    Map.merge(ask_data, %{bid_price: nil, pid_quantity: nil})
  end
  defp merge({nil, {_bid_index, bid_data}}) do
    Map.merge(bid_data, %{ask_price: nil, ask_quantity: nil})
  end
  defp merge({{_ask_index, ask_data}, {_bid_index, bid_data}}) do
    Map.merge(ask_data, bid_data)
  end

end
