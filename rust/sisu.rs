// sisu.rs
// Cazzy — "SISU: Stoic Endurance in Code" (Rust reimagining)
// Build: rustc sisu.rs -O && ./sisu
//
// This single-file interpreter demonstrates:
//  - A single arena allocator (Vec) — "no malloc" spirit (we still use Vec but treat it as a fixed arena)
//  - Symbol interning (robust symbol equality)
//  - Deterministic RNG (seedable xorshift64*)
//  - Trace ring buffer (time-travel inspector)
//  - Snapshot save/load (binary format, portable-ish)
//  - Checkpoint / rewind support (store arena+sym snapshots in-memory ring)
//  - Provenance: objects record the REPL-step that created them
//  - Concurrent evaluation dispatcher (threaded eval requests guarded by Mutex/Arc)
//
// Design notes (human): The interpreter stores values as a `Value` enum:
//  - Int(i64) for immediate integers
//  - Sym(usize) for symbol ids
//  - Ptr(usize) for pointers into the arena (cons cells / closures)
//  - Nil for the empty list
//
// Objects in the arena are `Obj`: Cons or Closure. Each Obj gets an optional provenance stamp:
//  the REPL-step id that created it. This lets us trace where a value came from. It's tiny but
//  reveals the "origin story" for emergent behavior.
//
// Read the comments as a guided lab. Extend by adding macros, hygienic expansion, or reversible evaluation.
//

use std::collections::HashMap;
use std::fs::File;
use std::io::{self, Read, Write};
use std::sync::{Arc, Mutex};
use std::thread;
use std::time::{SystemTime, UNIX_EPOCH};

/// -----------------------------
///  Basic types & arena layout
/// -----------------------------
type Int = i64;

/// Value is the runtime tag for everything you can manipulate in Lisp code.
#[derive(Clone, Debug)]
enum Value {
    Int(Int),
    Sym(usize),    // symbol id into sym_table
    Ptr(usize),    // index into arena Vec<Obj>
    Nil,
}

impl Value {
    fn is_nil(&self) -> bool {
        matches!(self, Value::Nil)
    }
}

/// Objects held in the arena. A Cons is two Values (car,cdr).
/// A Closure holds params (as a Ptr to a list), body (Ptr), env (Ptr), and provenance (step id).
#[derive(Clone, Debug)]
enum Obj {
    Cons {
        car: Value,
        cdr: Value,
        prov: usize, // provenance: REPL step id
    },
    Closure {
        params: Value, // typically Ptr to a Cons-list of symbols or Nil
        body: Value,   // Ptr to AST (we store parsed lists in the arena too)
        env: Value,    // Ptr to environment list (conses)
        prov: usize,
    },
}

/// The runtime holds the arena, symbol table, RNG state, trace buffer, and checkpoints.
struct Runtime {
    arena: Vec<Obj>,                // arena: objects indexed by usize
    sym_table: Vec<String>,         // interned symbol names by id
    sym_map: HashMap<String, usize>,// map name->id
    trace: Vec<String>,             // ring buffer lines
    trace_head: usize,
    rng_state: u64,                 // deterministic RNG
    step_id: usize,                 // REPL step counter for provenance
    checkpoints: Vec<Snapshot>,     // in-memory ring of recent snapshots for rewind
    checkpoint_head: usize,
    max_trace: usize,
    max_checkpoints: usize,
}

#[derive(Clone)]
struct Snapshot {
    arena: Vec<Obj>,
    sym_table: Vec<String>,
    rng_state: u64,
    step_id: usize,
}

/// -----------------------------
/// Utilities: make/read symbols
/// -----------------------------
impl Runtime {
    fn new(arena_capacity: usize, max_trace: usize, max_checkpoints: usize) -> Runtime {
        let mut rt = Runtime {
            arena: Vec::with_capacity(arena_capacity),
            sym_table: Vec::new(),
            sym_map: HashMap::new(),
            trace: vec![String::new(); max_trace],
            trace_head: 0,
            rng_state: 88172645463325252u64, // default seed
            step_id: 0,
            checkpoints: vec![],
            checkpoint_head: 0,
            max_trace,
            max_checkpoints,
        };
        // Pre-intern common symbols
        rt.intern("nil");
        rt.intern("t");
        rt.intern("quote");
        rt.intern("atom");
        rt.intern("car");
        rt.intern("cdr");
        rt.intern("cons");
        rt.intern("eq");
        rt.intern("if");
        rt.intern("lambda");
        rt.intern("closure");
        rt.intern(":save");
        rt.intern(":load");
        rt.intern(":checkpoint");
        rt.intern(":rewind");
        rt.intern("rng");
        rt
    }

