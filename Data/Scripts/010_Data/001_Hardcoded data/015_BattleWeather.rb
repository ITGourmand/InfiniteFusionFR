module GameData
  class BattleWeather
    attr_reader :id
    attr_reader :real_name
    attr_reader :animation

    DATA = {}

    extend ClassMethodsSymbols
    include InstanceMethods

    def self.load; end
    def self.save; end

    def initialize(hash)
      @id        = hash[:id]
      @real_name = hash[:name] || "Unnamed"
      @animation = hash[:animation]
    end

    # @return [String] the translated name of this battle weather
    def name
      return _INTL(@real_name)
    end
  end
end

#===============================================================================

GameData::BattleWeather.register({
  :id   => :None,
  :name => _INTL("Aucun")
})

GameData::BattleWeather.register({
  :id        => :Sun,
  :name      => _INTL("Soleil"),
  :animation => "Sun"
})

GameData::BattleWeather.register({
  :id        => :Rain,
  :name      => _INTL("Pluie"),
  :animation => "Rain"
})

GameData::BattleWeather.register({
  :id        => :Sandstorm,
  :name      => _INTL("Tempête de sable"),
  :animation => "Sandstorm"
})

GameData::BattleWeather.register({
  :id        => :Hail,
  :name      => _INTL("Grêle"),
  :animation => "Hail"
})

GameData::BattleWeather.register({
  :id        => :HarshSun,
  :name      => _INTL("Soleil ardent"),
  :animation => "HarshSun"
})

GameData::BattleWeather.register({
  :id        => :HeavyRain,
  :name      => _INTL("Forte pluie"),
  :animation => "HeavyRain"
})

GameData::BattleWeather.register({
  :id        => :StrongWinds,
  :name      => _INTL("Vents forts"),
  :animation => "StrongWinds"
})

GameData::BattleWeather.register({
  :id        => :ShadowSky,
  :name      => _INTL("Ciel d'ombre"),
  :animation => "ShadowSky"
})
