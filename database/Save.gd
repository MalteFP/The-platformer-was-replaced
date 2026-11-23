extends HTTPRequest

var pending_action


func _ready() -> void:
	request_completed.connect(_on_request_completed)

func _save():
	pending_action = "save"
	if Auth.auth_user_id.is_empty() or Auth.access_token.is_empty():
		print("Cannot save code: player is not signed in.")
		return
	var row := {
		"user_id": Auth.auth_user_id,
		"level_id": ScreenHolder.currentScreenNum,
		"code": get_tree().get_first_node_in_group("Code Editor").text
	}
	
	var headers := PackedStringArray([
		"apikey: " + Auth.SUPABASE_KEY,
		"Authorization: Bearer " + Auth.access_token,
		"Content-Type: application/json",
		"Prefer: resolution=merge-duplicates,return=minimal"
	])
	
	request(
		Auth.SUPABASE_URL + "/rest/v1/player_level_code?on_conflict=user_id,level_id",
		headers,
		HTTPClient.METHOD_POST,
		JSON.stringify(row)
	)


func _load_code():
	pending_action = "load"
	if Auth.auth_user_id.is_empty() or Auth.access_token.is_empty():
		print("Cannot load code: player is not signed in.")
		return
	var url := "%s/rest/v1/player_level_code?select=code&user_id=eq.%s&level_id=eq.%s" % [
	Auth.SUPABASE_URL.trim_suffix("/"),
	Auth.auth_user_id,
	str(int(ScreenHolder.currentScreenNum))
]
	
	var headers := PackedStringArray([
		"apikey: " + Auth.SUPABASE_KEY,
		"Authorization: Bearer " + Auth.access_token
	])
	
	var err := request(url, headers, HTTPClient.METHOD_GET)
	if err != OK:
		push_error("Could not start load request: " + str(err))



func _on_request_completed(result: int, response_code: int, _response_headers: PackedStringArray, body: PackedByteArray) -> void:
	if pending_action == "save":
		return
	if result != HTTPRequest.RESULT_SUCCESS:
		push_error("The request failed " + str(result))
		return

	if pending_action == "set_completed":
		if response_code != 200 and response_code != 201 and response_code != 204:
			push_error("Supabase returned %d: %s" % [response_code, body.get_string_from_utf8()])
		return
	if pending_action == "load_completions":
		if response_code != 200:
			push_error("Supabase returned %d: %s" % [
				response_code,
				body.get_string_from_utf8()
			])
			return

		var rows: Variant = JSON.parse_string(body.get_string_from_utf8())
		if typeof(rows) != TYPE_ARRAY:
			push_error("Supabase returned an unexpected completion response.")
			return

		var completions: Array[bool] = []
		for i in range(_completion_level_count):
			completions.append(false)

		for row in rows:
			if typeof(row) != TYPE_DICTIONARY:
				continue

			var level_id := int(row.get("level_id", -1))
			if level_id >= 0 and level_id < completions.size():
				completions[level_id] = bool(row.get("completed", false))

		level_completions_loaded.emit(completions)
		return
	if response_code != 200:
		push_error("Supabase returned %d: %s" % [response_code, body.get_string_from_utf8()])
		return

	var r: Variant = JSON.parse_string(body.get_string_from_utf8())
	if typeof(r) != TYPE_ARRAY:
		push_error("Supabase returned an unexpected response")
		return
	if r.is_empty():
		print("No saved code for this level.")
		return
	var editor := get_tree().get_first_node_in_group("Code Editor")
	if editor == null:
		push_error("Code Editor node was not found.")
		return
	editor.text = str(r[0].get("code", ""))

func _set_completed(is_completed: bool) -> void:
	pending_action = "set_completed"
	if Auth.auth_user_id.is_empty() or Auth.access_token.is_empty():
		print("Cannot set completion: player is not signed in.")
		return

	var row := {
		"user_id": Auth.auth_user_id,
		"level_id": ScreenHolder.currentScreenNum,
		"completed": is_completed
	}

	var headers := PackedStringArray([
		"apikey: " + Auth.SUPABASE_KEY,
		"Authorization: Bearer " + Auth.access_token,
		"Content-Type: application/json",
		"Prefer: resolution=merge-duplicates,return=minimal"
	])

	var err := request(
		Auth.SUPABASE_URL.trim_suffix("/") + "/rest/v1/player_level_code?on_conflict=user_id,level_id",
		headers,
		HTTPClient.METHOD_POST,
		JSON.stringify(row)
	)
	if err != OK:
		push_error("Could not start completion request: " + str(err))


signal level_completions_loaded(completions: Array[bool])

var _completion_level_count := 0


func load_level_completions(level_count: int) -> void:
	if Auth.auth_user_id.is_empty() or Auth.access_token.is_empty():
		print("Cannot load completions: player is not signed in.")
		return
	if level_count <= 0:
		push_error("level_count must be greater than zero.")
		return

	pending_action = "load_completions"
	_completion_level_count = level_count

	var url := "%s/rest/v1/player_level_code?select=level_id,completed&user_id=eq.%s" % [
		Auth.SUPABASE_URL.trim_suffix("/"),
		Auth.auth_user_id
	]

	var headers := PackedStringArray([
		"apikey: " + Auth.SUPABASE_KEY,
		"Authorization: Bearer " + Auth.access_token
	])

	var err := request(url, headers, HTTPClient.METHOD_GET)
	if err != OK:
		push_error("Could not start completion request: " + str(err))
