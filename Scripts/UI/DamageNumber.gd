extends Node2D

var amount: float = 0.0

func _ready() -> void:
	$Label.text = str(round(amount))
	
	# Usando Tween para animar a subida e desaparecimento
	var tween = create_tween()
	# Sobe 40 pixels em 0.6 segundos, perdendo velocidade (EASE_OUT)
	tween.tween_property(self, "position:y", position.y - 40, 0.6).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	# Fica invisivel gradualmente ao mesmo tempo
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.6)
	
	# Deleta o no quando a animacao acaba
	tween.tween_callback(queue_free)
