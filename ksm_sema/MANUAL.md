# Terragrunt + Semaphore UI — Project Manual

This manual documents the sample project in this folder: a Terragrunt layout
for managing [Semaphore UI](https://semaphoreui.com) resources (projects,
views, task templates, keys, repositories, inventories) via the
[`semaphoreui/semaphore`](https://registry.terraform.io/providers/semaphoreui/semaphore)
Terraform provider, with dependencies wired automatically instead of by hand.

> **Before using this in production:** the Semaphore Terraform provider is
> young and its exact resource/attribute names have shifted between
> versions. Check the current docs on the Terraform Registry and adjust the
> modules under `modules/semaphore/*` if anything has changed.

---

## 1. The mental model

Semaphore's object graph looks like this:

```
project
  ├─▶ view                (groups templates in the UI)
  │     └─▶ task/template
  │           ├─▶ key           (ssh / login+password / none)
  │           ├─▶ repository    (needs a key for auth)
  │           └─▶ inventory     (needs a key too)
```

This project mirrors that graph **in the filesystem**, so folder position
*is* the relationship — you rarely write an explicit `dependency` block for
"depends on project" or "depends on my parent view/task" by hand. Instead,
a handful of shared **marker files** carry that dependency once, and every
descendant inherits it via `include`.

```
live/prod/
├── root.hcl                 # remote state + provider, included everywhere
├── _project.hcl              # "depends on project" — included by everything
├── project/
│   └── terragrunt.hcl        # the actual semaphore_project resource
└── views/
    └── deployments/
        ├── terragrunt.hcl    # the semaphore_project_view resource
        ├── _view.hcl         # "depends on THIS view" — included by its tasks
        └── tasks/
            └── deploy-app/
                ├── terragrunt.hcl   # the semaphore_project_template resource
                ├── _task.hcl        # marker so children can find this task's folder
                ├── ssh-keys/
                │   └── deploy-key/terragrunt.hcl
                ├── repo/terragrunt.hcl
                └── inventory/terragrunt.hcl
```

## 2. How the marker-file pattern works

Terragrunt's `find_in_parent_folders(name)` walks **upward** from the
calling file until it finds a file with that exact name — regardless of how
many levels deep the caller is nested. Each marker plays a specific role:

| File | Lives at | Declares dependency on | Included by |
|---|---|---|---|
| `root.hcl` | top of `live/prod/` | — (remote state / provider only) | every unit |
| `_project.hcl` | top of `live/prod/`, next to `project/` | `project/terragrunt.hcl` | every unit except `project/` itself |
| `_view.hcl` | inside a specific view folder | that view's own `terragrunt.hcl` | every task (and its children) under that view's `tasks/` |
| `_task.hcl` | inside a specific task folder | *(no dependency — see below)* | that task's `ssh-keys/`, `repo/`, `inventory/` children, to locate sibling folders |

**Golden rule:** a unit must never include its own marker file — that
creates a self-dependency and Terragrunt will fail to build the graph.
`_project.hcl` is for *descendants* of the project, `_view.hcl` for
*descendants* of the view, and so on.

`_task.hcl` is different from the other two: it holds **no** `dependency`
block. The task's own `terragrunt.hcl` depends *downward* on its own
`ssh-keys/`, `repo/`, and `inventory/` children (normal `dependency` blocks,
by relative path, since they're fixed siblings). The children, in turn, use
`_task.hcl` only to find their *own* task folder — e.g. so `repo/` can look
up its sibling `ssh-keys/deploy-key/` without hardcoding `../../` chains
that break if you change nesting depth later.

## 3. Adding things

**A new task under an existing view** — copy the `deploy-app/` folder,
rename it, and edit the four `terragrunt.hcl` files inside (task, key, repo,
inventory) with new names/values. Everything else (project + view wiring)
is inherited automatically through the includes.

**A new view** — copy the `deployments/` folder (including its `_view.hcl`)
to a sibling, e.g. `views/maintenance/`, and give the view unit a new
`title`/`position`.

**A key shared by multiple tasks** — this layout assumes one key mostly
belongs to one task. If two tasks legitimately need the *same* repository or
key, don't duplicate the resource (that causes drift — two Terraform
resources pointing at one Git URL). Either:
- point one task's `dependency "key"` at the *other* task's key folder
  directly (breaks the "position = relationship" invariant for that one
  edge — leave a comment explaining why), or
- promote shared resources to a flat top-level folder (e.g.
  `live/prod/shared-keys/`) instead of nesting them under a task.

## 4. Running it

```bash
cd live/prod
terragrunt run-all plan     # walks the whole dependency graph, safe with mock_outputs
terragrunt run-all apply    # applies in dependency order, parallelizing independent units
```

To operate on a single branch of the tree (e.g. just one task and its
children):

```bash
cd live/prod/views/deployments/tasks/deploy-app
terragrunt run-all apply
```

## 5. `mock_outputs`, explained

Every `dependency` block includes:

```hcl
mock_outputs = { id = 0 }
mock_outputs_allowed_terraform_commands = ["validate", "plan"]
```

This lets `terragrunt run-all plan` (and CI validation) succeed even when a
dependency hasn't been applied yet — Terragrunt substitutes `0` for the
real ID during `plan`, but **refuses** to use the mock during `apply`,
forcing dependencies to be applied first. Without this, a `plan` on a
never-applied tree fails outright.

## 6. File index

```
live/prod/
  root.hcl                                                  — remote state + provider
  _project.hcl                                               — project dependency marker
  project/terragrunt.hcl                                     — semaphore_project
  views/deployments/terragrunt.hcl                           — semaphore_project_view
  views/deployments/_view.hcl                                — view dependency marker
  views/deployments/tasks/deploy-app/terragrunt.hcl          — semaphore_project_template
  views/deployments/tasks/deploy-app/_task.hcl               — task location marker
  views/deployments/tasks/deploy-app/ssh-keys/deploy-key/…   — semaphore_project_key
  views/deployments/tasks/deploy-app/repo/terragrunt.hcl     — semaphore_project_repository
  views/deployments/tasks/deploy-app/inventory/terragrunt.hcl— semaphore_project_inventory

modules/semaphore/
  project/main.tf        — wraps semaphore_project
  view/main.tf           — wraps semaphore_project_view
  template/main.tf       — wraps semaphore_project_template
  key/main.tf            — wraps semaphore_project_key (ssh / login_password / none)
  repository/main.tf     — wraps semaphore_project_repository
  inventory/main.tf      — wraps semaphore_project_inventory (static inventory shown)
```

## 7. Before you `apply` for real

- Set `SEMAPHORE_URL` and `SEMAPHORE_API_TOKEN` env vars (used by `root.hcl`'s
  generated provider block).
- Point `remote_state.config.bucket` / `dynamodb_table` in `root.hcl` at your
  own S3 bucket and lock table (or swap the backend entirely).
- Don't commit real SSH private keys into `ssh-keys/*/terragrunt.hcl` — pull
  them from a secrets manager (example commented out in the sample file).
- Double-check `modules/semaphore/template/main.tf`'s `app` values and
  `modules/semaphore/key/main.tf`'s nested blocks against the current
  provider schema — these evolve as the provider matures.
