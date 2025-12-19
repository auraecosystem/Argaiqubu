defmodule Mobilizon.Events.Categories do
  @moduledoc """
  Module that handles event categories
  """
  import Mobilizon.Web.Gettext

  @default "UNKNOWN"

  @spec default :: String.t()
  def default do
    @default
  end

  @spec list :: [%{id: atom(), label: String.t()}]
  def list do
    build_in_categories() ++ extra_categories()
  end

  @spec get_category(String.t() | nil) :: String.t()
  def get_category(category) do
    if category in Enum.map(list(), &String.upcase(to_string(&1.id))) do
      category
    else
      default()
    end
  end

  defp build_in_categories do
    [
      %{
        id: :arts,
        label: gettext("Arts")
      },
      %{
        id: :auto_boat_air,
        label: gettext("Auto, boat and air")
      },
      %{
        id: :book_clubs,
        label: gettext("Book clubs")
      },
      %{
        id: :business,
        label: gettext("Business")
      },
      %{
        id: :causes,
        label: gettext("Causes")
      },
      %{
        id: :climat_environment,
        label: gettext("Climat & Environment")
      },
      %{
        id: :community,
        label: gettext("Community")
      },
      %{
        id: :comedy,
        label: gettext("Comedy")
      },
      %{
        id: :crafts,
        label: gettext("Crafts")
      },
      %{
        id: :creative_jam,
        label: gettext("Creative jam")
      },
      %{
        id: :diy_maker_spaces,
        label: gettext("Diy maker spaces")
      },
      %{
        id: :family_education,
        label: gettext("Family & Education")
      },
      %{
        id: :fashion_beauty,
        label: gettext("Fashion & Beauty")
      },
      %{
        id: :festivals,
        label: gettext("Festivals")
      },
      %{
        id: :film_media,
        label: gettext("Film & Media")
      },
      %{
        id: :food_drink,
        label: gettext("Food & Drink")
      },
      %{
        id: :games,
        label: gettext("Games")
      },
      %{
        id: :health,
        label: gettext("Health")
      },
      %{
        id: :inclusive_spaces,
        label: gettext("Inclusive spaces")
      },
      %{
        id: :language_culture,
        label: gettext("Language & Culture")
      },
      %{
        id: :learning,
        label: gettext("Learning")
      },
      %{
        id: :lgbtq,
        label: gettext("LGBTQ")
      },
      %{
        id: :meeting,
        label: gettext("Meeting")
      },
      %{
        id: :meditation_wellbeing,
        label: gettext("Meditation & Wellbeing")
      },
      %{
        id: :movements_politics,
        label: gettext("Movements and politics")
      },
      %{
        id: :music,
        label: gettext("Music")
      },
      %{
        id: :networking,
        label: gettext("Networking")
      },
      %{
        id: :outdoors_adventure,
        label: gettext("Outdoors & Adventure")
      },
      %{
        id: :party,
        label: gettext("Party")
      },
      %{
        id: :performing_visual_arts,
        label: gettext("Performing & Visual Arts")
      },
      %{
        id: :pets,
        label: gettext("Pets")
      },
      %{
        id: :photography,
        label: gettext("Photography")
      },
      %{
        id: :science_tech,
        label: gettext("Science & Tech")
      },
      %{
        id: :spirituality_religion_beliefs,
        label: gettext("Spirituality, Religion & Beliefs")
      },
      %{
        id: :sports,
        label: gettext("Sports")
      },
      %{
        id: :theatre,
        label: gettext("Theatre")
      },
      %{
        id: :workshops_skill_sharing,
        label: gettext("Workshops skill sharing")
      },
      # Legacy default value
      %{
        id: :unknown,
        label: gettext("Unknown")
      }
    ]
  end

  @spec extra_categories :: [%{id: atom(), label: String.t()}]
  defp extra_categories do
    :mobilizon
    |> Application.get_env(:instance)
    |> Keyword.get(:extra_categories, [])
  end
end