    fn intern(&mut self, s: &str) -> usize {
        if let Some(&id) = self.sym_map.get(s) {
            return id;
        }
        let id = self.sym_table.len();
        self.sym_table.push(s.to_string());
        self.sym_map.insert(s.to_string(), id);
        id
    }

    fn sym_name(&self, id: usize) -> &str {
        &self.sym_table[id]
    }

    fn push_trace(&mut self, s: String) {
        self.trace[self.trace_head] = s;
        self.trace_head = (self.trace_head + 1) % self.max_trace;
    }

    fn dump_trace(&self) {
        println!("--- eval trace (latest first) ---");
        let mut i = self.trace_head;
        for _ in 0..self.max_trace {
            i = (i + self.max_trace - 1) % self.max_trace;
            if !self.trace[i].is_empty() {
                println!("[{}] {}", i, self.trace[i]);
            }
        }
        println!("---------------------------------");
    }

    /// deterministic xorshift64* RNG
    fn seed_rng(&mut self, s: u64) {
        self.rng_state = if s == 0 { 88172645463325252u64 } else { s };
        self.push_trace(format!("rng seeded {}", self.rng_state));
    }
    fn rand_i64(&mut self) -> i64 {
        let mut x = self.rng_state;
        x ^= x >> 12;
        x ^= x << 25;
        x ^= x >> 27;
        self.rng_state = x;
        let v = (x.wrapping_mul(2685821657736338717u64) & 0x7fffffffffffffff) as i64;
        v
    }

    /// allocate a Cons object, return a pointer (Ptr(index))
    fn alloc_cons(&mut self, car: Value, cdr: Value) -> Value {
        let prov = self.step_id;
        let idx = self.arena.len();
        self.arena.push(Obj::Cons { car, cdr, prov });
        Value::Ptr(idx)
    }

    /// allocate a Closure
    fn alloc_closure(&mut self, params: Value, body: Value, env: Value) -> Value {
        let prov = self.step_id;
        let idx = self.arena.len();
        self.arena.push(Obj::Closure { params, body, env, prov });
        Value::Ptr(idx)
    }

    fn get_obj(&self, p: &Value) -> Option<&Obj> {
        match p {
            Value::Ptr(i) => self.arena.get(*i),
            _ => None,
        }
    }
    fn get_obj_mut(&mut self, p: &Value) -> Option<&mut Obj> {
        match p {
            Value::Ptr(i) => self.arena.get_mut(*i),
            _ => None,
        }
    }

    /// Snapshot save/load (binary). This writes arena length, then object kinds and data,
    /// then symbol table, RNG, and step id. It's intentionally simple and portable across same-arch.
    fn save_snapshot_to_file(&self, fname: &str) -> io::Result<()> {
        let mut f = File::create(fname)?;
        // write arena length
        let arena_len = self.arena.len() as u64;
        f.write_all(&arena_len.to_le_bytes())?;
        for obj in &self.arena {
            match obj {
                Obj::Cons { car, cdr, prov } => {
                    f.write_all(&[0u8])?; // tag 0 = cons
                    self.write_value(&mut f, car)?;
                    self.write_value(&mut f, cdr)?;
                    f.write_all(&prov.to_le_bytes())?;
                }
                Obj::Closure { params, body, env, prov } => {
                    f.write_all(&[1u8])?; // tag 1 = closure
                    self.write_value(&mut f, params)?;
                    self.write_value(&mut f, body)?;
                    self.write_value(&mut f, env)?;
                    f.write_all(&prov.to_le_bytes())?;
                }
            }
        }
        // symbol table
        let sym_count = self.sym_table.len() as u64;
        f.write_all(&sym_count.to_le_bytes())?;
        for s in &self.sym_table {
            let bytes = s.as_bytes();
            let len = bytes.len() as u64;
            f.write_all(&len.to_le_bytes())?;
            f.write_all(bytes)?;
        }
        // rng and step id
        f.write_all(&self.rng_state.to_le_bytes())?;
        f.write_all(&(self.step_id as u64).to_le_bytes())?;
        Ok(())
    }

    fn write_value(&self, f: &mut File, v: &Value) -> io::Result<()> {
        match v {
            Value::Int(i) => {
                f.write_all(&[0u8])?;
                f.write_all(&i.to_le_bytes())?;
            }
            Value::Sym(sid) => {
                f.write_all(&[1u8])?;
                f.write_all(&(*sid as u64).to_le_bytes())?;
            }
            Value::Ptr(idx) => {
                f.write_all(&[2u8])?;
                f.write_all(&(*idx as u64).to_le_bytes())?;
            }
            Value::Nil => {
                f.write_all(&[3u8])?;
            }
        }
        Ok(())
    }

