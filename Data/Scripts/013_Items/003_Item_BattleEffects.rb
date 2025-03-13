#===============================================================================
# CanUseInBattle handlers
#===============================================================================
ItemHandlers::CanUseInBattle.add(:GUARDSPEC,proc { |item,pokemon,battler,move,firstAction,battle,scene,showMessages|
  if !battler || battler.pbOwnSide.effects[PBEffects::Mist]>0
    scene.pbDisplay(_INTL("Cela n'aura aucun effet.")) if showMessages
    next false
  end
  next true
})

ItemHandlers::CanUseInBattle.add(:POKEDOLL,proc { |item,pokemon,battler,move,firstAction,battle,scene,showMessages|
  if !battle.wildBattle?
    if showMessages
      scene.pbDisplay(_INTL("Les mots de Oak ont fait écho... Il y a un temps et un lieu pour tout! Mais pas maintenant."))
    end
    next false
  end
  if !battle.canRun
    scene.pbDisplay(_INTL("Tu ne peux pas t'échapper!")) if showMessages
    next false
  end
  next true
})

ItemHandlers::CanUseInBattle.copy(:POKEDOLL,:FLUFFYTAIL,:POKETOY)

ItemHandlers::CanUseInBattle.addIf(proc { |item| GameData::Item.get(item).is_poke_ball? },   # Poké Balls
  proc { |item,pokemon,battler,move,firstAction,battle,scene,showMessages|
    if battle.pbPlayer.party_full? && $PokemonStorage.full?
      scene.pbDisplay(_INTL("Il n'y a plus de place dans le PC!")) if showMessages
      next false
    end
    # NOTE: Using a Poké Ball consumes all your actions for the round. The code
    #       below is one half of making this happen; the other half is in def
    #       pbItemUsesAllActions?.
    if !firstAction
      scene.pbDisplay(_INTL("Il est impossible de viser sans être concentré!")) if showMessages
      next false
    end
    if battler.semiInvulnerable?
      scene.pbDisplay(_INTL("Ce n'est pas bon! Il est impossible de viser un Pokémon qui n'est pas en vue!")) if showMessages
      next false
    end

    if $game_switches[SWITCH_SILVERBOSS_BATTLE]
      scene.pbDisplay(_INTL("Ce n'est pas bon! C'est trop agité pour viser!")) if showMessages
      next false
    end


      # NOTE: The code below stops you from throwing a Poké Ball if there is more
    #       than one unfainted opposing Pokémon. (Snag Balls can be thrown in
    #       this case, but only in trainer battles, and the trainer will deflect
    #       them if they are trying to catch a non-Shadow Pokémon.)
    if battle.pbOpposingBattlerCount>1 && !(GameData::Item.get(item).is_snag_ball? && battle.trainerBattle?)
      if battle.pbOpposingBattlerCount==2
        if $game_switches[SWITCH_SILVERBOSS_BATTLE]
          scene.pbDisplay(_INTL("Ce n'est pas bon! Il est encore trop agité pour viser!")) if showMessages
        else
          scene.pbDisplay(_INTL("C'est pas bon! C'est impossible de viser quand il y a deux Pokémon!")) if showMessages
        end
      else
        if $game_switches[SWITCH_SILVERBOSS_BATTLE]
          scene.pbDisplay(_INTL("Ce n'est pas bon! C'est encore trop agité pour viser!")) if showMessages
        else
          scene.pbDisplay(_INTL("Ce n'est pas bon! Il est impossible de viser quand il y a plus d'un Pokémon!")) if showMessages
        end
      end
      next false
    end
    next true
  }
)

ItemHandlers::CanUseInBattle.add(:POTION,proc { |item,pokemon,battler,move,firstAction,battle,scene,showMessages|
  if !pokemon.able? || pokemon.hp==pokemon.totalhp
    scene.pbDisplay(_INTL("Cela n'aura aucun effet.")) if showMessages
    next false
  end
  next true
})

ItemHandlers::CanUseInBattle.copy(:POTION,
   :SUPERPOTION,:HYPERPOTION,:MAXPOTION,:BERRYJUICE,:SWEETHEART,:FRESHWATER,
   :SODAPOP,:LEMONADE,:MOOMOOMILK,:ORANBERRY,:SITRUSBERRY,:ENERGYPOWDER,
   :ENERGYROOT, :POISONMUSHROOM)
ItemHandlers::CanUseInBattle.copy(:POTION,:RAGECANDYBAR) if !Settings::RAGE_CANDY_BAR_CURES_STATUS_PROBLEMS

