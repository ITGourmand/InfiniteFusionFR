#===============================================================================
#
#===============================================================================
class TrainerPC
  def shouldShow?
    return true
  end

  def name
    return _INTL("PC de {1}",$Trainer.name)
  end

  def access
    pbMessage(_INTL("\\se[PC access]A accédé au PC de {1} .",$Trainer.name))
    pbTrainerPCMenu
  end
end

#===============================================================================
#
#===============================================================================
class StorageSystemPC
  def shouldShow?
    return true
  end

  def name
    return "Stockage de Pokemon"
    #if $Trainer.seen_storage_creator
    #  return _INTL("{1}'s PC",pbGetStorageCreator)
    #else
    #  return _INTL("Someone's PC")
    #end
  end

  def access
    pbMessage(_INTL("\\se[PC access]Le système de stockage des Pokémon a été ouvert.."))
    command = 0
    loop do
      command = pbShowCommandsWithHelp(nil,
         [_INTL("Organiser / fusionner"),
         _INTL("Retirer un Pokémon"),
         _INTL("Déposer un Pokémon"),
         _INTL("Eteindre le PC")],
         [_INTL("Organisez les Pokémon dans les boîtes et dans votre équipe."),
         _INTL("Déplacez les Pokémon stockés dans les boîtes vers votre équipe."),
         _INTL("Stockez les Pokémon de votre équipe dans des boîtes."),
         _INTL("Retour au menu précédent.")],-1,command
      )
      if command>=0 && command<3
        if command==1   # Withdraw
          if $PokemonStorage.party_full?
            pbMessage(_INTL("Votre équipe est complète!"))
            next
          end
        elsif command==2   # Deposit
          count=0
          for p in $PokemonStorage.party
            count += 1 if p && !p.egg? && p.hp>0
          end
          if count<=1
            pbMessage(_INTL("Impossible de déposer le dernier Pokémon!"))
            next
          end
        end
        pbFadeOutIn {
          scene = PokemonStorageScene.new
          screen = PokemonStorageScreen.new(scene,$PokemonStorage)
          screen.pbStartScreen(command)
        }
      else
        break
      end
    end
  end
end

#===============================================================================
#
#===============================================================================
module PokemonPCList
  @@pclist = []

  def self.registerPC(pc)
    @@pclist.push(pc)
  end

  def self.getCommandList
    commands = []
    for pc in @@pclist
      commands.push(pc.name) if pc.shouldShow?
    end
    commands.push(_INTL("Se Déconnecter"))
    return commands
  end

  def self.callCommand(cmd)
    return false if cmd<0 || cmd>=@@pclist.length
    i = 0
    for pc in @@pclist
      next if !pc.shouldShow?
      if i==cmd
        pc.access
        return true
      end
      i += 1
    end
    return false
  end
end

#===============================================================================
# PC menus
#===============================================================================
def pbPCItemStorage
  command = 0
  loop do
    command = pbShowCommandsWithHelp(nil,
       [_INTL("Retirer l'Objet"),
       _INTL("Déposer un Objet"),
       _INTL("Jeter l'Objet"),
       _INTL("Sortir")],
       [_INTL("Retirer des Objets du PC."),
       _INTL("Stocker des Objets dans le PC.."),
       _INTL("Jeter les Objets stockés dans le PC."),
       _INTL("Retourner au menu précédent.")],-1,command
    )
    case command
    when 0   # Withdraw Item
      if !$PokemonGlobal.pcItemStorage
        $PokemonGlobal.pcItemStorage = PCItemStorage.new
      end
      if $PokemonGlobal.pcItemStorage.empty?
        pbMessage(_INTL("Il n'y a pas d'Objets."))
      else
        pbFadeOutIn {
          scene = WithdrawItemScene.new
          screen = PokemonBagScreen.new(scene,$PokemonBag)
          screen.pbWithdrawItemScreen
        }
      end
    when 1   # Deposit Item
      pbFadeOutIn {
        scene = PokemonBag_Scene.new
        screen = PokemonBagScreen.new(scene,$PokemonBag)
        screen.pbDepositItemScreen
      }
    when 2   # Toss Item
      if !$PokemonGlobal.pcItemStorage
        $PokemonGlobal.pcItemStorage = PCItemStorage.new
      end
      if $PokemonGlobal.pcItemStorage.empty?
        pbMessage(_INTL("Il n'y a pas d'Objets."))
      else
        pbFadeOutIn {
          scene = TossItemScene.new
          screen = PokemonBagScreen.new(scene,$PokemonBag)
          screen.pbTossItemScreen
        }
      end
    else
      break
    end
  end
