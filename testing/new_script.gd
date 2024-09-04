extends Node

const TEMP_DATA_SUFFIX: String = "~0*0~0*0~0*0~0*0]"

func load_code():
	var start_time = OS.get_system_time_msecs()
	
	var passed_level_code: String = saved_levels_util.load_level_code_file("user://level_list/caa6d28b-6dc9-4d66-aa46-6af92b484495.127level")
	var level_info := LevelInfo.new(passed_level_code)
	
	print(OS.get_system_time_msecs() - start_time)
