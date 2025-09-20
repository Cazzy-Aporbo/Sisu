let score = 0;
let num1, num2, operator;

const questionEl = document.getElementById('question');
const answerEl = document.getElementById('answer');
const feedbackEl = document.getElementById('feedback');
const scoreEl = document.getElementById('score');
const submitBtn = document.getElementById('submit');

function randomOperator() {
    return Math.random() < 0.5 ? '+' : '-';
}

function generateQuestion() {
    num1 = Math.floor(Math.random() * 20) + 1;
    num2 = Math.floor(Math.random() * 20) + 1;
    operator = randomOperator();

    if(operator === '-' && num2 > num1) [num1, num2] = [num2, num1]; // avoid negative

    questionEl.textContent = `What is ${num1} ${operator} ${num2}?`;
    answerEl.value = '';
    answerEl.focus();
}

function checkAnswer() {
    let userAnswer = parseInt(answerEl.value);
    let correctAnswer = operator === '+' ? num1 + num2 : num1 - num2;

    if(userAnswer === correctAnswer) {
        score += 10;
        feedbackEl.textContent = `🎉 Correct! Great job!`;
        feedbackEl.style.color = `hsl(${Math.random()*360}, 80%, 50%)`;
    } else {
        score -= 5;
        feedbackEl.textContent = `❌ Oops! The correct answer was ${correctAnswer}`;
        feedbackEl.style.color = `hsl(${Math.random()*360}, 80%, 50%)`;
    }

    scoreEl.textContent = `Score: ${score}`;
    generateQuestion();
}

submitBtn.addEventListener('click', checkAnswer);
answerEl.addEventListener('keypress', function(e){
    if(e.key === 'Enter') checkAnswer();
});

// Initialize first question
generateQuestion();