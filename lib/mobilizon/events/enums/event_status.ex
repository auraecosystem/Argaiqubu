defmodule Mobilizon.Events.Enums.EventStatus do
  @moduledoc false

  use EctoEnum,
    tentative: 0,
    confirmed: 1,
    cancelled: 6
end
