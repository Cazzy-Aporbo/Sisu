-- Alien echoes from a chaotic console 👽✨

math.randomseed(os.time())

-- “Brain” of the script
brain = {"🜁","☯","⚡","❂","∴","☠","☣","♻","⟁","✶"}

-- Function to generate a nonsense word
function make_word()
    local len = math.random(2,6)
    local word = ""
    for i = 1, len do
        word = word .. brain[math.random(1,#brain)]
    end
    return word
end

-- Function to make a “sentence” that may or may not make sense
function speak()
    local words = math.random(2,7)
    local sentence = ""
    for i = 1, words do
        sentence = sentence .. make_word()
        if math.random() < 0.3 then
            sentence = sentence .. "-"
        else
            sentence = sentence .. " "
        end
    end
    return sentence
end

-- Self-modifying brain: randomly add new symbols
function mutate_brain()
    local new_sym = utf8.char(math.random(0x2600,0x26FF))
    brain[math.random(1,#brain)] = new_sym
end

-- Main alien loop
while true do
    local action = math.random()
    if action < 0.1 then
        print("\n*** SYSTEM ERROR ***\n")
    elseif action < 0.4 then
        print(speak())
    elseif action < 0.6 then
        print("~echoing thoughts~")
    else
        print(make_word() .. make_word())
    end
    mutate_brain()
    io.write("Press Enter to see what it does next... ")
    io.read()
end