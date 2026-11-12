# CODEOWNERS
# Location: repository root, .gitlab/CODEOWNERS, or docs/CODEOWNERS
# Rule: the LAST matching pattern wins, so general rules go first,
# specific ones further down.

# ---------------------------------------------------------------
# Catch-all: anything not matched below (lockfiles, misc config)
# ---------------------------------------------------------------
*                           @acme/platform-team

# ---------------------------------------------------------------
# CI/CD and container config: often touched by Renovate
# ---------------------------------------------------------------
.gitlab-ci.yml              @acme/platform-team
/.gitlab/ci/                @acme/platform-team
Dockerfile                  @acme/platform-team
**/Dockerfile               @acme/platform-team
docker-compose*.yml         @acme/platform-team

# Renovate config itself
renovate.json               @acme/platform-team @jdoe

# ---------------------------------------------------------------
# Frontend (npm)
# ---------------------------------------------------------------
/frontend/                  @acme/frontend
/frontend/package.json      @acme/frontend
/frontend/package-lock.json @acme/frontend

# ---------------------------------------------------------------
# Backend (Java / Maven)
# ---------------------------------------------------------------
/backend/                   @acme/backend
/backend/pom.xml            @acme/backend @mschmidt

# ---------------------------------------------------------------
# Infrastructure (Terraform, Helm)
# ---------------------------------------------------------------
/infra/terraform/           @acme/infra
*.tf                        @acme/infra
/infra/helm/                @acme/infra @kmueller

# ---------------------------------------------------------------
# Docs: nobody needs to review dependency bumps here
# ---------------------------------------------------------------
/docs/                      @techwriter
