defmodule Exchange.ETSTest do
  use ExUnit.Case

  alias Exchange.Storage.ETS
  alias Exchange.DefaultSerializer
  alias Exchange.Storage

  describe "&init/0" do
    test "should return %Storage{}" do
      assert %Storage{
        ask_storage: :ask_test,
        bid_storage: :bid_test,
        serializer: DefaultSerializer
      } = ETS.init(ask_name: :ask_test, bid_name: :bid_test)
    end

    test "should create two ets tables" do
      ETS.init(ask_name: :ask_test, bid_name: :bid_test)

      assert table_exist?(:ask_test)
      assert table_exist?(:bid_test)
    end
  end

  defp table_exist?(name) do
    case :ets.info(name) do
      :undefined -> false
      _ -> true
    end
  end

end
