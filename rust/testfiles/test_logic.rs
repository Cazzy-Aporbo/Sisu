// tests/test_advanced.rs
use your_crate_name::utils::*;

#[test]
fn test_large_prime_check() {
    assert!(is_prime(7919)); // 7919 is a known prime
}

#[test]
fn test_large_factorial_mod() {
    let n = 20;
    let result = factorial(n);
    assert_eq!(result % 1000, 176); // example of modular check to avoid huge numbers
}

#[test]
fn test_composite_detection() {
    for n in 4..20 {
        if ![4,6,8,9,10,12,14,15,16,18].contains(&n) {
            continue;
        }
        assert!(!is_prime(n));
    }
}