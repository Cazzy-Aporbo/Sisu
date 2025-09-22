import os

# ==============================
# Helper functions
# ==============================
def create_file(path, content=""):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8") as f:
        f.write(content)

def markdown_template(file_name, project_name, project_type):
    content = f"# {file_name.replace('.md','')}\n\n"
    content += f"Project: {project_name}\n"
    content += f"Type: {project_type}\n\n"
    content += "## Description\nProvide a detailed description here.\n\n"
    content += "## Usage\nProvide usage instructions here.\n\n"
    content += "## Notes\nAny additional notes or instructions.\n"
    return content

def skeleton_code(file_path, project_type):
    ext = os.path.splitext(file_path)[1]
    content = ""
    if ext in [".py"]:
        content = "# Python skeleton\n\ndef main():\n    pass\n\nif __name__ == '__main__':\n    main()\n"
    elif ext in [".cpp", ".cc", ".cxx"]:
        content = "// C++ skeleton\n#include <iostream>\n\nint main() {\n    std::cout << \"Hello World\" << std::endl;\n    return 0;\n}\n"
    elif ext in [".R", ".r"]:
        content = "# R skeleton\nprint('Hello World')\n"
    elif ext in [".f90", ".f95"]:
        content = "! Fortran skeleton\nprogram main\n    print *, 'Hello World'\nend program main\n"
    elif ext in [".ipynb"]:
        content = '{ "cells": [], "metadata": {}, "nbformat": 4, "nbformat_minor": 2 }'
    elif ext in [".cql"]:
        content = "-- Cassandra skeleton\n-- Define schema and queries here\n"
    return content

# ==============================
# User Input
# ==============================
print("Welcome to Ultimate Repo Builder!")
project_type = input("Enter project type (Python, C++, R, Fortran, Jupyter, Cassandra, AI, etc.): ").strip()
repo_name = input("Enter repository name: ").strip()
include_ai = input("Include AI/data structure folders? (y/n): ").strip().lower() == 'y'

base_path = os.path.join(os.getcwd(), repo_name)

# ==============================
# Base folders
# ==============================
folders = {
    "src": [],
    "docs": ["README.md", "INSTALL.md", "USAGE.md", "CONTRIBUTING.md", "CHANGELOG.md", "FAQ.md"],
    "tests": [],
    "data/raw": [],
    "data/processed": [],
    "notebooks": [],
    "scripts": [],
    "configs": [],
    "models": [],
    "examples": [],
    "results": [],
}

# ==============================
# Language-specific skeletons
# ==============================
lang_files = {
    "Python": ["src/main.py", "tests/test_main.py", "scripts/utils.py"],
    "C++": ["src/main.cpp", "src/utils.cpp", "src/utils.h", "tests/test_main.cpp"],
    "R": ["src/main.R", "src/functions.R", "tests/test_main.R"],
    "Fortran": ["src/main.f90", "src/module1.f90", "tests/test_main.f90"],
    "Jupyter": ["notebooks/example_notebook.ipynb"],
    "Cassandra": ["src/schema.cql", "src/queries.cql"],
    "AI": ["src/model.py", "src/train.py", "src/predict.py", "notebooks/data_exploration.ipynb"],
}

# Add language files
for lang, files in lang_files.items():
    if lang.lower() in project_type.lower() or (lang=="AI" and include_ai):
        for f in files:
            folder, file_name = os.path.split(f)
            if folder:  # Create folder
                if folder not in folders:
                    folders[folder] = []
            folders.setdefault(folder, []).append(file_name)

# ==============================
# Create folders and files
# ==============================
for folder, files in folders.items():
    folder_path = os.path.join(base_path, folder)
    os.makedirs(folder_path, exist_ok=True)
    for file in files:
        file_path = os.path.join(folder_path, file)
        if file.endswith(".md"):
            content = markdown_template(file, repo_name, project_type)
        else:
            content = skeleton_code(file_path, project_type)
        create_file(file_path, content)

# ==============================
# Print final repo structure
# ==============================
print(f"\n✅ Repository '{repo_name}' created successfully at {base_path}!\n")
print("Structure:")
for root, dirs, files in os.walk(base_path):
    level = root.replace(base_path, "").count(os.sep)
    indent = " " * 4 * level
    print(f"{indent}{os.path.basename(root)}/")
    subindent = " " * 4 * (level + 1)
    for f in files:
        print(f"{subindent}{f}")