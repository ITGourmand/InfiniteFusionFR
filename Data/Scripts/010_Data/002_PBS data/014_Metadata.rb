module GameData
  class Metadata
    attr_reader :id
    attr_reader :home
    attr_reader :wild_battle_BGM
    attr_reader :trainer_battle_BGM
    attr_reader :wild_victory_ME
    attr_reader :trainer_victory_ME
    attr_reader :wild_capture_ME
    attr_reader :surf_BGM
    attr_reader :bicycle_BGM
    attr_reader :player_A
    attr_reader :player_B
    attr_reader :player_C
    attr_reader :player_D
    attr_reader :player_E
    attr_reader :player_F
    attr_reader :player_G
    attr_reader :player_H

    DATA = {}
    DATA_FILENAME = "metadata.dat"

    SCHEMA = {
      "Home"             => [1,  "vuuu"],
      "WildBattleBGM"    => [2,  "s"],
      "TrainerBattleBGM" => [3,  "s"],
      "WildVictoryME"    => [4,  "s"],
      "TrainerVictoryME" => [5,  "s"],
      "WildCaptureME"    => [6,  "s"],
      "SurfBGM"          => [7,  "s"],
      "BicycleBGM"       => [8,  "s"],
      "PlayerA"          => [9,  "esssssss", :TrainerType],
      "PlayerB"          => [10, "esssssss", :TrainerType],
      "PlayerC"          => [11, "esssssss", :TrainerType],
      "PlayerD"          => [12, "esssssss", :TrainerType],
      "PlayerE"          => [13, "esssssss", :TrainerType],
      "PlayerF"          => [14, "esssssss", :TrainerType],
      "PlayerG"          => [15, "esssssss", :TrainerType],
      "PlayerH"          => [16, "esssssss", :TrainerType]
    }

    extend ClassMethodsIDNumbers
    include InstanceMethods

    def self.editor_properties
      return [
         ["Home",             MapCoordsFacingProperty, _INTL("ID de la carte et coordonnées X et Y de l'endroit où le joueur se rend si aucun Centre Pokémon n'a été entré après une perte.")],
         ["WildBattleBGM",    BGMProperty,             _INTL("BGM par défaut pour les combats de Pokémon sauvages.")],
         ["TrainerBattleBGM", BGMProperty,             _INTL("BGM par défaut pour les combats des dresseurs.")],
         ["WildVictoryME",    MEProperty,              _INTL("ME par défaut joué après avoir remporté un combat de Pokémon sauvage.")],
         ["TrainerVictoryME", MEProperty,              _INTL("ME par défaut joué après avoir remporté un combat de dresseur.")],
         ["WildCaptureME",    MEProperty,              _INTL("ME par défaut joué après avoir attrapé un Pokémon.")],
         ["SurfBGM",          BGMProperty,             _INTL("BGM jouée pendant le surf.")],
         ["BicycleBGM",       BGMProperty,             _INTL("BGM jouée sur un vélo.")],
         ["PlayerA",          PlayerProperty,          _INTL("Spécifie le joueur A.")],
         ["PlayerB",          PlayerProperty,          _INTL("Spécifie le joueur B.")],
         ["PlayerC",          PlayerProperty,          _INTL("Spécifie le joueur C.")],
         ["PlayerD",          PlayerProperty,          _INTL("Spécifie le joueur D.")],
         ["PlayerE",          PlayerProperty,          _INTL("Spécifie le joueur E.")],
         ["PlayerF",          PlayerProperty,          _INTL("Spécifie le joueur F.")],
         ["PlayerG",          PlayerProperty,          _INTL("Spécifie le joueur G.")],
         ["PlayerH",          PlayerProperty,          _INTL("Spécifie le joueur H.")]
      ]
    end

    def self.get
      return DATA[0]
    end

    def self.get_player(id)
      return self.get.player_A
      case id
      when 0 then return self.get.player_A
      when 1 then return self.get.player_B
      when 2 then return self.get.player_C
      when 3 then return self.get.player_D
      when 4 then return self.get.player_E
      when 5 then return self.get.player_F
      when 6 then return self.get.player_G
      when 7 then return self.get.player_H
      end
      return nil
    end

    def initialize(hash)
      @id                  = hash[:id]
      @home                = hash[:home]
      @wild_battle_BGM     = hash[:wild_battle_BGM]
      @trainer_battle_BGM  = hash[:trainer_battle_BGM]
      @wild_victory_ME     = hash[:wild_victory_ME]
      @trainer_victory_ME  = hash[:trainer_victory_ME]
      @wild_capture_ME     = hash[:wild_capture_ME]
      @surf_BGM            = hash[:surf_BGM]
      @bicycle_BGM         = hash[:bicycle_BGM]
      @player_A            = hash[:player_A]
      @player_B            = hash[:player_B]
      @player_C            = hash[:player_C]
      @player_D            = hash[:player_D]
      @player_E            = hash[:player_E]
      @player_F            = hash[:player_F]
      @player_G            = hash[:player_G]
      @player_H            = hash[:player_H]
    end

    def property_from_string(str)
      case str
      when "Home"             then return @home
      when "WildBattleBGM"    then return @wild_battle_BGM
      when "TrainerBattleBGM" then return @trainer_battle_BGM
      when "WildVictoryME"    then return @wild_victory_ME
      when "TrainerVictoryME" then return @trainer_victory_ME
      when "WildCaptureME"    then return @wild_capture_ME
      when "SurfBGM"          then return @surf_BGM
      when "BicycleBGM"       then return @bicycle_BGM
      when "PlayerA"          then return @player_A
      when "PlayerB"          then return @player_B
      when "PlayerC"          then return @player_C
      when "PlayerD"          then return @player_D
      when "PlayerE"          then return @player_E
      when "PlayerF"          then return @player_F
      when "PlayerG"          then return @player_G
      when "PlayerH"          then return @player_H
      end
      return nil
    end
  end
end

#===============================================================================
# Deprecated methods
#===============================================================================
# @deprecated This alias is slated to be removed in v20.
def pbLoadMetadata
  Deprecation.warn_method('pbLoadMetadata', 'v20', 'GameData::Metadata.get or GameData::MapMetadata.get(map_id)')
  return nil
end

# @deprecated This alias is slated to be removed in v20.
def pbGetMetadata(map_id, metadata_type)
  if map_id == 0   # Global metadata
    Deprecation.warn_method('pbGetMetadata', 'v20', 'GameData::Metadata.get.something')
  else   # Map metadata
    Deprecation.warn_method('pbGetMetadata', 'v20', 'GameData::MapMetadata.get(map_id).something')
  end
  return nil
end
