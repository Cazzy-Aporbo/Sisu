#!/usr/bin/env python3
"""
sureni.py - Reflective Code Analysis for Data Science and Engineering
----------------------------------------------------------------------
A inspection tool that challenges assumptions, identifies risks,
and promotes rigorous thinking in scientific computing and production systems.

Usage:
    python sureni.py [--verbose] [--focus area] your_script.py
    
Options:
    --verbose       Show detailed analysis including AST inspection
    --focus area    Focus on specific area: stats, memory, concurrency, numerical
    
Author: Cazandra Aporbo
"""

import sys
import re
import ast
import argparse
import traceback
from collections import defaultdict, Counter
from typing import List, Dict, Tuple, Optional, Set
import os
import importlib.util


class CodePattern:
    """Represents a code pattern with associated concerns and questions."""
    
    def __init__(self, pattern: str, category: str, questions: List[str], 
                 severity: str = "medium", context_required: bool = False):
        self.pattern = re.compile(pattern, re.IGNORECASE)
        self.category = category
        self.questions = questions
        self.severity = severity
        self.context_required = context_required


class StatisticalAnalyzer:
    """Analyzes statistical and mathematical operations for correctness."""
    
    def __init__(self):
        self.numpy_operations = {
            'mean', 'std', 'var', 'cov', 'corrcoef', 'percentile',
            'median', 'quantile', 'histogram', 'bincount'
        }
        
        self.scipy_operations = {
            'ttest_ind', 'pearsonr', 'spearmanr', 'kstest', 'normaltest',
            'chi2_contingency', 'f_oneway', 'mannwhitneyu'
        }
        
        self.sklearn_models = {
            'LinearRegression', 'LogisticRegression', 'RandomForestClassifier',
            'SVC', 'KMeans', 'PCA', 'GradientBoostingRegressor', 'XGBClassifier'
        }
        
    def analyze_statistical_assumptions(self, line: str) -> List[str]:
        questions = []
        
        if any(op in line for op in self.numpy_operations):
            questions.extend([
                "Have you checked for NaN and infinite values before this operation?",
                "What happens to this calculation with extreme outliers?",
                "Is the data normalized or standardized as this operation expects?"
            ])
            
        if any(op in line for op in self.scipy_operations):
            questions.extend([
                "Have you verified the assumptions of this statistical test?",
                "What is your null hypothesis and is it appropriate here?",
                "Have you corrected for multiple comparisons if running many tests?",
                "What is the statistical power of this test given your sample size?"
            ])
            
        if any(model in line for model in self.sklearn_models):
            questions.extend([
                "Have you performed cross-validation to assess generalization?",
                "What is the class balance and how does it affect this model?",
                "Have you examined feature importance and collinearity?",
                "Is there data leakage between your train and test sets?"
            ])
            
        if 'p_value' in line or 'pvalue' in line:
            questions.append("Are you interpreting p-values correctly without p-hacking?")
            
        if 'random_state' in line:
            questions.append("Is the random seed set for reproducibility across all operations?")
            
        return questions


class MemoryProfiler:
    """Analyzes memory usage patterns and potential issues."""
    
    def __init__(self):
        self.memory_intensive_operations = {
            'read_csv': "Consider chunking large files with chunksize parameter",
            'pivot_table': "Pivot operations can explode memory with high cardinality",
            'merge': "Merge operations duplicate data - consider join type carefully",
            'groupby': "Groupby with many groups can consume significant memory",
            'concat': "Concatenation creates copies - consider append for iterative building",
            'copy': "Deep copies double memory usage - is this necessary?",
            'tolist': "Converting to list loses efficient array storage",
            'apply': "Apply with complex functions prevents vectorization"
        }
        
    def analyze_memory_patterns(self, line: str) -> List[str]:
        questions = []
        
        for operation, concern in self.memory_intensive_operations.items():
            if operation in line:
                questions.append(concern)
                questions.append(f"Have you profiled memory usage for this {operation}?")
                
        if 'global' in line:
            questions.append("Global variables persist in memory - is this intentional?")
            
        if re.search(r'\.iloc\[.*:.*\]', line) or re.search(r'\.loc\[.*:.*\]', line):
            questions.append("Are you creating views or copies? This affects memory usage.")
            
        if 'lambda' in line and ('apply' in line or 'map' in line):
            questions.append("Lambda functions in apply/map prevent efficient vectorization.")
            
        return questions


