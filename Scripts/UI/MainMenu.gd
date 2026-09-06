extends Control

@onready var btn_jogar = $VBoxContainer/BtnJogar
@onready var btn_sair = $VBoxContainer/BtnSair

func _ready():
	btn_jogar.pressed.connect(_on_jogar_pressed)
	btn_sair.pressed.connect(_on_sair_pressed)

func _on_jogar_pressed():
	get_tree().change_scene_to_file("res://Scenes/World/TestLevel.tscn")

func _on_sair_pressed():
	get_tree().quit()
