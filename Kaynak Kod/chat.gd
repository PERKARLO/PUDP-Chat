extends Panel

var udp = PacketPeerUDP.new()

func _process(delta):
	if (not udp.is_listening()):
		return
	
	while(udp.get_available_packet_count() > 0):
		var packet = udp.get_var()
		if (typeof(packet) == TYPE_STRING):
				var host = udp.get_packet_ip()
				var port = udp.get_packet_port()
				get_node("chat/text").add_text("(" + host + ":" + str(port) + ":) " + packet)
				get_node("chat/text").newline()

func _ready():
	get_node("chat").add_style_override("panel", get_stylebox("bg", "Tree"))
	set_process(true)

func send_message(text):
	if (udp.is_listening()):
		udp.put_var(text)

func _on_connect_toggled(pressed):
	if (pressed):
		var err = udp.listen(get_node("listen_port").get_val())
		if (err != OK):
			get_node("status").set_text("Hata!")
			get_node("connect").set_pressed(false)
		else:
			get_node("status").set_text("Bağlı")
			get_node("status").set("custom_colors/font_color", Color(0,255,0))
			get_node("connect").set_text("Bağı Kes")
			err = udp.set_send_address(get_node("remote_host").get_text(),get_node("remote_port").get_val())
			if (err != OK):
				get_node("status").set_text("Hata!")
				get_node("connect").set_pressed(false)
			else:
				send_message("# " + get_node("user_name").get_text() + " görüşmeye katıldı.")
	else:
		udp.close()
		get_node("status").set("custom_colors/font_color", Color(255,0,0))
		get_node("status").set_text("Bağlantı Yok")
		get_node("connect").set_text("Bağlan")
		get_node("chat/text").set_text("")

func _on_entry_line_text_entered(text):
	_on_entry_button_pressed()

func _on_entry_button_pressed():
	var msg = get_node("entry_line").get_text()
	if (msg == ""):
		return
	send_message("( " + get_node("user_name").get_text() + " )" + " > " + msg)
	get_node("chat/text").add_text("( " + get_node("user_name").get_text() + " )" + " > " + msg)
	get_node("chat/text").newline()
	get_node("entry_line").set_text("")