extends Control

@onready var lista = $Panel/VBoxContainer/ItemList
@onready var btn_fechar = $Panel/VBoxContainer/BtnFechar
@onready var lbl_equipada = $Panel/VBoxContainer/LblEquipada

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS # Funciona mesmo com o jogo pausado
	visible = false
	btn_fechar.pressed.connect(fechar_inventario)
	lista.item_activated.connect(_on_item_ativado)

func _process(_delta):
	if Input.is_action_just_pressed("inventario"):
		if visible:
			fechar_inventario()
		else:
			abrir_inventario()

func abrir_inventario():
	visible = true
	get_tree().paused = true # Pausa o jogo
	atualizar_lista()

func fechar_inventario():
	visible = false
	get_tree().paused = false # Despausa o jogo

func atualizar_lista():
	lista.clear()
	for arma in InventoryManager.armas_coletadas:
		lista.add_item(arma)
	
	if InventoryManager.arma_equipada:
		lbl_equipada.text = "Arma Equipada: " + InventoryManager.arma_equipada
	else:
		lbl_equipada.text = "Arma Equipada: Nenhuma"

# Quando der clique duplo em um item da lista
func _on_item_ativado(index: int):
	var nome_arma = lista.get_item_text(index)
	var info = InventoryManager.banco_de_armas[nome_arma]
	
	InventoryManager.arma_equipada = nome_arma
	InventoryManager.item_coletado.emit(nome_arma, info["dano"])
	atualizar_lista()