ItemHandlers::CanUseInBattle.add(:AWAKENING,proc { |item,pokemon,battler,move,firstAction,battle,scene,showMessages|
  next pbBattleItemCanCureStatus?(:SLEEP, pokemon, scene, showMessages)
})

ItemHandlers::CanUseInBattle.copy(:AWAKENING,:CHESTOBERRY)

ItemHandlers::CanUseInBattle.add(:BLUEFLUTE,proc { |item,pokemon,battler,move,firstAction,battle,scene,showMessages|
  if battler && battler.hasActiveAbility?(:SOUNDPROOF)
    scene.pbDisplay(_INTL("Cela n'aura aucun effet.")) if showMessages
    next false
  end
  next pbBattleItemCanCureStatus?(:SLEEP, pokemon, scene, showMessages)
})

ItemHandlers::CanUseInBattle.add(:ANTIDOTE,proc { |item,pokemon,battler,move,firstAction,battle,scene,showMessages|
  next pbBattleItemCanCureStatus?(:POISON, pokemon, scene, showMessages)
})

ItemHandlers::CanUseInBattle.copy(:ANTIDOTE,:PECHABERRY)

ItemHandlers::CanUseInBattle.add(:BURNHEAL,proc { |item,pokemon,battler,move,firstAction,battle,scene,showMessages|
  next pbBattleItemCanCureStatus?(:BURN, pokemon, scene, showMessages)
})

ItemHandlers::CanUseInBattle.copy(:BURNHEAL,:RAWSTBERRY)

ItemHandlers::CanUseInBattle.add(:PARALYZEHEAL,proc { |item,pokemon,battler,move,firstAction,battle,scene,showMessages|
  next pbBattleItemCanCureStatus?(:PARALYSIS, pokemon, scene, showMessages)
})

ItemHandlers::CanUseInBattle.copy(:PARALYZEHEAL,:PARLYZHEAL,:CHERIBERRY)

ItemHandlers::CanUseInBattle.add(:ICEHEAL,proc { |item,pokemon,battler,move,firstAction,battle,scene,showMessages|
  next pbBattleItemCanCureStatus?(:FROZEN, pokemon, scene, showMessages)
})

ItemHandlers::CanUseInBattle.copy(:ICEHEAL,:ASPEARBERRY)

ItemHandlers::CanUseInBattle.add(:FULLHEAL,proc { |item,pokemon,battler,move,firstAction,battle,scene,showMessages|
  if !pokemon.able? ||
     (pokemon.status == :NONE &&
     (!battler || battler.effects[PBEffects::Confusion]==0))
    scene.pbDisplay(_INTL("Cela n'aura aucun effet.")) if showMessages
    next false
  end
  next true
})

ItemHandlers::CanUseInBattle.copy(:FULLHEAL,
   :LAVACOOKIE,:OLDGATEAU,:CASTELIACONE,:LUMIOSEGALETTE,:SHALOURSABLE,
   :BIGMALASADA,:LUMBERRY,:HEALPOWDER)
ItemHandlers::CanUseInBattle.copy(:FULLHEAL,:RAGECANDYBAR) if Settings::RAGE_CANDY_BAR_CURES_STATUS_PROBLEMS

ItemHandlers::CanUseInBattle.add(:FULLRESTORE,proc { |item,pokemon,battler,move,firstAction,battle,scene,showMessages|
  if !pokemon.able? ||
     (pokemon.hp == pokemon.totalhp && pokemon.status == :NONE &&
     (!battler || battler.effects[PBEffects::Confusion]==0))
    scene.pbDisplay(_INTL("Cela n'aura aucun effet.")) if showMessages
    next false
  end
  next true
})

ItemHandlers::CanUseInBattle.add(:REVIVE,proc { |item,pokemon,battler,move,firstAction,battle,scene,showMessages|
  if pokemon.able? || pokemon.egg?
    scene.pbDisplay(_INTL("Cela n'aura aucun effet.")) if showMessages
    next false
  end
  next true
})

ItemHandlers::CanUseInBattle.copy(:REVIVE,:MAXREVIVE,:REVIVALHERB)

ItemHandlers::CanUseInBattle.add(:ETHER,proc { |item,pokemon,battler,move,firstAction,battle,scene,showMessages|
  if !pokemon.able? || move<0 ||
     pokemon.moves[move].total_pp<=0 ||
     pokemon.moves[move].pp==pokemon.moves[move].total_pp
    scene.pbDisplay(_INTL("Cela n'aura aucun effet.")) if showMessages
    next false
  end
  next true
})

