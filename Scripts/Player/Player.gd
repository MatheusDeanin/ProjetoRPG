extends CharacterBody2D

const SPEED = 350.0
const JUMP_VELOCITY = -650.0 # Aumentado de -400 para garantir que alcance as plataformas

# Pega a gravidade padrão do projeto
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Variáveis para a mecânica de Enlouquecimento
var controles_invertidos = false

func _ready():
	add_to_group("Player") # Identifica o jogador para os baús de forma 100% segura
	
	# Ajusta o tamanho da Pixel Art e deixa ela nítida (sem embaçar)
	if has_node("Animacao"):
		$Animacao.scale = Vector2(2.5, 2.5) # Tamanho equilibrado
		$Animacao.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST # Força o estilo Pixel Art perfeito
		
	# Escuta os sinais do StatsManager
	StatsManager.enlouquecendo.connect(_on_enlouquecendo)
	StatsManager.respawn.connect(_on_respawn)
	_configurar_controles_wasd()

func _configurar_controles_wasd():
	# Adiciona os controles WASD programaticamente para facilitar o teste
	if not InputMap.has_action("pular"): InputMap.add_action("pular")
	if not InputMap.has_action("andar_esquerda"): InputMap.add_action("andar_esquerda")
	if not InputMap.has_action("andar_direita"): InputMap.add_action("andar_direita")
	
	# Mapeia a tecla W e Espaço para Pular
	var key_w = InputEventKey.new()
	key_w.physical_keycode = KEY_W
	InputMap.action_add_event("pular", key_w)
	
	var key_space = InputEventKey.new()
	key_space.physical_keycode = KEY_SPACE
	InputMap.action_add_event("pular", key_space)
	
	# Mapeia A e D para movimentação
	var key_a = InputEventKey.new()
	key_a.physical_keycode = KEY_A
	InputMap.action_add_event("andar_esquerda", key_a)
	
	var key_d = InputEventKey.new()
	key_d.physical_keycode = KEY_D
	InputMap.action_add_event("andar_direita", key_d)

func _physics_process(delta):
	# Adiciona a gravidade
	if not is_on_floor():
		velocity.y += gravity * delta

	# Pulo (Agora usando W ou Espaço)
	if Input.is_action_just_pressed("pular") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Movimentação Horizontal (Agora usando A e D)
	var direction = Input.get_axis("andar_esquerda", "andar_direita")
	
	if controles_invertidos:
		direction *= -1 # Inverte a direção (mecânica do GDD)
		
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# --- MÁQUINA DE ANIMAÇÃO ---
	if has_node("Animacao"):
		var animacao = $Animacao
		
		# Vira o sprite para o lado certo
		if velocity.x != 0:
			animacao.flip_h = velocity.x < 0
			
		# Escolhe a animação
		if is_on_floor():
			if velocity.x == 0:
				animacao.play("idle")
			else:
				animacao.play("run")
		else:
			if velocity.y < 0:
				animacao.play("jump")
			else:
				animacao.play("fall")

	move_and_slide()

func _process(delta):
	# Botões de Teste (Q para Sanidade, E para Vida)
	if Input.is_physical_key_pressed(KEY_Q):
		StatsManager.perder_sanidade(20.0 * delta) # Perde rápido enquanto segura
	if Input.is_physical_key_pressed(KEY_E):
		StatsManager.tomar_dano(20.0 * delta)

func _on_enlouquecendo():
	controles_invertidos = true
	print("Personagem enlouqueceu! Movimentos invertidos.")

func _on_respawn():
	# Teleporta o jogador para o Checkpoint, zera a inércia e cura o trauma
	global_position = StatsManager.checkpoint_pos
	velocity = Vector2.ZERO
	controles_invertidos = false
