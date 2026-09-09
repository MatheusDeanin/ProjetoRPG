extends Node
# Autoload (Singleton) para gerenciar o estado global do jogador

# Atributos Base
var forca: int = 1
var agilidade: int = 1
var vitalidade: int = 1
var inteligencia: int = 1
var destreza: int = 1

# Status de Combate
var nivel: int = 1
var max_hp: float = 100.0
var hp_atual: float = 100.0

var max_mana: float = 50.0
var mana_atual: float = 50.0

# Classe do Personagem
var classe: String = "Guerreiro"

signal hp_changed(new_value)
signal mana_changed(new_value)
signal player_morreu()
signal respawn() # Aviso de que o jogador renasceu

# Posição do último Checkpoint salvo
var checkpoint_pos: Vector2 = Vector2(-160, 580)

# Posição de spawn personalizada para transição de fases (Vector2.INF se usar o padrão da cena)
var posicao_spawn: Vector2 = Vector2.INF

func _ready():
	_calcular_status_maximos()

func _calcular_status_maximos():
	# HP Baseado na vitalidade
	max_hp = 50.0 + (vitalidade * 20.0) + (nivel * 5.0)
	hp_atual = max_hp
	
	# Mana Baseado na inteligência
	max_mana = 20.0 + (inteligencia * 15.0) + (nivel * 5.0)
	mana_atual = max_mana

func tomar_dano(valor: float):
	hp_atual -= valor
	hp_atual = clamp(hp_atual, 0, max_hp)
	hp_changed.emit(hp_atual)
	if hp_atual <= 0:
		print("Personagem Morreu!")
		player_morreu.emit()

func gastar_mana(valor: float) -> bool:
	if mana_atual >= valor:
		mana_atual -= valor
		mana_changed.emit(mana_atual)
		return true
	return false

func recuperar_mana(valor: float):
	mana_atual += valor
	mana_atual = clamp(mana_atual, 0, max_mana)
	mana_changed.emit(mana_atual)

func recuperar_hp(valor: float):
	hp_atual += valor
	hp_atual = clamp(hp_atual, 0, max_hp)
	hp_changed.emit(hp_atual)

func resetar_status():
	hp_atual = max_hp
	mana_atual = max_mana
	hp_changed.emit(hp_atual)
	mana_changed.emit(mana_atual)

func renascer():
	# Reseta os status e avisa o Player para se teleportar
	resetar_status()
	respawn.emit()