    fn load_snapshot_from_file(&mut self, fname: &str) -> io::Result<()> {
        let mut f = File::open(fname)?;
        let mut buf8 = [0u8; 8];
        f.read_exact(&mut buf8)?; let arena_len = u64::from_le_bytes(buf8) as usize;
        self.arena.clear();
        for _ in 0..arena_len {
            let mut tag = [0u8;1]; f.read_exact(&mut tag)?;
            match tag[0] {
                0 => {
                    let car = self.read_value(&mut f)?;
                    let cdr = self.read_value(&mut f)?;
                    f.read_exact(&mut buf8)?; let prov = usize::try_from(u64::from_le_bytes(buf8)).unwrap_or(0);
                    self.arena.push(Obj::Cons{car,cdr,prov});
                }
                1 => {
                    let params = self.read_value(&mut f)?;
                    let body = self.read_value(&mut f)?;
                    let env = self.read_value(&mut f)?;
                    f.read_exact(&mut buf8)?; let prov = usize::try_from(u64::from_le_bytes(buf8)).unwrap_or(0);
                    self.arena.push(Obj::Closure{params,body,env,prov});
                }
                _ => { return Err(io::Error::new(io::ErrorKind::InvalidData,"bad obj tag")); }
            }
        }
        // symbols
        f.read_exact(&mut buf8)?; let sym_count = u64::from_le_bytes(buf8) as usize;
        self.sym_table.clear(); self.sym_map.clear();
        for _ in 0..sym_count {
            f.read_exact(&mut buf8)?; let len = u64::from_le_bytes(buf8) as usize;
            let mut sbuf = vec![0u8; len];
            f.read_exact(&mut sbuf)?;
            let s = String::from_utf8_lossy(&sbuf).into_owned();
            let id = self.sym_table.len();
            self.sym_map.insert(s.clone(), id);
            self.sym_table.push(s);
        }
        // rng and step id
        f.read_exact(&mut buf8)?; self.rng_state = u64::from_le_bytes(buf8);
        f.read_exact(&mut buf8)?; self.step_id = u64::from_le_bytes(buf8) as usize;
        Ok(())
    }

    fn read_value(&self, f: &mut File) -> io::Result<Value> {
        let mut tag = [0u8;1]; f.read_exact(&mut tag)?;
        let mut buf8 = [0u8;8];
        match tag[0] {
            0 => { f.read_exact(&mut buf8)?; Ok(Value::Int(i64::from_le_bytes(buf8))) }
            1 => { f.read_exact(&mut buf8)?; Ok(Value::Sym(u64::from_le_bytes(buf8) as usize)) }
            2 => { f.read_exact(&mut buf8)?; Ok(Value::Ptr(u64::from_le_bytes(buf8) as usize)) }
            3 => Ok(Value::Nil),
            _ => Err(io::Error::new(io::ErrorKind::InvalidData, "bad value tag")),
        }
    }

    /// Create an in-memory checkpoint (push to checkpoints ring)
    fn checkpoint(&mut self) {
        let snap = Snapshot {
            arena: self.arena.clone(),
            sym_table: self.sym_table.clone(),
            rng_state: self.rng_state,
            step_id: self.step_id,
        };
        if self.checkpoints.len() < self.max_checkpoints {
            self.checkpoints.push(snap);
            self.checkpoint_head = self.checkpoints.len() - 1;
        } else {
            self.checkpoint_head = (self.checkpoint_head + 1) % self.max_checkpoints;
            self.checkpoints[self.checkpoint_head] = snap;
        }
        self.push_trace(format!("checkpoint saved at step {}", self.step_id));
    }

    /// Rewind to the latest checkpoint (if any)
    fn rewind(&mut self) {
        if self.checkpoints.is_empty() {
            self.push_trace("rewind: no checkpoints".to_string());
            return;
        }
        let snap = self.checkpoints[self.checkpoint_head].clone();
        self.arena = snap.arena;
        self.sym_table = snap.sym_table;
        self.sym_map.clear();
        for (i,s) in self.sym_table.iter().enumerate() { self.sym_map.insert(s.clone(), i); }
        self.rng_state = snap.rng_state;
        self.step_id = snap.step_id;
        self.push_trace(format!("rewound to checkpoint step {}", self.step_id));
    }
}

