defmodule Exchange.Repository do

  def insert(storage, event), do: do_apply(storage, :insert, event)

  def update(storage, event), do: do_apply(storage, :update, event)

  def delete(storage, event) do
    do_apply(storage, :delete_with_shift, event)
  end

  def get_order_book(storage, depth) do
    case valid_depth?(storage, depth) do
      true ->
        resp =
          traverse(storage, depth)
          |> storage.serializer.serialize_response

        {:ok, resp}

      false ->
        {:error, :depth_not_valid}
    end
  end

  def traverse(storage, depth) do
    ask_root = get_first(storage, storage.ask_storage)
    bid_root = get_first(storage, storage.bid_storage)

    do_traverse(storage, depth - 1, [{ask_root, bid_root}])
  end

  defp do_traverse(_storage, 0, acc), do: acc
  defp do_traverse(storage, depth, [head | _tail] = acc) do
    case get_next(storage, head) do
      {:stop, :stop} -> acc

      result ->
        do_traverse(storage, depth - 1, [result | acc])
    end
  end

  defp valid_depth?(storage, depth) do
    cond do
      depth <= apply(storage.module, :current_depth, [storage.ask_storage]) -> true
      depth <= apply(storage.module, :current_depth, [storage.bid_storage]) -> true
      true -> false
    end
  end

  defp get_next(%{module: mod} = storage, {ask, bid}) do
    {
      apply(mod, :next, [storage.ask_storage, ask]),
      apply(mod, :next, [storage.bid_storage, bid])
    }
  end

  defp get_first(storage, table) do
    apply(storage.module, :first, [table])
  end

  defp do_apply(storage, command, %{side: side} = event, opts\\nil) do
    {key, payload} = storage.serializer.serialize(event)
    opts = opts || [key, payload]
    table = choose_table_by_side(storage, side)

    apply(storage.module, command, [table | opts])
  end

  defp choose_table_by_side(storage, :ask), do: storage.ask_storage
  defp choose_table_by_side(storage, :bid), do: storage.bid_storage
end
