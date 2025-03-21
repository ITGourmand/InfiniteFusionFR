class PokeBattle_Battler
  #=============================================================================
  # Generalised checks for whether a status problem can be inflicted
  #=============================================================================
  # NOTE: Not all "does it have this status?" checks use this method. If the
  #       check is leading up to curing self of that status condition, then it
  #       will look at the value of @status directly instead - if it is that
  #       status condition then it is curable. This method only checks for
  #       "counts as having that status", which includes Comatose which can't be
  #       cured.
  def pbHasStatus?(checkStatus)
    if BattleHandlers.triggerStatusCheckAbilityNonIgnorable(self.ability,self,checkStatus)
      return true
    end
    return @status==checkStatus
  end

  def pbHasAnyStatus?
    if BattleHandlers.triggerStatusCheckAbilityNonIgnorable(self.ability,self,nil)
      return true
    end
    return @status != :NONE
  end

  def pbCanInflictStatus?(newStatus,user,showMessages,move=nil,ignoreStatus=false)
    return false if fainted?
    selfInflicted = (user && user.index==@index)
    # Already have that status problem
    if self.status==newStatus && !ignoreStatus
      if showMessages
        msg = ""
        case self.status
        when :SLEEP     then msg = _INTL("{1} est déjà endormi !", pbThis)
        when :POISON    then msg = _INTL("{1} est déjà empoisonné !", pbThis)
        when :BURN      then msg = _INTL("{1} est déjà brûlé !!", pbThis)
        when :PARALYSIS then msg = _INTL("{1} est déjà paralysé!", pbThis)
        when :FROZEN    then msg = _INTL("{1} est déjà complètement gelé!", pbThis)
        end
        @battle.pbDisplay(msg)
      end
      return false
    end
    # Trying to replace a status problem with another one
    if self.status != :NONE && !ignoreStatus && !selfInflicted
      @battle.pbDisplay(_INTL("Cela n'affecte pas {1}...",pbThis(true))) if showMessages
      return false
    end
    # Trying to inflict a status problem on a Pokémon behind a substitute
    if @effects[PBEffects::Substitute]>0 && !(move && move.ignoresSubstitute?(user)) &&
       !selfInflicted
      @battle.pbDisplay(_INTL("Cela n'affecte pas {1}...",pbThis(true))) if showMessages
      return false
    end
    # Weather immunity
    if newStatus == :FROZEN && [:Sun, :HarshSun].include?(@battle.pbWeather)
      @battle.pbDisplay(_INTL("Cela n'affecte pas {1}...",pbThis(true))) if showMessages
      return false
    end
    # Terrains immunity
    if affectedByTerrain?
      case @battle.field.terrain
      when :Electric
        if newStatus == :SLEEP
          @battle.pbDisplay(_INTL("{1} s'entoure d'un terrain électrifié!",
             pbThis(true))) if showMessages
          return false
        end
      when :Misty
        @battle.pbDisplay(_INTL("{1} s'entoure d'un terrain brumeux!",pbThis(true))) if showMessages
        return false
      end
    end
    # Uproar immunity
    if newStatus == :SLEEP && !(hasActiveAbility?(:SOUNDPROOF) && !@battle.moldBreaker)
      @battle.eachBattler do |b|
        next if b.effects[PBEffects::Uproar]==0
        @battle.pbDisplay(_INTL("Mais le Brouhaha de {1} l'a réveillé!",pbThis(true))) if showMessages
        return false
      end
    end
    # Type immunities
    hasImmuneType = false
    case newStatus
    when :SLEEP
      # No type is immune to sleep
    when :POISON
      if !(user && user.hasActiveAbility?(:CORROSION))
        hasImmuneType |= pbHasType?(:POISON)
        hasImmuneType |= pbHasType?(:STEEL)
      end
    when :BURN
      hasImmuneType |= pbHasType?(:FIRE)
    when :PARALYSIS
      hasImmuneType |= pbHasType?(:ELECTRIC) && Settings::MORE_TYPE_EFFECTS
    when :FROZEN
      hasImmuneType |= pbHasType?(:ICE)
    end
    if hasImmuneType
      @battle.pbDisplay(_INTL("Cela n'affecte pas {1}...",pbThis(true))) if showMessages
      return false
    end
    # Ability immunity
    immuneByAbility = false; immAlly = nil
    if BattleHandlers.triggerStatusImmunityAbilityNonIgnorable(self.ability,self,newStatus)
      immuneByAbility = true
    elsif selfInflicted || !@battle.moldBreaker
      if abilityActive? && BattleHandlers.triggerStatusImmunityAbility(self.ability,self,newStatus)
        immuneByAbility = true
      else
        eachAlly do |b|
          next if !b.abilityActive?
          next if !BattleHandlers.triggerStatusImmunityAllyAbility(b.ability,self,newStatus)
          immuneByAbility = true
          immAlly = b
          break
        end
      end
    end
    if immuneByAbility
      if showMessages
        @battle.pbShowAbilitySplash(immAlly || self)
        msg = ""
        if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
          case newStatus
          when :SLEEP     then msg = _INTL("{1} reste éveillé!", pbThis)
          when :POISON    then msg = _INTL("{1} ne peut pas être empoisonné!", pbThis)
          when :BURN      then msg = _INTL("{1} ne peut pas être brûlé!", pbThis)
          when :PARALYSIS then msg = _INTL("{1} ne peut pas être paralysé!", pbThis)
          when :FROZEN    then msg = _INTL("{1} ne peut pas être gelé!", pbThis)
          end
        elsif immAlly
          case newStatus
          when :SLEEP
            msg = _INTL("{1} reste éveillé à cause de {2}'s {3}!",
               pbThis,immAlly.pbThis(true),immAlly.abilityName)
          when :POISON
            msg = _INTL("{1} ne peut pas être empoisonné à cause de {2}'s {3}!",
               pbThis,immAlly.pbThis(true),immAlly.abilityName)
          when :BURN
            msg = _INTL("{1} ne peut pas être brûlé à cause de {2}'s {3}!",
               pbThis,immAlly.pbThis(true),immAlly.abilityName)
          when :PARALYSIS
            msg = _INTL("{1} ne peut pas être paralysé à cause de {2}'s {3}!",
               pbThis,immAlly.pbThis(true),immAlly.abilityName)
          when :FROZEN
            msg = _INTL("{1} ne peut pas être gelé à cause de {2}'s {3}!",
               pbThis,immAlly.pbThis(true),immAlly.abilityName)
          end
        else
          case newStatus
          when :SLEEP     then msg = _INTL("{1} reste éveillé à cause de {2}!", pbThis, abilityName)
          when :POISON    then msg = _INTL("{1}'s {2} empêche l'empoisonnement!", pbThis, abilityName)
          when :BURN      then msg = _INTL("{1}'s {2} empêche la brûlure!", pbThis, abilityName)
          when :PARALYSIS then msg = _INTL("{1}'s {2} empêche la paralysie!", pbThis, abilityName)
          when :FROZEN    then msg = _INTL("{1}'s {2} empêche le gel!", pbThis, abilityName)
          end
        end
        @battle.pbDisplay(msg)
        @battle.pbHideAbilitySplash(immAlly || self)
      end
      return false
    end
    # Safeguard immunity
    if pbOwnSide.effects[PBEffects::Safeguard]>0 && !selfInflicted && move &&
       !(user && user.hasActiveAbility?(:INFILTRATOR))
      @battle.pbDisplay(_INTL("L'équipe de {1} est protégée par Rune Protect!",pbThis)) if showMessages
      return false
    end
    return true
  end

  def pbCanSynchronizeStatus?(newStatus,target)
    return false if fainted?
    # Trying to replace a status problem with another one
    return false if self.status != :NONE
    # Terrain immunity
    return false if @battle.field.terrain == :Misty && affectedByTerrain?
    # Type immunities
    hasImmuneType = false
    case newStatus
    when :POISON
      # NOTE: target will have Synchronize, so it can't have Corrosion.
      if !(target && target.hasActiveAbility?(:CORROSION))
        hasImmuneType |= pbHasType?(:POISON)
        hasImmuneType |= pbHasType?(:STEEL)
      end
    when :BURN
      hasImmuneType |= pbHasType?(:FIRE)
    when :PARALYSIS
      hasImmuneType |= pbHasType?(:ELECTRIC) && Settings::MORE_TYPE_EFFECTS
    end
    return false if hasImmuneType
    # Ability immunity
    if BattleHandlers.triggerStatusImmunityAbilityNonIgnorable(self.ability,self,newStatus)
      return false
    end
    if abilityActive? && BattleHandlers.triggerStatusImmunityAbility(self.ability,self,newStatus)
      return false
    end
    eachAlly do |b|
      next if !b.abilityActive?
      next if !BattleHandlers.triggerStatusImmunityAllyAbility(b.ability,self,newStatus)
      return false
    end
    # Safeguard immunity
    if pbOwnSide.effects[PBEffects::Safeguard]>0 &&
       !(user && user.hasActiveAbility?(:INFILTRATOR))
      return false
    end
    return true
  end

  #=============================================================================
  # Generalised infliction of status problem
  #=============================================================================
  def pbInflictStatus(newStatus,newStatusCount=0,msg=nil,user=nil)
    # Inflict the new status
    self.status      = newStatus
    self.statusCount = newStatusCount
    @effects[PBEffects::Toxic] = 0
    # Show animation
    if newStatus == :POISON && newStatusCount > 0
      @battle.pbCommonAnimation("Toxic", self)
    else
      anim_name = GameData::Status.get(newStatus).animation
      @battle.pbCommonAnimation(anim_name, self) if anim_name
    end
    # Show message
    if msg && !msg.empty?
      @battle.pbDisplay(msg)
    else
      case newStatus
      when :SLEEP
        @battle.pbDisplay(_INTL("{1} s'est endormi!", pbThis))
      when :POISON
        if newStatusCount>0
          @battle.pbDisplay(_INTL("{1} a été gravement empoisonné!", pbThis))
        else
          @battle.pbDisplay(_INTL("{1} a été empoisonné!", pbThis))
        end
      when :BURN
        @battle.pbDisplay(_INTL("{1} a été brûlé!", pbThis))
      when :PARALYSIS
        @battle.pbDisplay(_INTL("{1} est paralysé! Il est peut-être incapable de bouger!", pbThis))
      when :FROZEN
        @battle.pbDisplay(_INTL("{1} était complètement gelé!", pbThis))
      end
    end
    PBDebug.log("[Status change] #{pbThis}'s sleep count is #{newStatusCount}") if newStatus == :SLEEP
    # Form change check
    pbCheckFormOnStatusChange
    # Synchronize
    if abilityActive?
      BattleHandlers.triggerAbilityOnStatusInflicted(self.ability,self,user,newStatus)
    end
    # Status cures
    pbItemStatusCureCheck
    pbAbilityStatusCureCheck
    # Petal Dance/Outrage/Thrash get cancelled immediately by falling asleep
    # NOTE: I don't know why this applies only to Outrage and only to falling
    #       asleep (i.e. it doesn't cancel Rollout/Uproar/other multi-turn
    #       moves, and it doesn't cancel any moves if self becomes frozen/
    #       disabled/anything else). This behaviour was tested in Gen 5.
    if @status == :SLEEP && @effects[PBEffects::Outrage] > 0
      @effects[PBEffects::Outrage] = 0
      @currentMove = nil
    end
  end

  #=============================================================================
  # Sleep
  #=============================================================================
  def asleep?
    return pbHasStatus?(:SLEEP)
  end

  def pbCanSleep?(user, showMessages, move = nil, ignoreStatus = false)
    return pbCanInflictStatus?(:SLEEP, user, showMessages, move, ignoreStatus)
  end

  def pbCanSleepYawn?
    return false if self.status != :NONE
    if affectedByTerrain?
      return false if [:Electric, :Misty].include?(@battle.field.terrain)
    end
    if !hasActiveAbility?(:SOUNDPROOF)
      @battle.eachBattler do |b|
        return false if b.effects[PBEffects::Uproar]>0
      end
    end
    if BattleHandlers.triggerStatusImmunityAbilityNonIgnorable(self.ability, self, :SLEEP)
      return false
    end
    # NOTE: Bulbapedia claims that Flower Veil shouldn't prevent sleep due to
    #       drowsiness, but I disagree because that makes no sense. Also, the
    #       comparable Sweet Veil does prevent sleep due to drowsiness.
    if abilityActive? && BattleHandlers.triggerStatusImmunityAbility(self.ability, self, :SLEEP)
      return false
    end
    eachAlly do |b|
      next if !b.abilityActive?
      next if !BattleHandlers.triggerStatusImmunityAllyAbility(b.ability, self, :SLEEP)
      return false
    end
    # NOTE: Bulbapedia claims that Safeguard shouldn't prevent sleep due to
    #       drowsiness. I disagree with this too. Compare with the other sided
    #       effects Misty/Electric Terrain, which do prevent it.
    return false if pbOwnSide.effects[PBEffects::Safeguard]>0
    return true
  end

  def pbSleep(msg = nil)
    pbInflictStatus(:SLEEP, pbSleepDuration, msg)
  end

  def pbSleepSelf(msg = nil, duration = -1)
    pbInflictStatus(:SLEEP, pbSleepDuration(duration), msg)
  end

  def pbSleepDuration(duration = -1)
    duration = 2 + @battle.pbRandom(3) if duration <= 0
    duration = (duration / 2).floor if hasActiveAbility?(:EARLYBIRD)
    return duration
  end

  #=============================================================================
  # Poison
  #=============================================================================
  def poisoned?
    return pbHasStatus?(:POISON)
  end

  def pbCanPoison?(user, showMessages, move = nil)
    return pbCanInflictStatus?(:POISON, user, showMessages, move)
  end

  def pbCanPoisonSynchronize?(target)
    return pbCanSynchronizeStatus?(:POISON, target)
  end

  def pbPoison(user = nil, msg = nil, toxic = false)
    pbInflictStatus(:POISON, (toxic) ? 1 : 0, msg, user)
  end

  #=============================================================================
  # Burn
  #=============================================================================
  def burned?
    return pbHasStatus?(:BURN)
  end

  def pbCanBurn?(user, showMessages, move = nil)
    return pbCanInflictStatus?(:BURN, user, showMessages, move)
  end

  def pbCanBurnSynchronize?(target)
    return pbCanSynchronizeStatus?(:BURN, target)
  end

  def pbBurn(user = nil, msg = nil)
    pbInflictStatus(:BURN, 0, msg, user)
  end

  #=============================================================================
  # Paralyze
  #=============================================================================
  def paralyzed?
    return pbHasStatus?(:PARALYSIS)
  end

  def pbCanParalyze?(user, showMessages, move = nil)
    return pbCanInflictStatus?(:PARALYSIS, user, showMessages, move)
  end

  def pbCanParalyzeSynchronize?(target)
    return pbCanSynchronizeStatus?(:PARALYSIS, target)
  end

  def pbParalyze(user = nil, msg = nil)
    pbInflictStatus(:PARALYSIS, 0, msg, user)
  end

  #=============================================================================
  # Freeze
  #=============================================================================
  def frozen?
    return pbHasStatus?(:FROZEN)
  end

  def pbCanFreeze?(user, showMessages, move = nil)
    return pbCanInflictStatus?(:FROZEN, user, showMessages, move)
  end

  def pbFreeze(msg = nil)
    pbInflictStatus(:FROZEN, 0, msg)
  end

  #=============================================================================
  # Generalised status displays
  #=============================================================================
  def pbContinueStatus
    if self.status == :POISON && @statusCount > 0
      @battle.pbCommonAnimation("Toxic", self)
    else
      anim_name = GameData::Status.get(self.status).animation
      @battle.pbCommonAnimation(anim_name, self) if anim_name
    end
    yield if block_given?
    case self.status
    when :SLEEP
      @battle.pbDisplay(_INTL("{1} est profondément endormi.", pbThis))
    when :POISON
      @battle.pbDisplay(_INTL("{1} a été blessé par le poison!", pbThis))
    when :BURN
      @battle.pbDisplay(_INTL("{1} a été blessé par sa brûlure!", pbThis))
    when :PARALYSIS
      @battle.pbDisplay(_INTL("{1} est paralysé! Il ne peut plus bouger!", pbThis))
    when :FROZEN
      @battle.pbDisplay(_INTL("{1} est complètement gelé!", pbThis))
    end
    PBDebug.log("[Status continues] #{pbThis}'s sleep count is #{@statusCount}") if self.status == :SLEEP
  end

  def pbCureStatus(showMessages=true)
    oldStatus = status
    self.status = :NONE
    if showMessages
      case oldStatus
      when :SLEEP     then @battle.pbDisplay(_INTL("{1} a été réveillé!", pbThis))
      when :POISON    then @battle.pbDisplay(_INTL("{1} a été guéri de son empoisonnement..", pbThis))
      when :BURN      then @battle.pbDisplay(_INTL("La brûlure de {1} a été guérie", pbThis))
      when :PARALYSIS then @battle.pbDisplay(_INTL("{1} a été guéri de la paralysie.", pbThis))
      when :FROZEN    then @battle.pbDisplay(_INTL("{1} est décongelé!", pbThis))
      end
    end
    PBDebug.log("[Status change] #{pbThis}'s status was cured") if !showMessages
  end

  #=============================================================================
  # Confusion
  #=============================================================================
  def pbCanConfuse?(user=nil,showMessages=true,move=nil,selfInflicted=false)
    return false if fainted?
    if @effects[PBEffects::Confusion]>0
      @battle.pbDisplay(_INTL("{1} est déjà confus.",pbThis)) if showMessages
      return false
    end
    if @effects[PBEffects::Substitute]>0 && !(move && move.ignoresSubstitute?(user)) &&
       !selfInflicted
      @battle.pbDisplay(_INTL("Mais ça a échoué!")) if showMessages
      return false
    end
    # Terrains immunity
    if affectedByTerrain? && @battle.field.terrain == :Misty
      @battle.pbDisplay(_INTL("{1} s'entoure d'un terrain brumeux!",pbThis(true))) if showMessages
      return false
    end
    if selfInflicted || !@battle.moldBreaker
      if hasActiveAbility?(:OWNTEMPO)
        if showMessages
          @battle.pbShowAbilitySplash(self)
          if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
            @battle.pbDisplay(_INTL("{1} évite la confusion!",pbThis))
          else
            @battle.pbDisplay(_INTL("{1}'s {2} évite la confusion!",pbThis,abilityName))
          end
          @battle.pbHideAbilitySplash(self)
        end
        return false
      end
    end
    if pbOwnSide.effects[PBEffects::Safeguard]>0 && !selfInflicted &&
       !(user && user.hasActiveAbility?(:INFILTRATOR))
      @battle.pbDisplay(_INTL(" l'équipe de {1} est protégée par Rune Protect!",pbThis)) if showMessages
      return false
    end
    return true
  end

  def pbCanConfuseSelf?(showMessages)
    return pbCanConfuse?(nil,showMessages,nil,true)
  end

  def pbConfuse(msg=nil)
    @effects[PBEffects::Confusion] = pbConfusionDuration
    @battle.pbCommonAnimation("Confusion",self)
    msg = _INTL("{1} est devenu confus!",pbThis) if nil_or_empty?(msg)
    @battle.pbDisplay(msg)
    PBDebug.log("[Lingering effect] #{pbThis}'s confusion count is #{@effects[PBEffects::Confusion]}")
    # Confusion cures
    pbItemStatusCureCheck
    pbAbilityStatusCureCheck
  end

  def pbConfusionDuration(duration=-1)
    duration = 2+@battle.pbRandom(4) if duration<=0
    return duration
  end

  def pbCureConfusion
    @effects[PBEffects::Confusion] = 0
  end

  #=============================================================================
  # Attraction
  #=============================================================================
  def pbCanAttract?(user,showMessages=true)
    return false if fainted?
    return false if !user || user.fainted?
    if @effects[PBEffects::Attract]>=0
      @battle.pbDisplay(_INTL("{1} n'est pas affecté!",pbThis)) if showMessages
      return false
    end
    agender = user.gender
    ogender = gender
    if agender==2 || ogender==2 || agender==ogender
      @battle.pbDisplay(_INTL("{1} n'est pas affecté!",pbThis)) if showMessages
      return false
    end
    if !@battle.moldBreaker
      if hasActiveAbility?([:AROMAVEIL,:OBLIVIOUS])
        if showMessages
          @battle.pbShowAbilitySplash(self)
          if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
            @battle.pbDisplay(_INTL("{1} n'est pas affecté!",pbThis))
          else
            @battle.pbDisplay(_INTL("{1}'s {2} empêche la romance!",pbThis,abilityName))
          end
          @battle.pbHideAbilitySplash(self)
        end
        return false
      else
        eachAlly do |b|
          next if !b.hasActiveAbility?(:AROMAVEIL)
          if showMessages
            @battle.pbShowAbilitySplash(self)
            if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
              @battle.pbDisplay(_INTL("{1} n'est pas affecté!",pbThis))
            else
              @battle.pbDisplay(_INTL("{1}'s {2} empêche la romance!",b.pbThis,b.abilityName))
            end
            @battle.pbHideAbilitySplash(self)
          end
          return true
        end
      end
    end
    return true
  end

  def pbAttract(user,msg=nil)
    @effects[PBEffects::Attract] = user.index
    @battle.pbCommonAnimation("Attract",self)
    msg = _INTL("{1} est tombé amoureux!",pbThis) if nil_or_empty?(msg)
    @battle.pbDisplay(msg)
    # Destiny Knot
    if hasActiveItem?(:DESTINYKNOT) && user.pbCanAttract?(self,false)
      user.pbAttract(self,_INTL("{1} tombé amoureux par {2}!",user.pbThis(true),itemName))
    end
    # Attraction cures
    pbItemStatusCureCheck
    pbAbilityStatusCureCheck
  end

  def pbCureAttract
    @effects[PBEffects::Attract] = -1
  end

  #=============================================================================
  # Flinching
  #=============================================================================
  def pbFlinch(_user=nil)
    return if hasActiveAbility?(:INNERFOCUS) && !@battle.moldBreaker
    @effects[PBEffects::Flinch] = true
  end
end
