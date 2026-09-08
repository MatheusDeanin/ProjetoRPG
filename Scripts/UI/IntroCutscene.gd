extends Control

@onready var texto = $ColorRect/VBoxContainer/RichTextLabel
@onready var btn_continuar = $ColorRect/VBoxContainer/BtnContinuar

var historia = [
	"O Reino de Eldoria viveu em paz por séculos...",
	"Até que uma fenda de magia selvagem se abriu nas ruínas da Floresta Alta.",
	"A natureza foi corrompida. Animais enlouqueceram e cresceram de forma assustadora.",
	"Atraídos por esse poder, Orcs invadiram o local e trancaram as masmorras mais profundas.",
	"Você é um bravo soldado do reino, enviado sozinho para investigar a floresta.",
	"Infelizmente, você sofreu uma emboscada e perdeu quase todo o seu equipamento.",
	"Agora, sua missão é recuperar suas armas, adentrar as masmorras e deter o Chefe Orc!"
]

var linha_atual = 0

func _ready():
	btn_continuar.visible = false
	btn_continuar.pressed.connect(_proxima_linha)
	_mostrar_linha()

func _mostrar_linha():
	if linha_atual < historia.size():
		texto.text = "[center]" + historia[linha_atual] + "[/center]"
		texto.visible_characters = 0
		btn_continuar.visible = false
		
		var tween = create_tween()
		# Demora 2.5 segundos para digitar a frase inteira
		tween.tween_property(texto, "visible_ratio", 1.0, 2.5)
		tween.finished.connect(_on_texto_terminou)
	else:
		# Quando a história acabar, carrega o Primeiro Mapa
		get_tree().change_scene_to_file("res://Scenes/World/PrimeiroMapa.tscn")

func _on_texto_terminou():
	btn_continuar.visible = true

func _proxima_linha():
	linha_atual += 1
	_mostrar_linha()

