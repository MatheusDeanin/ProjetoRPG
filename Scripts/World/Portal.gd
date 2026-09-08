extends Area2D

@export_file("*.tscn") var proxima_fase: String = ""
@export var precisa_de_chave: bool = false
@export var id_da_chave: String = "Chave da Masmorra"

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		
		# Verifica se precisa de chave
		if precisa_de_chave:
			if not InventoryManager.chaves_coletadas.has(id_da_chave):
				print("Portal Trancado! Você precisa da: ", id_da_chave)
				# Aqui poderia tocar um som de porta trancada ou exibir um aviso na tela
				return
		
		if proxima_fase != "":
			print("Fazendo transição para a fase: ", proxima_fase)
			get_tree().change_scene_to_file(proxima_fase)
		else:
			print("Aviso: O Portal não tem uma 'proxima_fase' configurada no Inspector!")