/// -----------------------------
/// Reader: simple S-expression parser
/// -----------------------------
/// Accepts integers, symbols, parentheses, dot-cons. No strings for simplicity.
///

fn is_delim(c: char) -> bool {
    c.is_whitespace() || c == '(' || c == ')' || c == '.' || c == '\0'
}

fn tokenize<'a>(s: &'a str) -> Vec<&'a str> {
    let mut toks = Vec::new();
    let mut i = 0;
    let bytes = s.as_bytes();
    let n = bytes.len();
    while i < n {
        let c = bytes[i] as char;
        if c.is_whitespace() { i += 1; continue; }
        if c == '(' || c == ')' || c == '.' {
            toks.push(&s[i..i+1]); i += 1; continue;
        }
        let start = i;
        while i < n && !is_delim(bytes[i] as char) { i += 1; }
        toks.push(&s[start..i]);
    }
    toks
}

/// The parser consumes tokens and allocates AST nodes in the arena.
/// For simplicity we represent AST as Values where lists are actual cons cells
/// stored in the runtime arena. The reader uses the runtime to allocate cons nodes.
fn read_expr(rt: &mut Runtime, toks: &[&str], pos: &mut usize) -> Value {
    if *pos >= toks.len() { return Value::Nil; }
    let t = toks[*pos];
    *pos += 1;
    if t == "(" {
        // read list until ')', handle dotted pair
        let mut head = Value::Nil;
        let mut tail = Value::Nil;
        while *pos < toks.len() && toks[*pos] != ")" {
            if toks[*pos] == "." {
                // dotted tail: read next expr and treat as final cdr
                *pos += 1;
                let d = read_expr(rt, toks, pos);
                // consume ')'
                if *pos < toks.len() && toks[*pos] == ")" { *pos +=1; }
                // attach d as cdr of tail
                if head.is_nil() {
                    return d;
                } else {
                    // set cdr of tail to d
                    if let Value::Ptr(idx) = tail {
                        if let Some(Obj::Cons{car:_, cdr:_, prov:_}) = rt.arena.get_mut(idx) {
                            rt.arena[idx] = Obj::Cons{ car: match rt.get_obj(&Value::Ptr(idx)).unwrap() {
                                Obj::Cons {car, ..} => car.clone(),
                                _ => Value::Nil,
                            }, cdr: d, prov: rt.step_id};
                        }
                    }
                    return head;
                }
            }
            let x = read_expr(rt, toks, pos);
            if head.is_nil() {
                head = rt.alloc_cons(x.clone(), Value::Nil);
                tail = head.clone();
            } else {
                // tail is Ptr
                if let Value::Ptr(idx) = tail {
                    // set cdr of tail to new cons
                    let new = rt.alloc_cons(x.clone(), Value::Nil);
                    if let Some(Obj::Cons{ref mut cdr, ..}) = rt.arena.get_mut(idx) {
                        *cdr = new.clone();
                    }
                    tail = new;
                }
            }
        }
        // consume ')'
        if *pos < toks.len() && toks[*pos] == ")" { *pos += 1; }
        if head.is_nil() { Value::Nil } else { head }
    } else if t == ")" {
        Value::Nil
    } else {
        // atom: integer or symbol
        if let Ok(i) = t.parse::<i64>() {
            Value::Int(i)
        } else {
            let id = rt.intern(t);
            Value::Sym(id)
        }
    }
}

/// -----------------------------
/// Evaluator (small set of forms)
/// -----------------------------
/// eval rules:
///  - ints -> ints
///  - symbols -> lookup in env
///  - (quote x) -> x
///  - (atom x) -> t if x is int or nil else nil
///  - (car x), (cdr x), (cons a b), (eq a b)
///  - (if t then else)
///  - (lambda (params) body) -> closure (params/body/env)
///  - application: evaluate op then apply (closures only)
///
/// Environment is represented as a linked list of pairs (sym . value) allocated in arena.
/// We represent env as a Value: Nil or Ptr to Cons of binding pairs.
/// A binding pair is a cons whose car is a cons (sym . value) and whose cdr is rest.
/// For simplicity we build env lists in the arena too.
/// -----------------------------
fn env_lookup(rt: &Runtime, sym: usize, env: &Value) -> Value {
    let mut cur = env.clone();
    while !cur.is_nil() {
        if let Value::Ptr(idx) = cur {
            if let Some(Obj::Cons{car, cdr:next, ..}) = rt.arena.get(idx) {
                // car is a binding (sym . value)
                if let Value::Ptr(bind_idx) = car {
                    if let Some(Obj::Cons{car:bsym, cdr:bval, ..}) = rt.arena.get(bind_idx) {
                        if let Value::Sym(sid) = bsym {
                            if *sid == sym {
                                return bval.clone();
                            }
                        }
                    }
                }
                cur = next.clone();
                continue;
            } else { break; }
        } else { break; }
    }
    Value::Nil
}

