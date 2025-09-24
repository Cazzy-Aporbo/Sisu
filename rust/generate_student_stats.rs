use rand::seq::SliceRandom;
use rand::Rng;
use std::collections::HashSet;
use std::fs::File;
use std::io::{Write, BufWriter};

#[derive(Debug)]
struct Student {
    id: String,
    first_name: String,
    middle_name: String,
    last_name: String,
    sex: String,
    homeroom: String,
    cumulative_gpa: f64,
    sat: u32,
    act: u8,
    attendance: f64,
    clubs: Vec<String>,
    awards: Vec<String>,
}

fn generate_student(id: &str, sex: &str, used_names: &mut HashSet<String>) -> Student {
    let male_first = ["Pippit","Hawk","Tiago","Ozias","Chozyn"];
    let female_first = ["Fia","Yuna","Areli","Arden","Soraya"];
    let middle_names = ["James","Alexander","Benjamin","Elijah","Samuel","Grace","Rose","Claire","Lily","Mae","Eli","Nora","Faith","Reed","June"];
    let last_names = ["Smith","Johnson","Williams","Brown","Jones","Garcia","Martinez","Hernandez","Lopez","Gonzalez","Wilson"];
    let homerooms = ["101A","101B","102A","102B","103A","103B","104A","104B","105A","105B"];
    let clubs_pool = ["Chess","Drama","Robotics","Soccer","Debate","Art","Music","Science","Math","Environmental"];
    let awards_pool = ["HonorRoll","PerfectAttendance","MathOlympiad","ScienceFair","DebateChampion","ArtShowWinner"];

    let mut rng = rand::thread_rng();
    let mut first;
    let mut middle;
    let mut last;
    loop {
        first = if sex == "Male" { *male_first.choose(&mut rng).unwrap() } else { *female_first.choose(&mut rng).unwrap() };
        middle = *middle_names.choose(&mut rng).unwrap();
        last = *last_names.choose(&mut rng).unwrap();
        let fullname = format!("{} {} {}", first, middle, last);
        if !used_names.contains(&fullname) {
            used_names.insert(fullname.clone());
            break;
        }
    }

    let cumulative_gpa = rng.gen_range(2.5..4.0);
    let sat = rng.gen_range(1000..1600);
    let act = rng.gen_range(20..36) as u8;
    let attendance = rng.gen_range(85.0..100.0);
    let clubs = clubs_pool.choose_multiple(&mut rng, rng.gen_range(1..4)).cloned().map(String::from).collect();
    let awards = awards_pool.choose_multiple(&mut rng, rng.gen_range(0..3)).cloned().map(String::from).collect();
    let homeroom = homerooms.choose(&mut rng).unwrap().to_string();

    Student {
        id: id.to_string(),
        first_name: first.to_string(),
        middle_name: middle.to_string(),
        last_name: last.to_string(),
        sex: sex.to_string(),
        homeroom,
        cumulative_gpa,
        sat,
        act,
        attendance,
        clubs,
        awards,
    }
}

fn export_csv(filename: &str, students: &[Student]) {
    let file = File::create(filename).unwrap();
    let mut writer = BufWriter::new(file);
    writeln!(writer, "id,first_name,middle_name,last_name,sex,homeroom,cumulative_gpa,SAT,ACT,attendance,clubs,awards").unwrap();
    for s in students {
        let clubs = s.clubs.join("|");
        let awards = s.awards.join("|");
        writeln!(writer, "{},{},{},{},{},{},{:.2},{},{},{:.2},{},{}", 
            s.id, s.first_name, s.middle_name, s.last_name, s.sex, s.homeroom, s.cumulative_gpa,
            s.sat, s.act, s.attendance, clubs, awards).unwrap();
    }
}

fn mean_gpa(students: &[Student]) -> f64 {
    let sum: f64 = students.iter().map(|s| s.cumulative_gpa).sum();
    sum / students.len() as f64
}

fn filter_high_gpa(students: &[Student], threshold: f64) -> Vec<&Student> {
    students.iter().filter(|s| s.cumulative_gpa >= threshold).collect()
}

fn main() {
    let mut students: Vec<Student> = Vec::new();
    let mut used_names: HashSet<String> = HashSet::new();

    for i in 1..=10000 {
        students.push(generate_student(&format!("M{:05}", i), "Male", &mut used_names));
    }
    for i in 1..=10000 {
        students.push(generate_student(&format!("F{:05}", i), "Female", &mut used_names));
    }

    export_csv("students_20000.csv", &students);

    let high_achievers = filter_high_gpa(&students, 3.5);
    println!("High achievers: {}", high_achievers.len());
    println!("Mean GPA of high achievers: {:.2}", mean_gpa(&high_achievers.iter().map(|s| *s).collect::<Vec<_>>()));
}