ItemHandlers::CanUseInBattle.copy(:ETHER,:MAXETHER,:LEPPABERRY)

ItemHandlers::CanUseInBattle.add(:ELIXIR,proc { |item,pokemon,battler,move,firstAction,battle,scene,showMessages|
  if !pokemon.able?
    scene.pbDisplay(_INTL("Cela n'aura aucun effet.")) if showMessages
    next false
  end
  canRestore = false
  for m in pokemon.moves
    next if m.id==0
    next if m.total_pp<=0 || m.pp==m.total_pp
    canRestore = true
    break
  end
  if !canRestore
    scene.pbDisplay(_INTL("Cela n'aura aucun effet.")) if showMessages
    next false
  end
  next true
})

ItemHandlers::CanUseInBattle.copy(:ELIXIR,:MAXELIXIR)

ItemHandlers::CanUseInBattle.add(:REDFLUTE,proc { |item,pokemon,battler,move,firstAction,battle,scene,showMessages|
  if !battler || battler.effects[PBEffects::Attract]<0 ||
     battler.hasActiveAbility?(:SOUNDPROOF)
    scene.pbDisplay(_INTL("Cela n'aura aucun effet.")) if showMessages
    next false
  end
  next true
})

ItemHandlers::CanUseInBattle.add(:PERSIMBERRY,proc { |item,pokemon,battler,move,firstAction,battle,scene,showMessages|
  if !battler || battler.effects[PBEffects::Confusion]==0
    scene.pbDisplay(_INTL("Cela n'aura aucun effet.")) if showMessages
    next false
  end
  next true
})

ItemHandlers::CanUseInBattle.add(:YELLOWFLUTE,proc { |item,pokemon,battler,move,firstAction,battle,scene,showMessages|
  if !battler || battler.effects[PBEffects::Confusion]==0 ||
     battler.hasActiveAbility?(:SOUNDPROOF)
    scene.pbDisplay(_INTL("Cela n'aura aucun effet.")) if showMessages
    next false
  end
  next true
})

ItemHandlers::CanUseInBattle.add(:XATTACK,proc { |item,pokemon,battler,move,firstAction,battle,scene,showMessages|
  next pbBattleItemCanRaiseStat?(:ATTACK,battler,scene,showMessages)
})

ItemHandlers::CanUseInBattle.copy(:XATTACK,:XATTACK2,:XATTACK3,:XATTACK6)

ItemHandlers::CanUseInBattle.add(:XDEFENSE,proc { |item,pokemon,battler,move,firstAction,battle,scene,showMessages|
  next pbBattleItemCanRaiseStat?(:DEFENSE,battler,scene,showMessages)
})

ItemHandlers::CanUseInBattle.copy(:XDEFENSE,
   :XDEFENSE2,:XDEFENSE3,:XDEFENSE6,:XDEFEND,:XDEFEND2,:XDEFEND3,:XDEFEND6)

ItemHandlers::CanUseInBattle.add(:XSPATK,proc { |item,pokemon,battler,move,firstAction,battle,scene,showMessages|
  next pbBattleItemCanRaiseStat?(:SPECIAL_ATTACK,battler,scene,showMessages)
})

ItemHandlers::CanUseInBattle.copy(:XSPATK,
   :XSPATK2,:XSPATK3,:XSPATK6,:XSPECIAL,:XSPECIAL2,:XSPECIAL3,:XSPECIAL6)

ItemHandlers::CanUseInBattle.add(:XSPDEF,proc { |item,pokemon,battler,move,firstAction,battle,scene,showMessages|
  next pbBattleItemCanRaiseStat?(:SPECIAL_DEFENSE,battler,scene,showMessages)
})

ItemHandlers::CanUseInBattle.copy(:XSPDEF,:XSPDEF2,:XSPDEF3,:XSPDEF6)

ItemHandlers::CanUseInBattle.add(:XSPEED,proc { |item,pokemon,battler,move,firstAction,battle,scene,showMessages|
  next pbBattleItemCanRaiseStat?(:SPEED,battler,scene,showMessages)
})

ItemHandlers::CanUseInBattle.copy(:XSPEED,:XSPEED2,:XSPEED3,:XSPEED6)

