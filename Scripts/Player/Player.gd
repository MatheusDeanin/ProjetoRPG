extends CharacterBody2D

const SPEED = 350.0
const JUMP_VELOCITY = -650.0
var DANO_ATAQUE = 10.0
var tem_arma = false

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var controles_invertidos = false

# Controle de ataque e combos
var is_attacking = false
var combo_requested = false

@onready var hitbox: Area2D = $HitboxAtaque

func _ready():
	InventoryManager.item_coletado.connect(_on_arma_coletada)
	add_to_group("Player")

	if has_node("Animacao"):
		$Animacao.scale = Vector2(1.5, 1.5)
		$Animacao.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

		# Forca as animacoes de ataque a NAO repetirem
		if $Animacao.sprite_frames.has_animation("attack"):
			$Animacao.sprite_frames.set_animation_loop("attack", false)
		if $Animacao.sprite_frames.has_animation("attack2"):
			$Animacao.sprite_frames.set_animation_loop("attack2", false)
		if $Animacao.sprite_frames.has_animation("attack_air"):
			$Animacao.sprite_frames.set_animation_loop("attack_air", false)

		$Animacao.animation_finished.connect(_on_animation_finished)

	hitbox.body_entered.connect(_on_hitbox_body_entered)

	StatsManager.enlouquecendo.connect(_on_enlouquecendo)
	StatsManager.respawn.connect(_on_respawn)
	StatsManager.player_morreu.connect(_on_player_morreu)
	_configurar_controles_wasd()

func _configurar_controles_wasd():
	if not InputMap.has_action("pular"): InputMap.add_action("pular")
	if not InputMap.has_action("andar_esquerda"): InputMap.add_action("andar_esquerda")
	if not InputMap.has_action("andar_direita"): InputMap.add_action("andar_direita")
	if not InputMap.has_action("atacar"): InputMap.add_action("atacar")

	var key_w = InputEventKey.new(); key_w.physical_keycode = KEY_W
	InputMap.action_add_event("pular", key_w)

	var key_space = InputEventKey.new(); key_space.physical_keycode = KEY_SPACE
	InputMap.action_add_event("pular", key_space)

	var key_a = InputEventKey.new(); key_a.physical_keycode = KEY_A
	InputMap.action_add_event("andar_esquerda", key_a)

	var key_d = InputEventKey.new(); key_d.physical_keycode = KEY_D
	InputMap.action_add_event("andar_direita", key_d)

	var key_j = InputEventKey.new(); key_j.physical_keycode = KEY_J
	InputMap.action_add_event("atacar", key_j)

	var mouse_left = InputEventMouseButton.new(); mouse_left.button_index = MOUSE_BUTTON_LEFT
	InputMap.action_add_event("atacar", mouse_left)

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

	# Processa o pedido de ataque
	if Input.is_action_just_pressed("atacar"):
		if is_attacking:
			if is_on_floor() and has_node("Animacao") and $Animacao.animation == "attack":
				combo_requested = true
		else:
			is_attacking = true
			_ativar_hitbox(true)
			if has_node("Animacao"):
				if is_on_floor():
					if tem_arma:
						$Animacao.play("attack_weapon")
					else:
						$Animacao.play("attack")
				else:
					if tem_arma:
						$Animacao.play("attack_weapon")
					elif $Animacao.sprite_frames.has_animation("attack_air"):
						$Animacao.play("attack_air")
					else:
						$Animacao.play("attack")

	# Se estiver atacando, trava novas acoes
	if is_attacking:
		if is_on_floor():
			velocity.x = move_toward(velocity.x, 0, SPEED)
		move_and_slide()
		return

	# Pulo normal
	if Input.is_action_just_pressed("pular") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Movimentacao Horizontal
	var direction = Input.get_axis("andar_esquerda", "andar_direita")
	if controles_invertidos: direction *= -1

	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# --- MAQUINA DE ANIMACAO ---
	if has_node("Animacao"):
		var animacao = $Animacao

		if velocity.x != 0:
			animacao.flip_h = velocity.x < 0

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

# --- Hitbox de ataque -------------------------------------------------------
func _ativar_hitbox(ativo: bool) -> void:
	hitbox.monitoring = ativo
	# Posiciona o hitbox na frente do personagem (direita ou esquerda)
	var lado = -1.0 if $Animacao.flip_h else 1.0
	hitbox.position = Vector2(50 * lado, -60)

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("receber_dano"):
		var dir = sign(body.global_position.x - global_position.x)
		if dir == 0: dir = 1.0 if not $Animacao.flip_h else -1.0
		
		# Passa o dano e a direcao do knockback
		body.receber_dano(DANO_ATAQUE, dir)


# --- Fim do ataque ----------------------------------------------------------
func _on_animation_finished():
	if not has_node("Animacao"): return

	var anim_name = $Animacao.animation

	if anim_name == "attack":
		if combo_requested and $Animacao.sprite_frames.has_animation("attack2"):
			$Animacao.play("attack2")
			combo_requested = false
		else:
			is_attacking = false
			combo_requested = false
			_ativar_hitbox(false)

	elif anim_name == "attack2" or anim_name == "attack_air" or anim_name == "attack_weapon":
		is_attacking = false
		combo_requested = false
		_ativar_hitbox(false)

func _process(delta):
	if Input.is_physical_key_pressed(KEY_Q): StatsManager.perder_sanidade(20.0 * delta)
	if Input.is_physical_key_pressed(KEY_E): StatsManager.tomar_dano(20.0 * delta)

func _on_enlouquecendo():
	controles_invertidos = true

func _on_player_morreu():
	set_physics_process(false)
	$Animacao.play("fall") # Or a death animation if we add one

func _on_respawn():
	global_position = StatsManager.checkpoint_pos
	velocity = Vector2.ZERO
	controles_invertidos = false
	is_attacking = false
	combo_requested = false
	_ativar_hitbox(false)

func _on_arma_coletada(nome_arma: String, dano: int) -> void:
	DANO_ATAQUE = float(dano)
	tem_arma = true
	print("Nova arma equipada: ", nome_arma, " - Dano: ", DANO_ATAQUE)
