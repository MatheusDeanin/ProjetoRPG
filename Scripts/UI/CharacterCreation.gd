extends CanvasLayer

var pontos_disponiveis = 5
var atributos_alocados = {
	"FOR": 1,
	"AGI": 1,
	"VIG": 1,
	"INT": 1,
	"PRE": 1
}

@onready var container = $Painel/VBox/AtributosContainer
@onready var label_pontos = $Painel/VBox/PontosLabel
@onready var btn_iniciar = $Painel/VBox/IniciarJogo

func _ready():
	btn_iniciar.pressed.connect(_on_iniciar)
	_criar_linhas_de_atributos()
	_atualizar_ui()

func _criar_linhas_de_atributos():
	for attr in atributos_alocados.keys():
		var hbox = HBoxContainer.new()
		hbox.alignment = BoxContainer.ALIGNMENT_CENTER
		hbox.add_theme_constant_override("separation", 20)
		
		var btn_menos = Button.new()
		btn_menos.text = "  -  "
		btn_menos.pressed.connect(func(): _alterar_atributo(attr, -1))
		
		var label = Label.new()
		label.text = attr + ": " + str(atributos_alocados[attr])
		label.custom_minimum_size = Vector2(100, 0)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 20)
		
		# Agrupamos o label para acharmos depois e atualizar o texto
		label.add_to_group("labels_attr_" + attr)
		
		var btn_mais = Button.new()
		btn_mais.text = "  +  "
		btn_mais.pressed.connect(func(): _alterar_atributo(attr, 1))
		
		hbox.add_child(btn_menos)
		hbox.add_child(label)
		hbox.add_child(btn_mais)
		
		container.add_child(hbox)

func _alterar_atributo(attr: String, valor: int):
	var atual = atributos_alocados[attr]
	
	# Adiciona ponto se tiver disponível (Máximo 5)
	if valor > 0 and pontos_disponiveis > 0 and atual < 5:
		atributos_alocados[attr] += 1
		pontos_disponiveis -= 1
	# Remove ponto se for maior que o mínimo (Agora permite descer até 0)
	elif valor < 0 and atual > 0:
		atributos_alocados[attr] -= 1
		pontos_disponiveis += 1
		
	_atualizar_ui()

func _atualizar_ui():
	label_pontos.text = "Pontos Disponíveis: " + str(pontos_disponiveis)
	if pontos_disponiveis == 0:
		label_pontos.add_theme_color_override("font_color", Color(1, 0.8, 0)) # Fica Dourado
	else:
		label_pontos.add_theme_color_override("font_color", Color(1, 1, 1)) # Branco
	
	for attr in atributos_alocados.keys():
		var labels = get_tree().get_nodes_in_group("labels_attr_" + attr)
		if labels.size() > 0:
			labels[0].text = attr + ": " + str(atributos_alocados[attr])

func _on_iniciar():
	# Salva os status definidos pelo jogador no Singleton
	StatsManager.forca = atributos_alocados["FOR"]
	StatsManager.agilidade = atributos_alocados["AGI"]
	StatsManager.vigor = atributos_alocados["VIG"]
	StatsManager.intelecto = atributos_alocados["INT"]
	StatsManager.presenca = atributos_alocados["PRE"]
	
	# Origem e trilha começam zeradas para serem achadas em missões
	StatsManager.origem = "Desconhecida"
	StatsManager.trilha = "Nenhuma"
	
	StatsManager._calcular_status_maximos()
	get_tree().change_scene_to_file("res://Scenes/World/TestLevel.tscn")