ItemHandlers::CanUseInBattle.add(:XACCURACY,proc { |item,pokemon,battler,move,firstAction,battle,scene,showMessages|
  next pbBattleItemCanRaiseStat?(:ACCURACY,battler,scene,showMessages)
})

ItemHandlers::CanUseInBattle.copy(:XACCURACY,:XACCURACY2,:XACCURACY3,:XACCURACY6)

ItemHandlers::CanUseInBattle.add(:DIREHIT,proc { |item,pokemon,battler,move,firstAction,battle,scene,showMessages|
  if !battler || battler.effects[PBEffects::FocusEnergy]>=1
    scene.pbDisplay(_INTL("Cela n'aura aucun effet.")) if showMessages
    next false
  end
  next true
})

ItemHandlers::CanUseInBattle.add(:DIREHIT2,proc { |item,pokemon,battler,move,firstAction,battle,scene,showMessages|
  if !battler || battler.effects[PBEffects::FocusEnergy]>=2
    scene.pbDisplay(_INTL("Cela n'aura aucun effet.")) if showMessages
    next false
  end
  next true
})

ItemHandlers::CanUseInBattle.add(:DIREHIT3,proc { |item,pokemon,battler,move,firstAction,battle,scene,showMessages|
  if !battler || battler.effects[PBEffects::FocusEnergy]>=3
    scene.pbDisplay(_INTL("Cela n'aura aucun effet.")) if showMessages
    next false
  end
  next true
})

ItemHandlers::CanUseInBattle.add(:POKEFLUTE,proc { |item,pokemon,battler,move,firstAction,battle,scene,showMessages|
  anyAsleep = false
  battle.eachBattler do |b|
    next if b.status != :SLEEP || b.hasActiveAbility?(:SOUNDPROOF)
    anyAsleep = true
    break
  end
  if !anyAsleep
    scene.pbDisplay(_INTL("Cela n'aura aucun effet.")) if showMessages
    next false
  end
  next true
})

#===============================================================================
# UseInBattle handlers
# For items used directly or on an opposing battler
#===============================================================================
ItemHandlers::UseInBattle.add(:GUARDSPEC,proc { |item,battler,battle|
  battler.pbOwnSide.effects[PBEffects::Mist] = 5
  battle.pbDisplay(_INTL("{1} est devenu enveloppé de brume!",battler.pbTeam))
  battler.pokemon.changeHappiness("battleitem")
})

ItemHandlers::UseInBattle.add(:POKEDOLL,proc { |item,battler,battle|
  battle.decision = 3
  battle.pbDisplayPaused(_INTL("Tu t'en es sorti sain et sauf!"))
})

ItemHandlers::UseInBattle.copy(:POKEDOLL,:FLUFFYTAIL,:POKETOY)

ItemHandlers::UseInBattle.add(:POKEFLUTE,proc { |item,battler,battle|
  battle.eachBattler do |b|
    next if b.status != :SLEEP || b.hasActiveAbility?(:SOUNDPROOF)
    b.pbCureStatus(false)
  end
  battle.pbDisplay(_INTL("Tous les Pokémon ont été réveillés par la mélodie !"))
})

ItemHandlers::UseInBattle.addIf(proc { |item| GameData::Item.get(item).is_poke_ball? },   # Poké Balls
  proc { |item,battler,battle|
    battle.pbThrowPokeBall(battler.index,item)
  }
)

#===============================================================================
# BattleUseOnPokemon handlers
# For items used on Pokémon or on a Pokémon's move
#===============================================================================
ItemHandlers::BattleUseOnPokemon.add(:POTION,proc { |item,pokemon,battler,choices,scene|
  pbBattleHPItem(pokemon,battler,20,scene)
})

ItemHandlers::BattleUseOnPokemon.copy(:POTION,:BERRYJUICE,:SWEETHEART)
ItemHandlers::BattleUseOnPokemon.copy(:POTION,:RAGECANDYBAR) if !Settings::RAGE_CANDY_BAR_CURES_STATUS_PROBLEMS

ItemHandlers::BattleUseOnPokemon.add(:SUPERPOTION,proc { |item,pokemon,battler,choices,scene|
  pbBattleHPItem(pokemon,battler,50,scene)
})

ItemHandlers::BattleUseOnPokemon.add(:HYPERPOTION,proc { |item,pokemon,battler,choices,scene|
  pbBattleHPItem(pokemon,battler,200,scene)
})

ItemHandlers::BattleUseOnPokemon.add(:MAXPOTION,proc { |item,pokemon,battler,choices,scene|
  pbBattleHPItem(pokemon,battler,pokemon.totalhp-pokemon.hp,scene)
})

