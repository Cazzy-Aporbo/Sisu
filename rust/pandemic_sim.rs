use rand::Rng;
use std::fs::File;
use std::io::{Write, BufWriter};

#[derive(Clone)]
struct Person {
    id: usize,
    age: u8,
    health: f64,
    immunity: f64,
    social_activity: f64,
    infected: bool,
    days_infected: u32,
    recovered: bool,
    deceased: bool,
}

struct Virus {
    transmission_rate: f64,
    mutation_rate: f64,
    fatality_rate: f64,
}

fn generate_population(size: usize) -> Vec<Person> {
    let mut pop = Vec::with_capacity(size);
    let mut rng = rand::thread_rng();
    for i in 0..size {
        pop.push(Person {
            id: i,
            age: rng.gen_range(1..80),
            health: rng.gen_range(0.5..1.0),
            immunity: rng.gen_range(0.0..1.0),
            social_activity: rng.gen_range(0.0..1.0),
            infected: false,
            days_infected: 0,
            recovered: false,
            deceased: false,
        });
    }
    pop
}

fn simulate_day(pop: &mut [Person], virus: &Virus) {
    let mut rng = rand::thread_rng();
    let infected_ids: Vec<usize> = pop.iter().filter(|p| p.infected && !p.deceased).map(|p| p.id).collect();

    for &i in &infected_ids {
        let infector = &pop[i];
        let contacts = (infector.social_activity * 20.0) as usize; // weighted contacts
        for _ in 0..contacts {
            let target_index = rng.gen_range(0..pop.len());
            let target = &mut pop[target_index];
            if !target.infected && !target.deceased {
                let base_chance = virus.transmission_rate;
                let immunity_factor = 1.0 - target.immunity;
                let age_factor = if target.age > 65 { 1.2 } else { 1.0 };
                let chance = base_chance * immunity_factor * age_factor;
                if rng.gen_bool(chance.min(1.0) as f64) {
                    target.infected = true;
                }
            }
        }
        // Update infected person
        pop[i].days_infected += 1;
        if rng.gen_bool(virus.fatality_rate * (1.0 - pop[i].health)) {
            pop[i].deceased = true;
            pop[i].infected = false;
        } else if pop[i].days_infected > 14 {
            pop[i].recovered = true;
            pop[i].infected = false;
            pop[i].immunity = (pop[i].immunity + 0.5).min(1.0);
        }
    }
}

fn export_csv(pop: &[Person], day: u32, filename: &str) {
    let file = File::create(filename).unwrap();
    let mut writer = BufWriter::new(file);
    writeln!(writer,"id,age,health,immunity,social_activity,infected,recovered,deceased,day").unwrap();
    for p in pop {
        writeln!(writer, "{},{:.0},{:.2},{:.2},{:.2},{},{},{},{}", 
            p.id, p.age, p.health, p.immunity, p.social_activity, p.infected, p.recovered, p.deceased, day).unwrap();
    }
}

fn main() {
    let mut population = generate_population(1000);
    population[0].infected = true;

    let virus = Virus {
        transmission_rate: 0.05,
        mutation_rate: 0.01,
        fatality_rate: 0.005,
    };

    for day in 1..=60 {
        simulate_day(&mut population, &virus);
        export_csv(&population, day, &format!("pandemic_day_{}.csv", day));

        let infected_count = population.iter().filter(|p| p.infected).count();
        let recovered_count = population.iter().filter(|p| p.recovered).count();
        let deceased_count = population.iter().filter(|p| p.deceased).count();
        println!("Day {}: Infected {}, Recovered {}, Deceased {}", day, infected_count, recovered_count, deceased_count);
    }
}