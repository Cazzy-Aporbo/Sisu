// tests/test_panic.rs
use your_crate_name::utils::*;

#[test]
#[should_panic]
fn test_factorial_overflow() {
    factorial(1000); // deliberately large to cause overflow
}

#[test]
#[should_panic]
fn test_invalid_input() {
    parse_input("-5").unwrap(); // example function that errors on negative input
}