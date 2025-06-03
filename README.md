
# DevOps Take-Home Project

A containerized Rust web service, with automated CI/CD using Docker, GitHub Actions, and infrastructure managed via Terraform on AWS.

---

## Table of Contents

- [Local Development](#local-development)
- [Testing Approach](#testing-approach)
- [Code Review Practices](#code-review-practices)
- [CI/CD Pipeline](#cicd-pipeline)
- [Scalability Strategy](#scalability-strategy)
- [Project Structure](#project-structure)
- [Secrets & Configuration](#secrets--configuration)
- [Contact](#contact)

---

## Local Development

**Requirements:**
- [Docker Desktop](https://www.docker.com/products/docker-desktop)
- [Rust toolchain](https://rustup.rs/) (for local development or running tests)

**Steps:**

1. Clone the repository:
   ```sh
   git clone https://github.com/<your-username>/devops-takehome.git
   cd devops-takehome
   ```

2. Build and run the app with Docker Compose:
   ```sh
   docker compose up --build
   ```
   - The service will be available at [http://localhost:8080](http://localhost:8080)

3. To stop and remove containers:
   ```sh
   docker compose down
   ```

---

## Testing Approach

- **Unit Tests:** Written in Rust, cover core business logic.  
  Run locally with:
  ```sh
  cargo test
  ```
- **Integration Tests:** Placed in the `tests/` directory.  
  Test end-to-end flows and API endpoints.
- **Automated CI:** All tests run on every push/PR via GitHub Actions.

---

## Code Review Practices

### Git Workflow
- Create a branch for your change (e.g., `feature/add-logging`).
- Commit with [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/):
  ```
  feat: add login endpoint
  fix: handle API error on auth
  docs: update README for setup
  ```
- Push and open a PR with a clear description.

### Code Review Priorities
- **Security:** No secrets in code; input validation; least privilege.
- **Readability:** Clear, maintainable code; meaningful naming.
- **Efficiency:** Avoid redundant computation; optimize for scale.
- **Correctness:** Passes all tests; robust error handling.
- **Testing:** Adequate unit and integration coverage.

### Automated Tools
- **Pre-commit Hooks:** Lint and format (`rustfmt`, `ESLint`, `Prettier`) before PRs.
- **GitHub Actions:** CI runs all tests and linters.
- **Dependabot:** Updates and monitors dependencies.

---

## CI/CD Pipeline

### Pipeline Flow
- **Build:** Compiles and tests the Rust application.
- **Docker:** Builds image, pushes to Docker Hub.
- **Terraform:** Provisions AWS EC2 and deploys the Docker container.

### How to Run
- All steps run automatically on PR or push to `main`.
- For this assessment, the Terraform configuration is included directly in this repo for convenience.


**Production Proposal:**  
For production, Terraform would live in a reusable, versioned repo managed by DevOps. The CI/CD pipeline would call this repo as a module, enforcing resource standards and consistency across environments.

---

## Scalability Strategy

- **Dockerized** for fast, repeatable deployments.
- **Terraform** manages cloud infra for easy scaling (instance size, load balancers, etc.).
- **CI/CD** for automated, consistent builds and deploys.
- **Modular Infra:** App and infrastructure code can be updated independently.

---

## Project Structure

```
.
├── .github/workflows/        # GitHub Actions workflows
├── src/                     # Rust source files
├── tests/                   # Integration tests
├── terraform/               # Infrastructure as Code (main.tf)
├── Dockerfile
├── docker-compose.yml
├── README.md
└── ...
```

---

## Secrets & Configuration

**Set these repository secrets in GitHub:**
- `DOCKER_HUB_USERNAME`
- `DOCKER_HUB_ACCESS_TOKEN`
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `TF_API_TOKEN` (optional, for Terraform Cloud)

---

## Contact

For issues or suggestions, open an issue or submit a pull request.

---
