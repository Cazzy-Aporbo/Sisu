func save_pet():
    var file = File.new()
    file.open("user://pet.save", File.WRITE)
    file.store_var({"hunger": hunger, "happiness": happiness, "energy": energy, "age": age})
    file.close()

func load_pet():
    var file = File.new()
    if file.file_exists("user://pet.save"):
        file.open("user://pet.save", File.READ)
        var data = file.get_var()
        hunger = data["hunger"]
        happiness = data["happiness"]
        energy = data["energy"]
        age = data["age"]
        file.close()
        update_ui()