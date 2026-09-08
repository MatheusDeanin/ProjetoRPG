extends CanvasLayer

@onready var hp_bar = $StatusPanel/Margin/VBox/HPBar
@onready var label_vida = $StatusPanel/Margin/VBox/HPBar/HPLabel
@onready var mp_bar = $StatusPanel/Margin/VBox/MPBar
@onready var label_sanidade = $StatusPanel/Margin/VBox/MPBar/MPLabel
@onready var label_loot = $LootLabel

@onready var game_over_panel = $GameOverPanel
@onready var btn_retry = $GameOverPanel/VBoxContainer/BtnRetry
@onready var btn_menu = $GameOverPanel/VBoxContainer/BtnMenu

func _ready():
	label_loot.text = ""
	game_over_panel.visible = false
	
	btn_retry.pressed.connect(_on_btn_retry_pressed)
	btn_menu.pressed.connect(_on_btn_menu_pressed)
	
	InventoryManager.item_coletado.connect(_on_item_coletado)
	
	_atualizar_vida(StatsManager.hp_atual)
	_atualizar_mana(StatsManager.mana_atual)
	
	StatsManager.hp_changed.connect(_atualizar_vida)
	StatsManager.mana_changed.connect(_atualizar_mana)
	StatsManager.player_morreu.connect(_on_player_morreu)

func _atualizar_vida(valor: float):
	hp_bar.max_value = StatsManager.max_hp
	hp_bar.value = valor
	label_vida.text = "HP: " + str(int(valor)) + " / " + str(int(StatsManager.max_hp))
	
func _atualizar_mana(valor: float):
	mp_bar.max_value = StatsManager.max_mana
	mp_bar.value = valor
	label_sanidade.text = "MP: " + str(int(valor)) + " / " + str(int(StatsManager.max_mana))

func _on_player_morreu():
	game_over_panel.visible = true

func _on_item_coletado(nome: String, dano: int):
	label_loot.text = "NOVO ITEM: " + nome + " (Dano: " + str(dano) + ")"
	await get_tree().create_timer(3.0).timeout
	if label_loot.text.begins_with("NOVO ITEM: " + nome):
		label_loot.text = ""

func _on_btn_retry_pressed():
	StatsManager.resetar_status()
	get_tree().reload_current_scene()

func _on_btn_menu_pressed():
	StatsManager.resetar_status()
	get_tree().change_scene_to_file("res://Scenes/UI/MainMenu.tscn")
