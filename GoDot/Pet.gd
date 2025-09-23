extends Node

class_name Pet

# Stats
var hunger = 100
var happiness = 100
var energy = 100
var age = 0

# Config
var stat_decay = 1    # points per tick
var tick_time = 5     # seconds

func _ready():
    $Timer.wait_time = tick_time
    $Timer.start()
    $Timer.connect("timeout", self, "_on_tick")

func _on_tick():
    hunger = max(hunger - stat_decay, 0)
    happiness = max(happiness - stat_decay, 0)
    energy = max(energy - stat_decay, 0)
    age += 1
    update_ui()
    check_status()

func feed():
    hunger = min(hunger + 20, 100)
    update_ui()

func play():
    happiness = min(happiness + 20, 100)
    energy = max(energy - 10, 0)
    update_ui()

func sleep():
    energy = min(energy + 30, 100)
    update_ui()

func update_ui():
    $HungerBar.value = hunger
    $HappinessBar.value = happiness
    $EnergyBar.value = energy

func check_status():
    if hunger <= 0 or energy <= 0:
        print("Your pet is sick! 😢")
    if hunger == 100 and happiness == 100 and energy == 100:
        print("Your pet is happy! 🥳")