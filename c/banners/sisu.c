/* sisu_plus.c
 * Author: Cazzy
 * A tiny Lisp-in-C with:
 *  - static arena (no malloc)
 *  - symbol interning (safe comparisons)
 *  - deterministic RNG (reproducible runs)
 *  - eval trace ring buffer (time-travel inspector)
 *  - snapshot save/load of arena (orthogonal persistence)
 *
 * Build: cc -std=c99 -O2 -o sisu_plus sisu_plus.c
 *
 * This file is intentionally verbose in comments — it teaches design choices.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

/* ---- Configurable arena ---- */
#define ARENA_WORDS  (1<<15)   /* 32k words, ~256KB on 64-bit */
typedef int64_t word;          /* value cell */

/* Tagging: low 2 bits reserved for tag */
#define TAG_IMMEDIATE 0   /* immediate integer (shifted) */
#define TAG_SYMBOL    1   /* symbol id (index into sym table) */
#define TAG_CONS      2   /* pointer into arena (address encoded) */
#define TAG_CLOSURE   3   /* closure object */

/* immediate integer helpers */
static inline word mk_int(long v){ return ((word)v<<2) | TAG_IMMEDIATE; }
static inline long int_val(word w){ return (w>>2); }
static inline int tag_of(word w){ return (int)(w & 3); }

/* ---- static arena (no malloc) ---- */
static word arena[ARENA_WORDS];
static word *hp; /* next free word index into arena as pointer */
static size_t hp_idx = 0;

/* A simple allocator that hands back an arena index encoded in a word.
   We encode a pointer as (base_index << 2) | TAG_CONS.  We keep alignment
   so each "cons cell" occupies two successive words (car, cdr). */
static inline word alloc_cells(size_t n){
    if(hp_idx + n >= ARENA_WORDS){
        fprintf(stderr, "ERROR: arena exhausted (needed %zu words, free %zu)\n", n, ARENA_WORDS - hp_idx);
        return 0;
    }
    size_t idx = hp_idx;
    hp_idx += n;
    /* return pointer-like word: store index and tag */
    return (word)((idx<<2) | TAG_CONS);
}

/* accessors: given pointer-word p (TAG_CONS), get arena index */
static inline size_t ptr_index(word p){
    return (size_t)( (p & ~3) >> 2 );
}
static inline word arena_ref(word p, size_t offset){
    return arena[ptr_index(p) + offset];
}
static inline void arena_set(word p, size_t offset, word val){
    arena[ptr_index(p) + offset] = val;
}

/* cons utility: allocate 2 words and store car/cdr */
static word cons(word a, word d){
    word p = alloc_cells(2);
    if(!p) return 0;
    arena_set(p, 0, a);
    arena_set(p, 1, d);
    return p;
}
static inline word car(word p){ return arena_ref(p, 0); }
static inline word cdr(word p){ return arena_ref(p, 1); }
static inline void setcar(word p, word v){ arena_set(p, 0, v); }
static inline void setcdr(word p, word v){ arena_set(p, 1, v); }

/* ---- Symbol interning ----
   We store symbol names in a simple string table (fixed size),
   intern returns a symbol word = (sym_index << 2) | TAG_SYMBOL.
*/
#define MAX_SYMBOLS 4096
#define MAX_SYM_CHARS 16384
static char sym_buf[MAX_SYM_CHARS];
static size_t sym_buf_used = 0;
static char *sym_tab[MAX_SYMBOLS];
static size_t sym_count = 0;

static word intern_symbol(const char *name){
    /* linear search (small table) */
    for(size_t i=0;i<sym_count;i++){
        if(strcmp(sym_tab[i], name)==0) return (word)((i<<2) | TAG_SYMBOL);
    }
    /* allocate in sym_buf */
    size_t len = strlen(name)+1;
    if(sym_count >= MAX_SYMBOLS || sym_buf_used + len >= MAX_SYM_CHARS){
        fprintf(stderr, "symbol table full\n"); return 0;
    }
    char *loc = sym_buf + sym_buf_used;
    strcpy(loc, name);
    sym_tab[sym_count++] = loc;
    sym_buf_used += len;
    return (word)(((word)(sym_count-1) << 2) | TAG_SYMBOL);
}
static const char *sym_name(word sym){
    if(tag_of(sym)!=TAG_SYMBOL) return "<not-sym>";
    return sym_tab[(size_t)(sym>>2)];
}

