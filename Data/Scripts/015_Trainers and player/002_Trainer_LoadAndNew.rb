#===============================================================================
#
#===============================================================================
#

def getTrainersDataMode
  mode = GameData::Trainer
  if $game_switches && $game_switches[SWITCH_MODERN_MODE]
    mode = GameData::TrainerModern
  elsif $game_switches && $game_switches[SWITCH_EXPERT_MODE]
    mode = GameData::TrainerExpert
  end
  return mode
end

def pbLoadTrainer(tr_type, tr_name, tr_version = 0)
  tr_type_data = GameData::TrainerType.try_get(tr_type)
  raise _INTL("Le type de dresseur {1} n'existe pas.", tr_type) if !tr_type_data
  tr_type = tr_type_data.id
  trainer_data = getTrainersDataMode.try_get(tr_type, tr_name, tr_version)
  if !trainer_data
    trainer_data = GameData::Trainer.try_get(tr_type, tr_name, tr_version)
  end
  return (trainer_data) ? trainer_data.to_trainer : nil
end

def pbNewTrainer(tr_type, tr_name, tr_version, save_changes = true)
  party = []
  for i in 0...Settings::MAX_PARTY_SIZE
    if i == 0
      pbMessage(_INTL("Veuillez saisir le premier Pokémon.", i))
    else
      break if !pbConfirmMessage(_INTL("Ajouter un autre Pokémon?"))
    end
    loop do
      species = pbChooseSpeciesList
      if species
        params = ChooseNumberParams.new
        params.setRange(1, GameData::GrowthRate.max_level)
        params.setDefaultValue(10)
        level = pbMessageChooseNumber(_INTL("Réglez le niveau sur {1} (max. #{params.maxNumber}).",
                                            GameData::Species.get(species).name), params)
        party.push([species, level])
        break
      else
        break if i > 0
        pbMessage(_INTL("Ce dresseur doit avoir au moins 1 Pokémon!"))
      end
    end
  end
  trainer = [tr_type, tr_name, [], party, tr_version]
  if save_changes
    trainer_hash = {
      :id_number => getTrainersDataMode::DATA.keys.length / 2,
      :trainer_type => tr_type,
      :name => tr_name,
      :version => tr_version,
      :pokemon => []
    }
    party.each do |pkmn|
      trainer_hash[:pokemon].push({
                                    :species => pkmn[0],
                                    :level => pkmn[1]
                                  })
    end
    # Add trainer's data to records
    trainer_hash[:id] = [trainer_hash[:trainer_type], trainer_hash[:name], trainer_hash[:version]]
    getTrainersDataMode.register(trainer_hash)
    getTrainersDataMode.save
    pbConvertTrainerData
    pbMessage(_INTL("Les données du dresseur ont été ajoutées à la liste des batailles et dans PBS/trainers.txt."))
  end
  return trainer
end

def pbConvertTrainerData
  tr_type_names = []
  GameData::TrainerType.each { |t| tr_type_names[t.id_number] = t.real_name }
  MessageTypes.setMessages(MessageTypes::TrainerTypes, tr_type_names)
  Compiler.write_trainer_types
  Compiler.write_trainers
end

def pbTrainerTypeCheck(trainer_type)
  return true if !$DEBUG
  return true if GameData::TrainerType.exists?(trainer_type)
  if pbConfirmMessage(_INTL("Ajouter un nouveau type de dresseur {1}?", trainer_type.to_s))
    pbTrainerTypeEditorNew(trainer_type.to_s)
  end
  pbMapInterpreter.command_end if pbMapInterpreter
  return false
end

# Called from trainer events to ensure the trainer exists
def pbTrainerCheck(tr_type, tr_name, max_battles, tr_version = 0)
  return true if !$DEBUG
  # Check for existence of trainer type
  pbTrainerTypeCheck(tr_type)
  tr_type_data = GameData::TrainerType.try_get(tr_type)
  return false if !tr_type_data
  tr_type = tr_type_data.id
  # Check for existence of trainer with given ID number
  return true if getTrainersDataMode.exists?(tr_type, tr_name, tr_version)
  # Add new trainer
  if pbConfirmMessage(_INTL("Ajouter une nouvelle variante de dresseur {1} (of {2}) pour {3} {4}?",
                            tr_version, max_battles, tr_type.to_s, tr_name))
    pbNewTrainer(tr_type, tr_name, tr_version)
  end
  return true
end

def pbGetFreeTrainerParty(tr_type, tr_name)
  tr_type_data = GameData::TrainerType.try_get(tr_type)
  raise _INTL("Le type de dresseur {1} n'existe pas.", tr_type) if !tr_type_data
  tr_type = tr_type_data.id
  for i in 0...256
    return i if !getTrainersDataMode.try_get(tr_type, tr_name, i)
  end
  return -1
end

def pbMissingTrainer(tr_type, tr_name, tr_version)
  tr_type_data = GameData::TrainerType.try_get(tr_type)
  raise _INTL("Le type de dresseur {1} n'existe pas.", tr_type) if !tr_type_data
  tr_type = tr_type_data.id
  if !$DEBUG
    #raise _INTL("Can't find trainer ({1}, {2}, ID {3})", tr_type.to_s, tr_name, tr_version)
    message = ""
    if $game_switches[SWITCH_MODERN_MODE]
      message << "[MODERN MODE] "
    end
    message << "This trainer appears to be missing from the game. Please report this on the game's Discord channel whenever you get a chance."
    pbMessage(message)
    return 1
  end
  message = ""
  if tr_version != 0
    message = _INTL("Ajouter un nouveau dresseur ({1}, {2}, ID {3})?", tr_type.to_s, tr_name, tr_version)
  else
    message = _INTL("Ajouter un nouveau dresseur ({1}, {2})?", tr_type.to_s, tr_name)
  end
  cmd = pbMessage(message, [_INTL("Oui"), _INTL("Non")], 2)
  pbNewTrainer(tr_type, tr_name, tr_version) if cmd == 0
  return cmd
end
