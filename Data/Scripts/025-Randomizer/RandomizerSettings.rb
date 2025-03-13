module OptionTypes
  WILD_POKE = 0
  TRAINER_POKE = 1
end

class RandomizerOptionsScene < PokemonOption_Scene
  def initialize
    super
    @openTrainerOptions = false
    @openWildOptions = false
    @openGymOptions = false
    @openItemOptions = false
    $game_switches[SWITCH_RANDOMIZED_AT_LEAST_ONCE] = true
  end

  def getDefaultDescription
    return _INTL("Définir les paramètres du randomiseur")
  end

  def pbStartScene(inloadscreen = false)
    super
    @changedColor = true
    @sprites["title"] = Window_UnformattedTextPokemon.newWithSize(
      _INTL("Paramètres du Randomiseur"), 0, 0, Graphics.width, 64, @viewport)
    @sprites["textbox"].text = getDefaultDescription
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbGetOptions(inloadscreen = false)
    options = [
      EnumOption.new(_INTL("Pokémon"), [_INTL("On"), _INTL("Off")],
                     proc {
                       $game_switches[SWITCH_RANDOM_WILD] ? 0 : 1
                     },
                     proc { |value|
                       if !$game_switches[SWITCH_RANDOM_WILD] && value == 0
                         @openWildOptions = true
                         openWildPokemonOptionsMenu()
                       end
                       $game_switches[SWITCH_RANDOM_WILD] = value == 0
                     }, "Sélectionnez les options de randomisation pour Pokémon"
      ),
      EnumOption.new(_INTL("Dresseur/PNJ"), [_INTL("On"), _INTL("Off")],
                     proc { $game_switches[SWITCH_RANDOM_TRAINERS] ? 0 : 1 },
                     proc { |value|
                       if !$game_switches[SWITCH_RANDOM_TRAINERS] && value == 0
                         @openTrainerOptions = true
                         openTrainerOptionsMenu()
                       end
                       $game_switches[SWITCH_RANDOM_TRAINERS] = value == 0
                     }, "Sélectionnez les options de randomisation pour les dresseurs"
      ),

      EnumOption.new(_INTL("Champion d'arène"), [_INTL("On"), _INTL("Off")],
                     proc { $game_switches[SWITCH_RANDOMIZE_GYMS_SEPARATELY] ? 0 : 1 },
                     proc { |value|
                       if !$game_switches[SWITCH_RANDOMIZE_GYMS_SEPARATELY] && value == 0
                         @openGymOptions = true
                         openGymOptionsMenu()
                       end
                       $game_switches[SWITCH_RANDOMIZE_GYMS_SEPARATELY] = value == 0
                     }, "Limiter les Champion d'arène à un seul type"
      ),

      EnumOption.new(_INTL("Objets"), [_INTL("On"), _INTL("Off")],
                     proc { $game_switches[SWITCH_RANDOM_ITEMS_GENERAL] ? 0 : 1 },
                     proc { |value|
                       if !$game_switches[SWITCH_RANDOM_ITEMS_GENERAL] && value == 0
                         @openItemOptions = true
                         openItemOptionsMenu()
                       end
                       $game_switches[SWITCH_RANDOM_ITEMS_GENERAL] = value == 0
                     }, "Sélectionnez les options de randomisation pour les Objets"
      ),

    ]
    return options
  end

  def openGymOptionsMenu()
    return if !@openGymOptions
    pbFadeOutIn {
      scene = RandomizerGymOptionsScene.new
      screen = PokemonOptionScreen.new(scene)
      screen.pbStartScreen
    }
    @openGymOptions = false
  end

  def openItemOptionsMenu()
    return if !@openItemOptions
    pbFadeOutIn {
      scene = RandomizerItemOptionsScene.new
      screen = PokemonOptionScreen.new(scene)
      screen.pbStartScreen
    }
    @openItemOptions = false
  end

  def openTrainerOptionsMenu()
    return if !@openTrainerOptions
    pbFadeOutIn {
      scene = RandomizerTrainerOptionsScene.new
      screen = PokemonOptionScreen.new(scene)
      screen.pbStartScreen
    }
    @openTrainerOptions = false
  end

  def openWildPokemonOptionsMenu()
    return if !@openWildOptions
    pbFadeOutIn {
      scene = RandomizerWildPokemonOptionsScene.new
      screen = PokemonOptionScreen.new(scene)
      screen.pbStartScreen
    }
    @openWildOptions = false
  end

