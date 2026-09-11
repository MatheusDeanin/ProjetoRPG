extends Control

@onready var texto = $ColorRect/VBoxContainer/RichTextLabel
@onready var btn_continuar = $ColorRect/VBoxContainer/BtnContinuar
@onready var skip_container = $SkipContainer
@onready var skip_progress_bar = $SkipContainer/SkipProgressBar

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
var tween_texto: Tween = null

var dica_pular_visivel: bool = false
var tempo_segurando_enter: float = 0.0
const TEMPO_PARA_PULAR: float = 1.2
var cutscene_pulada: bool = false

func _ready():
	btn_continuar.visible = false
	btn_continuar.pressed.connect(_proxima_linha)

	skip_container.modulate.a = 0.0
	skip_progress_bar.value = 0.0

	_mostrar_linha()

func _input(event: InputEvent) -> void:
	if cutscene_pulada:
		return
	# Se apertar qualquer tecla ou botão e a dica ainda não estiver visível
	if event.is_pressed() and not dica_pular_visivel:
		_mostrar_dica_pular()

func _mostrar_dica_pular() -> void:
	dica_pular_visivel = true
	var tween_dica = create_tween()
	tween_dica.tween_property(skip_container, "modulate:a", 1.0, 0.4)

func _process(delta: float) -> void:
	if cutscene_pulada:
		return

	# Verifica se o ENTER (normal ou teclado numérico) está sendo segurado
	if Input.is_key_pressed(KEY_ENTER) or Input.is_key_pressed(KEY_KP_ENTER):
		if not dica_pular_visivel:
			_mostrar_dica_pular()

		tempo_segurando_enter += delta
		skip_progress_bar.value = clamp((tempo_segurando_enter / TEMPO_PARA_PULAR) * 100.0, 0.0, 100.0)

		if tempo_segurando_enter >= TEMPO_PARA_PULAR:
			_pular_cutscene()
	else:
		if tempo_segurando_enter > 0.0:
			tempo_segurando_enter = 0.0
			skip_progress_bar.value = 0.0

func _pular_cutscene() -> void:
	if cutscene_pulada:
		return
	cutscene_pulada = true
	set_process(false)

	if tween_texto and tween_texto.is_valid():
		tween_texto.kill()

	get_tree().change_scene_to_file("res://Scenes/World/PrimeiroMapa.tscn")

func _mostrar_linha():
	if linha_atual < historia.size():
		texto.text = "[center]" + historia[linha_atual] + "[/center]"
		texto.visible_characters = 0
		btn_continuar.visible = false

		if tween_texto and tween_texto.is_valid():
			tween_texto.kill()

		tween_texto = create_tween()
		# Demora 2.5 segundos para digitar a frase inteira
		tween_texto.tween_property(texto, "visible_ratio", 1.0, 2.5)
		tween_texto.finished.connect(_on_texto_terminou)
	else:
		# Quando a história acabar, carrega o Primeiro Mapa
		_pular_cutscene()

func _on_texto_terminou():
	btn_continuar.visible = true

func _proxima_linha():
	linha_atual += 1
	_mostrar_linha()
