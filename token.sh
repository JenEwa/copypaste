ensure_pipeline_schedule() {
  local description="Nightly pipeline"
  local cron="0 2 * * *"
  local timezone="Europe/Berlin"
  local ref="main"

  local schedule
  schedule=$(GLAB_PAGER=cat glab schedule list --per-page 100 --output json \
    | jq -c --arg d "$description" '[.[] | select(.description == $d)] | first // empty') \
    || { echo "Failed to list schedules" >&2; return 1; }

  if [ -z "$schedule" ]; then
    GLAB_PAGER=cat glab schedule create \
      --description "$description" \
      --cron "$cron" \
      --cronTimeZone "$timezone" \
      --ref "$ref" \
      --active >/dev/null \
      || { echo "Failed to create schedule '$description'" >&2; return 1; }
    echo "Created schedule '$description'" >&2
    return 0
  fi

  local id cur_cron cur_tz cur_ref cur_active
  id=$(jq -r '.id' <<< "$schedule")
  cur_cron=$(jq -r '.cron' <<< "$schedule")
  cur_tz=$(jq -r '.cron_timezone' <<< "$schedule")
  cur_ref=$(jq -r '.ref | sub("^refs/heads/"; "")' <<< "$schedule")
  cur_active=$(jq -r '.active' <<< "$schedule")

  if [ "$cur_cron" = "$cron" ] && [ "$cur_tz" = "$timezone" ] \
     && [ "$cur_ref" = "$ref" ] && [ "$cur_active" = "true" ]; then
    echo "Schedule '$description' is up to date" >&2
    return 0
  fi

  GLAB_PAGER=cat glab schedule update "$id" \
    --cron "$cron" \
    --cronTimeZone "$timezone" \
    --ref "$ref" \
    --active >/dev/null \
    || { echo "Failed to update schedule '$description'" >&2; return 1; }
  echo "Updated schedule '$description' (ID $id)" >&2
}
