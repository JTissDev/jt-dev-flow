# jtflow CLI

`jtflow` is a lightweight, developer-centric CLI tool designed to automate project release management, semantic versioning, automated testing, and Git Flow branch synchronization.

---

## Features

- **Automated Quality Gate:** Detects project structure (e.g., Java/Maven) and executes full test suites before allowing a release.
- **Documentation Synchronization:** Scans and cleans TODO/FIXME tags across your project and automatically populates CHANGELOG.md using Git commit history.
- **Semantic Versioning:** Interactively prompts for release versions and updates configuration files (pom.xml).
- **Strict Git Flow Strategy:**
  - Performs non-fast-forward (--no-ff) merges from dev into master to preserve visual branch topology.
  - Generates immutable release tags (vX.Y.Z).
  - Automatically resets the dev branch to the next development iteration (-SNAPSHOT).

---

## Prerequisites

- **OS:** Windows (Git Bash environment recommended)
- **Dependencies:** Git, Java JDK, and Apache Maven (for Maven-based projects)

---

## Installation

1. Clone or place jtflow into your local tools directory (e.g., C:/Users/jtiss/dev-tools/jt-dev-flow).
2. Add the executable path to your Git Bash environment (~/.bashrc or ~/.bash_profile):
   export PATH="$PATH:/c/Users/jtiss/dev-tools/jt-dev-flow"
3. Reload your terminal configuration: source ~/.bashrc

*---

## Usage

Navigate to any Git project working directory on the dev branch and execute:
jtflow release

---

## Authh® & Support

- **Author:** J.Tiss
- **Email:** jtissdev@gmail.com