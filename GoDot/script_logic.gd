extends Node

var hunger = 80
var happiness = 80
var energy = 80
var mischief = 20

func _ready():
    $Timer.wait_time = 5
    $Timer.start()
    $Timer.connect("timeout", self, "_on_tick")
    update_ui()
    update_mood()

func _on_tick():
    # decay stats
    hunger = max(hunger - 2, 0)
    energy = max(energy - 1, 0)
    mischief = min(mischief + 1, 100)
    update_mood()
    update_ui()

func feed():
    hunger = min(hunger + 25, 100)
    happiness = min(happiness + 5, 100)
    mischief = max(mischief - 5, 0)
    play_animation("eat")
    update_mood()

func play():
    happiness = min(happiness + 15, 100)
    energy = max(energy - 10, 0)
    mischief = min(mischief + 5, 100)
    play_animation("play")
    update_mood()

func pet():
    happiness = min(happiness + 10, 100)
    mischief = max(mischief - 10, 0)
    play_animation("happy")
    update_mood()

func update_ui():
    $HungerBar.value = hunger
    $HappinessBar.value = happiness
    $EnergyBar.value = energy
    $MischiefBar.value = mischief

func update_mood():
    if hunger < 30:
        show_mood_emoji("sad")
    elif happiness > 80 and energy > 50:
        show_mood_emoji("playful")
    elif mischief > 60:
        show_mood_emoji("cheeky")
    else:
        show_mood_emoji("neutral")

func show_mood_emoji(mood):
    $MoodEmoji.frame = mood_to_frame(mood)

func play_animation(anim_name):
    $PetSprite.play(anim_name)