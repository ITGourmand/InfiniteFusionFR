#===============================================================================
# Pokédex Regional Dexes list menu screen
# * For choosing which region list to view. Only appears when there is more
#   than one accessible region list to choose from, and if
#   Settings::USE_CURRENT_REGION_DEX is false.
#===============================================================================
class Window_DexesList < Window_CommandPokemon
  def initialize(commands,commands2,width)
    @commands2 = commands2
    super(commands,width)
    @selarrow = AnimatedBitmap.new("Graphics/Pictures/selarrow_white")
    self.baseColor   = Color.new(248,248,248)
    self.shadowColor = Color.new(0,0,0)
    self.windowskin  = nil
  end

  def drawItem(index,count,rect)
    super(index,count,rect)
    if index>=0 && index<@commands2.length
      pbDrawShadowText(self.contents,rect.x+254,rect.y,64,rect.height,
         sprintf("%d",@commands2[index][0]),self.baseColor,self.shadowColor,1)
      pbDrawShadowText(self.contents,rect.x+350,rect.y,64,rect.height,
         sprintf("%d",@commands2[index][1]),self.baseColor,self.shadowColor,1)
      allseen = (@commands2[index][0]>=@commands2[index][2])
      allown  = (@commands2[index][1]>=@commands2[index][2])
      pbDrawImagePositions(self.contents,[
        ["Graphics/Pictures/Pokedex/icon_menuseenown",rect.x+236,rect.y+2,(allseen) ? 24 : 0,0,24,24],
        ["Graphics/Pictures/Pokedex/icon_menuseenown",rect.x+332,rect.y+2,(allown) ? 24 : 0,24,24,24]
      ])
    end
  end
end

#===============================================================================
#
#===============================================================================
class PokemonPokedexMenu_Scene
  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

  def pbStartScene(commands,commands2)
    @commands = commands
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    @sprites["background"] = IconSprite.new(0,0,@viewport)
    @sprites["background"].setBitmap(_INTL("Graphics/Pictures/Pokedex/bg_menu"))
    @sprites["headings"]=Window_AdvancedTextPokemon.newWithSize(
       _INTL("<c3=F8F8F8,C02028>SEEN<r>OBTAINED</c3>"),286,136,208,64,@viewport)
    @sprites["headings"].windowskin  = nil
    @sprites["commands"] = Window_DexesList.new(commands,commands2,Graphics.width-84)
    @sprites["commands"].x      = 40
    @sprites["commands"].y      = 192
    @sprites["commands"].height = 192
    @sprites["commands"].viewport = @viewport
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbScene
    ret = -1
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::BACK)
        pbPlayCloseMenuSE
        break
      elsif Input.trigger?(Input::USE)
        ret = @sprites["commands"].index
        (ret==@commands.length-1) ? pbPlayCloseMenuSE : pbPlayDecisionSE
        break
      end
    end
    return ret
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end

#===============================================================================
#
#===============================================================================
class PokemonPokedexMenuScreen
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen
    commands  = []
    commands2 = []
    dexnames = Settings.pokedex_names
    $Trainer.pokedex.accessible_dexes.each do |dex|
      if dexnames[dex].nil?
        commands.push(_INTL("Pokédex Complet"))
      elsif dexnames[dex].is_a?(Array)
        commands.push(dexnames[dex][0])
      else
        commands.push(dexnames[dex])
      end
      commands2.push([$Trainer.pokedex.seen_count(dex),
                      $Trainer.pokedex.owned_count(dex),
                      pbGetRegionalDexLength(dex)])
    end

    commands.push(_INTL("Pokémon possédé"))

    commands.push(_INTL("Quitter"))
    @scene.pbStartScene(commands,commands2)
    loop do
      cmd = @scene.pbScene
      break if cmd<0 || cmd>1   # Cancel/Exit
      $PokemonGlobal.pokedexDex = $Trainer.pokedex.accessible_dexes[0]
      only_owned = cmd == 1
      pbFadeOutIn {
        scene = PokemonPokedex_Scene.new
        screen = PokemonPokedexScreen.new(scene)
        screen.pbStartScreen(only_owned)
      }
    end
    @scene.pbEndScene
  end
end
