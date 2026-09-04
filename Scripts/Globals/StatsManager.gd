extends Node
# Autoload (Singleton) para gerenciar o estado global do jogador

# Atributos Base
var forca: int = 1
var agilidade: int = 1
var vigor: int = 1
var intelecto: int = 1
var presenca: int = 1

# Status de Combate e Sobrevivência
var nex: int = 5 # Nível de Exposição Paranormal (%)
var max_pv: float = 100.0
var pv_atual: float = 100.0

var max_pe: float = 50.0
var pe_atual: float = 50.0

var max_sanidade: float = 100.0
var sanidade_atual: float = 100.0

# Origem do Personagem
var origem: String = "Desconhecida"
var trilha: String = "Nenhuma"

signal pv_changed(new_value)
signal sanidade_changed(new_value)
signal enlouquecendo()
signal respawn() # Aviso de que o jogador renasceu

# Posição do último Checkpoint salvo (Ex: Símbolo da Ordem na parede)
var checkpoint_pos: Vector2 = Vector2(640, 500)

func _ready():
	_calcular_status_maximos()

func _calcular_status_maximos():
	# Baseado no Vigor e Presença, como descrito no GDD
	max_pv = 50.0 + (vigor * 20.0) + (nex * 2.0)
	pv_atual = max_pv
	
	max_sanidade = 80.0 + (presenca * 15.0)
	sanidade_atual = max_sanidade

func tomar_dano(valor: float):
	pv_atual -= valor
	pv_atual = clamp(pv_atual, 0, max_pv)
	pv_changed.emit(pv_atual)
	if pv_atual <= 0:
		print("Personagem Morreu. Voltando ao checkpoint...")
		renascer()

func renascer():
	# Reseta os status e avisa o Player para se teleportar
	pv_atual = max_pv
	sanidade_atual = max_sanidade
	pv_changed.emit(pv_atual)
	sanidade_changed.emit(sanidade_atual)
	respawn.emit()

func perder_sanidade(valor: float):
	sanidade_atual -= valor
	sanidade_atual = clamp(sanidade_atual, 0, max_sanidade)
	sanidade_changed.emit(sanidade_atual)
	
	if sanidade_atual <= 0:
		enlouquecendo.emit()
		print("Estado de Trauma! Controles invertidos/Game Over em 60s.")

