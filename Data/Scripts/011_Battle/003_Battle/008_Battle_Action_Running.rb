class PokeBattle_Battle
  #=============================================================================
  # Running from battle
  #=============================================================================
  def pbCanRun?(idxBattler)
    return false if trainerBattle?
    battler = @battlers[idxBattler]
    return false if !@canRun && !battler.opposes?
    return true if battler.pbHasType?(:GHOST) && Settings::MORE_TYPE_EFFECTS
    return true if battler.abilityActive? &&
                   BattleHandlers.triggerRunFromBattleAbility(battler.ability,battler)
    return true if battler.itemActive? &&
                   BattleHandlers.triggerRunFromBattleItem(battler.item,battler)
    return false if battler.effects[PBEffects::Trapping]>0 ||
                    battler.effects[PBEffects::MeanLook]>=0 ||
                    battler.effects[PBEffects::Ingrain] ||
                    @field.effects[PBEffects::FairyLock]>0
    eachOtherSideBattler(idxBattler) do |b|
      return false if b.abilityActive? &&
                      BattleHandlers.triggerTrappingTargetAbility(b.ability,battler,b,self)
      return false if b.itemActive? &&
                      BattleHandlers.triggerTrappingTargetItem(b.item,battler,b,self)
    end
    return true
  end

  # Return values:
  # -1: Failed fleeing
  #  0: Wasn't possible to attempt fleeing, continue choosing action for the round
  #  1: Succeeded at fleeing, battle will end
  # duringBattle is true for replacing a fainted Pokémon during the End Of Round
  # phase, and false for choosing the Run command.
  def pbRun(idxBattler,duringBattle=false)
    battler = @battlers[idxBattler]
    if battler.opposes?
      return 0 if trainerBattle?
      @choices[idxBattler][0] = :Run
      @choices[idxBattler][1] = 0
      @choices[idxBattler][2] = nil
      return -1
    end
    # Fleeing from trainer battles
    if trainerBattle?
      if $DEBUG && Input.press?(Input::CTRL)
        if pbDisplayConfirm(_INTL("Considérez cette bataille comme une victoire?"))
          @decision = 1
          return 1
        elsif pbDisplayConfirm(_INTL("Considérez cette bataille comme une perte?"))
          @decision = 2
          return 1
        end
      elsif @internalBattle
        if pbDisplayConfirm(_INTL("Souhaitez-vous abandonner le match et quitter maintenant?"))
          pbSEPlay("Battle flee")
          pbDisplay(_INTL("{1} a perdu le match!",self.pbPlayer.name))
          @decision = 2
          return 1
        end
      elsif pbDisplayConfirm(_INTL("Souhaitez-vous abandonner le match et quitter maintenant?"))
        pbSEPlay("Battle flee")
        pbDisplay(_INTL("{1} a perdu le match!",self.pbPlayer.name))
        @decision = 3
        return 1
      end
      return 0
    end
    # Fleeing from wild battles
    if $DEBUG && Input.press?(Input::CTRL)
      pbSEPlay("Battle flee")
      pbDisplayPaused(_INTL("Tu t'es enfui!"))
      @decision = 3
      return 1
    end
    if !@canRun
      pbDisplayPaused(_INTL("Tu ne peux pas t'échapper!"))
      return 0
    end
    if !duringBattle
      if battler.pbHasType?(:GHOST) && Settings::MORE_TYPE_EFFECTS
        pbSEPlay("Battle flee")
        pbDisplayPaused(_INTL("Tu t'es enfui!"))
        @decision = 3
        return 1
      end
      # Abilities that guarantee escape
      if battler.abilityActive?
        if BattleHandlers.triggerRunFromBattleAbility(battler.ability,battler)
          pbShowAbilitySplash(battler,true)
          pbHideAbilitySplash(battler)
          pbSEPlay("Battle flee")
          pbDisplayPaused(_INTL("Tu t'es enfui!"))
          @decision = 3
          return 1
        end
      end
      # Held items that guarantee escape
      if battler.itemActive?
        if BattleHandlers.triggerRunFromBattleItem(battler.item,battler)
          pbSEPlay("Battle flee")
          pbDisplayPaused(_INTL("{1} s'est enfui en utilisant {2}!",
             battler.pbThis,battler.itemName))
          @decision = 3
          return 1
        end
      end
      # Other certain trapping effects
      if battler.effects[PBEffects::Trapping]>0 ||
         battler.effects[PBEffects::MeanLook]>=0 ||
         battler.effects[PBEffects::Ingrain] ||
         @field.effects[PBEffects::FairyLock]>0
        pbDisplayPaused(_INTL("Tu ne peux pas t'échapper!"))
        return 0
      end
      # Trapping abilities/items
      eachOtherSideBattler(idxBattler) do |b|
        next if !b.abilityActive?
        if BattleHandlers.triggerTrappingTargetAbility(b.ability,battler,b,self)
          pbDisplayPaused(_INTL("{1} empêche la fuite avec {2}!",b.pbThis,b.abilityName))
          return 0
        end
      end
      eachOtherSideBattler(idxBattler) do |b|
        next if !b.itemActive?
        if BattleHandlers.triggerTrappingTargetItem(b.item,battler,b,self)
          pbDisplayPaused(_INTL("{1} empêche la fuite avec {2}!",b.pbThis,b.itemName))
          return 0
        end
      end
    end
    # Fleeing calculation
    # Get the speeds of the Pokémon fleeing and the fastest opponent
    # NOTE: Not pbSpeed, because using unmodified Speed.
    @runCommand += 1 if !duringBattle   # Make it easier to flee next time
    speedPlayer = @battlers[idxBattler].speed
    speedEnemy = 1
    eachOtherSideBattler(idxBattler) do |b|
      speed = b.speed
      speedEnemy = speed if speedEnemy<speed
    end
    # Compare speeds and perform fleeing calculation
    if speedPlayer>speedEnemy
      rate = 256
    else
      rate = (speedPlayer*128)/speedEnemy
      rate += @runCommand*30
    end
    if rate>=256 || @battleAI.pbAIRandom(256)<rate
      pbSEPlay("Battle flee")
      pbDisplayPaused(_INTL("Tu t'es enfui!"))
      @decision = 3
      return 1
    end
    pbDisplayPaused(_INTL("Tu ne pouvais pas t'échapper!"))
    return -1
  end
end
