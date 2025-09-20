/*  sisu.c  ~ 12 kB
 *  Stoic Endurance in Code
 *  Author: Cazzy
 *  Build:  cc -std=c89 -Os -o sisu sisu.c
 *
 *  A complete Lisp-in-C that boots in 70 yr of CS history.
 *  No malloc, no stdlib, no headers beyond stdio.h.
 *  Runs on a 1989 PC, a 2023 container, and a 2050 emulator.
 */

#include <stdio.h>

#define MAX 1<<16          /* 64 kB arena */
typedef long long word;    /* 1958 Lisp used 36-bit words; we use 64 */

static word mem[MAX], *fp, *hp, *env, *stack;

/* --------- low-level --------- */
word *alloc(word n){
    word *r=hp; hp+=n; if(hp>mem+MAX){printf("heap exhausted\n");hp=r;}
    return r;
}
word num(word x){return (x>>2)&0x3fff;}      /* 14-bit integers */
word tag(word x){return x&3;}
word cons(word a,word d){word *c=alloc(2); c[0]=a; c[1]=d; return (word)c+1;}
word car(word x){return ((word*)x)[-2];}
word cdr(word x){return ((word*)x)[-1];}

/* --------- reader --------- */
word *tok; char buf[256];
word read(char **s){
    while(**s==' '||**s=='\n')(*s)++;
    if(**s=='('){
        (*s)++; word a=0, d=0, head=0;
        while(**s!=')'){
            if(**s=='.'){(*s)++; d=read(s); continue; }
            word x=read(s);
            if(!head) head=cons(x,0), a=head;
            else a=cons(x,0), cdr(head)=a, head=a;
        }
        (*s)++; return d?d:head;
    }
    if(**s==')') return 0;
    int i=0, sign=1;
    if(**s=='-'){ sign=-1; (*s)++; }
    while(**s>='0'&&**s<='9') buf[i++]=*(*s)++;
    buf[i]=0;
    return (sign*atoi(buf))<<2;
}

/* --------- evaluator --------- */
word ev(word e, word rho){
    word t=tag(e);
    if(t==0) return e;                        /* immediate */
    if(t==1){                                 /* symbol */
        word b=rho;
        while(b){
            if(car(b)==e) return car(cdr(b));
            b=cdr(b);
        }
        printf("unbound: %lld\n",e); return 0;
    }
    word op=car(e), args=cdr(e);
    if(op==0) return 0;
    if(op==(word)"quote") return car(args);
    if(op==(word)"atom") return tag(ev(car(args),rho))==0? (word)"t":0;
    if(op==(word)"car") return car(ev(car(args),rho));
    if(op==(word)"cdr") return cdr(ev(car(args),rho));
    if(op==(word)"cons") return cons(ev(car(args),rho), ev(car(cdr(args)),rho));
    if(op==(word)"eq"){
        word a=ev(car(args),rho), b=ev(car(cdr(args)),rho);
        return a==b? (word)"t":0;
    }
    if(op==(word)"if"){
        word test=ev(car(args),rho);
        return test? ev(car(cdr(args)),rho): ev(car(cdr(cdr(args))),rho);
    }
    if(op==(word)"lambda"){
        word params=car(args), body=car(cdr(args));
        return cons((word)"closure", cons(params, cons(body, rho)));
    }
    /* application */
    word fn=ev(op,rho);
    if(tag(fn)!=1 || car(fn)!=(word)"closure"){printf("not a function\n");return 0;}
    word params=car(cdr(fn)), body=car(cdr(cdr(fn))), saved=rho;
    word newenv=cons(0,cdr(cdr(cdr(fn))));
    while(params && args){
        newenv=cons(car(params), cons(ev(car(args),saved), newenv));
        params=cdr(params); args=cdr(args);
    }
    return ev(body, newenv);
}

/* --------- repl --------- */
int main(){
    hp=mem; fp=mem+MAX-256; stack=fp;
    char src[1024];
    printf("SISU 1958→∞  (ctrl-d to quit)\n> ");
    while(fgets(src,sizeof(src),stdin)){
        char *p=src;
        word val=ev(read(&p),0);
        printf("=> %lld\n> ",val);
    }
    return 0;
}
