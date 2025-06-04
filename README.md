
# DevOps Take-Home Project

A containerized Rust web service with automated CI/CD using Docker, GitHub Actions, and infrastructure managed via Terraform on AWS.

---

## Features
- REST API built with Actix Web (Rust)
- Containerized with Docker
- CI/CD pipeline with GitHub Actions
- Infrastructure provisioned via Terraform (AWS EC2, ALB, ASG)
- Integration and unit test coverage
- Code quality checks via pre-commit hooks and linters


## Table of Contents

1. [Local Development](#local-development)
2. [Testing Approach](#testing-approach)
3. [Code Review Practices](#code-review-practices)
4. [CI/CD Pipeline](#cicd-pipeline)
5. [Scalability Strategy](#scalability-strategy)
6. [Project Structure](#project-structure)
7. [Secrets & Configuration](#secrets--configuration)
8. [Contact](#contact)

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

2. Build and start the service locally with Docker Compose:
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

1. **Unit Tests**

  - Core business logic resides in src/lib.rs (or equivalent modules).

  - Execute locally with:

```sh
cargo test
```

2. **Integration Tests**

  - Located in the tests/ directory (e.g., tests/test_basic.rs).

  - These spin up a test server (using actix_web::test), send HTTP requests, and validate end-to-end behavior.

  - Example snippet from tests/test_basic.rs:

```rust
use actix_web::{test, App};

#[actix_web::test]
async fn test_index_ok() {
    // Import the handler from lib.rs
    use devops_takehome::index;

    let app = test::init_service(App::new().service(index)).await;
    let req = test::TestRequest::get().uri("/").to_request();
    let resp = test::call_service(&app, req).await;

    // Expect HTTP 200 and correct body
    assert!(resp.status().is_success());
    let body = test::read_body(resp).await;
    assert_eq!(body, "Hello, DevOps candidate!");
}
```
3. **Automated CI**

  - GitHub Actions runs all tests on every push or pull request to main, ensuring no regressions are merged.

---

## Code Review Practices

### 1. Git Workflow (Branching & PR Structure)
1. **Branch Naming**
   - Use slash-based, descriptive names, optionally prefixed by an issue/ticket:
     ```
     feature/ABC-123-add-structured-logging
     bugfix/XYZ-456-fix-docker-compose-permissions
     chore/update-dependencies
     ```
   - Keep branch topology aligned with GitFlow or trunk-based patterns (your choice), but always isolate feature work to its own branch.

2. **Commit Messages**
   - Follow [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/):
     ```
     feat: add structured logging to main service
     fix: handle API error when upstream is unavailable
     docs: update README with deployment instructions
     chore: upgrade actix-web to v4.11.0
     ```
   - Use present tense, concise summaries, and reference issue IDs if applicable.

3. **PR Template & Checklist**
   - Include a one-paragraph description of “what changed” and “why.”
   - Reference related issues or RFCs.
   - Provide clear steps to reproduce or verify.
   - Include a checklist, e.g.:
     - [ ] Tests cover new or modified functionality.
     - [ ] Code formatted (`cargo fmt` / `eslint`).
     - [ ] No secrets or credentials are hardcoded.
     - [ ] IAM/Terraform changes reviewed for least privilege.
   - PRs should target `main` (or a long-lived integration branch) and be rebased/squashed to maintain a clean history.

4. **Review SLAs & Approvals**
   - At least **two reviewers** must approve major feature PRs (one across the team and one from a tech lead).
   - All PRs should receive initial feedback within **48 hours**; final merge within **72 hours**.

---

### 2. Review Priorities
When reviewing a PR, focus on:

1. **Security & Safety**
   - **Secrets/credentials**: Ensure no hardcoded tokens or passwords.
   - **Input validation & sanitization**: Avoid injection vulnerabilities (SQL, shell, path traversal).
   - **Least privilege**: Check IAM roles, security group rules, and Terraform policies.
   ** The PipeLine should be configured to fail if any of these checks are not met.**
   - **Dependency vulnerabilities**: Confirm that `cargo audit` or `trivy` checks have passed.

2. **Readability & Maintainability**
   - **Naming**: Variables, functions, and modules should have clear, intention-revealing names.
   - **Formatting**: Must pass `cargo fmt -- --check`.
   - **Documentation**: Public functions and critical modules should have Rust doc comments (`///`).
   - **Module structure**: Each module should follow single-responsibility; business logic should be in `lib.rs`, not buried in `main.rs`.

3. **Efficiency & Performance**
** This is a lot to check for in a PR, so focus on the most critical paths first.**
   - **Hot paths**: Examine asynchronous vs. blocking calls (e.g., use `actix_web::web::block` if necessary).
   - **Memory allocations**: Avoid unnecessary clones or large buffers; use zero-copy where possible.
   - **Algorithmic complexity**: Refuse O(n²) in loops if data can grow; suggest using iterators or more efficient data structures.

4. **Correctness & Robustness**
   - **Error handling**: No unwrapped `Result`/`Option` in production code—propagate or map errors gracefully.
   - **Edge cases**: Validate all inputs (out-of-range, empty, null).
   - **Graceful shutdown**: Ensure the Actix-Web server handles `SIGINT`/`SIGTERM` without dropping connections mid-request.

5. **Testing & Coverage**
   - **Unit tests**: Cover core business functions (especially any parsing, transformations, or critical computations).
   - **Integration tests**: Validate HTTP handlers end-to-end (using `actix_web::test`); ensure that any external resource calls are mocked.
   - **Fuzz / Property tests** (optional): For parsing or serialization code, consider `proptest` or `quickcheck`.
   - **Test automation**: Ensure `cargo test --all --locked` passes in CI, and `cargo clippy -- -D warnings` yields zero errors.

---

### 3. Automated Code Review Tools
Automate as many checks as possible so that reviewers focus on higher-level concerns:

1. **Pre-commit Hooks**
   - Use [pre-commit](https://pre-commit.com/) with these hooks:
     ```yaml
     repos:
       - repo: https://github.com/rust-lang/rustfmt
         rev: stable
         hooks:
           - id: rustfmt
       - repo: https://github.com/rust-lang/rust-clippy
         rev: stable
         hooks:
           - id: clippy
       - repo: https://github.com/pre-commit/mirrors-eslint
         rev: v7.32.0
         hooks:
           - id: eslint
       - repo: https://github.com/pre-commit/mirrors-prettier
         rev: stable
         hooks:
           - id: prettier
     ```
   - This enforces formatting (Rust/JS) and linting before any commit is created, preventing style/drift issues.

2. **GitHub Actions**
   - A dedicated CI workflow runs on every PR & merge to `main`, performing:
     1. `cargo fmt -- --check`
     2. `cargo clippy -- -D warnings`
     3. `cargo test --all --locked`
     4. `cargo audit` (dependency vulnerability scan)
     5. `docker build --target tester` (verify that the Dockerfile’s “test” stage exits 0)
   - Failure at any step blocks merging.

3. **Dependabot (or Renovate)**
   - A `.github/dependabot.yml` config ensures that any out-of-date Rust crates (or Docker base images) automatically generate PRs.
   - Each dependency bump triggers the same CI workflow (`tests`, `clippy`, `audit`) so we know immediately if a crate upgrade breaks anything.

4. **Container Scanning (Trivy)**
   - Add a GitHub Action step:
     ```yaml
     - name: Scan Docker image with Trivy
       uses: aquasecurity/trivy-action@v0.8.0
       with:
         image-ref: ${{ secrets.DOCKER_HUB_USERNAME }}/devops-takehome:latest
     ```
   - Alerts on any OS or Rust dependency vulnerabilities before publishing.

---


---

## CI/CD Pipeline

### Pipeline Flow
- **Build:** Compiles and tests the Rust application.
- **Docker:** Builds image, pushes to Docker Hub.
- **Terraform:** Provisions AWS EC2 and deploys the Docker container.

### How to Run
- All steps run automatically on PR or push to `main`.

**Current Production**
For this assessment, the Terraform configuration is included directly in this repo for convenience.


**Production Proposal:**
For production, Terraform would live in a reusable, versioned repo managed by DevOps. The CI/CD pipeline would call this repo as a module, enforcing resource standards and consistency across environments.

---

## Scalability Strategy

- **Dockerized** for fast, repeatable deployments.
- **Terraform-managed infrastructure** supports both horizontal and vertical scaling:
  - **Horizontal scaling** via an Auto Scaling Group:
    ```
    resource "aws_autoscaling_group" "app_asg" {
      name                      = "devops-asg"
      max_size                  = 3
      min_size                  = 1
      desired_capacity          = 1
      vpc_zone_identifier       = data.aws_subnets.default.ids
      target_group_arns         = [aws_lb_target_group.app_tg.arn]
      health_check_type         = "ELB"
      health_check_grace_period = 60

      launch_template {
        id      = aws_launch_template.app_lt.id
        version = "$Latest"
      }

      tag {
        key                 = "Name"
        value               = "devops-app-instance"
        propagate_at_launch = true
      }
    }
    ```
    - When CPU (or custom CloudWatch) alarms fire, the ASG can scale out by increasing `desired_capacity` up to `max_size`.

  - **Vertical scaling** by updating the `instance_type` in the `aws_launch_template` (e.g., moving from `t2.micro` to `t3.medium`).

  - **Load balancing** using an Application Load Balancer (ALB):
      ```
    resource "aws_lb" "app_alb" {
    name               = "devops-alb"
    load_balancer_type = "application"
    subnets            = data.aws_subnets.default.ids
    security_groups    = [aws_security_group.devops_sg.id]
    }

    resource "aws_lb_target_group" "app_tg" {
      name     = "devops-tg"
      port     = 8080
      protocol = "HTTP"
      vpc_id   = data.aws_vpc.default.id

      health_check {
        path                = "/"
        interval            = 30
        healthy_threshold   = 3
        unhealthy_threshold = 2
        matcher             = "200-399"
      }
    }
    resource "aws_lb_listener" "http" {
      load_balancer_arn = aws_lb.app_alb.arn
      port              = 80
      protocol          = "HTTP"
      default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.app_tg.arn
      }
    }

- **Health checks and monitoring**:
  - The ALB’s health check polls `/` every 30 seconds; unhealthy instances (HTTP status ≠ 2xx/3xx) are replaced automatically by the ASG.
  - CloudWatch Alarms track metrics (CPUUtilization, RequestCount, 5xx rate). Example:
    ```hcl
    resource "aws_cloudwatch_metric_alarm" "high_cpu" {
      alarm_name          = "HighCPUAlarm"
      comparison_operator = "GreaterThanThreshold"
      evaluation_periods  = 2
      metric_name         = "CPUUtilization"
      namespace           = "AWS/EC2"
      period              = 60
      statistic           = "Average"
      threshold           = 75
      alarm_actions       = [aws_sns_topic.alerts.arn]
      dimensions = { InstanceId = aws_instance.app.id }
    }
    ```
    - When CPU > 75% for 2 consecutive minutes, it can trigger an SNS notification or a Lambda that increases ASG capacity.

- **CI/CD driven scaling**:
  - Terraform is organized into reusable modules under terraform/modules/ (e.g., alb/, asg/, launch_template/).

  - This separation allows teams to extend functionality (e.g., integrate Redis or RDS modules) without modifying the application’s module.

  - Terraform state is managed remotely (S3 backend + DynamoDB lock) to prevent drift in a team environment.

- **Modular infrastructure**:
  - Application and infra code are separated (e.g., `/terraform/modules/asg` and `/terraform/modules/alb`), so you can independently update scaling policies or add new components (e.g., a caching layer or a secondary region).

With this setup, you have:
1. **Horizontal scaling**: Auto Scaling Group with ALB health checks automatically adjusts the instance fleet under load.
2. **Vertical scaling**: Change instance_type in the launch template and reapply Terraform to upgrade instance specifications.
3. **Load Balancing & Fault Tolerance**: ALB distributes traffic only to healthy instances, and the ASG automatically rejoins or replaces failing nodes.
4. **Automated changes**: All scaling rules live in Terraform, so any change to scaling thresholds or instance sizes goes through your GitHub Actions pipeline for review and consistency.
5. **Monitoring & Alerts**: ALB health checks and CloudWatch Alarms ensure rapid detection and remediation of infrastructure issues.
6. **CI/CD Integration**: All changes to scaling rules or instance specs flow through a code-reviewed CI pipeline, guaranteeing consistency and auditability.

---

## Project Structure

```
.
├── .github/
│   └── workflows/
│       └── continuous-integration.yml   # GitHub Actions CI/CD pipeline
├── src/
│   ├── lib.rs                           # Library entry point (business logic & handlers)
│   └── main.rs                          # Actix-Web server bootstrap
├── tests/
│   └── test_basic.rs                    # Integration tests (HTTP endpoints)
├── terraform/
│   └── main.tf                          # Terraform IaC for AWS (EC2, ALB, ASG, Security Groups)
├── Dockerfile                           # Multi-stage build for Rust + Docker image
├── docker-compose.yml                   # Local development compose file
├── Cargo.toml                           # Rust project manifest
├── README.md                            # This file
└── ...
```

---

## Secrets & Configuration

**Set these repository secrets in GitHub:**
- `DOCKER_HUB_USERNAME`
- `DOCKER_HUB_ACCESS_TOKEN`
- `AWS_ACCESS_KEY_ID` - **Required GitHub repository secrets:read,write, delete**
- `AWS_SECRET_ACCESS_KEY` - **Required GitHub repository secrets:read,write, delete**
- `TF_API_TOKEN` (optional, for Terraform Cloud)

---

---

## Last-Minute Reflections

- During the course of this take-home, I discovered AWS Fargate as a serverless compute option for running containers. In a longer timeframe, I would have refactored the Terraform code to deploy the Docker image to an ECS Fargate cluster instead of EC2 instances. Fargate eliminates the need to manage EC2 host capacity and would further simplify horizontal scaling and patching.

- I also learned more about modular, reusable Terraform repositories (aka “Terraform modules”). If there were additional time, I would have extracted the ASG/ALB/security-group logic into standalone, versioned modules stored in a separate GitHub repo. This pattern would allow any downstream team to import the same “app-autoscaling” and “app-load-balancer” modules with a single `source` URL, ensuring consistent network/security settings and scaling policies across environments (dev, staging, prod).

- In a production scenario, I would:
  1. Break out Terraform into two repos (one for “networking+infra” modules, one for “application” composition).
  2. Push the “networking+infra” modules to a versioned module registry (e.g., Terraform Cloud Registry, private S3 bucket).
  3. Reference those modules in the application repo’s root module (`main.tf`), passing in variables like `docker_image`, `min_size`, `max_size`, and `instance_type`.
  4. Consider migrating to Fargate to offload host maintenance and use capacity providers for even more granular scaling.

- Overall, this exercise reinforced the value of:
  - Building back-end code (Rust/Actix) that can be tested and containerized in a single pipeline.
  - Defining Terraform modules early so that infrastructure changes can be peer-reviewed and versioned independently of application logic.
  - Exploring serverless/container-orchestration options like Fargate when time permits, to reduce operational overhead.

If given more time, I would have implemented both of those enhancements—migrating to AWS Fargate and splitting Terraform into reusable modules—so that future feature releases, scaling tweaks, or security updates could be made with minimal cross-team coordination and maximum consistency.  

---

## Contact

For issues, open a GitHub issue. For feature suggestions or improvements, submit a PR.

---
