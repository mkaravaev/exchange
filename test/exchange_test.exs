defmodule ExchangeTest do
  use ExUnit.Case

  setup [:init_storage]

  describe "&send_instruction/2 :new" do
    test "should add new ask entry", context do
      instr = build_instruction(:new, :ask, %{price: 1.0})
      Exchange.send_instruction(context.pid, instr)

      assert :ets.info(:exchange_ask)[:size] == 1
    end

    test "should add new bid entry", context do
      instr = build_instruction(:new, :bid, %{price: 1.0})
      Exchange.send_instruction(context.pid, instr)
      assert :ets.info(:exchange_bid)[:size] == 1
    end
  end

  describe "&send_instruction/2 :update" do
    test "should update ask entry", context do
      instr = build_instruction(:new, :ask, %{price: 1.0})
      Exchange.send_instruction(context.pid, instr)

      update_instr = build_instruction(:update, :ask, %{price: 2.0})
      Exchange.send_instruction(context.pid, update_instr)

      [{key, data}] = :ets.lookup(:exchange_ask, 1)
      assert data.ask_price == 2.0
    end

    test "should update bid entry", context do
      instr = build_instruction(:new, :bid, %{price: 1.0})
      Exchange.send_instruction(context.pid, instr)

      update_instr = build_instruction(:update, :bid, %{price: 2.0})
      Exchange.send_instruction(context.pid, update_instr)


      [{key, data}] = :ets.lookup(:exchange_bid, 1)
      assert data.bid_price == 2.0
    end

    test "should return error if entry not exist", context do
      instr = build_instruction(:update, :bid, %{price: 1.0})
      assert {:error, :price_level_not_exist} = Exchange.send_instruction(context.pid, instr)
    end
  end

  describe "&send_instruction/2 :delete" do
    @tag :f
    test "should delete ask entry", context do
      instr = build_instruction(:new, :ask)
      Exchange.send_instruction(context.pid, instr)

      del_instr = build_instruction(:delete, :ask)
      Exchange.send_instruction(context.pid, del_instr)

      assert :ets.info(:exchange_ask)[:size] == 0
    end

    test "should update bid entry", context do
      instr = build_instruction(:new, :bid, %{price: 1.0})
      Exchange.send_instruction(context.pid, instr)

      del_instr = build_instruction(:delete, :bid)
      Exchange.send_instruction(context.pid, del_instr)

      assert :ets.info(:exchange_bid)[:size] == 0
    end

    test "should shift up lefted entries", context do
      insert_instructions(context, 4, :ask)
      [{_index, before_data}] = :ets.lookup(:exchange_ask, 4)
      del_instr = build_instruction(:delete, :ask, %{price_level_index: 2})
      Exchange.send_instruction(context.pid, del_instr)

      [{_index, after_data}] = :ets.lookup(:exchange_ask, 3)
      assert after_data.ask_price == before_data.ask_price
      assert :ets.lookup(:exchange_ask, 4) == []
    end
  end

  describe "&get_order_book/2" do
    setup context do
      insert_instructions(context, 10, :ask)
      insert_instructions(context, 2, :bid)
      :ok
    end

    test "should return book order for given depth", context  do
      {:ok, [first | tail]} = Exchange.order_book(context.pid, 8)

      assert %{ask_price: 1, bid_price: 1} = first
      assert %{ask_price: 8, bid_price: nil} = List.last(tail)
    end
  end

  defp init_storage(context) do
    {:ok, pid} = Exchange.start_link()
    [pid: pid]
  end

  defp insert_instructions(context, level_depth, side) do
    for i <- 1..level_depth do
      instr = build_instruction(:new, side, %{side: side, price_level_index: i, price: i})
      Exchange.send_instruction(context.pid, instr)
    end
  end

  defp build_instruction(type, side, args \\ %{}) do
    default = %{
      instruction: type,
      side: side,
      price_level_index: 1,
      price: Enum.random(1..100) / 1,
      quantity: Enum.random(1..100)
    }

    params = Map.merge(default, args)
    struct(Exchange.Event, params)
  end

end
