ensure_project_token() {
  local name="ci-push-token"
  local scopes="read_repository,write_repository"
  local level="maintainer"
  local duration="365d"

  local count
  count=$(GLAB_PAGER=cat glab token list --output json \
    | jq --arg n "$name" '[.[] | select(.name == $n and .active and (.revoked | not))] | length') \
    || { echo "Failed to list tokens" >&2; return 1; }

  if [ "$count" -gt 0 ]; then
    echo "Token '$name' already exists, skipping" >&2
    return 0
  fi

  GLAB_PAGER=cat glab token create "$name" \
    --access-level "$level" \
    --scope "$scopes" \
    --duration "$duration" \
    || { echo "Failed to create token '$name'" >&2; return 1; }
}
