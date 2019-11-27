defmodule Exchange do
  @moduledoc """
  Documentation for Exchange.
  """
  use GenServer

  @type exchange :: pid()
  @type book_depth() :: integer()
  @type output :: list(map())
  @type instruction_action :: :new | :update | :delete
  @type event :: %{
    instruction: instruction_action(),
    side: :bid | :ask,
    price_level_index: integer(),
    price: float(),
    quantity: integer()
  }

  @storage Application.get_env(:exchange, :storage)

  def start_link(init_args \\ []) do
    GenServer.start_link(__MODULE__, init_args, name: __MODULE__)
  end

  @spec send_instruction(exchange, event) :: :ok | {:error, any()}
  def send_instruction(pid, event) do
    GenServer.call(pid, {:exec_instr, event})
  end

  @spec order_book(exchange(), book_depth()) :: output()
  def order_book(pid, book_depth) do
    GenServer.call(pid, {:order_book, book_depth})
  end

  @impl true
  def init(_) do
    {:ok, @storage.init()}
  end

  @impl true
  def handle_call({:exec_instr, %{instruction: :new} = event}, _from, state) do
    {:reply, :ok, state}
  end

  def handle_call({:exec_instr, %{instruction: :delete}}, _from, state) do
    {:reply, :ok, state}
  end

  def handle_call({:exec_instr, %{instruction: :update}}, _from, state) do
    {:reply, :ok, state}
  end

  def handle_call({:order_book, depth}, _from, storage) do
    {:ok, {:ok, %{}}, storage}
  end
end
