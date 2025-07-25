defmodule Mobilizon.Events.EventStatus do
  @moduledoc """
  Putting Enum Types in own file because of problems with test
  """
  use EctoEnum, terminate: 0, confirmed: 1, cancelled: 2
end
