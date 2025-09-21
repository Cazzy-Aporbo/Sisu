use rand::Rng;
use std::io::{self, Read};
use std::time::{Duration, Instant};
use std::thread;
use termios::{Termios, TCSANOW, ICANON, ECHO, tcsetattr};

const MAP_W: i32 = 120;
const MAP_H: i32 = 40;
const VIEW_W: i32 = 50;
const VIEW_H: i32 = 20;

const NUM_PEOPLE: usize = 20;
const NUM_DOGS: usize = 8;
const NUM_CATS: usize = 8;
const NUM_BIRDS: usize = 10;
const NUM_CARS: usize = 10;
const NUM_BUSES: usize = 3;
const NUM_TRAINS: usize = 2;
const NUM_BUILDINGS: usize = 20;
const NUM_TREES: usize = 15;
const NUM_CLOUDS: usize = 6;

#[derive(Clone)]
struct Entity {
    x: i32,
    y: i32,
    etype: usize,
    direction: i32,
}

// emoji sets
const PEOPLE: [&str; 5] = ["🧑", "🧍", "🧑‍🦱", "🧑‍🦰", "🧑‍🦳"];
const DOGS: [&str; 3] = ["🐕", "🐶", "🐕‍🦺"];
const CATS: [&str; 3] = ["🐈", "🐱", "🐈‍⬛"];
const BIRDS: [&str; 3] = ["🐦", "🕊️", "🦅"];
const CARS: [&str; 5] = ["🚗", "🚕", "🚙", "🚓", "🛻"];
const BUSES: [&str; 2] = ["🚌", "🚍"];
const TRAINS: [&str; 2] = ["🚆", "🚄"];
const BUILDINGS: [&str; 5] = ["🏢", "🏬", "🏣", "🏤", "🏦"];
const TREES: [&str; 3] = ["🌳", "🌴", "🌿"];
const CLOUDS: [&str; 3] = ["☁️", "🌥️", "⛅"];
const WEATHER: [&str; 3] = ["☀️", "🌧️", "❄️"];

fn clear_screen() {
    print!("\x1B[2J\x1B[H");
}

fn make_entities(n: usize, max_type: usize, max_y: i32, fixed_y: Option<i32>, direction: Option<i32>) -> Vec<Entity> {
    let mut rng = rand::thread_rng();
    (0..n).map(|_| Entity {
        x: rng.gen_range(0..MAP_W),
        y: match fixed_y {
            Some(v) => v,
            None => rng.gen_range(0..max_y),
        },
        etype: rng.gen_range(0..max_type),
        direction: direction.unwrap_or(rng.gen_range(0..4)),
    }).collect()
}

