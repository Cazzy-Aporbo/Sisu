// Compile: rustc counterfactual.rs && ./counterfactual
// A toy “stress” score: s = max(0, exp_inc - 0.8) + max(0, 0.2 - bal_inc)
// Suggest minimal nudges to flip s < 0.5.

fn stress(exp_inc: f64, bal_inc: f64) -> f64 {
    let a = (exp_inc - 0.8).max(0.0);
    let b = (0.2 - bal_inc).max(0.0);
    a + b
}

fn main() {
    let (mut e, mut b) = (0.92, 0.12);
    let mut s = stress(e,b);
    println!("Start: e/i={:.2}, b/i={:.2}  score={:.2}", e,b,s);

    let step = 0.01;
    for _ in 0..500 {
        if s < 0.5 { break; }
        // try two nudges: reduce e, increase b
        let se = stress((e - step).max(0.0), b);
        let sb = stress(e, (b + step).min(3.0));
        if se <= sb { e = (e - step).max(0.0); s = se; }
        else { b = (b + step).min(3.0); s = sb; }
    }
    println!("Flip to safe: e/i={:.2}, b/i={:.2}  score={:.2}", e,b,s);
}
