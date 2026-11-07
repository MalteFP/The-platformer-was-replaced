extends Node

signal signed_in(user: Dictionary)
signal signup_confirmation_required(email: String)
signal auth_error(message: String)

const SUPABASE_URL := "https://hjwhxpngkxvruzjvfgup.supabase.co"
const SUPABASE_KEY := "sb_publishable_d7hodaYb7n8Jdqr-T7CZyw_xLk8ZeEt"

var access_token := ""
var refresh_token := ""
var current_user: Dictionary = {}
var auth_user_id: String = ""


var _http: HTTPRequest
var _busy := false
var _action := ""
var _pending_email := ""

var pending_auth_action

func _ready() -> void:
	_http = HTTPRequest.new()
	add_child(_http)
	_http.request_completed.connect(_on_request_completed)

func sign_up(email: String, password: String) -> void:
	_pending_email = email
	_send("/auth/v1/signup", {"email": email, "password": password}, "signup")

func sign_in(email: String, password: String) -> void:
	_send(
		"/auth/v1/token?grant_type=password",
		{"email": email, "password": password},
        "signin"
	)

func sign_out() -> void:
	if _busy:
		auth_error.emit("Please wait for the current request to finish")
		return
	if access_token.is_empty():
		clear_saved_session()
		return
	_busy = true
	pending_auth_action = "sign_out"
	var headers := PackedStringArray([
		"apikey: " + SUPABASE_KEY,
		"Authorization: Bearer " + access_token
	])
	var err = _http.request(
		SUPABASE_URL + "/auth/v1/logout?scope=local",
		headers,
		HTTPClient.METHOD_POST
	)
	if err != OK:
		_busy = false
		pending_auth_action = ""
		push_error("Could not start sign-out request: %s" % err)

func _send(path: String, payload: Dictionary, action: String) -> void:
	if _busy:
		auth_error.emit("Please wait for the current request to finish.")
		return

	_busy = true
	_action = action

	var headers := PackedStringArray([
		"apikey: " + SUPABASE_KEY,
        "Content-Type: application/json"
	])

	var err := _http.request(
		SUPABASE_URL + path,
		headers,
		HTTPClient.METHOD_POST,
		JSON.stringify(payload)
	)

	if err != OK:
		_busy = false
		auth_error.emit("Could not start request: " + str(err))

func clear_saved_session():
	access_token = ""
	refresh_token = ""
	current_user= {}
	auth_user_id = ""

func _on_request_completed(_result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var completed_action = pending_auth_action
	pending_auth_action = ""
	_busy = false
	if completed_action == "sign_out" and response_code >= 200 and response_code < 300:
		clear_saved_session()
		return
	var text := body.get_string_from_utf8()
	var data = JSON.parse_string(text)

	
	if response_code < 200 or response_code >= 300:
		var message := text
		if data is Dictionary:
			message = str(data.get("msg", data.get("message", text)))
		auth_error.emit(message)
		return

	if not data is Dictionary:
		auth_error.emit("Supabase returned an unexpected response.")
		return

	if _action == "signup" and str(data.get("access_token", "")).is_empty():
		signup_confirmation_required.emit(_pending_email)
		return
	
	access_token = str(data.get("access_token", ""))
	refresh_token = str(data.get("refresh_token", ""))
	var user_data: Variant = data.get("user", {})
	if not user_data is Dictionary:
		user_data = {}
	current_user = user_data
	auth_user_id = str(current_user.get("id", ""))
	if auth_user_id.is_empty():
		clear_saved_session()
		auth_error.emit("Authentication succeeded, but the response did not include a user ID.")
	signed_in.emit(current_user)
