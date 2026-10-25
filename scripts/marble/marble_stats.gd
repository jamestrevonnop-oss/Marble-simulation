extends RefCounted

var max_health := 100.0
var health := 100.0
var radius := 18.0
var attack_damage := 12.0
var attack_range := 48.0
var attack_cooldown := 0.8

func take_damage(amount: float) -> bool:
    health = maxf(0.0, health - amount)
    return health <= 0.0