end

class RandomizerTrainerOptionsScene < PokemonOption_Scene
  RANDOM_TEAMS_CUSTOM_SPRITES = 600
  RANDOM_GYM_TYPES = 921

  def initialize
    @changedColor = false
  end

  def pbStartScene(inloadscreen = false)
    super
    @sprites["option"].nameBaseColor = MessageConfig::BLUE_TEXT_MAIN_COLOR
    @sprites["option"].nameShadowColor = MessageConfig::BLUE_TEXT_SHADOW_COLOR
    @changedColor = true
    for i in 0...@PokemonOptions.length
      @sprites["option"][i] = (@PokemonOptions[i].get || 0)
    end
    @sprites["title"] = Window_UnformattedTextPokemon.newWithSize(
      _INTL("Paramètres du Randomiseur: Dresseurs"), 0, 0, Graphics.width, 64, @viewport)
    @sprites["textbox"].text = _INTL("Définir les paramètres de randomisation pour les dresseurs")

    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbFadeInAndShow(sprites, visiblesprites = nil)
    return if !@changedColor
    super
  end

  def pbGetOptions(inloadscreen = false)
    options = []
    if !$game_switches[SWITCH_DURING_INTRO]
      options << SliderOption.new(_INTL("Degré d'aléatoire"), 25, 500, 5,
                                  proc { $game_variables[VAR_RANDOMIZER_TRAINER_BST] },
                                  proc { |value|
                                    $game_variables[VAR_RANDOMIZER_TRAINER_BST] = value
                                  })
    end
    options << EnumOption.new(_INTL("Sprites Personnalisés Uniquement"), [_INTL("On"), _INTL("Off")],
                              proc { $game_switches[RANDOM_TEAMS_CUSTOM_SPRITES] ? 0 : 1 },
                              proc { |value|
                                $game_switches[RANDOM_TEAMS_CUSTOM_SPRITES] = value == 0
                              },
                              "Utilisez uniquement des Pokémon qui ont des sprites personnalisés dans les équipes de dresseurs"
    )

    # options << EnumOption.new(_INTL("Allow legendaries"), [_INTL("On"), _INTL("Off")],
    #                           proc { $game_switches[SWITCH_RANDOM_TRAINER_LEGENDARIES] ? 0 : 1 },
    #                           proc { |value|
    #                             $game_switches[SWITCH_RANDOM_TRAINER_LEGENDARIES] = value == 0
    #                           }, "Regular Pokémon can also be randomized into legendaries"
    # )

    return options
  end
end

