// tests/test_parameterized.rs
use your_crate_name::utils::*;

#[test]
fn test_multiple_primes() {
    let numbers = [2, 3, 4, 5, 10];
    let expected = [true, true, false, true, false];
    for (i, &n) in numbers.iter().enumerate() {
        assert_eq!(is_prime(n), expected[i]);
    }
}