class ConcurrencyAnalyzer:
    """Examines parallel and concurrent code for safety and efficiency."""
    
    def __init__(self):
        self.concurrent_patterns = {
            'Thread': "Thread safety",
            'Process': "Process communication overhead",
            'Lock': "Deadlock potential",
            'Queue': "Queue size bounds",
            'Pool': "Pool size optimization",
            'async': "Async coordination",
            'await': "Blocking behavior",
            'Future': "Future exception handling"
        }
        
    def analyze_concurrency(self, line: str) -> List[str]:
        questions = []
        
        for pattern, concern in self.concurrent_patterns.items():
            if pattern in line:
                questions.extend([
                    f"Have you considered {concern} for this {pattern}?",
                    "What happens if this concurrent operation fails?",
                    "Is shared state properly synchronized?",
                    "Have you tested this under high concurrency?"
                ])
                
        if 'GIL' not in line and 'threading' in line.lower():
            questions.append("Are you aware of Python's GIL limitations for CPU-bound threading?")
            
        if 'multiprocessing' in line:
            questions.extend([
                "What is the serialization overhead for data passed between processes?",
                "Have you considered the startup cost of new processes?"
            ])
            
        return questions


class NumericalStabilityAnalyzer:
    """Checks for numerical stability and precision issues."""
    
    def __init__(self):
        self.unstable_operations = {
            'exp': "Exponentials can overflow - consider log-space computation",
            'log': "Logarithm of zero or negative - add epsilon or check domain",
            'sqrt': "Square root of negative - validate input domain",
            'inv': "Matrix inversion is numerically unstable - consider pseudoinverse",
            'det': "Determinant near zero indicates singular matrix",
            '**': "Power operations can overflow or underflow rapidly",
            'softmax': "Softmax overflow - subtract max before exponentiating"
        }
        
    def analyze_numerical_stability(self, line: str) -> List[str]:
        questions = []
        
        for operation, concern in self.unstable_operations.items():
            if operation in line:
                questions.append(concern)
                
        if '==' in line and ('float' in line or '.' in line):
            questions.append("Floating point equality is dangerous - use np.isclose() or tolerance")
            
        if '1/' in line or '1.0/' in line:
            questions.append("Division by zero check needed - what happens at boundaries?")
            
        if 'gradient' in line.lower() or 'grad' in line:
            questions.extend([
                "Have you checked for vanishing or exploding gradients?",
                "Is gradient clipping implemented for stability?"
            ])
            
        return questions


