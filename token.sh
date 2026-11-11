# create_schedule DESCRIPTION CRON TIMEZONE REF
create_schedule() {
  GLAB_PAGER=cat glab schedule create \
    --description "$1" \
    --cron "$2" \
    --cronTimeZone "$3" \
    --ref "$4" \
    --active >/dev/null
}

# update_schedule ID CRON TIMEZONE REF
update_schedule() {
  GLAB_PAGER=cat glab schedule update "$1" \
    --cron "$2" \
    --cronTimeZone "$3" \
    --ref "$4" \
    --active >/dev/null
}

DESC="Nightly pipeline"
CRON="0 2 * * *"
TZ_NAME="Europe/Berlin"
REF="main"

id=$(GLAB_PAGER=cat glab schedule list --per-page 100 --output json \
  | jq -r --arg d "$DESC" '[.[] | select(.description == $d)] | first | .id // empty')

if [ -z "$id" ]; then
  create_schedule "$DESC" "$CRON" "$TZ_NAME" "$REF"
else
  update_schedule "$id" "$CRON" "$TZ_NAME" "$REF"
fi
