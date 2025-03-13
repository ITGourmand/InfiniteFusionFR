#==============================================================================
# * Scene_Controls
#------------------------------------------------------------------------------
# Shows a help screen listing the keyboard controls.
# Display with:
#      pbEventScreen(ButtonEventScene)
#==============================================================================
class ButtonEventScene < EventScene
  def initialize(viewport = nil)
    super
    Graphics.freeze
    @current_screen = 1
    addImage(0, 0, "Graphics/Pictures/Controls help/help_bg")
    @labels = []
    @label_screens = []
    @keys = []
    @key_screens = []

    addImageForScreen(1, 44, 122, "Graphics/Pictures/Controls help/help_f1")
    addImageForScreen(1, 44, 252, "Graphics/Pictures/Controls help/help_f8")
    addLabelForScreen(1, 134, 84, 352, _INTL("Ouvre la fenêtre Raccourcis clavier, dans laquelle vous pouvez choisir les touches du clavier à utiliser pour chaque contrôle."))
    addLabelForScreen(1, 134, 244, 352, _INTL("Prenez une capture d'écran. Elle est placée dans le même dossier que le fichier de sauvegarde."))

    addImageForScreen(2, 16, 158, "Graphics/Pictures/Controls help/help_arrows")
    addLabelForScreen(2, 134, 100, 352, _INTL("Utilisez les touches fléchées pour déplacer le personnage.\r\n\r\nVous pouvez aussi utiliser les touches fléchées pour sélectionner des entrées et naviguer dans les menus."))

    addImageForScreen(3, 16, 106, "Graphics/Pictures/Controls help/help_usekey")
    addImageForScreen(3, 16, 236, "Graphics/Pictures/Controls help/help_backkey")
    addLabelForScreen(3, 134, 84, 352, _INTL("Utilisé pour confirmer un choix, interagir avec des personnes et des objets et parcourir du texte. (Default: C)"))
    addLabelForScreen(3, 134, 212, 352, _INTL("Permet de quitter, d'annuler un choix et d'annuler un mode. Permet également d'ouvrir le menu Pause. (Default: X)"))

    addImageForScreen(4, 16, 90, "Graphics/Pictures/Controls help/help_actionkey")
    addImageForScreen(4, 16, 252, "Graphics/Pictures/Controls help/help_specialkey")
    addLabelForScreen(4, 134, 52, 352, _INTL("Possède diverses fonctions selon le contexte. Tout en vous déplaçant, maintenez enfoncé pour vous déplacer à une vitesse différente. (Default: Z)"))
    addLabelForScreen(4, 134, 212, 352, _INTL("Appuyez pour ouvrir le menu, où les éléments enregistrés et les déplacements de champ disponibles peuvent être utilisés. (Default: D)"))

    set_up_screen(@current_screen)
    Graphics.transition(20)
    # Go to next screen when user presses USE
    onCTrigger.set(method(:pbOnScreenEnd))
  end

  def addLabelForScreen(number, x, y, width, text)
    @labels.push(addLabel(x, y, width, text))
    @label_screens.push(number)
    @picturesprites[@picturesprites.length - 1].opacity = 0
  end

  def addImageForScreen(number, x, y, filename)
    @keys.push(addImage(x, y, filename))
    @key_screens.push(number)
    @picturesprites[@picturesprites.length - 1].opacity = 0
  end

  def set_up_screen(number)
    @label_screens.each_with_index do |screen, i|
      @labels[i].moveOpacity((screen == number) ? 10 : 0, 10, (screen == number) ? 255 : 0)
    end
    @key_screens.each_with_index do |screen, i|
      @keys[i].moveOpacity((screen == number) ? 10 : 0, 10, (screen == number) ? 255 : 0)
    end
    pictureWait   # Update event scene with the changes
  end

  def pbOnScreenEnd(scene, *args)
    last_screen = [@label_screens.max, @key_screens.max].max
    if @current_screen >= last_screen
      # End scene
      Graphics.freeze
      Graphics.transition(20, "fadetoblack")
      scene.dispose
    else
      # Next screen
      @current_screen += 1
      onCTrigger.clear
      set_up_screen(@current_screen)
      onCTrigger.set(method(:pbOnScreenEnd))
    end
  end
end