class PackageAnalyzer:
    """Deep analysis of package usage and dependencies."""
    
    def __init__(self):
        self.package_concerns = {
            'pandas': {
                'concerns': [
                    "Are you using vectorized operations instead of iterrows?",
                    "Have you set appropriate dtypes to minimize memory usage?",
                    "Are categorical columns encoded as category dtype?"
                ],
                'performance': [
                    "Consider pyarrow backend for better performance",
                    "Use query() for complex filtering instead of chained operations"
                ]
            },
            'numpy': {
                'concerns': [
                    "Are arrays contiguous in memory for cache efficiency?",
                    "Have you considered using numba for loop acceleration?",
                    "Are you aware of numpy's automatic broadcasting rules?"
                ],
                'performance': [
                    "Use numpy's built-in functions instead of Python loops",
                    "Consider einsum for complex tensor operations"
                ]
            },
            'torch': {
                'concerns': [
                    "Is autograd enabled only when needed?",
                    "Are tensors on the correct device (CPU/GPU)?",
                    "Have you called model.eval() during inference?",
                    "Are gradients properly zeroed between iterations?"
                ],
                'performance': [
                    "Use torch.no_grad() context for inference",
                    "Consider mixed precision training with autocast",
                    "Profile with torch.profiler for bottlenecks"
                ]
            },
            'tensorflow': {
                'concerns': [
                    "Are you using tf.function for graph compilation?",
                    "Is eager execution mode appropriate for your use case?",
                    "Have you considered data pipeline optimization with tf.data?"
                ],
                'performance': [
                    "Use tf.data.Dataset for efficient data loading",
                    "Consider XLA compilation for performance"
                ]
            },
            'sklearn': {
                'concerns': [
                    "Have you scaled features before distance-based algorithms?",
                    "Is the random_state set for reproducibility?",
                    "Have you performed appropriate cross-validation?"
                ],
                'performance': [
                    "Use n_jobs=-1 for parallel processing where available",
                    "Consider incremental learning for large datasets"
                ]
            },
            'requests': {
                'concerns': [
                    "Are you handling timeout and retry logic?",
                    "Is SSL verification enabled for security?",
                    "Are you respecting rate limits?"
                ],
                'performance': [
                    "Use session objects for connection pooling",
                    "Consider async alternatives like aiohttp for concurrent requests"
                ]
            },
            'sqlalchemy': {
                'concerns': [
                    "Are database connections properly closed?",
                    "Have you parameterized queries to prevent SQL injection?",
                    "Is connection pooling configured appropriately?"
                ],
                'performance': [
                    "Use bulk operations for multiple inserts",
                    "Consider query optimization with EXPLAIN"
                ]
            },
            'multiprocessing': {
                'concerns': [
                    "Is shared memory properly synchronized?",
                    "Are you handling process cleanup correctly?",
                    "What is the serialization overhead?"
                ],
                'performance': [
                    "Use Pool for reusable worker processes",
                    "Consider joblib for simpler parallelization"
                ]
            },
            'asyncio': {
                'concerns': [
                    "Are all blocking operations properly async?",
                    "Is the event loop properly managed?",
                    "Are exceptions in async tasks handled?"
                ],
                'performance': [
                    "Use gather() for concurrent async operations",
                    "Consider uvloop for better performance"
                ]
            },
            'scipy': {
                'concerns': [
                    "Are optimization bounds and constraints properly set?",
                    "Have you chosen the appropriate solver for your problem?",
                    "Is the tolerance appropriate for your precision needs?"
                ],
                'performance': [
                    "Use sparse matrices where applicable",
                    "Consider compiled functions with numba for custom operations"
                ]
            }
        }
        
    def analyze_imports(self, line: str) -> List[str]:
        questions = []
        
        for package, details in self.package_concerns.items():
            if f'import {package}' in line or f'from {package}' in line:
                questions.extend(details['concerns'])
                questions.extend(details['performance'])
                
        if 'import *' in line:
            questions.extend([
                "Wildcard imports pollute namespace - are you tracking what's imported?",
                "This makes code dependencies unclear - consider explicit imports"
            ])
            
        return questions


class ASTAnalyzer(ast.NodeVisitor):
    """Advanced Abstract Syntax Tree analysis for deeper code inspection."""
    
    def __init__(self):
        self.complexity_score = 0
        self.max_nesting = 0
        self.current_nesting = 0
        self.function_lines = defaultdict(int)
        self.class_methods = defaultdict(list)
        self.global_vars = set()
        self.recursive_calls = []
        
    def visit_FunctionDef(self, node):
        self.function_lines[node.name] = len(node.body)
        self.generic_visit(node)
        
    def visit_ClassDef(self, node):
        for item in node.body:
            if isinstance(item, ast.FunctionDef):
                self.class_methods[node.name].append(item.name)
        self.generic_visit(node)
        
    def visit_For(self, node):
        self.current_nesting += 1
        self.max_nesting = max(self.max_nesting, self.current_nesting)
        self.complexity_score += 1
        self.generic_visit(node)
        self.current_nesting -= 1
        
    def visit_While(self, node):
        self.current_nesting += 1
        self.max_nesting = max(self.max_nesting, self.current_nesting)
        self.complexity_score += 2  # While loops are more complex
        self.generic_visit(node)
        self.current_nesting -= 1
        
    def visit_If(self, node):
        self.current_nesting += 1
        self.max_nesting = max(self.max_nesting, self.current_nesting)
        self.complexity_score += 1
        self.generic_visit(node)
        self.current_nesting -= 1
        
    def visit_Global(self, node):
        self.global_vars.update(node.names)
        self.generic_visit(node)