fn is_true(v: &Value) -> bool {
    !matches!(v, Value::Nil)
}

fn eval(rt_arc: &Arc<Mutex<Runtime>>, expr: Value, env: Value) -> Value {
    // increment step id and record provenance for objects allocated during this eval
    let mut rt = rt_arc.lock().unwrap();
    rt.step_id += 1;
    let this_step = rt.step_id;
    rt.push_trace(format!("eval step {} begin: {:?}", this_step, show_val(&rt, &expr)));
    drop(rt); // unlock while evaluating recursively to allow concurrency in other threads

    // define recursive closure using interior mutability pattern via Arc<Mutex<_>> to allow recursion
    fn eval_inner(rt_arc: &Arc<Mutex<Runtime>>, expr: Value, env: Value) -> Value {
        let mut rt = rt_arc.lock().unwrap();
        // Log the expr
        rt.push_trace(format!("eval_inner step {} expr {:?}", rt.step_id, show_val(&rt, &expr)));
        match expr {
            Value::Int(_) => expr,
            Value::Nil => Value::Nil,
            Value::Sym(sid) => {
                if rt.sym_table.get(sid).map(|s| s.as_str()) == Some("t") {
                    Value::Sym(sid)
                } else {
                    let v = env_lookup(&*rt, sid, &env);
                    if v.is_nil() {
                        rt.push_trace(format!("unbound symbol {} at step {}", rt.sym_name(sid), rt.step_id));
                        Value::Nil
                    } else {
                        v
                    }
                }
            }
            Value::Ptr(idx) => {
                // a pointer used as expression: evaluate as list / application
                // get op and args
                if let Some(Obj::Cons{car:op, cdr:args, ..}) = rt.arena.get(idx).cloned() {
                    // special forms: op could be a symbol (quote, atom, car, cdr, cons, eq, if, lambda)
                    if let Value::Sym(sid) = op {
                        let name = rt.sym_name(sid).to_string();
                        if name == "quote" {
                            // (quote x) -> return x (car of args)
                            if let Value::Ptr(arg_idx) = args {
                                if let Some(Obj::Cons{car:x, ..}) = rt.arena.get(arg_idx) {
                                    return x.clone();
                                }
                            }
                            return Value::Nil;
                        } else if name == "atom" {
                            // (atom x)
                            if let Value::Ptr(arg_idx) = args {
                                if let Some(Obj::Cons{car:x, ..}) = rt.arena.get(arg_idx) {
                                    let r = eval_inner(rt_arc, x.clone(), env.clone());
                                    match r {
                                        Value::Int(_) | Value::Nil => {
                                            let tid = rt.intern("t");
                                            return Value::Sym(tid);
                                        }
                                        _ => return Value::Nil,
                                    }
                                }
                            }
                            return Value::Nil;
                        } else if name == "car" {
                            if let Value::Ptr(arg_idx) = args {
                                if let Some(Obj::Cons{car:x, ..}) = rt.arena.get(arg_idx) {
                                    let prod = eval_inner(rt_arc, x.clone(), env.clone());
                                    if let Value::Ptr(pidx) = prod {
                                        if let Some(Obj::Cons{car:ccar, ..}) = rt.arena.get(pidx) {
                                            return ccar.clone();
                                        }
                                    }
                                }
                            }
                            return Value::Nil;
                        } else if name == "cdr" {
                            if let Value::Ptr(arg_idx) = args {
                                if let Some(Obj::Cons{car:x, ..}) = rt.arena.get(arg_idx) {
                                    let prod = eval_inner(rt_arc, x.clone(), env.clone());
                                    if let Value::Ptr(pidx) = prod {
                                        if let Some(Obj::Cons{cdr:ccdr, ..}) = rt.arena.get(pidx) {
                                            return ccdr.clone();
                                        }
                                    }
                                }
                            }
                            return Value::Nil;
                        } else if name == "cons" {
                            if let Value::Ptr(arg_idx) = args {
                                // first arg
                                if let Some(Obj::Cons{car:a, cdr:rest, ..}) = rt.arena.get(arg_idx) {
                                    let aval = eval_inner(rt_arc, a.clone(), env.clone());
                                    // second arg is car of rest
                                    if let Value::Ptr(rest_idx) = rest {
                                        if let Some(Obj::Cons{car:b, ..}) = rt.arena.get(rest_idx) {
                                            let bval = eval_inner(rt_arc, b.clone(), env.clone());
                                            return rt.alloc_cons(aval, bval);
                                        }
                                    }
                                }
                            }
                            return Value::Nil;
                        } else if name == "eq" {
                            if let Value::Ptr(arg_idx) = args {
                                if let Some(Obj::Cons{car:a, cdr:rest, ..}) = rt.arena.get(arg_idx) {
                                    let aval = eval_inner(rt_arc, a.clone(), env.clone());
                                    if let Value::Ptr(rest_idx) = rest {
                                        if let Some(Obj::Cons{car:b, ..}) = rt.arena.get(rest_idx) {
                                            let bval = eval_inner(rt_arc, b.clone(), env.clone());
                                            // equality: for simplicity compare Int and Sym by value, and Ptr by pointer index
                                            let eq = match (&aval, &bval) {
                                                (Value::Int(ai), Value::Int(bi)) => ai == bi,
                                                (Value::Sym(asid), Value::Sym(bsid)) => asid == bsid,
                                                (Value::Ptr(ai), Value::Ptr(bi)) => ai == bi,
                                                (Value::Nil, Value::Nil) => true,
                                                _ => false,
                                            };
                                            if eq {
                                                let tid = rt.intern("t"); return Value::Sym(tid);
                                            } else { return Value::Nil; }
                                        }
                                    }
                                }
                            }
                            return Value::Nil;
                        } else if name == "if" {
                            // (if test then else)
                            if let Value::Ptr(arg_idx) = args {
                                if let Some(Obj::Cons{car:test, cdr:rest, ..}) = rt.arena.get(arg_idx) {
                                    let tval = eval_inner(rt_arc, test.clone(), env.clone());
                                    if is_true(&tval) {
                                        // then: car of rest
                                        if let Value::Ptr(rest_idx) = rest {
                                            if let Some(Obj::Cons{car:then_exp, ..}) = rt.arena.get(rest_idx) {
                                                return eval_inner(rt_arc, then_exp.clone(), env.clone());
                                            }
                                        }
                                    } else {
                                        // else: car of cdr(rest)
                                        if let Value::Ptr(rest_idx) = rest {
                                            if let Some(Obj::Cons{cdr:rest2, ..}) = rt.arena.get(rest_idx) {
                                                if let Value::Ptr(rest2_idx) = rest2 {
                                                    if let Some(Obj::Cons{car:else_exp, ..}) = rt.arena.get(rest2_idx) {
                                                        return eval_inner(rt_arc, else_exp.clone(), env.clone());
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            return Value::Nil;
                        } else if name == "lambda" {
                            // produce closure, closure captures env by pointer to env list (we'll use Nil for now)
                            if let Value::Ptr(arg_idx) = args {
                                if let Some(Obj::Cons{car:params, cdr:rest, ..}) = rt.arena.get(arg_idx) {
                                    if let Value::Ptr(rest_idx) = rest {
                                        if let Some(Obj::Cons{car:body, ..}) = rt.arena.get(rest_idx) {
                                            // closure captures current env (we'll represent env as a Value::Ptr to a cons-list)
                                            let env_ptr = env.clone();
                                            return rt.alloc_closure(params.clone(), body.clone(), env_ptr);
                                        }
                                    }
                                }
                            }
                            return Value::Nil;
                        } else if name == "rng" {
                            // builtin RNG returns positive integer
                            let v = rt.rand_i64();
                            return Value::Int(v);
                        } else if name == ":save" {
                            // :save filename-symbol
                            if let Value::Ptr(arg_idx) = args {
                                if let Some(Obj::Cons{car:fname_sym, ..}) = rt.arena.get(arg_idx) {
                                    if let Value::Sym(fid) = fname_sym {
                                        let fname = rt.sym_name(*fid).to_string();
                                        match rt.save_snapshot_to_file(&fname) {
                                            Ok(_) => { rt.push_trace(format!("saved snapshot to {}", fname)); return Value::Sym(rt.intern("t")); }
                                            Err(e) => { rt.push_trace(format!("save failed: {}", e)); return Value::Nil; }
                                        }
                                    }
                                }
                            }
                            return Value::Nil;
                        } else if name == ":load" {
                            if let Value::Ptr(arg_idx) = args {
                                if let Some(Obj::Cons{car:fname_sym, ..}) = rt.arena.get(arg_idx) {
                                    if let Value::Sym(fid) = fname_sym {
                                        let fname = rt.sym_name(*fid).to_string();
                                        match rt.load_snapshot_from_file(&fname) {
                                            Ok(_) => { rt.push_trace(format!("loaded snapshot from {}", fname)); return Value::Sym(rt.intern("t")); }
                                            Err(e) => { rt.push_trace(format!("load failed: {}", e)); return Value::Nil; }
                                        }
                                    }
                                }
                            }
                            return Value::Nil;
                        } else if name == ":checkpoint" {
                            rt.checkpoint(); return Value::Sym(rt.intern("t"));
                        } else if name == ":rewind" {
                            rt.rewind(); return Value::Sym(rt.intern("t"));
                        }
                    } // end special forms check
                    // Otherwise treat as application: evaluate op and args, expect closure
                    let fnv = eval_inner(rt_arc, op.clone(), env.clone());
                    // evaluate args into a list of Values, building a temporary list in arena
                    let mut arg_vals: Vec<Value> = vec![];
                    if let Value::Ptr(arg_idx) = args {
                        let mut cur = Value::Ptr(arg_idx);
                        while !cur.is_nil() {
                            if let Value::Ptr(ci) = cur {
                                if let Some(Obj::Cons{car:acar, cdr:acdr, ..}) = rt.arena.get(ci) {
                                    let aval = eval_inner(rt_arc, acar.clone(), env.clone());
                                    arg_vals.push(aval);
                                    cur = acdr.clone();
                                } else { break; }
                            } else { break; }
                        }
                    }
                    // apply
                    if let Value::Ptr(pidx) = fnv {
                        if let Some(Obj::Closure{params, body, env:clos_env, ..}) = rt.arena.get(pidx).cloned() {
                            // build new env: for each param symbol, pair with arg value as a binding cons ( (sym . val) . rest )
                            let mut new_env = clos_env.clone(); // start with closure's captured env
                            // iterate params list and arg_vals
                            let mut pi = params.clone();
                            for (i, argval) in arg_vals.into_iter().enumerate() {
                                // get param symbol at head of pi
                                if let Value::Ptr(pidx2) = pi {
                                    if let Some(Obj::Cons{car:pname, cdr:prem, ..}) = rt.arena.get(pidx2) {
                                        // create binding (pname . argval)
                                        let binding = rt.alloc_cons(pname.clone(), argval);
                                        // push to env as (binding . new_env)
                                        new_env = rt.alloc_cons(binding, new_env);
                                        pi = prem.clone();
                                        continue;
                                    }
                                }
                                break;
                            }
                            // evaluate body in new_env
                            drop(rt); // unlock before recursion
                            let res = eval_inner(rt_arc, body.clone(), new_env);
                            return res;
                        } else {
                            rt.push_trace(format!("apply: not a closure at {:?}", fnv));
                            return Value::Nil;
                        }
                    } else {
                        rt.push_trace(format!("apply: fn not pointer {:?}", fnv));
                        return Value::Nil;
                    }
                }
                // else fallthrough
                Value::Nil
            }
        }
    }

    // call inner
    let res = eval_inner(rt_arc, expr, env);
    let mut rt = rt_arc.lock().unwrap();
    rt.push_trace(format!("eval step {} end -> {:?}", rt.step_id, show_val(&rt, &res)));
    // attach provenance if we created an Obj (some allocations happened inside eval_inner and used rt.step_id)
    res
}

/// -----------------------------
/// Small pretty-printer for Values (human friendly)
/// -----------------------------
fn show_val(rt: &Runtime, v: &Value) -> String {
    match v {
        Value::Nil => "nil".to_string(),
        Value::Int(i) => format!("{}", i),
        Value::Sym(id) => rt.sym_name(*id).to_string(),
        Value::Ptr(idx) => {
            if let Some(obj) = rt.arena.get(*idx) {
                match obj {
                    Obj::Cons{car, cdr, prov} => {
                        // show short list if small
                        if let Value::Int(_) | Value::Sym(_) = car {
                        } // continue
                        let car_s = show_val(rt, car);
                        let cdr_s = show_val(rt, cdr);
                        return format!("(cons[{}] {} . {})", prov, car_s, cdr_s);
                    }
                    Obj::Closure{params, body, env, prov} => {
                        let params_s = show_val(rt, params);
                        return format!("#<closure[{}] {}>", prov, params_s);
                    }
                }
            } else {
                format!("<ptr {}>", idx)
            }
        }
    }
}

/// -----------------------------
/// REPL & concurrency launcher
/// -----------------------------
fn repl_main() -> io::Result<()> {
    let rt = Runtime::new(4096, 256, 16); // arena cap 4096 objects, trace 256, 16 checkpoints
    let rt = Arc::new(Mutex::new(rt));

    println!("SISU (Rust) — compact Lisp with snapshots, trace, provenance");
    println!("Type expressions, or meta commands:");
    println!("  :trace           -- show recent eval trace");
    println!("  :seed N          -- set RNG seed");
    println!("  :save filename   -- save binary snapshot");
    println!("  :load filename   -- load binary snapshot");
    println!("  :checkpoint      -- store in-memory checkpoint");
    println!("  :rewind          -- restore last checkpoint");
    println!("  :sym             -- list symbols");
    println!("  :hp              -- show arena usage");
    println!("  :q               -- quit");
    println!("You can spawn concurrent evals with `&` suffix (not recommended for beginners).");
    println!();

    let stdin = io::stdin();
    loop {
        print!("sisu> ");
        io::Write::flush(&mut io::stdout())?;
        let mut line = String::new();
        if stdin.read_line(&mut line)? == 0 {
            println!(); break;
        }
        let line = line.trim();
        if line.is_empty() { continue; }
        if line.starts_with(":") {
            // meta commands
            let mut parts = line.split_whitespace();
            let cmd = parts.next().unwrap();
            match cmd {
                ":trace" => { let rtlock = rt.lock().unwrap(); rtlock.dump_trace(); continue; }
                ":seed" => {
                    if let Some(nstr) = parts.next() {
                        if let Ok(n) = nstr.parse::<u64>() {
                            let mut rtlock = rt.lock().unwrap();
                            rtlock.seed_rng(n);
                            println!("seeded {}", n);
                        } else { println!("bad seed"); }
                    } else { println!("usage: :seed N"); }
                    continue;
                }
                ":save" => {
                    if let Some(fnname) = parts.next() {
                        let r = { let rtlock = rt.lock().unwrap(); rtlock.save_snapshot_to_file(fnname) };
                        match r {
                            Ok(_) => println!("saved {}", fnname),
                            Err(e) => println!("save failed: {}", e),
                        }
                    } else { println!("usage: :save filename"); }
                    continue;
                }
                ":load" => {
                    if let Some(fnname) = parts.next() {
                        let r = { let mut rtlock = rt.lock().unwrap(); rtlock.load_snapshot_from_file(fnname) };
                        match r {
                            Ok(_) => println!("loaded {}", fnname),
                            Err(e) => println!("load failed: {}", e),
                        }
                    } else { println!("usage: :load filename"); }
                    continue;
                }
                ":checkpoint" => {
                    let mut rtlock = rt.lock().unwrap(); rtlock.checkpoint(); println!("checkpoint saved"); continue;
                }
                ":rewind" => {
                    let mut rtlock = rt.lock().unwrap(); rtlock.rewind(); println!("rewound"); continue;
                }
                ":sym" => {
                    let rtlock = rt.lock().unwrap();
                    println!("symbols:");
                    for (i,s) in rtlock.sym_table.iter().enumerate() {
                        println!("  {} -> {}", i, s);
                    }
                    continue;
                }
                ":hp" => {
                    let rtlock = rt.lock().unwrap();
                    println!("arena len = {}", rtlock.arena.len());
                    continue;
                }
                ":q" | ":quit" => break,
                _ => { println!("unknown meta: {}", cmd); continue; }
            }
        }

        // allow trailing & to run concurrently
        let spawn_concurrent = line.ends_with('&');
        let src = if spawn_concurrent { &line[..line.len()-1] } else { line };
        // copy runtime Arc for closure
        let rt_clone = Arc::clone(&rt);
        let src_str = src.to_string();

        let job = move || {
            let mut rtlock = rt_clone.lock().unwrap();
            let toks = tokenize(&src_str);
            let mut pos = 0usize;
            let expr = read_expr(&mut rtlock, &toks, &mut pos);
            drop(rtlock);
            let res = eval(&rt_clone, expr, Value::Nil);
            let rtlock = rt_clone.lock().unwrap();
            println!("{}", show_val(&rtlock, &res));
        };

        if spawn_concurrent {
            // spawn a thread
            thread::spawn(job);
        } else {
            job();
        }
    }
    Ok(())
}

/// -----------------------------
/// main entry
/// -----------------------------
fn main() {
    if let Err(e) = repl_main() {
        eprintln!("fatal repl error: {}", e);
    }
}