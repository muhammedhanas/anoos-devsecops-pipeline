# Architecture Decision Records

## ADR-001: Self-managed k3s over EKS

**Status:** Accepted  
**Date:** 2026-10-28

### Context
The project requires a Kubernetes cluster on 3× EC2 instances. Options: EKS (managed control plane) or self-managed k3s.

### Decision
Use k3s self-managed on 3× EC2.

### Consequences
- **Pros:**
  - Full control over cluster internals — every component is visible and auditable
  - Lower cost: no $73/mo EKS control plane fee
  - Manual install aligns with the runbook philosophy — employers see every step
  - k3s is production-grade (CNCF-certified) and lightweight
- **Cons:**
  - No AWS-managed control plane HA — if node-1 dies, the API server is down
  - More operational burden: etcd backup, certificate rotation, upgrades are manual
  - Not suitable for production workloads without additional HA measures

### Rationale
This is a portfolio project demonstrating platform engineering skills. The manual bootstrap is the point — it proves understanding of Kubernetes internals, not just how to click "create cluster" in the AWS console.

---

## ADR-002: Nexus as image registry over ECR

**Status:** Accepted  
**Date:** 2026-10-28

### Context
The pipeline builds container images and needs a registry. Options: AWS ECR or Nexus docker-hosted repo.

### Decision
Use Nexus docker-hosted repo.

### Consequences
- **Pros:**
  - Single tool for Maven artifacts, Docker images, and Helm charts — reduces operational surface
  - Demonstrates Nexus depth (proxy repos, hosted repos, group repos, cleanup policies)
  - No AWS-specific lock-in
  - Free (no per-GB storage or data transfer costs beyond EC2)
- **Cons:**
  - No AWS IAM integration — must manage Nexus credentials separately
  - No built-in image scanning (must layer Trivy on top)
  - Self-managed = you own the backups and HA

### Rationale
Nexus is already in the stack for Maven artifacts. Using it for Docker images consolidates tooling and showcases Nexus expertise, which is what interviewers probe.

---

## ADR-003: Jenkins over GitHub Actions for CI

**Status:** Accepted  
**Date:** 2026-10-28

### Context
The pipeline needs a CI engine. Options: GitHub Actions, GitLab CI, Jenkins, Tekton.

### Decision
Use Jenkins with Kubernetes plugin (ephemeral agents).

### Consequences
- **Pros:**
  - Industry-standard, widely used in enterprise — directly transferable skill
  - Kubernetes plugin gives ephemeral build pods — no long-lived agents to patch
  - Declarative pipeline syntax is readable and version-controlled
  - Integrates with Nexus, SonarQube, Trivy via well-documented plugins
- **Cons:**
  - Higher operational overhead than GitHub Actions (Jenkins controller needs HA, plugin updates)
  - Groovy DSL is verbose compared to YAML-based alternatives
  - Not cloud-native by default (but the Kubernetes plugin fixes that)

### Rationale
Jenkins is the enterprise CI tool. Showing you can run it on Kubernetes with ephemeral agents demonstrates both CI expertise and Kubernetes fluency.

---

## ADR-004: ArgoCD for GitOps over Flux

**Status:** Accepted  
**Date:** 2026-10-28

### Context
The cluster needs a GitOps controller. Options: ArgoCD, Flux.

### Decision
Use ArgoCD.

### Consequences
- **Pros:**
  - Web UI for visualizing sync status — easier to demo and debug
  - Application CRD is explicit and readable
  - Supports Kustomize, Helm, Jsonnet out of the box
  - Larger community and more enterprise adoption
- **Cons:**
  - Heavier than Flux (controller + repo-server + application-controller)
  - Web UI is a nice-to-have but not strictly necessary for GitOps

### Rationale
ArgoCD's UI makes the GitOps loop visible, which is valuable for a portfolio project. The Application CRD is also more explicit than Flux's HelmRelease/Kustomization CRDs.

---

## ADR-005: local-path storage over EBS CSI

**Status:** Accepted  
**Date:** 2026-10-28

### Context
Stateful workloads (Nexus, SonarQube, Postgres, Jenkins) need persistent storage. Options: AWS EBS CSI driver or k3s local-path provisioner.

### Decision
Use local-path provisioner.

### Consequences
- **Pros:**
  - Zero AWS cost (uses local disk on EC2 instances)
  - No CSI driver to install or maintain
  - Demonstrates understanding of storage classes and PVCs without cloud dependency
- **Cons:**
  - Data is tied to the node — if the node dies, the data is gone (unless you back up)
  - No cross-node migration — pods are pinned to the node with the data
  - Not suitable for production without a backup strategy

### Rationale
This is a portfolio project, not production. local-path keeps costs at zero and demonstrates storage concepts without AWS lock-in. The README explicitly notes that a real deployment would swap in a CSI driver.