ItemHandlers::BattleUseOnPokemon.add(:FRESHWATER,proc { |item,pokemon,battler,choices,scene|
  pbBattleHPItem(pokemon,battler,50,scene)
})

ItemHandlers::BattleUseOnPokemon.add(:SODAPOP,proc { |item,pokemon,battler,choices,scene|
  pbBattleHPItem(pokemon,battler,60,scene)
})

ItemHandlers::BattleUseOnPokemon.add(:LEMONADE,proc { |item,pokemon,battler,choices,scene|
  pbBattleHPItem(pokemon,battler,80,scene)
})

ItemHandlers::BattleUseOnPokemon.add(:MOOMOOMILK,proc { |item,pokemon,battler,choices,scene|
  pbBattleHPItem(pokemon,battler,100,scene)
})

ItemHandlers::BattleUseOnPokemon.add(:ORANBERRY,proc { |item,pokemon,battler,choices,scene|
  pbBattleHPItem(pokemon,battler,10,scene)
})

ItemHandlers::BattleUseOnPokemon.add(:SITRUSBERRY,proc { |item,pokemon,battler,choices,scene|
  pbBattleHPItem(pokemon,battler,pokemon.totalhp/4,scene)
})

ItemHandlers::BattleUseOnPokemon.add(:AWAKENING,proc { |item,pokemon,battler,choices,scene|
  pokemon.heal_status
  battler.pbCureStatus(false) if battler
  name = (battler) ? battler.pbThis : pokemon.name
  scene.pbRefresh
  scene.pbDisplay(_INTL("{1} s'est réveillé.",name))
})

ItemHandlers::BattleUseOnPokemon.copy(:AWAKENING,:CHESTOBERRY,:BLUEFLUTE)

ItemHandlers::BattleUseOnPokemon.add(:ANTIDOTE,proc { |item,pokemon,battler,choices,scene|
  pokemon.heal_status
  battler.pbCureStatus(false) if battler
  name = (battler) ? battler.pbThis : pokemon.name
  scene.pbRefresh
  scene.pbDisplay(_INTL("{1} a été guéri de son empoisonnement.",name))
})

ItemHandlers::BattleUseOnPokemon.copy(:ANTIDOTE,:PECHABERRY)

ItemHandlers::BattleUseOnPokemon.add(:BURNHEAL,proc { |item,pokemon,battler,choices,scene|
  pokemon.heal_status
  battler.pbCureStatus(false) if battler
  name = (battler) ? battler.pbThis : pokemon.name
  scene.pbRefresh
  scene.pbDisplay(_INTL("La brûlure de {1} a été guérie.",name))
})

ItemHandlers::BattleUseOnPokemon.copy(:BURNHEAL,:RAWSTBERRY)

ItemHandlers::BattleUseOnPokemon.add(:PARALYZEHEAL,proc { |item,pokemon,battler,choices,scene|
  pokemon.heal_status
  battler.pbCureStatus(false) if battler
  name = (battler) ? battler.pbThis : pokemon.name
  scene.pbRefresh
  scene.pbDisplay(_INTL("{1} a été guéri de la paralysie.",name))
})

ItemHandlers::BattleUseOnPokemon.copy(:PARALYZEHEAL,:PARLYZHEAL,:CHERIBERRY)

ItemHandlers::BattleUseOnPokemon.add(:ICEHEAL,proc { |item,pokemon,battler,choices,scene|
  pokemon.heal_status
  battler.pbCureStatus(false) if battler
  name = (battler) ? battler.pbThis : pokemon.name
  scene.pbRefresh
  scene.pbDisplay(_INTL("{1} a été décongelé.",name))
})

ItemHandlers::BattleUseOnPokemon.copy(:ICEHEAL,:ASPEARBERRY)

ItemHandlers::BattleUseOnPokemon.add(:FULLHEAL,proc { |item,pokemon,battler,choices,scene|
  pokemon.heal_status
  battler.pbCureStatus(false) if battler
  battler.pbCureConfusion if battler
  name = (battler) ? battler.pbThis : pokemon.name
  scene.pbRefresh
  scene.pbDisplay(_INTL("{1} est en bonne santé.",name))
})

ItemHandlers::BattleUseOnPokemon.copy(:FULLHEAL,
   :LAVACOOKIE,:OLDGATEAU,:CASTELIACONE,:LUMIOSEGALETTE,:SHALOURSABLE,
   :BIGMALASADA,:LUMBERRY)