fn main() {
    // raw terminal mode
    let fd = 0; // stdin
    let termios = Termios::from_fd(fd).unwrap();
    let mut new_termios = termios.clone();
    new_termios.c_lflag &= !(ICANON | ECHO);
    tcsetattr(fd, TCSANOW, &new_termios).unwrap();

    // world
    let mut people = make_entities(NUM_PEOPLE, PEOPLE.len(), MAP_H, None, None);
    let mut dogs = make_entities(NUM_DOGS, DOGS.len(), MAP_H, None, None);
    let mut cats = make_entities(NUM_CATS, CATS.len(), MAP_H, None, None);
    let mut birds = make_entities(NUM_BIRDS, BIRDS.len(), MAP_H / 2, None, None);
    let mut cars = make_entities(NUM_CARS, CARS.len(), MAP_H, Some(MAP_H - 3), Some(1));
    let mut buses = make_entities(NUM_BUSES, BUSES.len(), MAP_H, Some(MAP_H - 4), Some(1));
    let mut trains = make_entities(NUM_TRAINS, TRAINS.len(), MAP_H, Some(MAP_H - 2), Some(1));
    let mut buildings = make_entities(NUM_BUILDINGS, BUILDINGS.len(), MAP_H - 5, None, None);
    let mut trees = make_entities(NUM_TREES, TREES.len(), MAP_H - 3, None, None);
    let mut clouds = make_entities(NUM_CLOUDS, CLOUDS.len(), 5, None, Some(1));

    let mut player_x = MAP_W / 2;
    let mut player_y = MAP_H / 2;
    let mut time_of_day = 0;
    let mut weather = 0;
    let mut frame_counter = 0;

    // game loop
    let mut buf = [0u8; 1];
    loop {
        frame_counter += 1;

        // draw
        clear_screen();
        println!("🌆 Emoji City - {} - Weather: {} - Pos: {},{}\n",
            if time_of_day == 0 { "Day" } else { "Night" },
            WEATHER[weather],
            player_x, player_y);

        for y in 0..VIEW_H {
            for x in 0..VIEW_W {
                let wx = player_x - VIEW_W / 2 + x;
                let wy = player_y - VIEW_H / 2 + y;
                if wx < 0 || wy < 0 || wx >= MAP_W || wy >= MAP_H {
                    print!("  ");
                    continue;
                }

                let mut symbol = "  ";

                if let Some(e) = clouds.iter().find(|e| e.x == wx && e.y == wy) { symbol = CLOUDS[e.etype]; }
                if let Some(e) = buildings.iter().find(|e| e.x == wx && e.y == wy) { symbol = BUILDINGS[e.etype]; }
                if let Some(e) = trees.iter().find(|e| e.x == wx && e.y == wy) { symbol = TREES[e.etype]; }
                if let Some(e) = trains.iter().find(|e| e.x == wx && e.y == wy) { symbol = TRAINS[e.etype]; }
                if let Some(e) = buses.iter().find(|e| e.x == wx && e.y == wy) { symbol = BUSES[e.etype]; }
                if let Some(e) = cars.iter().find(|e| e.x == wx && e.y == wy) { symbol = CARS[e.etype]; }
                if let Some(e) = people.iter().find(|e| e.x == wx && e.y == wy) { symbol = PEOPLE[e.etype]; }
                if let Some(e) = dogs.iter().find(|e| e.x == wx && e.y == wy) { symbol = DOGS[e.etype]; }
                if let Some(e) = cats.iter().find(|e| e.x == wx && e.y == wy) { symbol = CATS[e.etype]; }
                if let Some(e) = birds.iter().find(|e| e.x == wx && e.y == wy) { symbol = BIRDS[e.etype]; }

                if wx == player_x && wy == player_y {
                    symbol = "🧑‍🚀";
                }

                print!("{}", symbol);
            }
            println!();
        }
        println!("\nUse WASD to move, Q to quit");

        // non-blocking input
        if io::stdin().read(&mut buf).unwrap_or(0) > 0 {
            let c = buf[0] as char;
            if c == 'q' || c == 'Q' { break; }
            if c == 'w' && player_y > 0 { player_y -= 1; }
            if c == 's' && player_y < MAP_H - 1 { player_y += 1; }
            if c == 'a' && player_x > 0 { player_x -= 1; }
            if c == 'd' && player_x < MAP_W - 1 { player_x += 1; }
        }

        // update
        if frame_counter % 100 == 0 {
            time_of_day = 1 - time_of_day;
            weather = (weather + 1) % 3;
        }

        for e in people.iter_mut() {
            e.x = (e.x + rand::thread_rng().gen_range(-1..=1)).clamp(0, MAP_W - 1);
            e.y = (e.y + rand::thread_rng().gen_range(-1..=1)).clamp(0, MAP_H - 1);
        }

        for e in dogs.iter_mut() {
            e.x = (e.x + rand::thread_rng().gen_range(-1..=1)).clamp(0, MAP_W - 1);
            e.y = (e.y + rand::thread_rng().gen_range(-1..=1)).clamp(0, MAP_H - 1);
        }

        for e in cats.iter_mut() {
            e.x = (e.x + rand::thread_rng().gen_range(-1..=1)).clamp(0, MAP_W - 1);
            e.y = (e.y + rand::thread_rng().gen_range(-1..=1)).clamp(0, MAP_H - 1);
        }

        for e in birds.iter_mut() {
            e.x = (e.x + rand::thread_rng().gen_range(-1..=1)).rem_euclid(MAP_W);
            e.y = (e.y + rand::thread_rng().gen_range(-1..=1)).clamp(0, MAP_H/2 - 1);
        }

        for e in cars.iter_mut() {
            e.x = (e.x + e.direction).rem_euclid(MAP_W);
        }

        for e in buses.iter_mut() {
            e.x = (e.x + e.direction).rem_euclid(MAP_W);
        }

        for e in trains.iter_mut() {
            e.x = (e.x + 2 * e.direction).rem_euclid(MAP_W);
        }

        for e in clouds.iter_mut() {
            e.x = (e.x + e.direction).rem_euclid(MAP_W);
        }

        // frame delay
        thread::sleep(Duration::from_millis(100));
    }

    // restore terminal
    tcsetattr(fd, TCSANOW, &termios).unwrap();
}