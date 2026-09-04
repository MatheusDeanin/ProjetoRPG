extends Area2D

# Variável exposta no editor da Godot para podermos escolher o que tem no baú
@export var arma_conteudo: String = "Faca Enferrujada"
var aberto = false

func _ready():
	# Carrega a textura do baú e ajusta o tamanho
	if ResourceLoader.exists("res://Assets/chest.jpg"):
		$Sprite2D.texture = load("res://Assets/chest.jpg")
		$Sprite2D.scale = Vector2(0.08, 0.08)
		$Sprite2D.modulate = Color(1, 1, 1, 1)
		
	# Conecta o evento de colisão
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# Se quem encostou for do grupo jogador e o baú estiver fechado
	if body.is_in_group("Player") and not aberto:
		aberto = true
		$Sprite2D.modulate = Color(0.4, 0.4, 0.4) # Fica cinza escuro para mostrar que abriu
		InventoryManager.adicionar_arma(arma_conteudo)

