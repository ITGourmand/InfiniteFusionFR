class BattleSwapScene
  def pbStartRentScene(rentals)
    @rentals = rentals
    @mode = 0   # rental (pick 3 out of 6 initial Pokémon)
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    addBackgroundPlane(@sprites, "bg", "rentbg", @viewport)
    @sprites["title"] = Window_UnformattedTextPokemon.newWithSize(
       _INTL("POKÉMON DE LOCATION"), 0, 0, Graphics.width, 64, @viewport)
    @sprites["list"] = Window_AdvancedCommandPokemonEx.newWithSize(
       [], 0, 64, Graphics.width, Graphics.height - 128 , @viewport)
    @sprites["help"] = Window_UnformattedTextPokemon.newWithSize("",
       0, Graphics.height - 64, Graphics.width, 64, @viewport)
    @sprites["msgwindow"] = Window_AdvancedTextPokemon.newWithSize("",
       0, Graphics.height - 64, Graphics.height, 64, @viewport)
    @sprites["msgwindow"].visible = false
    pbUpdateChoices([])
    pbDeactivateWindows(@sprites)
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbStartSwapScene(currentPokemon, newPokemon)
    @currentPokemon = currentPokemon
    @newPokemon = newPokemon
    @mode = 1   # swap (pick 1 out of 3 opponent's Pokémon to take)
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    addBackgroundPlane(@sprites, "bg", "swapbg", @viewport)
    @sprites["title"] = Window_UnformattedTextPokemon.newWithSize(
       _INTL("ÉCHANGE DE POKÉMON"), 0, 0, Graphics.width, 64, @viewport)
    @sprites["list"] = Window_AdvancedCommandPokemonEx.newWithSize(
       [], 0, 64, Graphics.width, Graphics.height - 128, @viewport)
    @sprites["help"] = Window_UnformattedTextPokemon.newWithSize(
       "", 0, Graphics.height - 64, Graphics.width, 64, @viewport)
    @sprites["msgwindow"] = Window_AdvancedTextPokemon.newWithSize(
       "", 0, Graphics.height - 64, Graphics.width, 64, @viewport)
    @sprites["msgwindow"].visible = false
    pbInitSwapScreen
    pbDeactivateWindows(@sprites)
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbInitSwapScreen
    commands = pbGetCommands(@currentPokemon, [])
    commands.push(_INTL("ANNULER"))
    @sprites["help"].text = _INTL("Sélectionnez le Pokémon à échanger.")
    @sprites["list"].commands = commands
    @sprites["list"].index = 0
    @mode = 1
  end

  # End the scene here
  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end

  def pbShowCommands(commands)
    UIHelper.pbShowCommands(@sprites["msgwindow"], nil, commands) { pbUpdate }
  end

  def pbConfirm(message)
    UIHelper.pbConfirm(@sprites["msgwindow"], message) { pbUpdate }
  end

  def pbGetCommands(list, choices)
    commands = []
    for i in 0...list.length
      pkmn = list[i]
      category = pkmn.species_data.category
      cmd = _INTL("{1} - {2} Pokémon", pkmn.speciesName, category)
      cmd = "<c3=E82010,F8A8B8>" + cmd if choices.include?(i)   # Red text
      commands.push(cmd)
    end
    return commands
  end

  # Processes the scene
  def pbChoosePokemon(canCancel)
    pbActivateWindow(@sprites, "list") {
      loop do
        Graphics.update
        Input.update
        pbUpdate
        if Input.trigger?(Input::BACK) && canCancel
          return -1
        elsif Input.trigger?(Input::USE)
          index = @sprites["list"].index
          if index == @sprites["list"].commands.length - 1 && canCancel
            return -1
          elsif index == @sprites["list"].commands.length - 2 && canCancel && @mode == 2
            return -2
          else
            return index
          end
        end
      end
    }
  end

  def pbUpdateChoices(choices)
    commands = pbGetCommands(@rentals, choices)
    @choices = choices
    if choices.length == 0
      @sprites["help"].text = _INTL("Choisissez le premier Pokémon.")
    elsif choices.length == 1
      @sprites["help"].text = _INTL("Choisissez le deuxième Pokémon.")
    else
      @sprites["help"].text = _INTL("Choisissez le troisième Pokémon.")
    end
    @sprites["list"].commands = commands
  end

  def pbSwapChosen(_pkmnindex)
    commands=pbGetCommands(@newPokemon, [])
    commands.push(_INTL("PKMN POUR ÉCHANGE"))
    commands.push(_INTL("ANNULER"))
    @sprites["help"].text = _INTL("Sélectionnez le Pokémon à accepter.")
    @sprites["list"].commands = commands
    @sprites["list"].index = 0
    @mode = 2
  end

  def pbSwapCanceled
    pbInitSwapScreen
  end

  def pbSummary(list, index)
    visibleSprites = pbFadeOutAndHide(@sprites) { pbUpdate }
    scene = PokemonSummary_Scene.new
    screen = PokemonSummaryScreen.new(scene)
    @sprites["list"].index = screen.pbStartScreen(list, index)
    pbFadeInAndShow(@sprites, visibleSprites) { pbUpdate }
  end

  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end
