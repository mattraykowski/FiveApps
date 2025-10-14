defmodule FiveApps.Helpers.NameGenerator do
  @moduledoc """
  A helper module to generate random names for ships, crew members, and groups.
  """

  # Ship Name Generator
  @ship_adjectives [
    "Galactic",
    "Stellar",
    "Cosmic",
    "Nebular",
    "Quantum",
    "Interstellar",
    "Celestial",
    "Luminous",
    "Ethereal",
    "Radiant",
    "Astral",
    "Solar",
    "Ecliptic",
    "Orbital",
    "Spectral",
    "Gravitational",
    "Plasma",
    "Void",
    "Hyper",
    "Warp"
  ]

  @ship_nouns [
    "Voyager",
    "Explorer",
    "Pioneer",
    "Crusader",
    "Odyssey",
    "Eclipse",
    "Horizon",
    "Phoenix",
    "Nebula",
    "Comet",
    "Pulsar",
    "Nova",
    "Meteor",
    "Starship",
    "Galaxy",
    "Interceptor",
    "Ranger",
    "Sentinel",
    "Vanguard",
    "Drifter"
  ]

  @doc """
  Generates a random sci-fi ship name by combining an adjective and a noun.

  ## Examples

      iex> FiveApps.Helpers.NameGenerator.generate_ship_name()
      "Galactic Voyager"
  """
  def generate_ship_name do
    adjective = Enum.random(@ship_adjectives)
    noun = Enum.random(@ship_nouns)
    "#{adjective} #{noun}"
  end

  # Crew Member Name Generator
  @male_first_names [
    "Arin",
    "Jax",
    "Kai",
    "Zane",
    "Orin",
    "Dax",
    "Rian",
    "Talon",
    "Vyn",
    "Lior"
  ]

  @female_first_names [
    "Aria",
    "Nova",
    "Luna",
    "Mira",
    "Tess",
    "Vera",
    "Lyra",
    "Nia",
    "Selene",
    "Elara"
  ]

  @last_names [
    "Smith",
    "Johnson",
    "Williams",
    "Brown",
    "Jones",
    "Garcia",
    "Miller",
    "Davis",
    "Rodriguez",
    "Martinez",
    "Hernandez",
    "Lopez",
    "Gonzalez",
    "Wilson",
    "Anderson",
    "Thomas",
    "Taylor",
    "Moore",
    "Jackson",
    "Martin"
  ]

  @doc """
  Generates a random crew member name by combining a first name and a last name.

  ## Options

    - `:gender` - `:male`, `:female`, or `:any` (default: `:any`)

  ## Examples

      iex> FiveApps.Helpers.NameGenerator.generate_crew_member_name()
      "Aria Smith"

      iex> FiveApps.Helpers.NameGenerator.generate_crew_member_name(gender: :male)
      "Jax Johnson"

      iex> FiveApps.Helpers.NameGenerator.generate_crew_member_name(gender: :female)
      "Luna Brown"
  """
  def generate_crew_member_name(opts \\ [gender: :any]) do
    first_name =
      case opts[:gender] do
        :male -> Enum.random(@male_first_names)
        :female -> Enum.random(@female_first_names)
        _ -> Enum.random(@male_first_names ++ @female_first_names)
      end

    last_name = Enum.random(@last_names)
    "#{first_name} #{last_name}"
  end

  # Group Name Generator
  @group_adjectives [
    "Rogue",
    "Shadow",
    "Iron",
    "Crimson",
    "Silver",
    "Eclipse",
    "Nebula",
    "Phantom",
    "Warp",
    "Void"
  ]

  @group_nouns [
    "Raiders",
    "Marauders",
    "Corsairs",
    "Outlaws",
    "Drifters",
    "Vanguard",
    "Nomads",
    "Rangers",
    "Specters",
    "Wolves"
  ]

  @doc """
  Generates a random crew name suitable for a band of bandits, spacers, or a street gang.

  ## Examples

      iex> FiveApps.Helpers.NameGenerator.generate_group_name()
      "Shadow Raiders"

      iex> FiveApps.Helpers.NameGenerator.generate_group_name()
      "Crimson Wolves"
  """
  def generate_group_name do
    adjective = Enum.random(@group_adjectives)
    noun = Enum.random(@group_nouns)
    "#{adjective} #{noun}"
  end
end