class RandomizerWildPokemonOptionsScene < PokemonOption_Scene
  RANDOM_WILD_AREA = 777
  RANDOM_WILD_GLOBAL = 956
  RANDOM_STATIC = 955
  REGULAR_TO_FUSIONS = 953
  GIFT_POKEMON = 780

  def initialize
    @changedColor = false
  end

  def pbStartScene(inloadscreen = false)
    super
    @sprites["option"].nameBaseColor = Color.new(70, 170, 40)
    @sprites["option"].nameShadowColor = Color.new(40, 100, 20)
    @changedColor = true
    for i in 0...@PokemonOptions.length
      @sprites["option"][i] = (@PokemonOptions[i].get || 0)
    end
    @sprites["title"] = Window_UnformattedTextPokemon.newWithSize(
      _INTL("Paramètres du Randomizer: Pokémon"), 0, 0, Graphics.width, 64, @viewport)
    @sprites["textbox"].text = _INTL("Définir les paramètres de randomisation pour les Pokémon sauvages")
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbFadeInAndShow(sprites, visiblesprites = nil)
    return if !@changedColor
    super
  end

  def pbGetOptions(inloadscreen = false)
    options = []
    if !$game_switches[SWITCH_DURING_INTRO]
      options << SliderOption.new(_INTL("Degré d'aléatoire"), 25, 500, 5,
                                  proc { $game_variables[VAR_RANDOMIZER_WILD_POKE_BST] },
                                  proc { |value|
                                    $game_variables[VAR_RANDOMIZER_WILD_POKE_BST] = value
                                  })
    end

    options << EnumOption.new(_INTL("Type"), [_INTL("Global"), _INTL("Zone")],
                              proc {
                                if $game_switches[RANDOM_WILD_AREA]
                                  1
                                else
                                  0
                                end
                              },
                              proc { |value|
                                if value == 0
                                  $game_switches[RANDOM_WILD_GLOBAL] = true
                                  $game_switches[RANDOM_WILD_AREA] = false
                                else
                                  value == 1
                                  $game_switches[RANDOM_WILD_GLOBAL] = false
                                  $game_switches[RANDOM_WILD_AREA] = true
                                end
                              },
                              [
                                "Randomise les Pokémon en utilisant une cartographie un à un du Pokédex",
                                "Randomise les rencontres dans chaque route individuellement"
                              ]
    )
    options << EnumOption.new(_INTL("Sprites Personnalisés Uniquement"), [_INTL("On"), _INTL("Off")],
                              proc { $game_switches[SWITCH_RANDOM_WILD_ONLY_CUSTOMS] ? 0 : 1 },
                              proc { |value|
                                $game_switches[SWITCH_RANDOM_WILD_ONLY_CUSTOMS] = value == 0
                              }, "['Fuse everything' & starters] Inclure uniquement les Pokémon avec un sprite personnalisé."
    )

    options << EnumOption.new(_INTL("Autoriser les Légendaires"), [_INTL("On"), _INTL("Off")],
                              proc { $game_switches[SWITCH_RANDOM_WILD_LEGENDARIES] ? 0 : 1 },
                              proc { |value|
                                $game_switches[SWITCH_RANDOM_WILD_LEGENDARIES] = value == 0
                              }, ["Les Pokémon sauvages réguliers peuvent également être randomisés en Pokémon légendaires.",
                                  "Seuls les légendaires peuvent être randomisés en légendaires"]
    )


    options << EnumOption.new(_INTL("Starters"), [_INTL("1er Stade"), _INTL("N'importe"), _INTL("Off")],
                              proc {
                                getStarterRandomizerSelectedOption() },
                              proc { |value|
                                case value
                                when 0
                                  $game_switches[SWITCH_RANDOM_STARTERS] = true
                                  $game_switches[SWITCH_RANDOM_STARTER_FIRST_STAGE] = true
                                when 1
                                  $game_switches[SWITCH_RANDOM_STARTERS] = true
                                  $game_switches[SWITCH_RANDOM_STARTER_FIRST_STAGE] = false
                                else
                                  $game_switches[SWITCH_RANDOM_STARTERS] = false
                                  $game_switches[SWITCH_RANDOM_STARTER_FIRST_STAGE] = false
                                end

                                echoln "random starters: #{$game_switches[SWITCH_RANDOM_STARTERS]}"
                                echoln "random 1st stage: #{$game_switches[SWITCH_RANDOM_STARTER_FIRST_STAGE]}"

                              }, ["Les starters seront toujours un Pokémon de première évolution",
                                  "Les starters peuvent être n'importe quel Pokémon",
                                  "Les starters ne sont pas randomisés"]
    )
    options << EnumOption.new(_INTL("Rencontres statiques"), [_INTL("On"), _INTL("Off")],
                              proc { $game_switches[RANDOM_STATIC] ? 0 : 1 },
                              proc { |value|
                                $game_switches[RANDOM_STATIC] = value == 0
                              },
                              "Randomiser les Pokémon qui apparaissent dans le monde (y compris les légendaires)"
    )

    options << EnumOption.new(_INTL("Pokémon Offerts"), [_INTL("On"), _INTL("Off")],
                              proc { $game_switches[GIFT_POKEMON] ? 0 : 1 },
                              proc { |value|
                                $game_switches[GIFT_POKEMON] = value == 0
                              }, "Randomiser les Pokémon offerts au joueur"
    )

    options << EnumOption.new(_INTL("Tout Fusionner"), [_INTL("On"), _INTL("Off")],
                              proc { $game_switches[REGULAR_TO_FUSIONS] ? 0 : 1 },
                              proc { |value|
                                $game_switches[REGULAR_TO_FUSIONS] = value == 0
                              }, "Tous les Pokémon sauvages seront déjà pré-fusionnés"
    )
    return options
  end


  def getStarterRandomizerSelectedOption()
    return 0 if $game_switches[SWITCH_RANDOM_STARTERS] && $game_switches[SWITCH_RANDOM_STARTER_FIRST_STAGE]
    return 1 if $game_switches[SWITCH_RANDOM_STARTERS]
    return 2
  end
