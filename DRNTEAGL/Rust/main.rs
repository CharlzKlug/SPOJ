use std::collections::VecDeque;
use std::io;
use std::str::FromStr;

fn get_i32_vecdeque_from_stdin() -> VecDeque<i32> {
    let mut buffer = VecDeque::new();
    let mut some_string = String::new();
    
    if io::stdin().read_line(&mut some_string).is_ok() {
	let split = some_string.split_whitespace();
	
	for str in split {
	    if let Ok(k) = i32::from_str(str){
		buffer.push_back(k);
	    }
	}
    }
    buffer
}

fn refresh_buffer(mut buffer: VecDeque<i32>) -> VecDeque<i32> {
    while buffer.is_empty() {
	buffer = get_i32_vecdeque_from_stdin();
    }
    buffer
}

fn calc_distance(x: i32, y: i32) -> i32 {
    (x.pow(2)) + (y.pow(2))
}

fn proceed_coords(planets_number:i32, mut buffer:VecDeque<i32>) -> VecDeque<i32> {
    let mut farthest_planet_index = 0;
    let mut greatest_distance = 0;

    for i in 1..(planets_number + 1) {
	buffer = refresh_buffer(buffer);
	if let Some(x) = buffer.pop_front() {
	    buffer = refresh_buffer(buffer);
	    if let Some(y) = buffer.pop_front() {
		let current_distance = calc_distance(x, y);
		if current_distance > greatest_distance {
		    
		    greatest_distance = current_distance;
		    farthest_planet_index = i;
		}
	    }
	}
    }
    println!("{}", farthest_planet_index);
    buffer
}

fn proceed_case(mut buffer: VecDeque<i32>) -> VecDeque<i32> {
    buffer = refresh_buffer(buffer);
    if let Some(planets_number) = buffer.pop_front() {
	buffer = proceed_coords(planets_number, buffer);
    }
    buffer
}

fn proceed_test_cases(mut cases_quantity: i32, mut i32_buffer: VecDeque<i32>) {
    for i in 1..(cases_quantity + 1) {
	//while cases_quantity > 0 {
	print!("Case {}: ", i);
	i32_buffer = proceed_case(i32_buffer);
	cases_quantity -=1;
    }
}

fn proceed_tests() {
    let mut buffer = refresh_buffer(VecDeque::new());
    if let Some(tests_quantity) = buffer.pop_front() {
	proceed_test_cases(tests_quantity, buffer);
    }
}

fn main() {
    proceed_tests();
}
