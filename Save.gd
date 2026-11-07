extends HTTPRequest

func _ready() -> void:
	request_completed.connect(_on_request_completed)

func _save():
	if Auth.auth_user_id.is_empty() or Auth.access_token.is_empty():
		push_error("Cannot save code: player is not signed in.")
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
	if Auth.auth_user_id.is_empty() or Auth.access_token.is_empty():
		push_error("Cannot load code: player is not signed in.")
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
	if result != HTTPRequest.RESULT_SUCCESS:
		push_error("The request failed " + str(result))
		return
	if response_code != 200:
		push_error("Supabase returned %d: %s" % [response_code, body.get_string_from_utf8()])
		return
	
	var rows: Variant = JSON.parse_string(body.get_string_from_utf8())
	if typeof(rows) != TYPE_ARRAY:
		push_error("Supabase returned an unexpected response")
		return
	if rows.is_empty():
		print("No saved code for this level.")
		return
	var editor := get_tree().get_first_node_in_group("Code Editor")
	if editor == null:
		push_error("Code Editor node was not found.")
		return
	editor.text = str(rows[0].get("code", ""))
