module GameData
  class MapMetadata
    attr_reader :id
    attr_reader :outdoor_map
    attr_reader :announce_location
    attr_reader :can_bicycle
    attr_reader :always_bicycle
    attr_reader :teleport_destination
    attr_reader :weather
    attr_reader :town_map_position
    attr_reader :dive_map_id
    attr_reader :dark_map
    attr_reader :safari_map
    attr_reader :snap_edges
    attr_reader :random_dungeon
    attr_reader :battle_background
    attr_reader :wild_battle_BGM
    attr_reader :trainer_battle_BGM
    attr_reader :wild_victory_ME
    attr_reader :trainer_victory_ME
    attr_reader :wild_capture_ME
    attr_reader :town_map_size
    attr_reader :battle_environment

    DATA = {}
    DATA_FILENAME = "map_metadata.dat"

    SCHEMA = {
       "Outdoor"          => [1,  "b"],
       "ShowArea"         => [2,  "b"],
       "Bicycle"          => [3,  "b"],
       "BicycleAlways"    => [4,  "b"],
       "HealingSpot"      => [5,  "vuu"],
       "Weather"          => [6,  "eu", :Weather],
       "MapPosition"      => [7,  "uuu"],
       "DiveMap"          => [8,  "v"],
       "DarkMap"          => [9,  "b"],
       "SafariMap"        => [10, "b"],
       "SnapEdges"        => [11, "b"],
       "Dungeon"          => [12, "b"],
       "BattleBack"       => [13, "s"],
       "WildBattleBGM"    => [14, "s"],
       "TrainerBattleBGM" => [15, "s"],
       "WildVictoryME"    => [16, "s"],
       "TrainerVictoryME" => [17, "s"],
       "WildCaptureME"    => [18, "s"],
       "MapSize"          => [19, "us"],
       "Environment"      => [20, "e", :Environment]
    }

    extend ClassMethodsIDNumbers
    include InstanceMethods

    def self.editor_properties
      return [
        ["Outdoor",          BooleanProperty,                    _INTL("Si vrai, cette carte est une carte extérieure et sera teintée en fonction de l'heure de la journée.")],
        ["ShowArea",         BooleanProperty,                    _INTL("Si vrai, le jeu affichera le nom de la carte à l'entrée.")],
        ["Bicycle",          BooleanProperty,                    _INTL("Si vrai, la bicyclette peut être utilisée sur cette carte.")],
        ["BicycleAlways",    BooleanProperty,                    _INTL("Si vrai, la bicyclette sera automatiquement utilisée sur cette carte et ne pourra pas être désactivée.")],
        ["HealingSpot",      MapCoordsProperty,                  _INTL("ID de la ville de ce Centre Pokémon, et coordonnées X et Y de son entrée dans cette ville.")],
        ["Weather",          WeatherEffectProperty,              _INTL("Conditions météorologiques en vigueur sur cette carte.")],
        ["MapPosition",      RegionMapCoordsProperty,            _INTL("Identifie le point sur la carte régionale correspondant à cette carte.")],
        ["DiveMap",          MapProperty,                        _INTL("Spécifie la couche sous-marine de cette carte. À utiliser uniquement si cette carte contient de l'eau profonde.")],
        ["DarkMap",          BooleanProperty,                    _INTL("Si vrai, cette carte est sombre et un cercle de lumière apparaît autour du joueur. Flash peut être utilisé pour agrandir le cercle.")],
        ["SafariMap",        BooleanProperty,                    _INTL("Si vrai, cette carte fait partie de la Zone Safari (intérieur et extérieur). Ne pas utiliser pour la réception.")],
        ["SnapEdges",        BooleanProperty,                    _INTL("Si vrai, lorsque le joueur s'approche du bord de cette carte, le jeu ne centre pas le joueur comme d'habitude.")],
        ["Dungeon",          BooleanProperty,                    _INTL("Si vrai, cette carte a une disposition générée aléatoirement. Voir le wiki pour plus d'informations.")],
        ["BattleBack",       StringProperty,                     _INTL("Fichiers PNG nommés 'XXX_bg', 'XXX_base0', 'XXX_base1', 'XXX_message' dans le dossier Battlebacks, où XXX est la valeur de cette propriété.")],
        ["WildBattleBGM",    BGMProperty,                        _INTL("BGM par défaut pour les combats contre des Pokémon sauvages sur cette carte.")],
        ["TrainerBattleBGM", BGMProperty,                        _INTL("BGM par défaut pour les combats contre des dresseurs sur cette carte.")],
        ["WildVictoryME",    MEProperty,                         _INTL("ME par défaut joué après avoir gagné un combat contre un Pokémon sauvage sur cette carte.")],
        ["TrainerVictoryME", MEProperty,                         _INTL("ME par défaut joué après avoir gagné un combat contre un dresseur sur cette carte.")],
        ["WildCaptureME",    MEProperty,                         _INTL("ME par défaut joué après avoir capturé un Pokémon sauvage sur cette carte.")],
        ["MapSize",          MapSizeProperty,                    _INTL("La largeur de la carte en cases de la Carte de Ville, et une chaîne indiquant quelles cases font partie de cette carte.")],
        ["Environment",      GameDataProperty.new(:Environment), _INTL("L'environnement de combat par défaut pour les combats sur cette carte.")]
      ]
    end

    def initialize(hash)
      @id                   = hash[:id]
      @outdoor_map          = hash[:outdoor_map]
      @announce_location    = hash[:announce_location]
      @can_bicycle          = hash[:can_bicycle]
      @always_bicycle       = hash[:always_bicycle]
      @teleport_destination = hash[:teleport_destination]
      @weather              = hash[:weather]
      @town_map_position    = hash[:town_map_position]
      @dive_map_id          = hash[:dive_map_id]
      @dark_map             = hash[:dark_map]
      @safari_map           = hash[:safari_map]
      @snap_edges           = hash[:snap_edges]
      @random_dungeon       = hash[:random_dungeon]
      @battle_background    = hash[:battle_background]
      @wild_battle_BGM      = hash[:wild_battle_BGM]
      @trainer_battle_BGM   = hash[:trainer_battle_BGM]
      @wild_victory_ME      = hash[:wild_victory_ME]
      @trainer_victory_ME   = hash[:trainer_victory_ME]
      @wild_capture_ME      = hash[:wild_capture_ME]
      @town_map_size        = hash[:town_map_size]
      @battle_environment   = hash[:battle_environment]
    end

    def property_from_string(str)
      case str
      when "Outdoor"          then return @outdoor_map
      when "ShowArea"         then return @announce_location
      when "Bicycle"          then return @can_bicycle
      when "BicycleAlways"    then return @always_bicycle
      when "HealingSpot"      then return @teleport_destination
      when "Weather"          then return @weather
      when "MapPosition"      then return @town_map_position
      when "DiveMap"          then return @dive_map_id
      when "DarkMap"          then return @dark_map
      when "SafariMap"        then return @safari_map
      when "SnapEdges"        then return @snap_edges
      when "Dungeon"          then return @random_dungeon
      when "BattleBack"       then return @battle_background
      when "WildBattleBGM"    then return @wild_battle_BGM
      when "TrainerBattleBGM" then return @trainer_battle_BGM
      when "WildVictoryME"    then return @wild_victory_ME
      when "TrainerVictoryME" then return @trainer_victory_ME
      when "WildCaptureME"    then return @wild_capture_ME
      when "MapSize"          then return @town_map_size
      when "Environment"      then return @battle_environment
      end
      return nil
    end
  end
end
