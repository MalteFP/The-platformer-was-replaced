extends Node
class_name DatabaseRequest
signal succeded(data: Variant)
signal failed(status_code: int, message: String)

var http: HTTPRequest

const SUPABASE_URL := "https://hjwhxpngkxvruzjvfgup.supabase.co/rest/v1/"
const SUPABASE_KEY := "sb_publishable_d7hodaYb7n8Jdqr-T7CZyw_xLk8ZeEt"

var endpoint_path: String

func _init(path: String) -> void:
	endpoint_path = path

func _ready() -> void:
	http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_on_request_completed)
	var path := endpoint_path
	if path.begins_with("/"):
		path = path.substr(1)
	var bearer_token := SUPABASE_KEY
	if not Auth.access_token.is_empty():
		bearer_token = Auth.access_token
	var headers := PackedStringArray([
	
"apikey: "
 + SUPABASE_KEY,
	
"Authorization: Bearer "
 + bearer_token,
	
"Accept: application/json"

])

	var err := http.request(
		SUPABASE_URL + "/" + path,
		headers,
		HTTPClient.METHOD_GET
	)

	if err != OK:
		push_error("Could not start request: " + str(err))

func _on_request_completed(
		_result: int,
		response_code: int,
		_headers: PackedStringArray,
		body: PackedByteArray
) -> void:
	var text := body.get_string_from_utf8()
	if response_code < 200 or response_code >= 300:
		failed.emit(response_code, text)
		return
	var data = JSON.parse_string(text)
	if data == null:
		failed.emit(response_code, "Could not parse the JSON response.")
		return
	succeded.emit(data)