end

def pbPCMailbox
  if !$PokemonGlobal.mailbox || $PokemonGlobal.mailbox.length==0
    pbMessage(_INTL("Il n'y a pas de courrier ici."))
  else
    loop do
      command = 0
      commands=[]
      for mail in $PokemonGlobal.mailbox
        commands.push(mail.sender)
      end
      commands.push(_INTL("Annuler"))
      command = pbShowCommands(nil,commands,-1,command)
      if command>=0 && command<$PokemonGlobal.mailbox.length
        mailIndex = command
        commandMail = pbMessage(_INTL("Que voulez-vous faire du courrier de {1} ?",
           $PokemonGlobal.mailbox[mailIndex].sender),[
           _INTL("Lire"),
           _INTL("Déplacer dans le sac"),
           _INTL("Donner"),
           _INTL("Annuler")
           ],-1)
        case commandMail
        when 0   # Read
          pbFadeOutIn {
            pbDisplayMail($PokemonGlobal.mailbox[mailIndex])
          }
        when 1   # Move to Bag
          if pbConfirmMessage(_INTL("Le message sera perdu. Cela vous convient-il?"))
            if $PokemonBag.pbStoreItem($PokemonGlobal.mailbox[mailIndex].item)
              pbMessage(_INTL("Le courrier a été remis dans le sac avec son message effacé."))
              $PokemonGlobal.mailbox.delete_at(mailIndex)
            else
              pbMessage(_INTL("Le sac est plein."))
            end
          end
        when 2   # Give
          pbFadeOutIn {
            sscene = PokemonParty_Scene.new
            sscreen = PokemonPartyScreen.new(sscene,$Trainer.party)
            sscreen.pbPokemonGiveMailScreen(mailIndex)
          }
        end
      else
        break
      end
    end
  end
end

def pbTrainerPCMenu
  command = 0
  loop do
    command = pbMessage(_INTL("Que voulez-vous faire?"),[
       _INTL("Stockage des Objets"),
       _INTL("Mail"),
       _INTL("Éteindre")
       ],-1,nil,command)
    case command
    when 0 then pbPCItemStorage
    when 1 then pbPCMailbox
    else        break
    end
  end
end

def pbTrainerPC
  pbMessage(_INTL("\\se[PC open]{1} a démarré le PC.",$Trainer.name))
  pbTrainerPCMenu
  pbSEPlay("PC fermé")
end

def checkPorygonEncounter
  porygon_chance = 200
  if $PokemonGlobal.stepcount % porygon_chance == 0
    pbSEPlay("Paralyze3")
    pbWait(12)
    pbMessage(_INTL("Hein ? Le PC a glitch pendant une seconde lors du démarrage."))
    pbMessage(_INTL("Quelque chose s'est introduit dans le PC?"))
    pbWait(8)
    pbAddPokemonSilent(:PORYGON,1)
    $PokemonGlobal.stepcount += 1
  end
    # code here
end

def pbPokeCenterPC
  pbMessage(_INTL("\\se[PC open]{1} a démarré le PC.",$Trainer.name))
  checkPorygonEncounter()
  command = 0
  loop do
    commands = PokemonPCList.getCommandList
    command = pbMessage(_INTL("Quel est le PC auquel il faut accéder ?"),commands,
       commands.length,nil,command)
    break if !PokemonPCList.callCommand(command)
  end
  pbSEPlay("PC fermé")
end

def pbGetStorageCreator
  creator = Settings.storage_creator_name
  creator = _INTL("Bill") if nil_or_empty?(creator)
  return creator
end

#===============================================================================
#
#===============================================================================
PokemonPCList.registerPC(StorageSystemPC.new)
PokemonPCList.registerPC(TrainerPC.new)
