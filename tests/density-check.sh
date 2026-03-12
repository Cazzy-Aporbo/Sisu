#!/usr/bin/env python3
# SISU — Density Check
# 
# DENSITY:     █████████░  [9/10]
# ENDURANCE:   ██████████  [10/10]  
# ABSTRACTION: ████████░░  [8/10]
#
# COLOR PHASE: #6EE7B7 (Peak Green - Optimal density)
#
# Historical Context:
#   Born from: McCabe Cyclomatic Complexity, 1976
#   Survived:  Every metric since (LOC, Halstead, etc.)
#   Evolves:   Into measuring essence vs ceremony
#

import os
import sys
import re
import ast
import math
from pathlib import Path
from dataclasses import dataclass
from typing import Dict, List, Tuple, Optional
from collections import defaultdict

# Sisu green colors (ANSI escape codes)
class Colors:
    WHISPER = '\033[38;2;240;253;244m'
    PRIMARY = '\033[38;2;167;243;208m'
    PEAK = '\033[38;2;110;231;183m'
    DEEP = '\033[38;2;74;222;128m'
    VOID = '\033[38;2;5;46;22m'
    TEAL = '\033[38;2;0;128;128m'
    RESET = '\033[0m'

@dataclass
class DensityMetrics:
    """Metrics for measuring code density"""
    file_path: str
    lines_of_code: int
    lines_total: int
    comment_lines: int
    blank_lines: int
    cyclomatic_complexity: int
    function_count: int
    unique_tokens: int
    total_tokens: int
    compression_ratio: float
    density_score: float
    color_assignment: str
    
    def __str__(self):
        """Formatted output with color"""
        color = getattr(Colors, self.color_assignment, Colors.RESET)
        return f"""{color}
File: {self.file_path}
  Lines (code/total): {self.lines_of_code}/{self.lines_total}
  Comments/Blanks: {self.comment_lines}/{self.blank_lines}
  Cyclomatic Complexity: {self.cyclomatic_complexity}
  Functions: {self.function_count}
  Token Uniqueness: {self.unique_tokens}/{self.total_tokens}
  Compression Ratio: {self.compression_ratio:.2f}:1
  Density Score: {self.density_score:.2f}/10
  Color Assignment: {self.color_assignment}
{Colors.RESET}"""

