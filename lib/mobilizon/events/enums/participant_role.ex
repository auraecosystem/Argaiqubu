defmodule Mobilizon.Events.ParticipantRole do
  @moduledoc """
  Putting Enum Types in own file because of problems with test
  """
  use EctoEnum,
    not_approved: 0,
    not_confirmed: 1,
    rejected: 2,
    participant: 3,
    moderator: 4,
    administrator: 5,
    creator: 6
end
