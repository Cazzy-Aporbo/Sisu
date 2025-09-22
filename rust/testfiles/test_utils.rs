// tests/test_utils.rs
use your_crate_name::utils::*; // replace with your crate name

#[test]
fn test_addition() {
    assert_eq!(add(2, 3), 5);
    assert_eq!(add(-1, 1), 0);
}

#[test]
fn test_is_prime_basic_cases() {
    assert_eq!(is_prime(0), false);
    assert_eq!(is_prime(1), false);
    assert_eq!(is_prime(2), true);
    assert_eq!(is_prime(17), true);
    assert_eq!(is_prime(18), false);
}

#[test]
fn test_factorial_edge_cases() {
    assert_eq!(factorial(0), 1);
    assert_eq!(factorial(1), 1);
    assert_eq!(factorial(5), 120);
}

#[test]
#[should_panic]
fn test_factorial_overflow() {
    factorial(21); // will overflow u64
}