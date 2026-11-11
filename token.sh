GLAB_PAGER=cat glab api --method PUT projects/:id \
  -f shared_runners_enabled=true \
  -f ci_push_repository_for_job_token_allowed=true \
  -f ci_config_path=.gitlab/gitlab-ci.yml >/dev/null
