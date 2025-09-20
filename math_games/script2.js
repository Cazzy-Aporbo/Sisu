const canvas = document.getElementById('gameCanvas');
const ctx = canvas.getContext('2d');

const tileSize = 40;
const rows = canvas.height / tileSize;
const cols = canvas.width / tileSize;

let player = { x: 0, y: 0, emoji: '🧑‍🚀' };
let score = 0;

const locations = [
    { x: 3, y: 2, type: 'add' },
    { x: 7, y: 1, type: 'subtract' },
    { x: 4, y: 5, type: 'prime' },
    { x: 9, y: 4, type: 'mod' }
];

const surrealObjects = [
    { x:2, y:3, emoji:'🛸'},
    { x:5, y:2, emoji:'🦄'},
    { x:6, y:5, emoji:'💃'}
];

const questionEl = document.getElementById('question');
const answerEl = document.getElementById('answer');
const feedbackEl = document.getElementById('feedback');
const scoreEl = document.getElementById('score');
const submitBtn = document.getElementById('submit');

let currentQuestion = null;

// Draw grid and entities
function drawGame() {
    ctx.clearRect(0,0,canvas.width,canvas.height);
    // Draw tiles
    for(let i=0;i<cols;i++){
        for(let j=0;j<rows;j++){
            ctx.strokeStyle = `hsl(${Math.random()*360}, 70%, 90%)`;
            ctx.strokeRect(i*tileSize,j*tileSize,tileSize,tileSize);
        }
    }

    // Draw locations
    locations.forEach(loc=>{
        ctx.fillText('🏢', loc.x*tileSize+10, loc.y*tileSize+30);
    });

    // Draw surreal objects
    surrealObjects.forEach(obj=>{
        ctx.fillText(obj.emoji, obj.x*tileSize+10, obj.y*tileSize+30);
    });

    // Draw player
    ctx.fillText(player.emoji, player.x*tileSize+10, player.y*tileSize+30);
}

drawGame();
ctx.font = "30px Comic Sans MS";

// Player movement
document.addEventListener('keydown', e=>{
    if(e.key==='ArrowUp' && player.y>0) player.y--;
    if(e.key==='ArrowDown' && player.y<rows-1) player.y++;
    if(e.key==='ArrowLeft' && player.x>0) player.x--;
    if(e.key==='ArrowRight' && player.x<cols-1) player.x--;

    drawGame();
    checkLocation();
});

// Generate question based on location type
function generateQuestion(type){
    let num1 = Math.floor(Math.random()*20)+1;
    let num2 = Math.floor(Math.random()*20)+1;
    let answer;
    let text = '';

    switch(type){
        case 'add':
            answer = num1+num2;
            text = `What is ${num1} + ${num2}?`;
            break;
        case 'subtract':
            if(num2>num1) [num1,num2]=[num2,num1];
            answer = num1-num2;
            text = `What is ${num1} - ${num2}?`;
            break;
        case 'prime':
            num1 = Math.floor(Math.random()*50)+2;
            answer = isPrime(num1)?1:0;
            text = `Is ${num1} prime? (1=yes,0=no)`;
            break;
        case 'mod':
            answer = num1%num2;
            text = `What is ${num1} % ${num2}?`;
            break;
    }
    return { text, answer };
}

function isPrime(n){
    if(n<2) return false;
    for(let i=2;i*i<=n;i++) if(n%i===0) return false;
    return true;
}

function checkLocation(){
    let loc = locations.find(l=>l.x===player.x && l.y===player.y);
    if(loc){
        currentQuestion = generateQuestion(loc.type);
        questionEl.textContent = currentQuestion.text;
        answerEl.value='';
        feedbackEl.textContent='';
        answerEl.focus();
    }
}

// Check answer
function checkAnswer(){
    if(currentQuestion===null) return;
    let userAns = parseInt(answerEl.value);
    if(userAns===currentQuestion.answer){
        score+=10;
        feedbackEl.textContent = `✅ Correct! 🎉`;
        feedbackEl.style.color = `hsl(${Math.random()*360}, 80%, 50%)`;
    } else {
        score-=5;
        feedbackEl.textContent = `❌ Wrong! Answer was ${currentQuestion.answer}`;
        feedbackEl.style.color = `hsl(${Math.random()*360}, 80%, 50%)`;
    }
    scoreEl.textContent = `Score: ${score}`;
    currentQuestion = null;
}

submitBtn.addEventListener('click', checkAnswer);
answerEl.addEventListener('keypress', e=>{ if(e.key==='Enter') checkAnswer(); });