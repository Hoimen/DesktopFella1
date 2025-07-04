extends VBoxContainer



func _on_send_pressed() -> void:
	var prompt = $HBoxContainer/UserInput.text
	$OutputText.text = "\nUster: "+ prompt + "\nAssistant: " 
	$ChatRequester.send_message(prompt)
	$ChatRequester.start_response()


func _on_chat_requester_new_word(word: String) -> void:
	$OutputText.text += word
	
