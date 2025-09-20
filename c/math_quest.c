#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>

#define MAX_LEVEL 5

void cls(){ printf("\033[2J\033[H"); }
void color(int c){ printf("\033[38;5;%dm",c); }

int rand_range(int min,int max){ return rand()%(max-min+1)+min; }

void arithmetic_adventure(int level){
    int num1,num2,ans,user;
    num1=rand_range(1,10*level);
    num2=rand_range(1,10*level);
    char ops[4] = {'+','-','*','/'};
    char op = ops[rand()%4];
    float correct;
    
    switch(op){
        case '+': correct=num1+num2; break;
        case '-': correct=num1-num2; break;
        case '*': correct=num1*num2; break;
        case '/': correct=(num2!=0)?(float)num1/num2:0; break;
    }
    
    printf("\nSolve: %d %c %d = ?\n",num1,op,num2);
    printf("Your answer: ");
    if(op=='/') scanf("%f",&correct); // trick: allow float input
    else scanf("%d",&user);
    
    if(op=='/'){
        float diff;
        scanf("%f",&user);
        diff=abs(correct-user);
        if(diff<0.01){ color(82); printf("✅ Correct! Nice division wizardry!\n"); color(15); }
        else{ color(196); printf("❌ Nope! Reality disagrees. Correct: %.2f\n",correct); color(15); }
    } else {
        if(user==(int)correct){ color(82); printf("✅ Correct! You math champ!\n"); color(15); }
        else{ color(196); printf("❌ Nope! Correct answer was %d\n",(int)correct); color(15); }
    }
}

void prime_pursuit(int level){
    int num=rand_range(2,50*level);
    char ans;
    int prime=1;
    for(int i=2;i*i<=num;i++) if(num%i==0) prime=0;
    printf("\nIs %d prime? (y/n): ",num);
    scanf(" %c",&ans);
    if((ans=='y' && prime) || (ans=='n' && !prime)){ color(82); printf("✅ Correct! Prime detective!\n"); color(15);}
    else{ color(196); printf("❌ Wrong! The number was %s\n",prime?"prime":"not prime"); color(15);}
}

void equation_escape(int level){
    int a=rand_range(1,10*level),b=rand_range(1,20*level),x;
    char op = rand()%2?'+':'-';
    printf("\nSolve for x: x %c %d = %d\n",op,b,(op=='+')?a+b:a-b);
    printf("x = "); scanf("%d",&x);
    if((op=='+' && x==a)||(op=='-' && x==a)){ color(82); printf("✅ Correct! Equation tamer!\n"); color(15);}
    else{ color(196); printf("❌ Nope! Correct x=%d\n",a); color(15);}
}

void modulo_madness(int level){
    int a=rand_range(1,20*level),b=rand_range(1,10*level),ans;
    printf("\nWhat is %d %% %d? ",a,b);
    scanf("%d",&ans);
    if(ans==a%b){ color(82); printf("✅ Correct! Mod maestro!\n"); color(15);}
    else{ color(196); printf("❌ Wrong! %d %% %d = %d\n",a,b,a%b); color(15);}
}

int main(){
    srand(time(NULL));
    cls();
    printf("🌟 Welcome to Math Quest: The Number Odyssey 🌟\n");
    int level=1,choice;
    while(1){
        printf("\nLevel %d\nChoose a challenge:\n1) Arithmetic Adventure\n2) Prime Pursuit\n3) Equation Escape\n4) Modulo Madness\n0) Quit\nChoice: ",level);
        scanf("%d",&choice);
        if(choice==0) break;
        switch(choice){
            case 1: arithmetic_adventure(level); break;
            case 2: prime_pursuit(level); break;
            case 3: equation_escape(level); break;
            case 4: modulo_madness(level); break;
            default: printf("🤔 Not an option!"); break;
        }
        level = (level<MAX_LEVEL)?level+1:MAX_LEVEL;
        usleep(300000);
    }
    printf("\n🎉 Thanks for playing! Keep being a math wizard! 🧙‍♂️\n");
    return 0;
}