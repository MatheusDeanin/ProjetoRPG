extends Area2D

@export var arma_conteudo: String = "Machado"
var aberto = false
var player_perto = false

@onready var aviso = $AvisoE
@onready var particulas = $Brilho
@onready var sprite = $Sprite2D

func _ready():
	aviso.visible = false
	particulas.emitting = false
	
	
		
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.is_in_group("Player") and not aberto:
		player_perto = true
		aviso.visible = true

func _on_body_exited(body):
	if body.is_in_group("Player"):
		player_perto = false
		aviso.visible = false

func _unhandled_input(event):
	if event is InputEventKey and event.pressed and event.physical_keycode == KEY_E:
		if player_perto and not aberto:
			_abrir_bau()

func _abrir_bau():
	aberto = true
	aviso.visible = false
	particulas.emitting = true
	
		# Animacao de "pulo" do bau (tampa explodindo) e troca de imagem
	sprite.region_rect = Rect2(320, 272, 32, 32)
	
	var tween = create_tween()
	tween.tween_property(sprite, "scale", sprite.scale * 1.3, 0.1)
	tween.tween_property(sprite, "scale", sprite.scale / 1.3, 0.2).set_trans(Tween.TRANS_BOUNCE)
	
	_mostrar_texto_flutuante()
	InventoryManager.adicionar_arma(arma_conteudo)

func _mostrar_texto_flutuante():
	var lbl = Label.new()
	lbl.text = arma_conteudo + " Equipado!"
	lbl.add_theme_color_override("font_color", Color(1, 0.8, 0.2))
	lbl.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	lbl.add_theme_constant_override("outline_size", 4)
	lbl.add_theme_font_size_override("font_size", 18)
	add_child(lbl)
	lbl.position = Vector2(-70, -40)
	
	var tw = create_tween()
	# Texto sobe devagar
	tw.tween_property(lbl, "position:y", -90, 1.5).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	# Fica invisivel
	tw.parallel().tween_property(lbl, "modulate:a", 0.0, 1.5)
	# Deleta no fim
	tw.tween_callback(lbl.queue_free)


