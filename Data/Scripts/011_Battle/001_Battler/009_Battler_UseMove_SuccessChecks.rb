class PokeBattle_Battler
  #=============================================================================
  # Decide whether the trainer is allowed to tell the Pokémon to use the given
  # move. Called when choosing a command for the round.
  # Also called when processing the Pokémon's action, because these effects also
  # prevent Pokémon action. Relevant because these effects can become active
  # earlier in the same round (after choosing the command but before using the
  # move) or an unusable move may be called by another move such as Metronome.
  #=============================================================================
  def pbCanChooseMove?(move,commandPhase,showMessages=true,specialUsage=false)
    # Disable
    if @effects[PBEffects::DisableMove]==move.id && !specialUsage
      if showMessages
        msg = _INTL("{1}'s {2} est désactivé!",pbThis,move.name)
        (commandPhase) ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
      end
      return false
    end
    # Heal Block
    if @effects[PBEffects::HealBlock]>0 && move.healingMove?
      if showMessages
        msg = _INTL("{1} impossible d'utiliser {2} à cause de Anti-Soin!",pbThis,move.name)
        (commandPhase) ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
      end
      return false
    end
    # Gravity
    if @battle.field.effects[PBEffects::Gravity]>0 && move.unusableInGravity?
      if showMessages
        msg = _INTL("{1} impossible d'utiliser {2} à cause de Gravité!",pbThis,move.name)
        (commandPhase) ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
      end
      return false
    end
    # Throat Chop
    if @effects[PBEffects::ThroatChop]>0 && move.soundMove?
      if showMessages
        msg = _INTL("{1} impossible d'utiliser {2} à cause de Exécu-Son!",pbThis,move.name)
        (commandPhase) ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
      end
      return false
    end
    # Choice Band
    if @effects[PBEffects::ChoiceBand]
      if hasActiveItem?([:CHOICEBAND,:CHOICESPECS,:CHOICESCARF]) &&
         pbHasMove?(@effects[PBEffects::ChoiceBand])
        if move.id!=@effects[PBEffects::ChoiceBand]
          if showMessages
            msg = _INTL("{1} permet l'utilisation uniquement de {2}!",itemName,
               GameData::Move.get(@effects[PBEffects::ChoiceBand]).name)
            (commandPhase) ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
          end
          return false
        end
      else
        @effects[PBEffects::ChoiceBand] = nil
      end
    end
    # Taunt
    if @effects[PBEffects::Taunt]>0 && move.statusMove?
      if showMessages
        msg = _INTL("{1} ne peut pas utiliser {2} après la provocation!",pbThis,move.name)
        (commandPhase) ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
      end
      return false
    end
    # Torment
    if @effects[PBEffects::Torment] && !@effects[PBEffects::Instructed] &&
       @lastMoveUsed && move.id==@lastMoveUsed && move.id!=@battle.struggle.id
      if showMessages
        msg = _INTL("{1} impossible d'utiliser la même attaque deux fois de suite à cause du tourment!",pbThis)
        (commandPhase) ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
      end
      return false
    end
    # Imprison
    @battle.eachOtherSideBattler(@index) do |b|
      next if !b.effects[PBEffects::Imprison] || !b.pbHasMove?(move.id)
      if showMessages
        msg = _INTL("{1} ne peut pas l'utiliser {2} est scellé!",pbThis,move.name)
        (commandPhase) ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
      end
      return false
    end
    # Assault Vest (prevents choosing status moves but doesn't prevent
    # executing them)
    if hasActiveItem?(:ASSAULTVEST) && move.statusMove? && commandPhase
      if showMessages
        msg = _INTL("Les effets du {1} empêchent l'utilisation des attaques de statut!",
           itemName)
        (commandPhase) ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
      end
      return false
    end
    # Belch
    return false if !move.pbCanChooseMove?(self,commandPhase,showMessages)
    return true
  end

  #=============================================================================
  # Obedience check
  #=============================================================================
  # Return true if Pokémon continues attacking (although it may have chosen to
  # use a different move in disobedience), or false if attack stops.
  def pbObedienceCheck?(choice)
    return true if usingMultiTurnAttack?
    return true if choice[0]!=:UseMove
    return true if !@battle.internalBattle
    return true if !@battle.pbOwnedByPlayer?(@index)
    disobedient = false
    # Pokémon may be disobedient; calculate if it is
    badgeLevel = 10 * (@battle.pbPlayer.badge_count + 1)
    badgeLevel = GameData::GrowthRate.max_level if @battle.pbPlayer.badge_count >= 8
    if (@pokemon.foreign?(@battle.pbPlayer) && @level>badgeLevel) || @pokemon.force_disobey
      a = ((@level+badgeLevel)*@battle.pbRandom(256)/256).floor
      disobedient |= (a>=badgeLevel)
    end
    disobedient |= !pbHyperModeObedience(choice[2])
    return true if !disobedient
    # Pokémon is disobedient; make it do something else
    return pbDisobey(choice,badgeLevel)
  end

  def pbDisobey(choice,badgeLevel)
    move = choice[2]
    PBDebug.log("[Disobedience] #{pbThis} disobeyed")
    @effects[PBEffects::Rage] = false
    # Do nothing if using Snore/Sleep Talk
    if @status == :SLEEP && move.usableWhenAsleep?
      @battle.pbDisplay(_INTL("{1} a ignoré ses ordres et continue de dormir!",pbThis))
      return false
    end
    b = ((@level+badgeLevel)*@battle.pbRandom(256)/256).floor
    # Use another move
    if b<badgeLevel
      @battle.pbDisplay(_INTL("{1} a ignoré ses ordres!",pbThis))
      return false if !@battle.pbCanShowFightMenu?(@index)
      otherMoves = []
      eachMoveWithIndex do |_m,i|
        next if i==choice[1]
        otherMoves.push(i) if @battle.pbCanChooseMove?(@index,i,false)
      end
      return false if otherMoves.length==0   # No other move to use; do nothing
      newChoice = otherMoves[@battle.pbRandom(otherMoves.length)]
      choice[1] = newChoice
      choice[2] = @moves[newChoice]
      choice[3] = -1
      return true
    end
    c = @level-badgeLevel
    r = @battle.pbRandom(256)
    # Fall asleep
    if r<c && pbCanSleep?(self,false)
      pbSleepSelf(_INTL("{1} a commencé à faire la sieste!",pbThis))
      return false
    end
    # Hurt self in confusion
    r -= c
    if r < c && @status != :SLEEP
      pbConfusionDamage(_INTL("{1} n'obéira pas! Il s'est blessé dans sa confusion!",pbThis))
      return false
    end
    # Show refusal message and do nothing
    case @battle.pbRandom(4)
    when 0 then @battle.pbDisplay(_INTL("{1} n'obéira pas!",pbThis))
    when 1 then @battle.pbDisplay(_INTL("{1} s'est détourné!",pbThis))
    when 2 then @battle.pbDisplay(_INTL("{1} est en train de flâner!",pbThis))
    when 3 then @battle.pbDisplay(_INTL("{1} fait semblant de ne pas remarquer!",pbThis))
    end
    return false
  end

  #=============================================================================
  # Check whether the user (self) is able to take action at all.
  # If this returns true, and if PP isn't a problem, the move will be considered
  # to have been used (even if it then fails for whatever reason).
  #=============================================================================
  def pbTryUseMove(choice,move,specialUsage,skipAccuracyCheck)
    # Check whether it's possible for self to use the given move
    # NOTE: Encore has already changed the move being used, no need to have a
    #       check for it here.
    if !pbCanChooseMove?(move,false,true,specialUsage)
      @lastMoveFailed = true
      return false
    end
    # Check whether it's possible for self to do anything at all
    if @effects[PBEffects::SkyDrop]>=0   # Intentionally no message here
      PBDebug.log("[Move failed] #{pbThis} can't use #{move.name} because of being Sky Dropped")
      return false
    end
    if @effects[PBEffects::HyperBeam]>0   # Intentionally before Truant
      @battle.pbDisplay(_INTL("{1} doit recharger!",pbThis))
      return false
    end
    if choice[1]==-2   # Battle Palace
      @battle.pbDisplay(_INTL("{1} semble incapable d'utiliser son pouvoir!",pbThis))
      return false
    end
    # Skip checking all applied effects that could make self fail doing something
    return true if skipAccuracyCheck
    # Check status problems and continue their effects/cure them
    case @status
    when :SLEEP
      self.statusCount -= 1
      if @statusCount<=0
        pbCureStatus
      else
        pbContinueStatus
        if !move.usableWhenAsleep?   # Snore/Sleep Talk
          @lastMoveFailed = true
          return false
        end
      end
    when :FROZEN
      if !move.thawsUser?
        if @battle.pbRandom(100)<20
          pbCureStatus
        else
          pbContinueStatus
          @lastMoveFailed = true
          return false
        end
      end
    end
    # Obedience check
    return false if !pbObedienceCheck?(choice)
    # Truant
    if hasActiveAbility?(:TRUANT)
      @effects[PBEffects::Truant] = !@effects[PBEffects::Truant]
      if !@effects[PBEffects::Truant]   # True means loafing, but was just inverted
        @battle.pbShowAbilitySplash(self)
        @battle.pbDisplay(_INTL("{1} est en train de flâner!",pbThis))
        @lastMoveFailed = true
        @battle.pbHideAbilitySplash(self)
        return false
      end
    end
    # Flinching
    if @effects[PBEffects::Flinch]
      @battle.pbDisplay(_INTL("{1} a eu peur et n'a pas pu agir!",pbThis))
      if abilityActive?
        BattleHandlers.triggerAbilityOnFlinch(self.ability,self,@battle)
      end
      @lastMoveFailed = true
      return false
    end
    # Confusion
    if @effects[PBEffects::Confusion]>0
      @effects[PBEffects::Confusion] -= 1
      if @effects[PBEffects::Confusion]<=0
        pbCureConfusion
        @battle.pbDisplay(_INTL("{1} est sorti de sa confusion.",pbThis))
      else
        @battle.pbCommonAnimation("Confusion",self)
        @battle.pbDisplay(_INTL("{1} est confus!",pbThis))
        threshold = (Settings::MECHANICS_GENERATION >= 7) ? 33 : 50   # % chance
        if @battle.pbRandom(100)<threshold
          pbConfusionDamage(_INTL("Il s'est blessé dans sa confusion!"))
          @lastMoveFailed = true
          return false
        end
      end
    end
    # Paralysis
    if @status == :PARALYSIS
      if @battle.pbRandom(100)<25
        pbContinueStatus
        @lastMoveFailed = true
        return false
      end
    end
    # Infatuation
    if @effects[PBEffects::Attract]>=0
      @battle.pbCommonAnimation("Attract",self)
      @battle.pbDisplay(_INTL("{1} est amoureux de {2}!",pbThis,
         @battle.battlers[@effects[PBEffects::Attract]].pbThis(true)))
      if @battle.pbRandom(100)<50
        @battle.pbDisplay(_INTL("{1} est immobilisé par l'amour!",pbThis))
        @lastMoveFailed = true
        return false
      end
    end
    return true
  end

  #=============================================================================
  # Initial success check against the target. Done once before the first hit.
  # Includes move-specific failure conditions, protections and type immunities.
  #=============================================================================
  def pbSuccessCheckAgainstTarget(move,user,target)
    typeMod = move.pbCalcTypeMod(move.calcType,user,target)
    target.damageState.typeMod = typeMod
    # Two-turn attacks can't fail here in the charging turn
    return true if user.effects[PBEffects::TwoTurnAttack]
    # Move-specific failures
    return false if move.pbFailsAgainstTarget?(user,target)
    # Immunity to priority moves because of Psychic Terrain
    if @battle.field.terrain == :Psychic && target.affectedByTerrain? && target.opposes?(user) &&
       @battle.choices[user.index][4]>0   # Move priority saved from pbCalculatePriority
      @battle.pbDisplay(_INTL("{1} s'entoure d'un terrain psychique!",target.pbThis))
      return false
    end
    # Crafty Shield
    if target.pbOwnSide.effects[PBEffects::CraftyShield] && user.index!=target.index &&
       move.statusMove? && !move.pbTarget(user).targets_all
      @battle.pbCommonAnimation("CraftyShield",target)
      @battle.pbDisplay(_INTL("Vigilance a protégé {1}!",target.pbThis(true)))
      target.damageState.protected = true
      @battle.successStates[user.index].protected = true
      return false
    end
    # Wide Guard
    if target.pbOwnSide.effects[PBEffects::WideGuard] && user.index!=target.index &&
       move.pbTarget(user).num_targets > 1 &&
       (Settings::MECHANICS_GENERATION >= 7 || move.damagingMove?)
      @battle.pbCommonAnimation("WideGuard",target)
      @battle.pbDisplay(_INTL("Garde Large a protégé {1}!",target.pbThis(true)))
      target.damageState.protected = true
      @battle.successStates[user.index].protected = true
      return false
    end
    if move.canProtectAgainst?
      # Quick Guard
      if target.pbOwnSide.effects[PBEffects::QuickGuard] &&
         @battle.choices[user.index][4]>0   # Move priority saved from pbCalculatePriority
        @battle.pbCommonAnimation("QuickGuard",target)
        @battle.pbDisplay(_INTL("Prévention a protégé {1}!",target.pbThis(true)))
        target.damageState.protected = true
        @battle.successStates[user.index].protected = true
        return false
      end
      # Protect
      if target.effects[PBEffects::Protect]
        @battle.pbCommonAnimation("Protect",target)
        @battle.pbDisplay(_INTL("{1} s'est protégé!",target.pbThis))
        target.damageState.protected = true
        @battle.successStates[user.index].protected = true
        return false
      end
      # King's Shield
      if target.effects[PBEffects::KingsShield] && move.damagingMove?
        @battle.pbCommonAnimation("KingsShield",target)
        @battle.pbDisplay(_INTL("{1} s'est protégé!",target.pbThis))
        target.damageState.protected = true
        @battle.successStates[user.index].protected = true
        if move.pbContactMove?(user) && user.affectedByContactEffect?
          if user.pbCanLowerStatStage?(:ATTACK)
            user.pbLowerStatStage(:ATTACK,2,nil)
          end
        end
        return false
      end
      # Spiky Shield
      if target.effects[PBEffects::SpikyShield]
        @battle.pbCommonAnimation("SpikyShield",target)
        @battle.pbDisplay(_INTL("{1} s'est protégé!",target.pbThis))
        target.damageState.protected = true
        @battle.successStates[user.index].protected = true
        if move.pbContactMove?(user) && user.affectedByContactEffect?
          @battle.scene.pbDamageAnimation(user)
          user.pbReduceHP(user.totalhp/8,false)
          @battle.pbDisplay(_INTL("{1} était blessé!",user.pbThis))
          user.pbItemHPHealCheck
        end
        return false
      end
      # Baneful Bunker
      if target.effects[PBEffects::BanefulBunker]
        @battle.pbCommonAnimation("BanefulBunker",target)
        @battle.pbDisplay(_INTL("{1} s'est protégé!",target.pbThis))
        target.damageState.protected = true
        @battle.successStates[user.index].protected = true
        if move.pbContactMove?(user) && user.affectedByContactEffect?
          user.pbPoison(target) if user.pbCanPoison?(target,false)
        end
        return false
      end
      # Mat Block
      if target.pbOwnSide.effects[PBEffects::MatBlock] && move.damagingMove?
        # NOTE: Confirmed no common animation for this effect.
        @battle.pbDisplay(_INTL("{1} a été bloqué par Tatamigaeshi!",move.name))
        target.damageState.protected = true
        @battle.successStates[user.index].protected = true
        return false
      end
    end
    # Magic Coat/Magic Bounce
    if move.canMagicCoat? && !target.semiInvulnerable? && target.opposes?(user)
      if target.effects[PBEffects::MagicCoat]
        target.damageState.magicCoat = true
        target.effects[PBEffects::MagicCoat] = false
        return false
      end
      if target.hasActiveAbility?(:MAGICBOUNCE) && !@battle.moldBreaker &&
         !target.effects[PBEffects::MagicBounce]
        target.damageState.magicBounce = true
        target.effects[PBEffects::MagicBounce] = true
        return false
      end
    end
    # Immunity because of ability (intentionally before type immunity check)
    return false if move.pbImmunityByAbility(user,target)
    # Type immunity
    if move.pbDamagingMove? && Effectiveness.ineffective?(typeMod)
      PBDebug.log("[Target immune] #{target.pbThis}'s type immunity")
      @battle.pbDisplay(_INTL("Cela n'affecte pas {1}...",target.pbThis(true)))
      return false
    end
    # Dark-type immunity to moves made faster by Prankster
    if Settings::MECHANICS_GENERATION >= 7 && user.effects[PBEffects::Prankster] &&
       target.pbHasType?(:DARK) && target.opposes?(user)
      PBDebug.log("[Target immune] #{target.pbThis} est de type Ténèbres et immunisé contre les attaques Farceur")
      @battle.pbDisplay(_INTL("Cela n'affecte pas {1}...",target.pbThis(true)))
      return false
    end
    # Airborne-based immunity to Ground moves
    if move.damagingMove? && move.calcType == :GROUND &&
       target.airborne? && !move.hitsFlyingTargets?
      if target.hasActiveAbility?(:LEVITATE) && !@battle.moldBreaker
        @battle.pbShowAbilitySplash(target)
        if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
          @battle.pbDisplay(_INTL("{1} a évité l'attaque!",target.pbThis))
        else
          @battle.pbDisplay(_INTL("{1} a évité l'attaque avec {2}!",target.pbThis,target.abilityName))
        end
        @battle.pbHideAbilitySplash(target)
        return false
      end
      if target.hasActiveItem?(:AIRBALLOON)
        @battle.pbDisplay(_INTL("{1}'s {2} a fait rater les capacités sol!",target.pbThis,target.itemName))
        return false
      end
      if target.effects[PBEffects::MagnetRise]>0
        @battle.pbDisplay(_INTL("{1} fait rater les capacités sol avec Vol Magnétik!",target.pbThis))
        return false
      end
      if target.effects[PBEffects::Telekinesis]>0
        @battle.pbDisplay(_INTL("{1} fait rater les capacités sol avec la télékinésie!",target.pbThis))
        return false
      end
    end
    # Immunity to powder-based moves
    if move.powderMove?
      if target.pbHasType?(:GRASS) && Settings::MORE_TYPE_EFFECTS
        PBDebug.log("[Target immune] #{target.pbThis} is Grass-type and immune to powder-based moves")
        @battle.pbDisplay(_INTL("Cela n'affecte pas {1}...",target.pbThis(true)))
        return false
      end
      if Settings::MECHANICS_GENERATION >= 6
        if target.hasActiveAbility?(:OVERCOAT) && !@battle.moldBreaker
          @battle.pbShowAbilitySplash(target)
          if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
            @battle.pbDisplay(_INTL("Cela n'affecte pas {1}...",target.pbThis(true)))
          else
            @battle.pbDisplay(_INTL("Cela n'affecte pas {1} à cause de {2}.",target.pbThis(true),target.abilityName))
          end
          @battle.pbHideAbilitySplash(target)
          return false
        end
        if target.hasActiveItem?(:SAFETYGOGGLES)
          PBDebug.log("[Item triggered] #{target.pbThis} has Safety Goggles and is immune to powder-based moves")
          @battle.pbDisplay(_INTL("Cela n'affecte pas {1}...",target.pbThis(true)))
          return false
        end
      end
    end
    # Substitute
    if target.effects[PBEffects::Substitute]>0 && move.statusMove? &&
       !move.ignoresSubstitute?(user) && user.index!=target.index
      PBDebug.log("[Target immune] #{target.pbThis} is protected by its Substitute")
      @battle.pbDisplay(_INTL("{1} a évité l'attaque!",target.pbThis(true)))
      return false
    end
    return true
  end

  #=============================================================================
  # Per-hit success check against the target.
  # Includes semi-invulnerable move use and accuracy calculation.
  #=============================================================================
  def pbSuccessCheckPerHit(move,user,target,skipAccuracyCheck)
    # Two-turn attacks can't fail here in the charging turn
    return true if user.effects[PBEffects::TwoTurnAttack]
    # Lock-On
    return true if user.effects[PBEffects::LockOn]>0 &&
                   user.effects[PBEffects::LockOnPos]==target.index
    # Toxic
    return true if move.pbOverrideSuccessCheckPerHit(user,target)
    miss = false; hitsInvul = false
    # No Guard
    hitsInvul = true if user.hasActiveAbility?(:NOGUARD) ||
                        target.hasActiveAbility?(:NOGUARD)
    # Future Sight
    hitsInvul = true if @battle.futureSight
    # Helping Hand
    hitsInvul = true if move.function=="09C"
    if !hitsInvul
      # Semi-invulnerable moves
      if target.effects[PBEffects::TwoTurnAttack]
        if target.inTwoTurnAttack?("0C9","0CC","0CE")   # Fly, Bounce, Sky Drop
          miss = true if !move.hitsFlyingTargets?
        elsif target.inTwoTurnAttack?("0CA")            # Dig
          miss = true if !move.hitsDiggingTargets?
        elsif target.inTwoTurnAttack?("0CB")            # Dive
          miss = true if !move.hitsDivingTargets?
        elsif target.inTwoTurnAttack?("0CD","14D")      # Shadow Force, Phantom Force
          miss = true
        end
      end
      if target.effects[PBEffects::SkyDrop]>=0 &&
         target.effects[PBEffects::SkyDrop]!=user.index
        miss = true if !move.hitsFlyingTargets?
      end
    end
    if user.hasActiveItem?(:MANKEYPAW)
      miss = true if rand(2)==1
    end
    if !miss
      # Called by another move
      return true if skipAccuracyCheck
      # Accuracy check
      return true if move.pbAccuracyCheck(user,target)   # Includes Counter/Mirror Coat
    end
    # Missed
    PBDebug.log("[Move failed] Failed pbAccuracyCheck or target is semi-invulnerable")
    return false
  end

  #=============================================================================
  # Message shown when a move fails the per-hit success check above.
  #=============================================================================
  def pbMissMessage(move,user,target)
    if move.pbTarget(user).num_targets > 1
      @battle.pbDisplay(_INTL("{1} a évité l'attaque!",target.pbThis))
    elsif target.effects[PBEffects::TwoTurnAttack]
      @battle.pbDisplay(_INTL("{1} a évité l'attaque",target.pbThis))
    elsif !move.pbMissMessage(user,target)
      @battle.pbDisplay(_INTL("L'attaque de {1} a raté!",user.pbThis))
    end
  end
end
