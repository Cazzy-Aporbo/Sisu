// tests/integration.rs
use your_crate_name::{add, utils};

#[test]
fn test_add_and_prime_integration() {
    let n = 7;
    let sum = add(3, 4);
    assert_eq!(sum, n);
    assert!(utils::is_prime(n));
}

#[test]
fn test_prime_and_factorial_combination() {
    let n = 5;
    assert!(utils::is_prime(n));
    assert_eq!(utils::factorial(n), 120);
}

#[test]
fn test_multiple_values() {
    let numbers = [2, 3, 4, 5, 10];
    let expected_primes = [true, true, false, true, false];

    for (i, &num) in numbers.iter().enumerate() {
        assert_eq!(utils::is_prime(num), expected_primes[i]);
    }
}