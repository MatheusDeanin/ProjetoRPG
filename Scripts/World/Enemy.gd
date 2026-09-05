extends CharacterBody2D

# -- Configuracoes exportaveis -----------------------------------------------
@export var velocidade_patrulha: float = 60.0
@export var velocidade_perseguicao: float = 130.0
@export var distancia_deteccao: float = 200.0
@export var distancia_ataque: float = 40.0
@export var dano_por_ataque: float = 10.0
@export var pv_max: float = 50.0
@export var patrol_distance: float = 100.0

# -- Estado da IA -------------------------------------------------------------
enum Estado { PATRULHA, PERSEGUICAO, ATAQUE, MORTO }
var estado: Estado = Estado.PATRULHA

var pv_atual: float
var player: Node2D = null

# Patrulha
var origem_patrulha: Vector2
var direcao_patrulha: float = 1.0

# Ataque
var pode_atacar: bool = true
var tempo_entre_ataques: float = 1.2

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# -- Nos ----------------------------------------------------------------------
@onready var anim: AnimatedSprite2D = $Animacao
@onready var timer_ataque: Timer = $TimerAtaque
@onready var area_deteccao: Area2D = $AreaDeteccao

func _ready() -> void:
	pv_atual = pv_max
	origem_patrulha = global_position

	anim.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	anim.scale = Vector2(2.5, 2.5)

	timer_ataque.wait_time = tempo_entre_ataques
	timer_ataque.one_shot = true
	timer_ataque.timeout.connect(_on_timer_ataque_timeout)

	area_deteccao.body_entered.connect(_on_body_entered)
	area_deteccao.body_exited.connect(_on_body_exited)

	_tocar_animacao("idle")

func _physics_process(delta: float) -> void:
	if estado == Estado.MORTO:
		return

	if not is_on_floor():
		velocity.y += gravity * delta

	match estado:
		Estado.PATRULHA:
			_fazer_patrulha()
		Estado.PERSEGUICAO:
			_perseguir_player()
		Estado.ATAQUE:
			velocity.x = move_toward(velocity.x, 0, velocidade_patrulha)
			_tentar_atacar()

	move_and_slide()

# -- Patrulha -----------------------------------------------------------------
func _fazer_patrulha() -> void:
	velocity.x = direcao_patrulha * velocidade_patrulha
	anim.flip_h = direcao_patrulha < 0
	_tocar_animacao("walk")

	var dist_origem = global_position.x - origem_patrulha.x
	if dist_origem > patrol_distance:
		direcao_patrulha = -1.0
	elif dist_origem < -patrol_distance:
		direcao_patrulha = 1.0

	if is_on_wall():
		direcao_patrulha *= -1.0

# -- Perseguicao --------------------------------------------------------------
func _perseguir_player() -> void:
	if not is_instance_valid(player):
		estado = Estado.PATRULHA
		return

	var dist = global_position.distance_to(player.global_position)

	if dist <= distancia_ataque:
		estado = Estado.ATAQUE
		return

	if dist > distancia_deteccao * 1.3:
		estado = Estado.PATRULHA
		return

	var dir = sign(player.global_position.x - global_position.x)
	velocity.x = dir * velocidade_perseguicao
	anim.flip_h = dir < 0
	_tocar_animacao("walk")

# -- Ataque -------------------------------------------------------------------
func _tentar_atacar() -> void:
	if not is_instance_valid(player):
		estado = Estado.PATRULHA
		return

	var dist = global_position.distance_to(player.global_position)

	if dist > distancia_ataque * 1.5:
		estado = Estado.PERSEGUICAO
		return

	if pode_atacar:
		pode_atacar = false
		_tocar_animacao("attack")
		await get_tree().create_timer(0.3).timeout
		if is_instance_valid(player) and estado != Estado.MORTO:
			if global_position.distance_to(player.global_position) <= distancia_ataque * 1.5:
				StatsManager.tomar_dano(dano_por_ataque)
		timer_ataque.start()

func _on_timer_ataque_timeout() -> void:
	pode_atacar = true

# -- Receber dano -------------------------------------------------------------
func receber_dano(valor: float) -> void:
	if estado == Estado.MORTO:
		return

	pv_atual -= valor
	pv_atual = clamp(pv_atual, 0, pv_max)

	if pv_atual <= 0:
		_morrer()
	else:
		_tocar_animacao("hurt")
		if estado == Estado.PATRULHA:
			estado = Estado.PERSEGUICAO

func _morrer() -> void:
	estado = Estado.MORTO
	velocity = Vector2.ZERO
	_tocar_animacao("death")
	set_physics_process(false)
	$CollisionShape2D.set_deferred("disabled", true)
	await get_tree().create_timer(1.5).timeout
	queue_free()

# -- Deteccao do Player -------------------------------------------------------
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player = body
		if estado == Estado.PATRULHA:
			estado = Estado.PERSEGUICAO

func _on_body_exited(body: Node2D) -> void:
	pass

# -- Utilitario de animacao ---------------------------------------------------
func _tocar_animacao(nome: String) -> void:
	if not anim.sprite_frames.has_animation(nome):
		return
	if anim.animation == nome and anim.is_playing():
		return
	anim.play(nome)
