use std::io::{self, BufRead};

const FLOOR: u8 = 0;
const SEAT_EMPTY: u8 = 1;
const SEAT_OCCUPIED: u8 = 2;

fn main() {
    let mut seats: Vec<Vec<u8>> = io::stdin().lock().lines().map(|line| {
        line.unwrap().chars().map(|char| {
            if char == '#' {
                SEAT_OCCUPIED
            } else if char == 'L' {
                SEAT_EMPTY
            } else {
                FLOOR
            }
        }).collect()
    }).collect();

    loop {
        let last_seats: Vec<Vec<u8>> = seats.clone();
        let mut changed: bool = false;

        for y in 0..last_seats.len() {
            for x in 0..last_seats[y].len() {
                let val = last_seats[y][x];
                if val == SEAT_EMPTY {
                    if count_occupied(&last_seats, y as i32, x as i32) == 0 {
                        seats[y][x] = SEAT_OCCUPIED;
                        changed = true;
                    }
                } else if val == SEAT_OCCUPIED {
                    if count_occupied(&last_seats, y as i32, x as i32) >= 5 {
                        seats[y][x] = SEAT_EMPTY;
                        changed = true;
                    }
                }
            }
        }

        if !changed { break }
    }

    let mut occupied: usize = 0;
    for y in 0..seats.len() {
        for x in 0..seats[y].len() {
            if seats[y][x] == SEAT_OCCUPIED {
                occupied += 1;
            }
        }
    }

    println!("{}", occupied)
}

fn count_occupied(seats: &Vec<Vec<u8>>, y: i32, x: i32) -> usize {
    let mut found: usize = 0;

    if sight_occupied(seats, y, x, -1, -1) { found += 1 }
    if sight_occupied(seats, y, x, 0, -1) { found += 1 }
    if sight_occupied(seats, y, x, 1, -1) { found += 1 }
    if sight_occupied(seats, y, x, -1, 0) { found += 1 }
    if sight_occupied(seats, y, x, 1, 0) { found += 1 }
    if sight_occupied(seats, y, x, -1, 1) { found += 1 }
    if sight_occupied(seats, y, x, 0, 1) { found += 1 }
    if sight_occupied(seats, y, x, 1, 1) { found += 1 }

    found
}

fn sight_occupied(seats: &Vec<Vec<u8>>, yb: i32, xb: i32, yd: i32, xd: i32) -> bool {
    let mut y: i32 = yb + yd;
    let mut x: i32 = xb + xd;
    while check_range(seats, y, x) && seats[y as usize][x as usize] == FLOOR {
        y += yd;
        x += xd;
    }
    return check_range(seats, y, x) && seats[y as usize][x as usize] == SEAT_OCCUPIED;
}

fn check_range(seats: &Vec<Vec<u8>>, y: i32, x: i32) -> bool {
    if y < 0 || y >= seats.len() as i32 {
        return false;
    }
    if x < 0 || x >= seats[y as usize].len() as i32 {
        return false;
    }
    true
}