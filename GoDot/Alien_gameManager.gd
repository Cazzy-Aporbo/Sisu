extends Node

var collected_flowers = []

func _ready():
    for flower in $FlowerContainer.get_children():
        flower.connect("collected", self, "_on_flower_collected")

func _on_flower_collected(flower_name):
    collected_flowers.append(flower_name)
    print("Collected: ", flower_name)
    update_journal_ui()

func update_journal_ui():
    var text = "Alien Flowers Collected:\n"
    for f in collected_flowers:
        text += "- " + f + "\n"
    $UI/JournalPanel.text = text