end



class BattleSwapScreen
  def initialize(scene)
    @scene = scene
  end

  def pbStartRent(rentals)
    @scene.pbStartRentScene(rentals)
    chosen = []
    loop do
      index = @scene.pbChoosePokemon(false)
      commands = []
      commands.push(_INTL("RÉSUMÉ"))
      if chosen.include?(index)
        commands.push(_INTL("DÉSÉLECTIONNER"))
      else
        commands.push(_INTL("LOUER"))
      end
      commands.push(_INTL("AUTRES"))
      command = @scene.pbShowCommands(commands)
      if command == 0
        @scene.pbSummary(rentals, index)
      elsif command == 1
        if chosen.include?(index)
          chosen.delete(index)
          @scene.pbUpdateChoices(chosen.clone)
        else
          chosen.push(index)
          @scene.pbUpdateChoices(chosen.clone)
          if chosen.length == 3
            if @scene.pbConfirm(_INTL("Ces trois Pokémon sont-ils OK?"))
              retval = []
              chosen.each { |i| retval.push(rentals[i]) }
              @scene.pbEndScene
              return retval
            else
              chosen.delete(index)
              @scene.pbUpdateChoices(chosen.clone)
            end
          end
        end
      end
    end
  end

  def pbStartSwap(currentPokemon, newPokemon)
    @scene.pbStartSwapScene(currentPokemon, newPokemon)
    loop do
      pkmn = @scene.pbChoosePokemon(true)
      if pkmn >= 0
        commands = [_INTL("RÉSUMÉ"), _INTL("ÉCHANGER"), _INTL("RECHOISIR")]
        command = @scene.pbShowCommands(commands)
        if command == 0
          @scene.pbSummary(currentPokemon, pkmn)
        elsif command == 1
          @scene.pbSwapChosen(pkmn)
          yourPkmn = pkmn
          loop do
            pkmn = @scene.pbChoosePokemon(true)
            if pkmn >= 0
              if @scene.pbConfirm(_INTL("Accepter ce Pokémon?"))
                @scene.pbEndScene
                currentPokemon[yourPkmn] = newPokemon[pkmn]
                return true
              end
            elsif pkmn == -2
              @scene.pbSwapCanceled
              break   # Back to first screen
            elsif pkmn == -1
              if @scene.pbConfirm(_INTL("Arrêtez d'échanger?"))
                @scene.pbEndScene
                return false
              end
            end
          end
        end
      else
        # Canceled
        if @scene.pbConfirm(_INTL("Arrêtez d'échanger?"))
          @scene.pbEndScene
          return false
        end
      end
    end
  end
end
