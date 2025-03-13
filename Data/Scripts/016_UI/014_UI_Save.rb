# @deprecated Use {Game.save} instead. pbSave is slated to be removed in v20.
def pbSave(safesave = false)
  Deprecation.warn_method('pbSave', 'v20', 'Game.save')
  Game.save(safe: safesave)
end

def pbEmergencySave
  oldscene = $scene
  $scene = nil
  pbMessage(_INTL("Le script prend trop de temps. Le jeu va redémarrer."))
  return if !$Trainer
  if SaveData.exists?
    File.open(SaveData::FILE_PATH, 'rb') do |r|
      File.open(SaveData::FILE_PATH + '.bak', 'wb') do |w|
        while s = r.read(4096)
          w.write s
        end
      end
    end
  end
  if Game.save
    pbMessage(_INTL("\\se[]Le jeu a été sauvegardé.\\me[GUI save game] la sauvegarde précédente a été restaurée.\\wtnp[30]"))
  else
    pbMessage(_INTL("\\se[]Sauvegarde impossible.\\wtnp[30]"))
  end
  $scene = oldscene
end

#===============================================================================
#
#===============================================================================
class PokemonSave_Scene
  def pbStartScreen
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @sprites={}
    totalsec = Graphics.frame_count / Graphics.frame_rate
    hour = totalsec / 60 / 60
    min = totalsec / 60 % 60
    mapname=$game_map.name
    textColor = ["0070F8,78B8E8","E82010,F8A8B8","0070F8,78B8E8"][$Trainer.gender]
    locationColor = "209808,90F090"   # green
    loctext=_INTL("<ac><c3={1}>{2}</c3></ac>",locationColor,mapname)
    loctext+=_INTL("Joueur<r><c3={1}>{2}</c3><br>",textColor,$Trainer.name)
    if hour>0
      loctext+=_INTL("Temps<r><c3={1}>{2}h {3}m</c3><br>",textColor,hour,min)
    else
      loctext+=_INTL("Temps<r><c3={1}>{2}m</c3><br>",textColor,min)
    end
    loctext+=_INTL("Badges<r><c3={1}>{2}</c3><br>",textColor,$Trainer.badge_count)
    if $Trainer.has_pokedex
      loctext+=_INTL("Pokédex<r><c3={1}>{2}/{3}</c3>",textColor,$Trainer.pokedex.owned_count,$Trainer.pokedex.seen_count)
    end

    @sprites["locwindow"]=Window_AdvancedTextPokemon.new(loctext)
    @sprites["locwindow"].viewport=@viewport
    @sprites["locwindow"].x=0
    @sprites["locwindow"].y=0
    @sprites["locwindow"].width=228 if @sprites["locwindow"].width<228
    @sprites["locwindow"].visible=true
  end

  def pbEndScreen
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end

#===============================================================================
#
#===============================================================================
class PokemonSaveScreen
  def initialize(scene)
    @scene=scene
  end

  def pbDisplay(text,brief=false)
    @scene.pbDisplay(text,brief)
  end

  def pbDisplayPaused(text)
    @scene.pbDisplayPaused(text)
  end

  def pbConfirm(text)
    return @scene.pbConfirm(text)
  end

  def pbSaveScreen
    ret = false
    @scene.pbStartScreen
    if pbConfirmMessage(_INTL('Voulez vous sauvegarder?'))
      if SaveData.exists? && $PokemonTemp.begunNewGame
        pbMessage(_INTL('ATTENTION!'))
        pbMessage(_INTL('Il existe un fichier de jeu différent qui est déjà sauvegardé..'))
        pbMessage(_INTL("Si vous enregistrez maintenant, l'aventure de l'autre fichier, sera entièrement perdue."))
        if !pbConfirmMessageSerious(
            _INTL("Êtes-vous sûr de vouloir enregistrer maintenant et écraser l'autre fichier d'enregistrement ?"))
          pbSEPlay('GUI save choice')
          @scene.pbEndScreen
          return false
        end
      end
      $PokemonTemp.begunNewGame = false
      pbSEPlay('GUI save choice')
      if Game.save
        pbMessage(_INTL("\\se[]{1} à sauvegarder la partie.\\me[GUI save game]\\wtnp[30]", $Trainer.name))
        ret = true
      else
        pbMessage(_INTL("\\se[]Sauvegarde impossible.\\wtnp[30]"))
        ret = false
      end
    else
      pbSEPlay('GUI save choice')
    end
    @scene.pbEndScreen
    return ret
  end
end

#===============================================================================
#
#===============================================================================
def pbSaveScreen
  scene = PokemonSave_Scene.new
  screen = PokemonSaveScreen.new(scene)
  ret = screen.pbSaveScreen
  return ret
end
