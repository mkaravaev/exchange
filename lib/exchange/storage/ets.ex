defmodule Exchange.Storage.ETS do
  @behaviour Exchange.Storage

  alias Exchange.Storage
  alias Exchange.DefaultSerializer


  @impl true
  def init(opts \\ [ask_name: :exchange_ask, bid_name: :exchange_bid]) do
    %Storage{
      ask_storage: do_init_table(name: opts[:ask_name]),
      bid_storage: do_init_table(name: opts[:bid_name]),
      serializer: DefaultSerializer
    }
  end

  @impl true
  def insert(table_name, key, payload) do
    :ets.insert(table_name, {key, payload})
  end

  @impl true
  def update(table_name, key, payload) do
    :ets.update(table_name, {key, payload})
  end

  @impl true
  def delete(table_name, key) do
    :ets.delete(table_name, key)
  end

  @impl true
  def get_from(table_name, key) do
    #TODO
  end

  defp do_init_table(name: name) do
    :ets.new(name, [:named_table, :protected])
  end

end
