-- Weird Lua playground 🌌🌀

math.randomseed(os.time())

-- Create a table of random symbols
symbols = {"☯", "⚡", "☢", "♻", "✨", "☠", "☂", "♞", "❄", "☘"}

-- Function to generate a random line of symbols
function random_line(length)
    local line = ""
    for i = 1, length do
        line = line .. symbols[math.random(1, #symbols)]
    end
    return line
end

-- Function to print a “weird pattern”
function weird_pattern(lines, max_length)
    for i = 1, lines do
        local len = math.random(1, max_length)
        print(random_line(len))
    end
end

-- Function to mutate symbols randomly
function mutate_symbols()
    local new_sym = utf8.char(math.random(0x2600,0x26FF)) -- random Unicode symbol
    symbols[math.random(1,#symbols)] = new_sym
end

-- Main loop: infinite weirdness
while true do
    weird_pattern(math.random(3,7), 20)
    mutate_symbols()
    io.write("\nPress Enter to continue weirder... or Ctrl+C to stop: ")
    io.read() -- wait for Enter
end