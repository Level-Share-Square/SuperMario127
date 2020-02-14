extends Resource

class_name Level

var formatVersion: String = "0.1.0";
var name: String = "My Level";
var areas = [];

func getVector2(result) -> Vector2:
	return Vector2(result.x, result.y);

func getArea(result) -> LevelArea:
	var area = LevelArea.new();
	area.settings = getSettings(result.settings);
	area.backgroundTiles = result.backgroundTiles;
	area.foregroundTiles = result.foregroundTiles;
	for objectResult in result.objects:
		var object = getObject(objectResult);
		area.objects.append(object);
	return area;
	
func getSettings(result) -> LevelAreaSettings:
	var settings = LevelAreaSettings.new();
	settings.background = result.background;
	settings.music = result.music;
	settings.size = getVector2(result.size);
	settings.spawn = getVector2(result.spawn);
	return settings;

func getObject(result) -> LevelObject:
	var object = LevelObject.new();
	object.type = result.type;
	object.properties = result.properties;
	return object;

func loadIn(json: LevelJSON):
	var parse = JSON.parse(json.contents);
	if parse.error != 0:
		print("Error " + parse.error_string + " at line " + parse.error_line);
		
	var result = parse.result;
	assert(result.formatVersion);
	assert(result.name);
	formatVersion = result.formatVersion;
	name = result.name;
	if formatVersion == "0.1.0":
		for areaResult in result.areas:
			var area = getArea(areaResult);
			areas.append(area);
		print(areas[0].settings.background)
	else:
		print("Incorrect format version, current version is 0.1.0 level uses version " + formatVersion);

func save() -> String:
	return "";