class SureniAnalyzer:
    """Main analyzer orchestrating all inspection components."""
    
    def __init__(self, verbose: bool = False, focus: Optional[str] = None):
        self.verbose = verbose
        self.focus = focus
        self.statistical = StatisticalAnalyzer()
        self.memory = MemoryProfiler()
        self.concurrency = ConcurrencyAnalyzer()
        self.numerical = NumericalStabilityAnalyzer()
        self.packages = PackageAnalyzer()
        
        self.universal_patterns = [
            CodePattern(
                r'except\s*:',
                'error_handling',
                [
                    "Bare except catches system exits - specify exception types",
                    "How are you logging or handling this exception?",
                    "Could this silently hide critical errors?"
                ]
            ),
            CodePattern(
                r'eval\(|exec\(',
                'security',
                [
                    "eval/exec are security vulnerabilities - is this absolutely necessary?",
                    "Have you sanitized all inputs to prevent code injection?",
                    "Consider ast.literal_eval for safe evaluation"
                ],
                severity='high'
            ),
            CodePattern(
                r'TODO|FIXME|XXX|HACK',
                'debt',
                [
                    "Technical debt marked - when will this be addressed?",
                    "Is this documented in your issue tracker?",
                    "What are the risks of leaving this unresolved?"
                ]
            ),
            CodePattern(
                r'sleep\(|time\.sleep',
                'performance',
                [
                    "Sleep blocks execution - consider async alternatives",
                    "Is this delay necessary or masking a race condition?",
                    "Have you tested behavior under different timing conditions?"
                ]
            ),
            CodePattern(
                r'print\(',
                'production',
                [
                    "Print statements in production code - use proper logging",
                    "Is this sensitive information that shouldn't be exposed?",
                    "Will this create performance issues at scale?"
                ]
            ),
            CodePattern(
                r'password|secret|key|token',
                'security',
                [
                    "Sensitive data detected - is this properly secured?",
                    "Are credentials in environment variables, not code?",
                    "Is this value encrypted at rest and in transit?"
                ],
                severity='high'
            )
        ]
        
    def analyze_line(self, line: str, lineno: int, context: List[str]) -> List[Tuple[str, str]]:
        """Analyze a single line with surrounding context."""
        
        questions_with_categories = []
        
        # Statistical analysis
        if not self.focus or self.focus == 'stats':
            stats_q = self.statistical.analyze_statistical_assumptions(line)
            questions_with_categories.extend([('statistics', q) for q in stats_q])
        
        # Memory analysis
        if not self.focus or self.focus == 'memory':
            memory_q = self.memory.analyze_memory_patterns(line)
            questions_with_categories.extend([('memory', q) for q in memory_q])
        
        # Concurrency analysis
        if not self.focus or self.focus == 'concurrency':
            concur_q = self.concurrency.analyze_concurrency(line)
            questions_with_categories.extend([('concurrency', q) for q in concur_q])
        
        # Numerical stability
        if not self.focus or self.focus == 'numerical':
            numer_q = self.numerical.analyze_numerical_stability(line)
            questions_with_categories.extend([('numerical', q) for q in numer_q])
        
        # Package-specific analysis
        package_q = self.packages.analyze_imports(line)
        questions_with_categories.extend([('packages', q) for q in package_q])
        
        # Universal patterns
        for pattern in self.universal_patterns:
            if pattern.pattern.search(line):
                questions_with_categories.extend([
                    (pattern.category, q) for q in pattern.questions
                ])
        
        # Context-aware analysis
        if re.search(r'def\s+\w+\(', line):
            # Function definition
            questions_with_categories.extend([
                ('design', "What are the preconditions and postconditions?"),
                ('design', "How does this handle edge cases and invalid inputs?"),
                ('testing', "What is the test coverage for this function?"),
                ('documentation', "Are the parameters and return values documented?")
            ])
            
        if re.search(r'class\s+\w+', line):
            # Class definition
            questions_with_categories.extend([
                ('design', "Does this follow SOLID principles?"),
                ('design', "What is the inheritance hierarchy and is it appropriate?"),
                ('testing', "Are there unit tests for each public method?"),
                ('documentation', "Is the class responsibility clearly documented?")
            ])
            
        if re.search(r'return\s+', line):
            # Return statement
            questions_with_categories.extend([
                ('design', "Are all code paths that should return covered?"),
                ('design', "Is the return type consistent and predictable?")
            ])
            
        if 'assert' in line:
            questions_with_categories.extend([
                ('testing', "Assertions are removed with -O flag - use explicit validation"),
                ('testing', "Is this assertion for debugging or actual validation?")
            ])
            
        # Data pipeline checks
        if any(x in line for x in ['pipeline', 'transform', 'fit_transform']):
            questions_with_categories.extend([
                ('data', "Is data leakage prevented between train and test?"),
                ('data', "Are transformations fit only on training data?"),
                ('data', "How are missing values handled in the pipeline?")
            ])
            
        # SQL and database patterns
        if re.search(r'SELECT|INSERT|UPDATE|DELETE|DROP', line, re.I):
            questions_with_categories.extend([
                ('database', "Is this query parameterized to prevent SQL injection?"),
                ('database', "What is the query execution plan and performance?"),
                ('database', "Are indexes being utilized effectively?"),
                ('database', "Is there proper transaction management?")
            ])
            
        # File operations
        if any(x in line for x in ['open(', 'read(', 'write(', 'with open']):
            questions_with_categories.extend([
                ('io', "Are file handles properly closed even on exception?"),
                ('io', "What is the behavior with large files?"),
                ('io', "Is the encoding explicitly specified?"),
                ('io', "Are you validating file existence and permissions?")
            ])
            
        # Network operations
        if any(x in line for x in ['requests.', 'urllib', 'http.client', 'socket']):
            questions_with_categories.extend([
                ('network', "Are network timeouts and retries configured?"),
                ('network', "How are network failures handled?"),
                ('network', "Is the connection secured with TLS/SSL?"),
                ('network', "Are you respecting rate limits and backoff strategies?")
            ])
            
        return questions_with_categories
    
    def analyze_ast(self, tree: ast.AST) -> List[str]:
        """Perform AST-level analysis."""
        
        analyzer = ASTAnalyzer()
        analyzer.visit(tree)
        
        questions = []
        
        if analyzer.max_nesting > 3:
            questions.append(f"Nesting depth of {analyzer.max_nesting} is high - consider refactoring")
            
        if analyzer.complexity_score > 10:
            questions.append(f"Cyclomatic complexity score of {analyzer.complexity_score} indicates high complexity")
            
        for func, lines in analyzer.function_lines.items():
            if lines > 50:
                questions.append(f"Function '{func}' has {lines} lines - consider breaking it down")
                
        for cls, methods in analyzer.class_methods.items():
            if len(methods) > 20:
                questions.append(f"Class '{cls}' has {len(methods)} methods - violates single responsibility?")
                
        if analyzer.global_vars:
            questions.append(f"Global variables detected: {analyzer.global_vars} - consider encapsulation")
            
        return questions


