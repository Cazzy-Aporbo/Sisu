// tests/test_basic.rs
use your_crate_name::{add, subtract};

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