ItemHandlers::BattleUseOnPokemon.copy(:FULLHEAL,:RAGECANDYBAR) if Settings::RAGE_CANDY_BAR_CURES_STATUS_PROBLEMS

ItemHandlers::BattleUseOnPokemon.add(:FULLRESTORE,proc { |item,pokemon,battler,choices,scene|
  pokemon.heal_status
  battler.pbCureStatus(false) if battler
  battler.pbCureConfusion if battler
  name = (battler) ? battler.pbThis : pokemon.name
  if pokemon.hp<pokemon.totalhp
    pbBattleHPItem(pokemon,battler,pokemon.totalhp,scene)
  else
    scene.pbRefresh
    scene.pbDisplay(_INTL("{1} est en bonne santé.",name))
  end
})

ItemHandlers::BattleUseOnPokemon.add(:REVIVE,proc { |item,pokemon,battler,choices,scene|
  pokemon.hp = pokemon.totalhp/2
  pokemon.hp = 1 if pokemon.hp<=0
  pokemon.heal_status
  scene.pbRefresh
  scene.pbDisplay(_INTL("{1} s'est remis de son évanouissement!",pokemon.name))
})

ItemHandlers::BattleUseOnPokemon.add(:MAXREVIVE,proc { |item,pokemon,battler,choices,scene|
  pokemon.heal_HP
  pokemon.heal_status
  scene.pbRefresh
  scene.pbDisplay(_INTL("{1} s'est remis de son évanouissement!",pokemon.name))
})

ItemHandlers::BattleUseOnPokemon.add(:ENERGYPOWDER,proc { |item,pokemon,battler,choices,scene|
  if pbBattleHPItem(pokemon,battler,50,scene)
    pokemon.changeHappiness("powder")
  end
})

ItemHandlers::BattleUseOnPokemon.add(:ENERGYROOT,proc { |item,pokemon,battler,choices,scene|
  if pbBattleHPItem(pokemon,battler,200,scene)
    pokemon.changeHappiness("energyroot")
  end
})

ItemHandlers::BattleUseOnPokemon.add(:HEALPOWDER,proc { |item,pokemon,battler,choices,scene|
  pokemon.heal_status
  battler.pbCureStatus(false) if battler
  battler.pbCureConfusion if battler
  pokemon.changeHappiness("powder")
  name = (battler) ? battler.pbThis : pokemon.name
  scene.pbRefresh
  scene.pbDisplay(_INTL("{1} est en bonne santé.",name))
})

ItemHandlers::BattleUseOnPokemon.add(:REVIVALHERB,proc { |item,pokemon,battler,choices,scene|
  pokemon.heal_HP
  pokemon.heal_status
  pokemon.changeHappiness("revivalherb")
  scene.pbRefresh
  scene.pbDisplay(_INTL("{1} s'est remis de son évanouissement!",pokemon.name))
})

ItemHandlers::BattleUseOnPokemon.add(:ETHER,proc { |item,pokemon,battler,choices,scene|
  idxMove = choices[3]
  pbBattleRestorePP(pokemon,battler,idxMove,10)
  scene.pbDisplay(_INTL("Les PP a été restauré."))
})

ItemHandlers::BattleUseOnPokemon.copy(:ETHER,:LEPPABERRY)

ItemHandlers::BattleUseOnPokemon.add(:MAXETHER,proc { |item,pokemon,battler,choices,scene|
  idxMove = choices[3]
  pbBattleRestorePP(pokemon,battler,idxMove,pokemon.moves[idxMove].total_pp)
  scene.pbDisplay(_INTL("Les PP a été restauré."))
})

ItemHandlers::BattleUseOnPokemon.add(:ELIXIR,proc { |item,pokemon,battler,choices,scene|
  for i in 0...pokemon.moves.length
    pbBattleRestorePP(pokemon,battler,i,10)
  end
  scene.pbDisplay(_INTL("Les PP a été restauré."))
})

ItemHandlers::BattleUseOnPokemon.add(:MAXELIXIR,proc { |item,pokemon,battler,choices,scene|
  for i in 0...pokemon.moves.length
    pbBattleRestorePP(pokemon,battler,i,pokemon.moves[i].total_pp)
  end
  scene.pbDisplay(_INTL("Les PP a été restauré."))
})

#===============================================================================
# BattleUseOnBattler handlers
# For items used on a Pokémon in battle
#===============================================================================

