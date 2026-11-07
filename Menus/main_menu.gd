extends Control

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://Menus/select_level.tscn")


func _on_exit_pressed() -> void:
	get_tree().quit()

func _ready() -> void:
	if not (Auth.auth_user_id.is_empty() or Auth.access_token.is_empty()):
		$VSplitContainer.visible = false
		$signout.visible = true
	
	Auth.signed_in.connect(_on_signed_in)
	Auth.signup_confirmation_required.connect(_on_confirmation_required)
	Auth.auth_error.connect(_on_auth_error)

func _on_signed_in(user: Dictionary) -> void:
	print("Signed in. User ID: ", user.get("id", ""))
	$VSplitContainer.visible = false
	$signout.visible = true

func _on_confirmation_required(email: String) -> void:
	print("Check your email to confirm: ", email)

func _on_auth_error(message: String) -> void:
	get_tree().get_first_node_in_group("Login Error").text = message


func _on_signin_pressed() -> void:
	Auth.sign_in($VSplitContainer/Email.text, $VSplitContainer/Password.text)


func _on_signup_pressed() -> void:
	Auth.sign_up($VSplitContainer/Email.text, $VSplitContainer/Password.text)


func _on_signout_pressed() -> void:
	Auth.sign_out()
	$VSplitContainer.visible = true
	$signout.visible = false