end



class RandomizerGymOptionsScene < PokemonOption_Scene
  RANDOM_GYM_TYPES = 921

  def initialize
    @changedColor = false
  end

  def pbStartScene(inloadscreen = false)
    super
    @sprites["option"].nameBaseColor = MessageConfig::BLUE_TEXT_MAIN_COLOR
    @sprites["option"].nameShadowColor = MessageConfig::BLUE_TEXT_SHADOW_COLOR
    @changedColor = true
    for i in 0...@PokemonOptions.length
      @sprites["option"][i] = (@PokemonOptions[i].get || 0)
    end
    @sprites["title"] = Window_UnformattedTextPokemon.newWithSize(
      _INTL("Paramètres du Randomiseur : Champion"), 0, 0, Graphics.width, 64, @viewport)
    @sprites["textbox"].text = _INTL("Définir les paramètres de randomisation pour les Champions")

    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbFadeInAndShow(sprites, visiblesprites = nil)
    return if !@changedColor
    super
  end

  def pbGetOptions(inloadscreen = false)
    options = []
    if !$game_switches[SWITCH_DURING_INTRO]
      options << SliderOption.new(_INTL("Degré d'aléatoire"), 25, 500, 5,
                                  proc { $game_variables[VAR_RANDOMIZER_TRAINER_BST] },
                                  proc { |value|
                                    $game_variables[VAR_RANDOMIZER_TRAINER_BST] = value
                                  })
    end
    options << EnumOption.new(_INTL("Sprites Personnalisés Uniquement"), [_INTL("On"), _INTL("Off")],
                              proc { $game_switches[SWITCH_RANDOM_GYM_CUSTOMS] ? 0 : 1 },
                              proc { |value|
                                $game_switches[SWITCH_RANDOM_GYM_CUSTOMS] = value == 0
                              }, ["Utilisez uniquement des Pokémon qui ont des sprites personnalisés dans les équipes de dresseurs/champion d'arène",
                                  "Choisissez n'importe quelle fusion possible, y compris les sprites générés automatiquement."]
    )
    options << EnumOption.new(_INTL("Types de Champion"), [_INTL("On"), _INTL("Off")],
                              proc { $game_switches[RANDOM_GYM_TYPES] ? 0 : 1 },
                              proc { |value|
                                $game_switches[RANDOM_GYM_TYPES] = value == 0
                              }, "Mélangez les types de Champion"
    )

    # options << EnumOption.new(_INTL("Allow legendaries"), [_INTL("On"), _INTL("Off")],
    #                           proc { $game_switches[SWITCH_RANDOM_GYM_LEGENDARIES] ? 0 : 1 },
    #                           proc { |value|
    #                             $game_switches[SWITCH_RANDOM_GYM_LEGENDARIES] = value == 0
    #                           }, "Regular Pokémon can also be randomized into legendaries"
    # )

    options << EnumOption.new(_INTL("Re-randomiser chaque combat"), [_INTL("On"), _INTL("Off")],
                              proc { $game_switches[SWITCH_GYM_RANDOM_EACH_BATTLE] ? 0 : 1 },
                              proc { |value|
                                $game_switches[SWITCH_GYM_RANDOM_EACH_BATTLE] = value == 0
                                $game_switches[SWITCH_RANDOM_GYM_PERSIST_TEAMS] = !$game_switches[SWITCH_GYM_RANDOM_EACH_BATTLE]
                              }, "Les dresseurs et les champion ont une nouvelle équipe à chaque essai au lieu de garder la même"
    )

    return options
  end
end

