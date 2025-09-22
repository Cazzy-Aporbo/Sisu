// tests/sisu_full_tests.rs
use std::fs::File;
use std::io::{Write, Read};
use std::env;
use tokio::time::{sleep, Duration};
use proptest::prelude::*;

// Replace with your crate name
use your_crate_name::{add, subtract, utils};

// -----------------------------
// Basic Unit Tests
// -----------------------------
#[test]
fn test_add_positive_numbers() {
    assert_eq!(add(2, 3), 5);
}

#[test]
fn test_add_negative_numbers() {
    assert_eq!(add(-5, -3), -8);
}

#[test]
fn test_subtract_basic() {
    assert_eq!(subtract(10, 4), 6);
}

// -----------------------------
// Edge Cases
// -----------------------------
#[test]
fn test_factorial_edge_cases() {
    assert_eq!(utils::factorial(0), 1);
    assert_eq!(utils::factorial(1), 1);
}

#[test]
fn test_is_prime_edge_cases() {
    assert_eq!(utils::is_prime(0), false);
    assert_eq!(utils::is_prime(1), false);
}

// -----------------------------
// Panic and Error Handling
// -----------------------------
#[test]
#[should_panic]
fn test_factorial_overflow() {
    utils::factorial(1000); // deliberately large to cause overflow
}

// -----------------------------
// Parameterized-like Tests
// -----------------------------
#[test]
fn test_multiple_primes() {
    let numbers = [2, 3, 4, 5, 10];
    let expected = [true, true, false, true, false];
    for (i, &n) in numbers.iter().enumerate() {
        assert_eq!(utils::is_prime(n), expected[i]);
    }
}

// -----------------------------
// Integration Tests
// -----------------------------
#[tokio::test]
async fn test_async_add_and_prime_combined() {
    sleep(Duration::from_millis(50)).await;
    let sum = add(3, 7);
    assert_eq!(sum, 10);
    assert!(!utils::is_prime(sum));
}

#[test]
fn test_prime_and_factorial_integration() {
    let numbers = [2, 3, 4, 5, 10];
    let expected_primes = [true, true, false, true, false];

    for (i, &n) in numbers.iter().enumerate() {
        assert_eq!(utils::is_prime(n), expected_primes[i]);
        assert!(utils::factorial(n) >= 1);
    }
}

// -----------------------------
// File-Based Test
// -----------------------------
#[test]
fn test_write_and_read_file() {
    let filename = env::temp_dir().join("sisu_test.txt");

    {
        let mut file = File::create(&filename).unwrap();
        writeln!(file, "hello sisu").unwrap();
    }

    let mut content = String::new();
    {
        let mut file = File::open(&filename).unwrap();
        file.read_to_string(&mut content).unwrap();
    }

    assert_eq!(content.trim(), "hello sisu");
}

// -----------------------------
// Property-Based Tests
// -----------------------------
proptest! {
    #[test]
    fn test_addition_commutative(a in -1000..1000i32, b in -1000..1000i32) {
        assert_eq!(add(a, b), add(b, a));
    }

    #[test]
    fn test_factorial_non_negative(n in 0u64..20) {
        assert!(utils::factorial(n) >= 1);
    }
}

// -----------------------------
// Mocking Example
// -----------------------------
use std::cell::RefCell;

thread_local! {
    static MOCK_RESPONSE: RefCell<Option<String>> = RefCell::new(None);
}

fn mock_fetch_data() -> String {
    MOCK_RESPONSE.with(|cell| {
        cell.borrow().clone().unwrap_or_else(|| "default".to_string())
    })
}

#[test]
fn test_mocked_network_call() {
    MOCK_RESPONSE.with(|cell| *cell.borrow_mut() = Some("mocked data".to_string()));
    let data = mock_fetch_data();
    assert_eq!(data, "mocked data");
}