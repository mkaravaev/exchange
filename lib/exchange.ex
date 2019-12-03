defmodule Exchange do
  @moduledoc """
  Documentation for Exchange.
  """
  use GenServer

  alias Exchange.Repository

  @type exchange :: pid()
  @type book_depth() :: integer()
  @type output :: list(map())
  @type event :: Exchange.Event.t()

  @storage Application.get_env(:exchange, :storage)

  def start_link(init_args \\ []) do
    GenServer.start_link(__MODULE__, init_args, name: __MODULE__)
  end

  @spec send_instruction(exchange, event) :: :ok | {:error, any()}
  def send_instruction(pid, %Exchange.Event{} = event) do
    GenServer.call(pid, {:exec_instr, event})
  end

  @spec send_instruction(exchange, map()) :: :ok | {:error, any()}
  def send_instruction(pid, event) do
    GenServer.call(pid, {
      :exec_instr,
      struct(Exchange.Event, event)
    })
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
    {:reply, Repository.insert(state, event), state}
  end

  def handle_call({:exec_instr, %{instruction: :delete} = event}, _from, state) do
    {:reply, Repository.delete(state, event), state}
  end

  def handle_call({:exec_instr, %{instruction: :update} = event}, _from, state) do
    {:reply, Repository.update(state, event), state}
  end

  def handle_call({:order_book, depth}, _from, state) do
    {:reply, Repository.get_order_book(state, depth), state}
  end
end