class RandomizerItemOptionsScene < PokemonOption_Scene
  RANDOM_HELD_ITEMS = 843

  def initialize
    @changedColor = false
  end

  def pbStartScene(inloadscreen = false)
    super
    @sprites["option"].nameBaseColor = MessageConfig::BLUE_TEXT_MAIN_COLOR
    @sprites["option"].nameShadowColor = MessageConfig::BLUE_TEXT_SHADOW_COLOR
    @changedColor = true
    for i in 0...@PokemonOptions.length
      @sprites["option"][i] = (@PokemonOptions[i].get || 0)
    end
    @sprites["title"] = Window_UnformattedTextPokemon.newWithSize(
      _INTL("Paramètres du Randomizer:Objet"), 0, 0, Graphics.width, 64, @viewport)
    @sprites["textbox"].text = _INTL("Définir les paramètres de randomisation pour les objets")

    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbFadeInAndShow(sprites, visiblesprites = nil)
    return if !@changedColor
    super
  end

  def pbGetOptions(inloadscreen = false)
    options = [
      EnumOption.new(_INTL("Objets trouvés"), [_INTL("On"), _INTL("Off")],
                     proc { $game_switches[SWITCH_RANDOM_FOUND_ITEMS] ? 0 : 1 },
                     proc { |value|
                       $game_switches[SWITCH_RANDOM_FOUND_ITEMS] = value == 0
                       $game_switches[SWITCH_RANDOM_ITEMS_MAPPED] = value == 0
                       $game_switches[SWITCH_RANDOM_ITEMS] = $game_switches[SWITCH_RANDOM_FOUND_ITEMS] || $game_switches[SWITCH_RANDOM_GIVEN_ITEMS]
                     }, "Randomiser les objets ramassés au sol"
      ),
      EnumOption.new(_INTL("CT trouvées"), [_INTL("On"), _INTL("Off")],
                     proc { $game_switches[SWITCH_RANDOM_FOUND_TMS] ? 0 : 1 },
                     proc { |value|
                       $game_switches[SWITCH_RANDOM_FOUND_TMS] = value == 0
                       $game_switches[SWITCH_RANDOM_TMS] = $game_switches[SWITCH_RANDOM_FOUND_TMS] || $game_switches[SWITCH_RANDOM_GIVEN_TMS]
                     }, "Randomiser les CT ramassées au sol"
      ),
      EnumOption.new(_INTL("Objets donnés"), [_INTL("On"), _INTL("Off")],
                     proc { $game_switches[SWITCH_RANDOM_GIVEN_ITEMS] ? 0 : 1 },
                     proc { |value|
                       $game_switches[SWITCH_RANDOM_GIVEN_ITEMS] = value == 0
                       $game_switches[SWITCH_RANDOM_ITEMS] = $game_switches[SWITCH_RANDOM_FOUND_ITEMS] || $game_switches[SWITCH_RANDOM_GIVEN_ITEMS]
                     }, "Randomiser les objets donnés par les PNJ (peut rendre certaines quêtes impossibles à terminer)"
      ),
      EnumOption.new(_INTL("CT donnés"), [_INTL("On"), _INTL("Off")],
                     proc { $game_switches[SWITCH_RANDOM_GIVEN_TMS] ? 0 : 1 },
                     proc { |value|
                       $game_switches[SWITCH_RANDOM_GIVEN_TMS] = value == 0
                       $game_switches[SWITCH_RANDOM_TMS] = $game_switches[SWITCH_RANDOM_FOUND_TMS] || $game_switches[SWITCH_RANDOM_GIVEN_TMS]
                     }, "Randomiser les CT données par les PNJ"
      ),

      EnumOption.new(_INTL("Objets de la boutique"), [_INTL("On"), _INTL("Off")],
                     proc { $game_switches[SWITCH_RANDOM_SHOP_ITEMS] ? 0 : 1 },
                     proc { |value|
                       $game_switches[SWITCH_RANDOM_SHOP_ITEMS] = value == 0
                     }, "Randomise les articles disponibles dans les magasins (toujours mappés)"
      ),

      EnumOption.new(_INTL("Objets détenus par les Dresseurs"), [_INTL("On"), _INTL("Off")],
                     proc { $game_switches[RANDOM_HELD_ITEMS] ? 0 : 1 },
                     proc { |value|
                       $game_switches[RANDOM_HELD_ITEMS] = value == 0
                     }, "Donnez des objets aléatoires à tous les Dresseurs"
      )
    ]
    return options
  end
end

