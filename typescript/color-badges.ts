// Run: ts-node color-badges.ts  (or tsc && node dist/...)
// Generates Shields.io URLs with your pastel palette.

const bg = ["E6E6FA","DDEBFF","C7CEFA","D4FFE4","FFECF5","DAE8FC"];
const lb = ["B5C7F2","F0E6FF","AEC6EB","DDEBFF","C7CEFA","D4FFE4"];

const pairs = [
  ["Swift","Basic"], ["C","Intermediate"], ["Rust","Basic"],
  ["Fortran","Basic"], ["COBOL","Basic"], ["Lisp","Basic"], ["TypeScript","Intermediate"]
];

pairs.forEach(([tech, level], i) => {
  const url = `https://img.shields.io/badge/${encodeURIComponent(tech)}-${encodeURIComponent(level)}-${bg[i%bg.length]}?style=for-the-badge&labelColor=${lb[i%lb.length]}`;
  console.log(url);
});