ItemHandlers::BattleUseOnBattler.add(:REDFLUTE,proc { |item,battler,scene|
  battler.pbCureAttract
  scene.pbDisplay(_INTL("{1} a surmonté son engouement.",battler.pbThis))
})

ItemHandlers::BattleUseOnBattler.add(:YELLOWFLUTE,proc { |item,battler,scene|
  battler.pbCureConfusion
  scene.pbDisplay(_INTL("{1} sort de sa confusion.",battler.pbThis))
})

ItemHandlers::BattleUseOnBattler.copy(:YELLOWFLUTE,:PERSIMBERRY)

ItemHandlers::BattleUseOnBattler.add(:XATTACK,proc { |item,battler,scene|
  battler.pbRaiseStatStage(:ATTACK,(Settings::X_STAT_ITEMS_RAISE_BY_TWO_STAGES) ? 2 : 1,battler)
  battler.pokemon.changeHappiness("battleitem")
})

ItemHandlers::BattleUseOnBattler.add(:XATTACK2,proc { |item,battler,scene|
  battler.pbRaiseStatStage(:ATTACK,2,battler)
  battler.pokemon.changeHappiness("battleitem")
})

ItemHandlers::BattleUseOnBattler.add(:XATTACK3,proc { |item,battler,scene|
  battler.pbRaiseStatStage(:ATTACK,3,battler)
  battler.pokemon.changeHappiness("battleitem")
})

ItemHandlers::BattleUseOnBattler.add(:XATTACK6,proc { |item,battler,scene|
  battler.pbRaiseStatStage(:ATTACK,6,battler)
  battler.pokemon.changeHappiness("battleitem")
})

ItemHandlers::BattleUseOnBattler.add(:XDEFENSE,proc { |item,battler,scene|
  battler.pbRaiseStatStage(:DEFENSE,(Settings::X_STAT_ITEMS_RAISE_BY_TWO_STAGES) ? 2 : 1,battler)
  battler.pokemon.changeHappiness("battleitem")
})

ItemHandlers::BattleUseOnBattler.copy(:XDEFENSE,:XDEFEND)

ItemHandlers::BattleUseOnBattler.add(:XDEFENSE2,proc { |item,battler,scene|
  battler.pbRaiseStatStage(:DEFENSE,2,battler)
  battler.pokemon.changeHappiness("battleitem")
})

ItemHandlers::BattleUseOnBattler.copy(:XDEFENSE2,:XDEFEND2)

ItemHandlers::BattleUseOnBattler.add(:XDEFENSE3,proc { |item,battler,scene|
  battler.pbRaiseStatStage(:DEFENSE,3,battler)
  battler.pokemon.changeHappiness("battleitem")
})

ItemHandlers::BattleUseOnBattler.copy(:XDEFENSE3,:XDEFEND3)

ItemHandlers::BattleUseOnBattler.add(:XDEFENSE6,proc { |item,battler,scene|
  battler.pbRaiseStatStage(:DEFENSE,6,battler)
  battler.pokemon.changeHappiness("battleitem")
})

ItemHandlers::BattleUseOnBattler.copy(:XDEFENSE6,:XDEFEND6)

ItemHandlers::BattleUseOnBattler.add(:XSPATK,proc { |item,battler,scene|
  battler.pbRaiseStatStage(:SPECIAL_ATTACK,(Settings::X_STAT_ITEMS_RAISE_BY_TWO_STAGES) ? 2 : 1,battler)
  battler.pokemon.changeHappiness("battleitem")
})

ItemHandlers::BattleUseOnBattler.copy(:XSPATK,:XSPECIAL)

ItemHandlers::BattleUseOnBattler.add(:XSPATK2,proc { |item,battler,scene|
  battler.pbRaiseStatStage(:SPECIAL_ATTACK,2,battler)
  battler.pokemon.changeHappiness("battleitem")
})

ItemHandlers::BattleUseOnBattler.copy(:XSPATK2,:XSPECIAL2)

ItemHandlers::BattleUseOnBattler.add(:XSPATK3,proc { |item,battler,scene|
  battler.pbRaiseStatStage(:SPECIAL_ATTACK,3,battler)
  battler.pokemon.changeHappiness("battleitem")
})

ItemHandlers::BattleUseOnBattler.copy(:XSPATK3,:XSPECIAL3)

ItemHandlers::BattleUseOnBattler.add(:XSPATK6,proc { |item,battler,scene|
  battler.pbRaiseStatStage(:SPECIAL_ATTACK,6,battler)
  battler.pokemon.changeHappiness("battleitem")
})

