defmodule Exchange.Event do
  @enforce_keys [
    :instruction,
    :side,
    :price_level_index
  ]

  defstruct [
    :instruction,
    :side,
    :price_level_index,
    :price,
    :quantity
  ]

  @type instruction_action :: :new | :update | :delete
  @type t :: %__MODULE__{
    instruction: instruction_action(),
    side: :bid | :ask,
    price_level_index: integer(),
    price: float(),
    quantity: integer()
  }

end
