defmodule Exchange.Storage.ETS do
  @behaviour Exchange.Storage

  alias Exchange.Storage
  alias Exchange.DefaultSerializer

  @impl true
  def init(opts \\ [ask_name: :exchange_ask, bid_name: :exchange_bid]) do
    %Storage{
      ask_storage: do_init_table(name: opts[:ask_name]),
      bid_storage: do_init_table(name: opts[:bid_name]),
      serializer: DefaultSerializer,
      module: __MODULE__
    }
  end

  @impl true
  def insert(table_name, key, payload) do
    :ets.insert(table_name, {key, payload})
  end

  @impl true
  def update(table_name, key, payload) do
    :ets.insert(table_name, {key, payload})
  end

  @impl true
  def delete(table_name, key) do
    :ets.delete(table_name, key)
  end

  @impl true
  def get(table_name, key) do
    case :ets.lookup(table_name, key) do
      [] -> nil
      [data] -> data
    end
  end

  def delete_with_shift(table_name, index, _) do
    delete(table_name, index)
    from = get(table_name, index + 1)
    do_shift(table_name, from)
  end

  defp do_shift(_table_name, nil), do: :ok
  defp do_shift(table_name, record) do
    shift_up(table_name, record)
    next = next(table_name, record)
    do_shift(table_name, next)
  end

  def first(table_name) do
    key = :ets.first(table_name)
    get(table_name, key)
  end

  def shift_up(table_name, {index, data}) do
    delete(table_name, index)
    insert(table_name, index - 1, data)
    get(table_name, index + 1)
  end

  def next(_table_name, nil), do: nil
  def next(table_name, {index, _record}) do
    case :ets.next(table_name, index) do
      "$end_of_table" -> :stop
      key -> get(table_name, key)
    end
  end

  defp do_init_table(name: name) do
    :ets.new(name, [:ordered_set, :named_table, :protected])
  end

end
