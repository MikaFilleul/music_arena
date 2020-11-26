extends Node

var _settings = {
	"audio":{
		"son": 42.0 ,
		"musique": 42.0
	},
	"controles":{
		"gauche": 1,
		"droite": 1,
		"saut": 1
	},
	"jeu":{
		"anim":false ,
		"fullscreen":false
	}
}

#settings par défaut
var defaultSavePath = "user://defaultSettingsFile.cfg"
var defaultConfig = ConfigFile.new()
var loadDefaultResponse = defaultConfig.load(defaultSavePath)

#settings enregistrés par l'utilisateur
var savePath = "user://saveFile.cfg"
var config = ConfigFile.new()
var loadResponse = config.load(savePath)


func _ready():
	saveDefaultValue(_settings)
	
	if(config.load(savePath) == OK):
		loadValue()
	else:
		loadDefaultValue()


func saveValue(settings):
	for section in settings.keys():
		for key in settings[section]:
			config.set_value(section, key, settings[section][key])
			
	config.save(savePath)
	
func saveDefaultValue(settings):
	for section in settings.keys():
		for key in settings[section]:
			defaultConfig.set_value(section, key, settings[section][key])
			
	defaultConfig.save(defaultSavePath)		
	
func loadDefaultValue():
	#soundValue = defaultConfig.get_value(section, key, soundValue)
	#return soundValue
	var error = defaultConfig.load(defaultSavePath)
	
	if error != OK:
		print("Erreur lors du chargement de %s" % error)
		return null
		
	for section in _settings.keys():
		for key in _settings[section]:
			_settings[section][key] = defaultConfig.get_value(section,key, null)
			
	return _settings
		
	
	
	
func loadValue():
	var error = config.load(savePath)
	
	
	if error != OK:
		print("Erreur lors du chargement de %s" % error)
		return []
		
	for section in _settings.keys():
		for key in _settings[section]:
			_settings[section][key] = config.get_value(section,key, null)
			
			
	return _settings
	
