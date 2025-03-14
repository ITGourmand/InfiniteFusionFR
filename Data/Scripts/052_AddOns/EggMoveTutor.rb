def pbRelearnEggMoveScreen(pkmn)
  retval = true
  pbFadeOutIn {
    scene = MoveRelearner_Scene.new
    screen = MoveRelearnerScreen.new(scene)
    retval = screen.pbStartScreenEgg(pkmn)
  }
  return retval
end

class MoveRelearnerScreen
  def pbStartScreenEgg(pkmn)
    baby = pbGetBabySpecies(pkmn.species)
    moves = pbGetSpeciesEggMoves(baby)

    @scene.pbStartScene(pkmn, moves)
    loop do
      move = @scene.pbChooseMove
      if move
        if @scene.pbConfirm(_INTL("A appris {1}?", GameData::Move.get(move).name))
          if pbLearnMove(pkmn, move)
            @scene.pbEndScene
            return true
          end
        end
      elsif @scene.pbConfirm(_INTL("Arrêtez d'essayer d'enseigner un nouveau move à {1}?", pkmn.name))
        @scene.pbEndScene
        return false
      end
    end
  end
end