class RandomizerItemOptionsScene < PokemonOption_Scene
  RANDOM_HELD_ITEMS = 843

  def initialize
    @changedColor = false
  end

  def pbStartScene(inloadscreen = false)
    super
    @sprites["option"].nameBaseColor = MessageConfig::BLUE_TEXT_MAIN_COLOR
    @sprites["option"].nameShadowColor = MessageConfig::BLUE_TEXT_SHADOW_COLOR
    @changedColor = true
    for i in 0...@PokemonOptions.length
      @sprites["option"][i] = (@PokemonOptions[i].get || 0)
    end
    @sprites["title"] = Window_UnformattedTextPokemon.newWithSize(
      _INTL("Paramètres du Randomizer: Objet"), 0, 0, Graphics.width, 64, @viewport)
    @sprites["textbox"].text = _INTL("Définir les paramètres de randomisation pour les objets")

    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbFadeInAndShow(sprites, visiblesprites = nil)
    return if !@changedColor
    super
  end

  def pbGetOptions(inloadscreen = false)
    options = [
      EnumOption.new(_INTL("Objets trouvés"), [_INTL("On"), _INTL("Off")],
                     proc { $game_switches[SWITCH_RANDOM_FOUND_ITEMS] ? 0 : 1 },
                     proc { |value|
                       $game_switches[SWITCH_RANDOM_FOUND_ITEMS] = value == 0
                       $game_switches[SWITCH_RANDOM_ITEMS_MAPPED] = value == 0
                       $game_switches[SWITCH_RANDOM_ITEMS] = $game_switches[SWITCH_RANDOM_FOUND_ITEMS] || $game_switches[SWITCH_RANDOM_GIVEN_ITEMS]
                     }, "Randomiser les objets ramassés au sol"
      ),
      EnumOption.new(_INTL("CT trouvées"), [_INTL("On"), _INTL("Off")],
                     proc { $game_switches[SWITCH_RANDOM_FOUND_TMS] ? 0 : 1 },
                     proc { |value|
                       $game_switches[SWITCH_RANDOM_FOUND_TMS] = value == 0
                       $game_switches[SWITCH_RANDOM_TMS] = $game_switches[SWITCH_RANDOM_FOUND_TMS] || $game_switches[SWITCH_RANDOM_GIVEN_TMS]
                     }, "Randomiser les CT ramassées au sol"
      ),
      EnumOption.new(_INTL("CT trouvées"), [_INTL("On"), _INTL("Off")],
                     proc { $game_switches[SWITCH_RANDOM_GIVEN_ITEMS] ? 0 : 1 },
                     proc { |value|
                       $game_switches[SWITCH_RANDOM_GIVEN_ITEMS] = value == 0
                       $game_switches[SWITCH_RANDOM_ITEMS] = $game_switches[SWITCH_RANDOM_FOUND_ITEMS] || $game_switches[SWITCH_RANDOM_GIVEN_ITEMS]
                     }, "Randomiser les objets donnés par les PNJ (peut rendre certaines quêtes impossibles à terminer)"
      ),
      EnumOption.new(_INTL("CT donnés"), [_INTL("On"), _INTL("Off")],
                     proc { $game_switches[SWITCH_RANDOM_GIVEN_TMS] ? 0 : 1 },
                     proc { |value|
                       $game_switches[SWITCH_RANDOM_GIVEN_TMS] = value == 0
                       $game_switches[SWITCH_RANDOM_TMS] = $game_switches[SWITCH_RANDOM_FOUND_TMS] || $game_switches[SWITCH_RANDOM_GIVEN_TMS]
                     }, "Randomiser les CT données par les PNJ"
      ),

      EnumOption.new(_INTL("Objets de la boutique"), [_INTL("On"), _INTL("Off")],
                     proc { $game_switches[SWITCH_RANDOM_SHOP_ITEMS] ? 0 : 1 },
                     proc { |value|
                       $game_switches[SWITCH_RANDOM_SHOP_ITEMS] = value == 0
                     }, "Randomise les articles disponibles dans les magasins (toujours mappés)"
      ),

      EnumOption.new(_INTL("Objets détenus par les Dresseurs"), [_INTL("On"), _INTL("Off")],
                     proc { $game_switches[RANDOM_HELD_ITEMS] ? 0 : 1 },
                     proc { |value|
                       $game_switches[RANDOM_HELD_ITEMS] = value == 0
                     }, "Donnez des objets aléatoires à tous les Dresseurs"
      )
    ]
    return options
  end
end