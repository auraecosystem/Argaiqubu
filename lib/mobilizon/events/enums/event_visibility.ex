defmodule Mobilizon.Events.EventVisibility do
  @moduledoc """
  Putting Enum Types in own file because of problems with test
  """
  use EctoEnum, public: 0, unlisted: 1, restricted: 2, private: 3
end