def format_output(lineno: int, line: str, questions: List[Tuple[str, str]], verbose: bool = False):
    """Format the analysis output."""
    
    # Group questions by category
    by_category = defaultdict(list)
    for category, question in questions:
        by_category[category].append(question)
    
    if not by_category:
        return
    
    print(f"Line {lineno:4d}: {line.strip()[:80]}{'...' if len(line.strip()) > 80 else ''}")
    
    for category, category_questions in by_category.items():
        if verbose:
            print(f"  [{category.upper()}]")
        for question in category_questions:
            prefix = "    " if verbose else "  "
            print(f"{prefix}? {question}")
    print()


def main():
    parser = argparse.ArgumentParser(description='Sureni - Reflective Code Analysis')
    parser.add_argument('file', help='Python file to analyze')
    parser.add_argument('--verbose', '-v', action='store_true', help='Show detailed analysis')
    parser.add_argument('--focus', choices=['stats', 'memory', 'concurrency', 'numerical'],
                       help='Focus analysis on specific area')
    
    args = parser.parse_args()
    
    if not os.path.exists(args.file):
        print(f"Error: File '{args.file}' not found")
        sys.exit(1)
    
    try:
        with open(args.file, 'r', encoding='utf-8') as f:
            content = f.read()
            lines = content.splitlines()
    except Exception as e:
        print(f"Error reading file: {e}")
        sys.exit(1)
    
    print(f"Analyzing {args.file}")
    print(f"{'Focused on ' + args.focus if args.focus else 'Comprehensive analysis'}")
    print("-" * 60)
    print()
    
    analyzer = SureniAnalyzer(verbose=args.verbose, focus=args.focus)
    
    # Line-by-line analysis
    for i, line in enumerate(lines, 1):
        # Get context (surrounding lines)
        context = lines[max(0, i-3):min(len(lines), i+2)]
        questions = analyzer.analyze_line(line, i, context)
        if questions:
            format_output(i, line, questions, args.verbose)
    
    # AST-level analysis
    if args.verbose:
        try:
            tree = ast.parse(content)
            ast_questions = analyzer.analyze_ast(tree)
            if ast_questions:
                print("STRUCTURAL ANALYSIS")
                print("-" * 60)
                for question in ast_questions:
                    print(f"  ? {question}")
                print()
        except SyntaxError as e:
            print(f"Syntax error prevents AST analysis: {e}")
    
    print("-" * 60)
    print("Analysis complete. Consider each question as an opportunity for improvement.")
    print("The best code is not just functional, but maintainable, scalable, and ethical.")


if __name__ == "__main__":
    main()