/* convenience constructors for booleans and nil as particular symbols */
static word sym_t, sym_nil;

/* ---- small reader (string -> s-expression) ----
   We accept integers and symbols and properly handle parentheses and dot-cons.
*/
static const char *inp;
static void skip_space(void){
    while(*inp && (*inp==' ' || *inp=='\n' || *inp=='\t' || *inp=='\r')) inp++;
}
static word read_sexpr(void);

/* read token (number or symbol) */
static word read_token(void){
    skip_space();
    if(*inp=='\0') return sym_nil;
    if(*inp=='('){ /* list */
        inp++; skip_space();
        if(*inp==')'){ inp++; return sym_nil; }
        word head = sym_nil, tail = sym_nil;
        while(*inp && *inp!=')'){
            if(*inp=='.'){ inp++; word d = read_sexpr(); skip_space(); if(*inp==')') { inp++; return d; } /* dotted tail */
            word x = read_sexpr();
            if(head==sym_nil){ head = cons(x, sym_nil); tail = head; }
            else { setcdr(tail, cons(x, sym_nil)); tail = cdr(tail); }
            skip_space();
        }
        if(*inp==')') inp++;
        return head;
    }
    /* atom: number or symbol */
    if((*inp>='0' && *inp<='9') || (*inp=='-' && (inp[1]>='0' && inp[1]<='9'))){
        int sign = 1;
        if(*inp=='-'){ sign=-1; inp++; }
        long val = 0;
        while(*inp>='0' && *inp<='9'){ val = val*10 + (*inp - '0'); inp++; }
        return mk_int(sign*val);
    }
    /* symbol */
    char tok[64]; int ti=0;
    while(*inp && *inp!=' ' && *inp!='\n' && *inp!='\t' && *inp!='(' && *inp!=')'){
        if(ti<63) tok[ti++]=*inp;
        inp++;
    }
    tok[ti]=0;
    return intern_symbol(tok);
}
static word read_sexpr(void){ return read_token(); }

/* ---- deterministic PRNG (xorshift64*) ---- */
static uint64_t rng_state = 88172645463325252ULL; /* default seed */
static uint64_t xorshift64star(void){
    uint64_t x = rng_state;
    x ^= x >> 12; x ^= x << 25; x ^= x >> 27;
    rng_state = x; return x * 2685821657736338717ULL;
}
static void seed_rng(uint64_t s){ rng_state = s ? s : 88172645463325252ULL; }

/* ---- evaluation trace (ring buffer) ----
   We capture evaluation events as short strings for inspection.
*/
#define TRACE_SIZE 128
static char trace_buf[TRACE_SIZE][128];
static int trace_head = 0;
static void trace_push(const char *s){
    strncpy(trace_buf[trace_head], s, 127); trace_buf[trace_head][127]=0;
    trace_head = (trace_head + 1) % TRACE_SIZE;
}
static void trace_dump(void){
    puts("---- eval trace ----");
    int i = trace_head;
    for(int n=0;n<TRACE_SIZE;n++){
        i = (i - 1 + TRACE_SIZE) % TRACE_SIZE;
        if(trace_buf[i][0]) printf("[%d] %s\n", i, trace_buf[i]);
    }
    puts("--------------------");
}

/* ---- evaluator (very small) ----
   Supports:
     - integers
     - symbols (lookup)
     - quote, atom, car, cdr, cons, eq, if, lambda, save/load, rng, trace commands
   Closures are stored as cons: (closure params body env)
*/
static word ev(word expr, word env);

static word env_lookup(word sym, word env){
    while(env!=sym_nil){
        if(car(car(env)) == sym) return cdr(car(env)); /* pair (sym . value) stored as cons */
        env = cdr(env);
    }
    return sym_nil;
}

/* make closure: cons(TAG_CLOSURE, cons(params, cons(body, env_index_word))) */
static word make_closure(word params, word body, word env_word){
    word c = cons(params, cons(body, env_word));
    /* mark as closure by setting a special wrapper */
    return cons(intern_symbol("closure"), c);
}

/* stringify small word for trace */
static void sprint_word(char *out, word w){
    int tg = tag_of(w);
    if(tg==TAG_IMMEDIATE) sprintf(out, "%ld", int_val(w));
    else if(tg==TAG_SYMBOL) sprintf(out, "%s", sym_name(w));
    else if(tg==TAG_CONS) sprintf(out, "<cons@%zu>", ptr_index(w));
    else sprintf(out, "<w:%ld>", (long)w);
}

/* core eval */
static word ev(word expr, word env){
    char tbuf[128]; sprint_word(tbuf, expr);
    trace_push(tbuf);

    int tg = tag_of(expr);
    if(tg == TAG_IMMEDIATE) return expr;
    if(tg == TAG_SYMBOL){
        if(expr == sym_t) return sym_t;
        word v = env_lookup(expr, env);
        if(v!=sym_nil) return v;
        fprintf(stderr, "unbound symbol: %s\n", sym_name(expr));
        return sym_nil;
    }
    /* application or special form: expect expr is a cons */
    word op = car(expr), args = cdr(expr);
    /* special forms by symbol */
    if(tag_of(op)==TAG_SYMBOL && op == intern_symbol("quote")) return car(args);
    if(tag_of(op)==TAG_SYMBOL && op == intern_symbol("atom")){
        word r = ev(car(args), env);
        return (tag_of(r)==TAG_IMMEDIATE || r==sym_nil) ? sym_t : sym_nil;
    }
    if(tag_of(op)==TAG_SYMBOL && op == intern_symbol("car")) return car(ev(car(args), env));
    if(tag_of(op)==TAG_SYMBOL && op == intern_symbol("cdr")) return cdr(ev(car(args), env));
    if(tag_of(op)==TAG_SYMBOL && op == intern_symbol("cons")){
        return cons(ev(car(args), env), ev(car(cdr(args)), env));
    }
    if(tag_of(op)==TAG_SYMBOL && op == intern_symbol("eq")){
        word a = ev(car(args), env), b = ev(car(cdr(args)), env);
        return (a==b) ? sym_t : sym_nil;
    }
    if(tag_of(op)==TAG_SYMBOL && op == intern_symbol("if")){
        word test = ev(car(args), env);
        if(test!=sym_nil) return ev(car(cdr(args)), env);
        else return ev(car(cdr(cdr(args))), env);
    }
    if(tag_of(op)==TAG_SYMBOL && op == intern_symbol("lambda")){
        return make_closure(car(args), car(cdr(args)), env);
    }
    /* builtin: rng -> random integer */
    if(tag_of(op)==TAG_SYMBOL && op == intern_symbol("rng")){
        uint64_t r = xorshift64star();
        return mk_int((long)(r & 0x7fffffff));
    }
    /* builtin: :save "file"  and :load "file"  (operating on atoms as strings symbols) */
    if(tag_of(op)==TAG_SYMBOL && op == intern_symbol(":save")){
        /* next arg is symbol whose characters we will use as filename */
        word a = ev(car(args), env);
        if(tag_of(a)==TAG_SYMBOL){
            const char *fn = sym_name(a);
            /* simple snapshot: write hp_idx and arena */
            FILE *f = fopen(fn, "wb");
            if(!f){ perror("fopen"); return sym_nil; }
            fwrite(&hp_idx, sizeof(hp_idx), 1, f);
            fwrite(arena, sizeof(arena[0]), hp_idx, f);
            fwrite(&sym_count, sizeof(sym_count),1,f);
            fwrite(&sym_buf_used, sizeof(sym_buf_used),1,f);
            fwrite(sym_buf, 1, sym_buf_used, f);
            fclose(f);
            return sym_t;
        }
        return sym_nil;
    }
    if(tag_of(op)==TAG_SYMBOL && op == intern_symbol(":load")){
        word a = ev(car(args), env);
        if(tag_of(a)==TAG_SYMBOL){
            const char *fn = sym_name(a);
            FILE *f = fopen(fn,"rb");
            if(!f){ perror("fopen"); return sym_nil; }
            size_t new_hp;
            fread(&new_hp, sizeof(new_hp), 1, f);
            if(new_hp >= ARENA_WORDS){ fclose(f); fprintf(stderr,"snapshot too large\n"); return sym_nil; }
            fread(arena, sizeof(arena[0]), new_hp, f);
            hp_idx = new_hp;
            fread(&sym_count, sizeof(sym_count),1,f);
            fread(&sym_buf_used, sizeof(sym_buf_used),1,f);
            fread(sym_buf, 1, sym_buf_used, f);
            fclose(f);
            return sym_t;
        }
        return sym_nil;
    }

    /* application: evaluate op, expect closure */
    word fn = ev(op, env);
    if(tag_of(fn)!=TAG_CONS || car(fn) != intern_symbol("closure")){
        fprintf(stderr, "not a function\n"); return sym_nil;
    }
    word clos_body = car(cdr(cdr(fn))); /* closure stored as cons( "closure", cons(params, cons(body, env_word))) */
    word clos_params = car(cdr(fn));
    word clos_env_word = cdr(cdr(cdr(fn))); /* env object */
    /* create new env by pairing params with evaluated args */
    word newenv = sym_nil;
    word p = clos_params, a = args;
    while(p!=sym_nil && a!=sym_nil){
        word pname = car(p);
        word aval = ev(car(a), env); /* evaluate argument in caller env (saved env) */
        newenv = cons(cons(pname, aval), newenv);
        p = cdr(p); a = cdr(a);
    }
    /* link closure env (note: we store closure env as a word already) */
    newenv = cons(cons(intern_symbol("__parent__"), clos_env_word), newenv);
    /* evaluate body in newenv */
    return ev(clos_body, newenv);
}

/* ---- REPL and utility ---- */
static char linebuf[1024];

static void prompt(void){
    printf("SISU+> ");
    fflush(stdout);
}

static void init_runtime(void){
    hp_idx = 0;
    sym_buf_used = 0; sym_count = 0;
    /* intern useful symbols */
    sym_nil = intern_symbol("nil");
    sym_t = intern_symbol("t");
    intern_symbol("quote"); intern_symbol("atom"); intern_symbol("car");
    intern_symbol("cdr"); intern_symbol("cons"); intern_symbol("eq"); intern_symbol("if");
    intern_symbol("lambda"); intern_symbol("closure"); intern_symbol(":save"); intern_symbol(":load");
    intern_symbol("rng");
    /* clear trace */
    for(int i=0;i<TRACE_SIZE;i++) trace_buf[i][0]=0;
    trace_head = 0;
    seed_rng(1234567); /* deterministic default seed — changeable by user */
}

/* simple inspect: print a tiny representation */
static void print_word(word w){
    int tg = tag_of(w);
    if(tg==TAG_IMMEDIATE) printf("%ld", int_val(w));
    else if(tg==TAG_SYMBOL) printf("%s", sym_name(w));
    else if(tg==TAG_CONS){
        printf("(");
        word cur = w;
        while(cur!=sym_nil){
            print_word(car(cur));
            cur = cdr(cur);
            if(cur!=sym_nil) printf(" ");
        }
        printf(")");
    } else printf("<w:%ld>", (long)w);
}

/* command parsing: lines starting with : are meta */
int main(void){
    init_runtime();
    printf("SISU+ (Cazzy) — tiny Lisp with snapshot & trace\n");
    while(1){
        prompt();
        if(!fgets(linebuf, sizeof(linebuf), stdin)) break;
        /* meta commands */
        if(linebuf[0]==':'){
            if(strncmp(linebuf, ":trace", 6)==0){ trace_dump(); continue; }
            if(strncmp(linebuf, ":seed ",6)==0){ uint64_t s=(uint64_t)atoll(linebuf+6); seed_rng(s); printf("seeded %llu\n",(unsigned long long)s); continue; }
            if(strncmp(linebuf, ":hp",3)==0){ printf("hp_idx=%zu\n", hp_idx); continue; }
            if(strncmp(linebuf, ":sym",4)==0){ printf("symbols (%zu):\n", sym_count); for(size_t i=0;i<sym_count;i++) printf("  %zu: %s\n", i, sym_tab[i]); continue; }
            if(strncmp(linebuf, ":quit",5)==0 || strncmp(linebuf, ":q",2)==0) break;
            printf("unknown meta command\n"); continue;
        }
        inp = linebuf;
        word expr = read_sexpr();
        if(expr==sym_nil){ printf("=> nil\n"); continue; }
        word val = ev(expr, sym_nil);
        print_word(val); printf("\n");
    }
    printf("\nbye\n");
    return 0;
}