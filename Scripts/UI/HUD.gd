extends CanvasLayer

@onready var label_vida = $VBoxContainer/HBoxVida/LabelVida
@onready var label_sanidade = $VBoxContainer/HBoxSanidade/LabelSanidade
@onready var label_loot = $LootLabel

func _ready():
	label_loot.text = ""
	InventoryManager.item_coletado.connect(_on_item_coletado)
	
	# Inicializa a UI com os dados do StatsManager
	_atualizar_vida(StatsManager.pv_atual)
	_atualizar_sanidade(StatsManager.sanidade_atual)
	
	# Conecta os sinais para que a interface se atualize sozinha
	StatsManager.pv_changed.connect(_atualizar_vida)
	StatsManager.sanidade_changed.connect(_atualizar_sanidade)
	StatsManager.enlouquecendo.connect(_on_trauma)

func _atualizar_vida(valor: float):
	# Formata o texto Ex: Vida (PV): 50 / 100
	label_vida.text = "Vida (PV): " + str(int(valor)) + " / " + str(int(StatsManager.max_pv))
	
func _atualizar_sanidade(valor: float):
	label_sanidade.text = "Sanidade: " + str(int(valor)) + " / " + str(int(StatsManager.max_sanidade))

func _on_trauma():
	label_sanidade.text = "ESTADO DE TRAUMA! (CONTROLES INVERTIDOS)"
	label_sanidade.add_theme_color_override("font_color", Color(1, 0, 0)) # Fica vermelho

func _on_item_coletado(nome: String, dano: int):
	# Mostra na tela o item!
	label_loot.text = "VOCÊ ENCONTROU: " + nome + " (Dano: " + str(dano) + ")"
	
	# Espera 3 segundos e apaga o texto
	await get_tree().create_timer(3.0).timeout
	if label_loot.text.begins_with("VOCÊ ENCONTROU: " + nome):
		label_loot.text = ""

