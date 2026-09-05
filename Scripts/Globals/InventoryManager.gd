extends Node
# Autoload para gerenciar o inventÃ¡rio e armas do jogador

signal item_coletado(nome_arma, dano)

var armas_coletadas = []
var arma_equipada = null

# Banco de Dados de Armas (DicionÃ¡rio de Dificuldade)
# Aqui controlamos o balanceamento. Masmorras NÃ­vel 3 dÃ£o armas NÃ­vel 3.
var banco_de_armas = {
	"Faca Enferrujada": {"dano": 10, "tipo": "Leve", "dificuldade": 1},
	"Machado": {"dano": 20, "tipo": "Pesada", "dificuldade": 1},
	"Pistola Silenciada": {"dano": 25, "tipo": "Fogo", "dificuldade": 2},
	"Katana AmaldiÃ§oada": {"dano": 55, "tipo": "Pesada", "dificuldade": 3},
	"RelÃ­quia de Sangue": {"dano": 120, "tipo": "Ritual", "dificuldade": 5}
}

func adicionar_arma(nome_arma: String):
	if banco_de_armas.has(nome_arma) and not armas_coletadas.has(nome_arma):
		armas_coletadas.append(nome_arma)
		arma_equipada = nome_arma
		
		var info = banco_de_armas[nome_arma]
		item_coletado.emit(nome_arma, info["dano"])
		return true
	return false


