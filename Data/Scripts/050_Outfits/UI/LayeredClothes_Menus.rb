def playOutfitRemovedAnimation()
  pbSEPlay("shiny", 80, 60)
  $scene.spriteset.addUserAnimation(Settings::OW_SHINE_ANIMATION_ID, $game_player.x, $game_player.y, true)
end

def playOutfitChangeAnimation()
  pbSEPlay("shiny", 80, 100)
  $scene.spriteset.addUserAnimation(Settings::OW_SHINE_ANIMATION_ID, $game_player.x, $game_player.y, true)
end

def selectHairstyle(all_unlocked = false)
  selector = OutfitSelector.new
  display_outfit_preview()
  hat = $Trainer.hat
  commands = ["Style suivant", "Style précédent", "Changer de chapeau", "Retour"]
  previous_input = 0
  # To enable turning the common event that lets you turn around while in the dialog box
  while (true)
    choice = pbShowCommands(nil, commands, commands.length, previous_input)
    previous_input = choice
    case choice
    when 0 #NEXT
      playOutfitChangeAnimation()
      selector.changeToNextHairstyle(1, all_unlocked)
      display_outfit_preview()
    when 1 #PREVIOUS
      playOutfitChangeAnimation()
      selector.changeToNextHairstyle(-1, all_unlocked)
      display_outfit_preview()
    when 2 #Toggle hat
      pbSEPlay("Stockage du GUI mis en place", 80, 100)
      if hat == $Trainer.hat
        $Trainer.hat = nil
      else
        $Trainer.hat = hat
      end
      display_outfit_preview()
    else
      break
    end
  end
  hide_outfit_preview()
  $Trainer.hat = hat
end

def swapToNextHairVersion()
  split_hair = getSplitHairFilenameAndVersionFromID($Trainer.hair)
  hair_version = split_hair[0]
  hair_style = split_hair[1]
  current_version = hair_version
  pbSEPlay("GUI party switch", 80, 100)
  newVersion = current_version.to_i + 1
  lastVersion = findLastHairVersion(hair_style)
  newVersion = lastVersion if newVersion <= 0
  newVersion = 1 if newVersion > lastVersion
  $Trainer.hair = getFullHairId(hair_style,newVersion)
end

def selectHairColor
  original_color = $Trainer.hair_color
  original_hair = $Trainer.hair
  $game_switches[SWITCH_SELECTING_CLOTHES]=true
  $game_map.update
  display_outfit_preview()
  hat = $Trainer.hat
  commands = ["Changer la Couleur","Monter", "Descendre", "Changer de chapeau", "Réinitialiser", "Confirmer", "Annuler"]
  previous_input = 0

  while (true)
    choice = pbShowCommands(nil, commands, commands.length, previous_input)
    previous_input = choice
    case choice
    when 0 #change base
      swapToNextHairVersion()
      display_outfit_preview()
      ret = false
    when 1 #NEXT
      #playOutfitChangeAnimation()
      pbSEPlay("Prendre un objet du stockage", 80, 100)
      shiftHairColor(10)
      display_outfit_preview()
      ret = true
    when 2 #PREVIOUS
      pbSEPlay("Prendre un objet du stockage", 80, 100)
      shiftHairColor(-10)
      display_outfit_preview()
      ret = true
    when 3 #Toggle hat
      pbSEPlay("Placer dans le stockage", 80, 100)
      if hat == $Trainer.hat
        $Trainer.hat = nil
      else
        $Trainer.hat = hat
      end
      display_outfit_preview()
    when 4 #Reset
      pbSEPlay("Placer dans le stockage", 80, 100)
      $Trainer.hair_color = 0
      display_outfit_preview()
      ret = false
    when 5 #Confirm
      break
    else
      $Trainer.hair_color = original_color
      $Trainer.hair = original_hair
      ret = false
      break
    end
  end
  hide_outfit_preview()
  $Trainer.hat = hat
  $game_switches[SWITCH_SELECTING_CLOTHES]=false
  $game_map.update
  return ret

end

