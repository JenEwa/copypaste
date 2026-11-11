# ensure_project_token NAME [SCOPES] [ACCESS_LEVEL] [DAYS] [PROJECT]
#   NAME          token name (required)
#   SCOPES        comma-separated, default: read_repository,write_repository
#   ACCESS_LEVEL  10 guest, 20 reporter, 30 developer, 40 maintainer (default 40)
#   DAYS          days until expiry (default 364)
#   PROJECT       project ID or URL-encoded path (default :id = current repo)
#
# stdout: the token value if created, nothing if it already existed
# return: 0 on success (created or already exists), 1 on error
ensure_project_token() {
  local name="${1:?token name required}"
  local scopes="${2:-read_repository,write_repository}"
  local level="${3:-40}"
  local days="${4:-364}"
  local project="${5:-:id}"

  local expires
  if date -d "+1 day" +%F >/dev/null 2>&1; then
    expires=$(date -d "+${days} days" +%F)        # GNU date
  else
    expires=$(date -v+"${days}"d +%F)             # macOS/BSD date
  fi

  local count
  count=$(GLAB_PAGER=cat glab api --paginate "projects/${project}/access_tokens" \
    | jq -s --arg n "$name" \
        '[.[][] | select(.name == $n and .active and (.revoked | not))] | length') \
    || { echo "Failed to list tokens" >&2; return 1; }

  if [ "$count" -gt 0 ]; then
    echo "Token '$name' already exists, skipping" >&2
    return 0
  fi

  local args=(-f name="$name" -f access_level="$level" -f expires_at="$expires")
  local s
  IFS=',' read -ra s <<< "$scopes"
  for scope in "${s[@]}"; do
    args+=(-f "scopes[]=$scope")
  done

  local token
  token=$(GLAB_PAGER=cat glab api --method POST "projects/${project}/access_tokens" "${args[@]}" \
    | jq -r '.token // empty') \
    || { echo "Failed to create token '$name'" >&2; return 1; }

  if [ -z "$token" ]; then
    echo "Token creation returned no token" >&2
    return 1
  fi

  echo "Created token '$name' (expires $expires)" >&2
  printf '%s\n' "$token"
}
