defmodule Exchange.Storage do
  @type payload :: map()
  @type key :: integer()
  @type t :: %__MODULE__{}

  @callback init() :: t() | {:error, any()}
  @callback insert(t(), key, payload) :: :ok | {:error, any()}
  @callback update(t(), key, payload) :: :ok | {:error, any()}
  @callback delete(t(), key) :: :ok | {:error, any()}
  @callback get_from(t(), key) :: [map()] | {:error, any()}

  defstruct [
    :ask_storage,
    :bid_storage,
    :serializer
  ]

end
