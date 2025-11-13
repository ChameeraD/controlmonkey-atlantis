# Atlantis Terraform Sample with GitHub CI Plan on PRs

This repository contains:
- A minimal Terraform configuration (`terraform/`) using the `random` provider.
- An `atlantis.yaml` to support Atlantis-based workflows.
- A GitHub Actions workflow that runs `terraform plan` on pull requests and comments the plan on the PR.

## Structure

```
.
├── .github/workflows/terraform-plan.yml   # PR plan workflow
├── atlantis.yaml                          # Atlantis repo-level config
├── terraform/
│   ├── main.tf                            # sample resources
│   └── providers.tf                       # random provider
└── .gitignore
```

## How it works

- On every pull request that changes files under `terraform/`, the workflow:
  - Checks out the repo
  - Installs Terraform
  - Runs `terraform init -backend=false`, `terraform validate`, and `terraform plan`
  - Posts the plan output as a sticky PR comment
  - Fails the job if `plan` fails

The sample uses the `random` provider so the plan can run without cloud credentials.

## Using Atlantis

- `atlantis.yaml` defines a single project at `terraform/` with `autoplan` enabled.
- To use Atlantis, deploy an Atlantis server (e.g. container/Helm) and connect it to your GitHub repository via webhooks or the GitHub App.
- Once Atlantis is set up, PRs will trigger `atlantis plan` automatically and you can run `atlantis apply` via PR comments.

## Local development

```bash
cd terraform
terraform init -backend=false
terraform validate
terraform plan
```

> Note: The GitHub workflow uses `-backend=false` to avoid creating local state in CI.


