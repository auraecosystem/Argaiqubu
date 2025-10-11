defmodule Mobilizon.Events.Enums do
  @moduledoc """
  All related Enum in seperate file to ensure stability in builds and compilation
  """

  import EctoEnum

  defenum(EventVisibility, :event_visibility, [
    :public,
    :unlisted,
    :restricted,
    :private
  ])

  defenum(JoinOptions, :join_options, [
    :free,
    :restricted,
    :invite,
    :external
  ])

  defenum(EventStatus, :event_status, [
    :tentative,
    :confirmed,
    :cancelled
  ])

  defenum(ParticipantRole, :participant_role, [
    :not_approved,
    :not_confirmed,
    :rejected,
    :participant,
    :moderator,
    :administrator,
    :creator
  ])
end