ItemHandlers::BattleUseOnBattler.copy(:XSPATK6,:XSPECIAL6)

ItemHandlers::BattleUseOnBattler.add(:XSPDEF,proc { |item,battler,scene|
  battler.pbRaiseStatStage(:SPECIAL_DEFENSE,(Settings::X_STAT_ITEMS_RAISE_BY_TWO_STAGES) ? 2 : 1,battler)
  battler.pokemon.changeHappiness("battleitem")
})

ItemHandlers::BattleUseOnBattler.add(:XSPDEF2,proc { |item,battler,scene|
  battler.pbRaiseStatStage(:SPECIAL_DEFENSE,2,battler)
  battler.pokemon.changeHappiness("battleitem")
})

ItemHandlers::BattleUseOnBattler.add(:XSPDEF3,proc { |item,battler,scene|
  battler.pbRaiseStatStage(:SPECIAL_DEFENSE,3,battler)
  battler.pokemon.changeHappiness("battleitem")
})

ItemHandlers::BattleUseOnBattler.add(:XSPDEF6,proc { |item,battler,scene|
  battler.pbRaiseStatStage(:SPECIAL_DEFENSE,6,battler)
  battler.pokemon.changeHappiness("battleitem")
})

ItemHandlers::BattleUseOnBattler.add(:XSPEED,proc { |item,battler,scene|
  battler.pbRaiseStatStage(:SPEED,(Settings::X_STAT_ITEMS_RAISE_BY_TWO_STAGES) ? 2 : 1,battler)
  battler.pokemon.changeHappiness("battleitem")
})

ItemHandlers::BattleUseOnBattler.add(:XSPEED2,proc { |item,battler,scene|
  battler.pbRaiseStatStage(:SPEED,2,battler)
  battler.pokemon.changeHappiness("battleitem")
})

ItemHandlers::BattleUseOnBattler.add(:XSPEED3,proc { |item,battler,scene|
  battler.pbRaiseStatStage(:SPEED,3,battler)
  battler.pokemon.changeHappiness("battleitem")
})

ItemHandlers::BattleUseOnBattler.add(:XSPEED6,proc { |item,battler,scene|
  battler.pbRaiseStatStage(:SPEED,6,battler)
  battler.pokemon.changeHappiness("battleitem")
})

ItemHandlers::BattleUseOnBattler.add(:XACCURACY,proc { |item,battler,scene|
  battler.pbRaiseStatStage(:ACCURACY,(Settings::X_STAT_ITEMS_RAISE_BY_TWO_STAGES) ? 2 : 1,battler)
  battler.pokemon.changeHappiness("battleitem")
})

ItemHandlers::BattleUseOnBattler.add(:XACCURACY2,proc { |item,battler,scene|
  battler.pbRaiseStatStage(:ACCURACY,2,battler)
  battler.pokemon.changeHappiness("battleitem")
})

ItemHandlers::BattleUseOnBattler.add(:XACCURACY3,proc { |item,battler,scene|
  battler.pbRaiseStatStage(:ACCURACY,3,battler)
  battler.pokemon.changeHappiness("battleitem")
})

ItemHandlers::BattleUseOnBattler.add(:XACCURACY6,proc { |item,battler,scene|
  battler.pbRaiseStatStage(:ACCURACY,6,battler)
  battler.pokemon.changeHappiness("battleitem")
})

ItemHandlers::BattleUseOnBattler.add(:DIREHIT,proc { |item,battler,scene|
  battler.effects[PBEffects::FocusEnergy] = 2
  scene.pbDisplay(_INTL("{1} est en train de se gonfler!",battler.pbThis))
  battler.pokemon.changeHappiness("battleitem")
})

ItemHandlers::BattleUseOnBattler.add(:DIREHIT2,proc { |item,battler,scene|
  battler.effects[PBEffects::FocusEnergy] = 2
  scene.pbDisplay(_INTL("{1} est en train de se gonfler!",battler.pbThis))
  battler.pokemon.changeHappiness("battleitem")
})

ItemHandlers::BattleUseOnBattler.add(:DIREHIT3,proc { |item,battler,scene|
  battler.effects[PBEffects::FocusEnergy] = 3
  scene.pbDisplay(_INTL("{1} est en train de se gonfler!",battler.pbThis))
  battler.pokemon.changeHappiness("battleitem")
})
