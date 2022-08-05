use std::{fs, vec};
use std::collections::{HashMap, HashSet};

#[derive(Debug)]
struct Display {
    input: Vec<Digit>,
    output: Vec<Digit>,
}

struct DecodedDisplay {
    display: Display,
    mapping: DisplayMapping,
}

struct DisplayMapping(Vec<(HashSet<char>, u64)>);

impl DisplayMapping {
    fn create(input: Vec<Digit>) -> Self {
        let mut mapping = Vec::with_capacity(10);
        let input = input.iter().filter_map(|digit| {
            use Digit::*;
            match digit {
                ONE(x) => {
                    let set = x.chars().collect::<HashSet<_>>();
                    mapping.push((set, 1));
                    None
                },
                TWO(x) => {
                    let set = x.chars().collect::<HashSet<_>>();
                    mapping.push((set, 2));
                    None
                },
                THREE(x) => {
                    let set = x.chars().collect::<HashSet<_>>();
                    mapping.push((set, 3));
                    None
                },
                FOUR(x) => {
                    let set = x.chars().collect::<HashSet<_>>();
                    mapping.push((set, 4));
                    None
                },
                FIVE(x) => {
                    let set = x.chars().collect::<HashSet<_>>();
                    mapping.push((set, 5));
                    None
                },
                SIX(x) => {
                    let set = x.chars().collect::<HashSet<_>>();
                    mapping.push((set, 6));
                    None
                },
                SEVEN(x) => {
                    let set = x.chars().collect::<HashSet<_>>();
                    mapping.push((set, 7));
                    None
                },
                EIGHT(x) => {
                    let set = x.chars().collect::<HashSet<_>>();
                    mapping.push((set, 8));
                    None
                },
                NINE(x) => {
                    let set = x.chars().collect::<HashSet<_>>();
                    mapping.push((set, 9));
                    None
                },
                ZERO(x) => {
                    let set = x.chars().collect::<HashSet<_>>();
                    mapping.push((set, 0));
                    None
                },
                UNKNOWN(x) => {
                    let set = x.chars().collect::<HashSet<_>>();
                    Some(set)
                },
            }
        });
        DisplayMapping(mapping)
    }
}

#[derive(Debug, Clone)]
enum Digit {
    ONE(String),
    TWO(String),
    THREE(String),
    FOUR(String),
    FIVE(String),
    SIX(String),
    SEVEN(String),
    EIGHT(String),
    NINE(String),
    ZERO(String),
    UNKNOWN(String),
}

impl Digit {
    fn try_parse(s: String) -> Self{
        match s.len() {
            2 => Digit::ONE(s),
            4 => Digit::FOUR(s),
            3 => Digit::SEVEN(s),
            7 => Digit::EIGHT(s),
            _ => Digit::UNKNOWN(s),
        }
    }
}

fn main() {
    for arg in std::env::args().skip(1) {
        solve_file(arg);
    }
}

fn solve_file(filepath: String) {
    let content = fs::read_to_string(filepath).unwrap();
    let displays = content.lines().map(|line| {
        let mut split = line.split("|");
        Display {
            input: split.next().unwrap().split_whitespace().map(|s| Digit::try_parse(s.to_owned())).collect(),
            output: split.next().unwrap().split_whitespace().map(|s| Digit::try_parse(s.to_owned())).collect(),
        }
    }).collect::<Vec<_>>();
    let result_part1 = displays.iter().flat_map(|display| display.output.clone()).filter(|digit| match digit {
        Digit::UNKNOWN(_) => false,
        _ => true,
    }).count();
    println!("result part 1: {:?}", result_part1);
}
