// Sisu core library
// Polyglot patterns expressed in Rust's type system.

/// Trait for anything that can be compressed to a smaller representation.
/// This is the central abstraction: every algorithm in this repo
/// takes something large and makes it smaller without losing meaning.
pub trait Compress {
    type Output;
    fn compress(&self) -> Self::Output;
    fn ratio(&self) -> f64;
}

/// Trait for patterns that survive across paradigm shifts.
/// If an algorithm works in C, Haskell, and Rust without
/// structural changes, it has endurance.
pub trait Endure {
    fn survived_years(&self) -> u32;
    fn is_paradigm_independent(&self) -> bool;
}

/// A density metric: concepts per line of code.
/// Higher is better. The goal is maximum understanding
/// per unit of reading time.
#[derive(Debug, Clone, Copy)]
pub struct Density {
    pub concepts: u32,
    pub lines: u32,
}

impl Density {
    pub fn new(concepts: u32, lines: u32) -> Self {
        Self { concepts, lines }
    }

    pub fn ratio(&self) -> f64 {
        if self.lines == 0 {
            return 0.0;
        }
        self.concepts as f64 / self.lines as f64
    }
}

/// Run-length encoding: the simplest compression that actually works.
/// Existed since the 1960s. Still used in JPEG, TIFF, PDF.
/// This implementation handles any type that implements Eq.
pub fn rle_encode<T: Eq + Clone>(input: &[T]) -> Vec<(T, usize)> {
    if input.is_empty() {
        return Vec::new();
    }

    let mut result = Vec::new();
    let mut current = &input[0];
    let mut count = 1;

    for item in input.iter().skip(1) {
        if item == current {
            count += 1;
        } else {
            result.push((current.clone(), count));
            current = item;
            count = 1;
        }
    }
    result.push((current.clone(), count));
    result
}

/// Decode run-length encoded data back to the original sequence.
pub fn rle_decode<T: Clone>(encoded: &[(T, usize)]) -> Vec<T> {
    encoded
        .iter()
        .flat_map(|(item, count)| std::iter::repeat(item.clone()).take(*count))
        .collect()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn density_ratio_empty() {
        let d = Density::new(0, 0);
        assert_eq!(d.ratio(), 0.0);
    }

    #[test]
    fn density_ratio_normal() {
        let d = Density::new(10, 5);
        assert!((d.ratio() - 2.0).abs() < f64::EPSILON);
    }

    #[test]
    fn rle_roundtrip() {
        let input = vec![1, 1, 1, 2, 2, 3, 3, 3, 3];
        let encoded = rle_encode(&input);
        let decoded = rle_decode(&encoded);
        assert_eq!(input, decoded);
    }

    #[test]
    fn rle_single_elements() {
        let input = vec![1, 2, 3, 4, 5];
        let encoded = rle_encode(&input);
        assert_eq!(encoded, vec![(1, 1), (2, 1), (3, 1), (4, 1), (5, 1)]);
    }

    #[test]
    fn rle_empty() {
        let input: Vec<i32> = vec![];
        let encoded = rle_encode(&input);
        assert!(encoded.is_empty());
    }

    #[test]
    fn rle_strings() {
        let input = vec!["a", "a", "b", "b", "b", "a"];
        let encoded = rle_encode(&input);
        assert_eq!(encoded, vec![("a", 2), ("b", 3), ("a", 1)]);
    }
}
