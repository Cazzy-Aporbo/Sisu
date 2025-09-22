// tests/test_edge_cases.rs
use your_crate_name::utils::*;

#[test]
fn test_factorial_edge_cases() {
    assert_eq!(factorial(0), 1);
    assert_eq!(factorial(1), 1);
}

#[test]
fn test_is_prime_edge_cases() {
    assert_eq!(is_prime(0), false);
    assert_eq!(is_prime(1), false);
}