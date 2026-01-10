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
import sys

username = input("GitHub username: ").strip()
dest = input("Destination directory [.]: ").strip() or "."
os.makedirs(dest, exist_ok=True)
print(f"\nFetching repos for {username}...")

all_repos = []
page = 1
while True:
    r = requests.get(
        f"https://api.github.com/users/{username}/repos",
        params={"per_page": 100, "page": page},
        headers={
            "Accept": "application/vnd.github+json",
            "User-Agent": "get_repos.sh"
        },
        timeout=30,
    )
    
    if r.status_code != 200:
        print("Failed to get repos")
        print(f"HTTP status {r.status_code}")
        sys.exit(1)
    
    repos = r.json()
    
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