def selectHatColor
  original_color = $Trainer.hat_color
  display_outfit_preview()
  commands = ["Monter", "Descendre", "Réinitialiser", "Confirmer", "Annuler"]
  previous_input = 0
  while (true)
    choice = pbShowCommands(nil, commands, commands.length, previous_input)
    previous_input = choice
    case choice
    when 0 #NEXT
      pbSEPlay("Prendre un objet du stockage", 80, 100)
      shiftHatColor(10)
      display_outfit_preview()
      ret = true
    when 1 #PREVIOUS
      pbSEPlay("Prendre un objet du stockage", 80, 100)
      shiftHatColor(-10)
      display_outfit_preview()
      ret = true
    when 2 #Reset
      pbSEPlay("Placer dans le stockage", 80, 100)
      $Trainer.hat_color = 0
      display_outfit_preview()
      refreshPlayerOutfit()
      ret = false
    when 3 #Confirm
      break
    else
      $Trainer.hat_color = original_color
      ret = false
      break
    end
  end
  refreshPlayerOutfit()
  hide_outfit_preview()
  return ret
end

def selectClothesColor
  original_color = $Trainer.clothes_color
  display_outfit_preview()
  commands = ["Monter", "Descendre", "Réinitialiser", "Confirmer", "Annuler"]
  previous_input = 0
  ret = false
  while (true)
    choice = pbShowCommands(nil, commands, commands.length, previous_input)
    previous_input = choice
    case choice
    when 0 #NEXT
      pbSEPlay("Prendre un objet du stockage", 80, 100)
      shiftClothesColor(10)
      display_outfit_preview()
      ret = true
    when 1 #PREVIOUS
      pbSEPlay("Prendre un objet du stockage", 80, 100)
      shiftClothesColor(-10)
      display_outfit_preview()
      ret = true
    when 2 #Reset
      pbSEPlay("Prendre un objet du stockage", 80, 100)
      $Trainer.clothes_color = 0
      display_outfit_preview()
      refreshPlayerOutfit()
      ret = false
    when 3 #Confirm
      break
    else
      $Trainer.clothes_color = original_color
      ret = false
      break
    end
  end
  refreshPlayerOutfit()
  hide_outfit_preview()
  return ret
end

def selectHat(all_unlocked = false)
  selector = OutfitSelector.new
  display_outfit_preview()
  commands = ["Chapeau suivant", "Chapeau précédent", "Enlever le chapeau", "Retour"]
  previous_input = 0
  while (true)
    choice = pbShowCommands(nil, commands, commands.length, previous_input)
    previous_input = choice
    case choice
    when 0 #NEXT
      playOutfitChangeAnimation()
      selector.changeToNextHat(1, all_unlocked)
      display_outfit_preview()
    when 1 #PREVIOUS
      playOutfitChangeAnimation()
      selector.changeToNextHat(-1, all_unlocked)
      display_outfit_preview()
    when 2 #REMOVE HAT
      playOutfitRemovedAnimation()
      $Trainer.hat = nil
      selector.display_outfit_preview()
    else
      break
    end
  end
  hide_outfit_preview()
end

def spinCharacter
  pbSEPlay("Echanger dans l'équipe", 80, 100)

end

def selectClothes(all_unlocked = false)
  selector = OutfitSelector.new
  display_outfit_preview()
  commands = ["Suivant", "Précédent"]
  #commands << "Remove clothes (DEBUG)" if $DEBUG
  commands << "Enlever" if $DEBUG
  commands << "Retour"
  previous_input = 0
  while (true)
    choice = pbShowCommands(nil, commands, commands.length, previous_input)
    previous_input = choice
    case choice
    when 0 #NEXT
      playOutfitChangeAnimation()
      selector.changeToNextClothes(1, all_unlocked)
      display_outfit_preview()
    when 1 #PREVIOUS
      playOutfitChangeAnimation()
      selector.changeToNextClothes(-1, all_unlocked)
      display_outfit_preview()
    when 2 #REMOVE CLOTHES
      break if !$DEBUG
      playOutfitRemovedAnimation()
      $Trainer.clothes = nil
      display_outfit_preview()
    else
      break
    end
  end
  hide_outfit_preview()
end

def place_hat_on_pokemon(pokemon)
  hatscreen = PokemonHatPresenter.new(nil, pokemon)
  hatscreen.pbStartScreen()
end