extends Area2D

@export var next_scene: String = ""

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D):
	if body.is_in_group("Player") and next_scene != "":
		# Salva a posicao inicial do novo mapa como checkpoint
		# Para simplificar, quando entrar na nova fase o _ready do Player/Level pode setar o checkpoint.
		# Mas a transicao pura e:
		get_tree().change_scene_to_file(next_scene)
