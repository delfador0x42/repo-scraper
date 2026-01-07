#!/bin/bash
"true" '''\'
set -e
cd "$(dirname "$0")"
if [[ -d .venv ]]; then
    echo "Virtual environment found"
else
    echo "Creating virtual environment..."
    python3 -m venv .venv
fi
echo "Activating virtual environment..."
source .venv/bin/activate
echo "Installing dependencies..."
pip install requests
echo "Starting clone script..."
echo ""
exec .venv/bin/python3 "$0"
'''
import os
import subprocess
import requests
import time

username = input("GitHub username: ").strip()
dest = input("Destination directory [.]: ").strip() or "."
os.makedirs(dest, exist_ok=True)
print(f"\nFetching repos for {username}...")

all_repos = []
page = 1
while True:
    repos = requests.get(f"https://api.github.com/users/{username}/repos", params={"per_page": 100, "page": page}).json()
    if not repos:
        break
    all_repos.extend(repos)
    page += 1

total = len(all_repos)
print(f"Found {total} repositories\n")

cloned = 0
for i, repo in enumerate(all_repos, 1):
    name = repo["name"]
    print(f"[{i}/{total}] CLONE {name}")
    subprocess.run(["git", "clone", repo["clone_url"]], cwd=dest)
    cloned += 1
    time.sleep(1)

print(f"\nDone. Cloned: {cloned}")
