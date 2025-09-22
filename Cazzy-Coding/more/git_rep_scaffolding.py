import os

# Function to create directories and files
def create_file(path, content=""):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8") as f:
        f.write(content)

# Prompt user for project type
print("Welcome to Repo Builder!")
project_type = input("Enter your project type (e.g., Python, C++, R, AI, Jupyter, Cassandra, Fortran): ").strip()

# Base folder
repo_name = input("Enter your repository name: ").strip()
base_path = os.path.join(os.getcwd(), repo_name)

# Common folders for any repo
folders = {
    "src": [],
    "docs": ["README.md", "INSTALL.md", "USAGE.md", "CONTRIBUTING.md", "CHANGELOG.md", "FAQ.md"],
    "tests": [],
    "data": [],
    "notebooks": [],
    "scripts": [],
    "configs": [],
    "examples": [],
}

# Language-specific folders and files
lang_specific = {
    "Python": ["src/__init__.py", "src/main.py", "tests/test_main.py"],
    "C++": ["src/main.cpp", "src/utils.cpp", "src/utils.h", "tests/test_main.cpp"],
    "R": ["src/main.R", "src/functions.R", "tests/test_main.R"],
    "Jupyter": ["notebooks/example_notebook.ipynb"],
    "Fortran": ["src/main.f90", "src/module1.f90", "tests/test_main.f90"],
    "Cassandra": ["src/schema.cql", "src/queries.cql"],
    "AI": ["src/model.py", "src/train.py", "src/predict.py", "notebooks/data_exploration.ipynb"],
}

# Merge language-specific into folders
for lang, files in lang_specific.items():
    if lang.lower() in project_type.lower():
        folders["src"].extend([f for f in files if "/" in f])  # Add nested files in src
        for f in files:
            if f.startswith("notebooks"):
                folders["notebooks"].append(f.replace("notebooks/", ""))

# Create folders and files
for folder, files in folders.items():
    folder_path = os.path.join(base_path, folder)
    os.makedirs(folder_path, exist_ok=True)
    for file in files:
        file_path = os.path.join(folder_path, file)
        # Add default content for docs files
        if file.endswith(".md"):
            content = f"# {file.replace('.md','')}\n\nProject: {repo_name}\nType: {project_type}\n"
        else:
            content = ""
        create_file(file_path, content)

print(f"\n✅ Repository '{repo_name}' created successfully at {base_path}!")
print("Structure:")
for root, dirs, files in os.walk(base_path):
    level = root.replace(base_path, "").count(os.sep)
    indent = " " * 4 * level
    print(f"{indent}{os.path.basename(root)}/")
    subindent = " " * 4 * (level + 1)
    for f in files:
        print(f"{subindent}{f}")