class CodeDensityAnalyzer:
    """Analyzes code density according to Sisu principles"""
    
    # Maximum acceptable values (beyond these, code needs compression)
    MAX_LINES = 100
    MAX_COMPLEXITY = 10
    MAX_FUNCTION_LENGTH = 20
    MIN_COMMENT_RATIO = 0.1  # At least 10% comments
    MAX_NESTING = 4
    
    def __init__(self, repo_root: str = "."):
        self.repo_root = Path(repo_root)
        self.metrics: List[DensityMetrics] = []
        
    def analyze_file(self, filepath: Path) -> Optional[DensityMetrics]:
        """Analyze a single file for density metrics"""
        try:
            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()
                lines = content.split('\n')
                
            # Basic line counts
            total_lines = len(lines)
            blank_lines = sum(1 for line in lines if not line.strip())
            comment_lines = self._count_comments(lines, filepath.suffix)
            code_lines = total_lines - blank_lines - comment_lines
            
            # Complexity analysis
            complexity = self._calculate_complexity(content, filepath.suffix)
            function_count = self._count_functions(content, filepath.suffix)
            
            # Token analysis
            tokens = self._tokenize(content)
            unique_tokens = len(set(tokens))
            total_tokens = len(tokens)
            
            # Calculate compression ratio
            compression_ratio = self._calculate_compression(
                code_lines, comment_lines, unique_tokens, total_tokens
            )
            
            # Calculate density score (0-10)
            density_score = self._calculate_density_score(
                code_lines, total_lines, complexity, 
                compression_ratio, comment_lines
            )
            
            # Assign color based on density
            color = self._assign_color(density_score)
            
            return DensityMetrics(
                file_path=str(filepath.relative_to(self.repo_root)),
                lines_of_code=code_lines,
                lines_total=total_lines,
                comment_lines=comment_lines,
                blank_lines=blank_lines,
                cyclomatic_complexity=complexity,
                function_count=function_count,
                unique_tokens=unique_tokens,
                total_tokens=total_tokens,
                compression_ratio=compression_ratio,
                density_score=density_score,
                color_assignment=color
            )
            
        except Exception as e:
            print(f"{Colors.VOID}Error analyzing {filepath}: {e}{Colors.RESET}")
            return None
    
    def _count_comments(self, lines: List[str], suffix: str) -> int:
        """Count comment lines based on file type"""
        comment_count = 0
        in_multiline = False
        
        for line in lines:
            line = line.strip()
            
            # C-style comments
            if suffix in ['.c', '.cpp', '.h', '.js', '.java', '.rs', '.go']:
                if '/*' in line:
                    in_multiline = True
                if in_multiline:
                    comment_count += 1
                if '*/' in line:
                    in_multiline = False
                elif line.startswith('//'):
                    comment_count += 1
                    
            # Python/Shell comments
            elif suffix in ['.py', '.sh']:
                if line.startswith('#'):
                    comment_count += 1
                    
            # Assembly comments
            elif suffix in ['.s', '.asm']:
                if line.startswith(';'):
                    comment_count += 1
                    
        return comment_count
    
    def _calculate_complexity(self, content: str, suffix: str) -> int:
        """Calculate cyclomatic complexity"""
        complexity = 1  # Base complexity
        
        # Keywords that increase complexity
        complexity_keywords = [
            r'\bif\b', r'\belse\b', r'\belif\b', r'\bfor\b', 
            r'\bwhile\b', r'\bcase\b', r'\bcatch\b', r'\bexcept\b',
            r'\b\?\s*:', r'&&', r'\|\|'  # Ternary and logical operators
        ]
        
        for keyword in complexity_keywords:
            complexity += len(re.findall(keyword, content))
        
        # Python-specific: use AST if possible
        if suffix == '.py':
            try:
                tree = ast.parse(content)
                complexity = self._ast_complexity(tree)
            except:
                pass  # Fall back to regex-based
                
        return complexity
    
    def _ast_complexity(self, node, complexity=1) -> int:
        """Calculate complexity using Python AST"""
        for child in ast.walk(node):
            if isinstance(child, (ast.If, ast.While, ast.For, ast.ExceptHandler)):
                complexity += 1
            elif isinstance(child, ast.BoolOp):
                complexity += len(child.values) - 1
                
        return complexity
    
    def _count_functions(self, content: str, suffix: str) -> int:
        """Count number of functions/methods"""
        patterns = {
            '.py': r'def\s+\w+',
            '.js': r'function\s+\w+|const\s+\w+\s*=\s*\([^)]*\)\s*=>',
            '.c': r'^\w+\s+\w+\s*\([^)]*\)\s*{',
            '.cpp': r'^\w+\s+\w+::\w+\s*\([^)]*\)\s*{|^\w+\s+\w+\s*\([^)]*\)\s*{',
            '.go': r'func\s+\w+',
            '.rs': r'fn\s+\w+',
            '.java': r'(public|private|protected)\s+\w+\s+\w+\s*\([^)]*\)',
        }
        
        pattern = patterns.get(suffix, r'function|def|func|fn')
        return len(re.findall(pattern, content, re.MULTILINE))
    
    def _tokenize(self, content: str) -> List[str]:
        """Tokenize code into meaningful units"""
        # Remove comments and strings
        content = re.sub(r'//.*?$', '', content, flags=re.MULTILINE)
        content = re.sub(r'/\*.*?\*/', '', content, flags=re.DOTALL)
        content = re.sub(r'".*?"', '""', content)
        content = re.sub(r"'.*?'", "''", content)
        
        # Tokenize
        tokens = re.findall(r'\w+|[^\w\s]', content)
        return [t for t in tokens if t.strip()]
    
    def _calculate_compression(self, code_lines: int, comment_lines: int,
                               unique_tokens: int, total_tokens: int) -> float:
        """Calculate compression ratio"""
        if total_tokens == 0:
            return 0.0
            
        # Token compression ratio
        token_ratio = total_tokens / max(unique_tokens, 1)
        
        # Line efficiency ratio
        line_ratio = code_lines / max(code_lines + comment_lines, 1)
        
        # Combined compression metric
        return (token_ratio * 0.6) + (line_ratio * 10 * 0.4)
    
    def _calculate_density_score(self, code_lines: int, total_lines: int,
                                 complexity: int, compression: float,
                                 comment_lines: int) -> float:
        """Calculate overall density score (0-10)"""
        scores = []
        
        # Line density (fewer lines = better)
        if code_lines <= 50:
            scores.append(10)
        elif code_lines <= 100:
            scores.append(8)
        elif code_lines <= 200:
            scores.append(6)
        else:
            scores.append(max(0, 10 - (code_lines / 50)))
        
        # Complexity score (lower = better)
        if complexity <= 5:
            scores.append(10)
        elif complexity <= 10:
            scores.append(8)
        elif complexity <= 20:
            scores.append(6)
        else:
            scores.append(max(0, 10 - (complexity / 5)))
        
        # Compression score
        scores.append(min(10, compression))
        
        # Comment ratio score
        comment_ratio = comment_lines / max(total_lines, 1)
        if 0.1 <= comment_ratio <= 0.3:
            scores.append(10)
        elif comment_ratio < 0.1:
            scores.append(max(0, comment_ratio * 100))
        else:
            scores.append(max(0, 10 - (comment_ratio * 20)))
        
        return sum(scores) / len(scores)
    
    def _assign_color(self, density_score: float) -> str:
        """Assign a Sisu color based on density score"""
        if density_score >= 9:
            return "PEAK"  # Perfect density
        elif density_score >= 8:
            return "PRIMARY"  # Sisu green
        elif density_score >= 7:
            return "DEEP"  # Good density
        elif density_score >= 5:
            return "WHISPER"  # Needs work
        else:
            return "VOID"  # Too sparse or complex
    
    def analyze_directory(self, directory: Path = None):
        """Analyze all files in a directory"""
        if directory is None:
            directory = self.repo_root
            
        patterns = ['*.c', '*.h', '*.cpp', '*.py', '*.js', '*.go', '*.rs', '*.java']
        
        for pattern in patterns:
            for filepath in directory.rglob(pattern):
                # Skip test files and vendor directories
                if 'test' in filepath.parts or 'vendor' in filepath.parts:
                    continue
                    
                metrics = self.analyze_file(filepath)
                if metrics:
                    self.metrics.append(metrics)
    
    def generate_report(self):
        """Generate density report"""
        print(f"\n{Colors.PRIMARY}╔═══════════════════════════════════════════════════════════╗{Colors.RESET}")
        print(f"{Colors.PRIMARY}║                   DENSITY CHECK REPORT                     ║{Colors.RESET}")
        print(f"{Colors.PRIMARY}╚═══════════════════════════════════════════════════════════╝{Colors.RESET}")
        
        if not self.metrics:
            print(f"{Colors.VOID}No files analyzed{Colors.RESET}")
            return
        
        # Sort by density score
        self.metrics.sort(key=lambda m: m.density_score, reverse=True)
        
        # Summary statistics
        avg_density = sum(m.density_score for m in self.metrics) / len(self.metrics)
        avg_complexity = sum(m.cyclomatic_complexity for m in self.metrics) / len(self.metrics)
        total_lines = sum(m.lines_of_code for m in self.metrics)
        
        print(f"\n{Colors.PRIMARY}Summary Statistics{Colors.RESET}")
        print(f"{Colors.WHISPER}{'─' * 40}{Colors.RESET}")
        print(f"Files analyzed: {Colors.PEAK}{len(self.metrics)}{Colors.RESET}")
        print(f"Average density: {Colors.PEAK}{avg_density:.2f}/10{Colors.RESET}")
        print(f"Average complexity: {Colors.PEAK}{avg_complexity:.2f}{Colors.RESET}")
        print(f"Total lines of code: {Colors.PEAK}{total_lines}{Colors.RESET}")
        
        # Files needing compression
        needs_compression = [m for m in self.metrics if m.density_score < 7]
        if needs_compression:
            print(f"\n{Colors.VOID}Files Needing Compression:{Colors.RESET}")
            for m in needs_compression:
                print(f"  - {m.file_path} (score: {m.density_score:.2f})")
        
        # Best files (examples of good density)
        best_files = [m for m in self.metrics if m.density_score >= 8][:5]
        if best_files:
            print(f"\n{Colors.PEAK}Exemplary Dense Files:{Colors.RESET}")
            for m in best_files:
                print(f"  - {m.file_path} (score: {m.density_score:.2f})")
        
        # Detailed report
        print(f"\n{Colors.PRIMARY}Detailed Analysis{Colors.RESET}")
        print(f"{Colors.WHISPER}{'─' * 40}{Colors.RESET}")
        
        for metrics in self.metrics[:10]:  # Top 10 files
            print(metrics)

def main():
    """Main execution"""
    # Get repository root
    repo_root = os.environ.get('REPO_ROOT', '.')
    
    analyzer = CodeDensityAnalyzer(repo_root)
    analyzer.analyze_directory()
    analyzer.generate_report()
    
    # Exit with error if average density is too low
    if analyzer.metrics:
        avg_density = sum(m.density_score for m in analyzer.metrics) / len(analyzer.metrics)
        if avg_density < 7.0:
            print(f"\n{Colors.VOID}❌ Average density {avg_density:.2f} below threshold (7.0){Colors.RESET}")
            sys.exit(1)
    
    print(f"\n{Colors.PEAK}✓ Density check complete{Colors.RESET}")

if __name__ == "__main__":
    main()
