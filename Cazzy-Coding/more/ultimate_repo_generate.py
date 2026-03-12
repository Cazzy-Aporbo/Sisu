import os

# Helper functions
def create_file(path, content=""):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8") as f:
        f.write(content)

def get_custom_markdown(file_name, project_name, project_type):
    print(f"\n--- Customizing {file_name} ---")
    title = input(f"Title for {file_name} (default '{file_name.replace('.md','')}'): ") or file_name.replace('.md','')
    description = input("Add a paragraph description: ") or f"Project: {project_name} ({project_type})"
    
    badges = []
    while True:
        add_badge = input("Add a badge? (y/n): ").lower()
        if add_badge != 'y':
            break
        label = input("Badge label: ")
        message = input("Badge message: ")
        color = input("Badge color (e.g., blue, green, red): ")
        badge_md = f"![{label}](https://img.shields.io/badge/{label}-{message}-{color})"
        badges.append(badge_md)

    content = f"# {title}\n\n"
    if badges:
        content += " ".join(badges) + "\n\n"
    content += f"{description}\n\n"

    while True:
        add_section = input("Add a section? (y/n): ").lower()
        if add_section != 'y':
            break
        section_title = input("Section title: ")
        section_content = input("Section content (you can write multiple lines, end with 'END'): \n")
        lines = []
        while section_content.strip().upper() != "END":
            lines.append(section_content)
            section_content = input()
        content += f"## {section_title}\n" + "\n".join(lines) + "\n\n"

    return content

def skeleton_code(file_path):
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

# User Input
print("Welcome to the Ultimate Repository Generator!")
project_type = input("Enter project type(s) (Python, C++, R, Fortran, Jupyter, Cassandra, AI, etc.): ").strip()
repo_name = input("Enter repository name: ").strip()
include_ai = input("Include AI/data folders? (y/n): ").strip().lower() == 'y'

base_path = os.path.join(os.getcwd(), repo_name)

# Base folders
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

# Language-specific skeletons
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
            if folder:
                folders.setdefault(folder, [])
            folders[folder].append(file_name)

# Create folders and files
for folder, files in folders.items():
    folder_path = os.path.join(base_path, folder)
    os.makedirs(folder_path, exist_ok=True)
    for file in files:
        file_path = os.path.join(folder_path, file)
        if file.endswith(".md"):
            content = get_custom_markdown(file, repo_name, project_type)
        else:
            content = skeleton_code(file_path)
        create_file(file_path, content)

# Print repo tree
print(f"\n✅ Ultimate repository '{repo_name}' created successfully at {base_path}!\n")
print("Structure:")
for root, dirs, files in os.walk(base_path):
    level = root.replace(base_path, "").count(os.sep)
    indent = " " * 4 * level
    print(f"{indent}{os.path.basename(root)}/")
    subindent = " " * 4 * (level + 1)
    for f in files:
        print(f"{subindent}{f}")