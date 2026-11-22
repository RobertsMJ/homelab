#!/usr/bin/env bash
# Onboards the simc tenant: its keyspace and an owner role that simc's own migrations use. Every statement is safe to rerun.
set -euo pipefail

creds=$(mktemp)
script=$(mktemp)
trap 'rm -f "$creds" "$script"' EXIT

# A credentials file keeps the superuser password out of process args; mktemp's 0600 mode satisfies cqlsh's permission check
printf '[plain_text_auth]\nusername = %s\npassword = %s\n' "$ADMIN_USERNAME" "$ADMIN_PASSWORD" > "$creds"

# Replication is create-only: RF changes on tablet keyspaces are a stepwise operational procedure, not something to converge automatically.
# The password is converged with ALTER so a rotated Secret takes effect on the Job's next periodic run.
cat > "$script" <<CQL
CREATE KEYSPACE IF NOT EXISTS simc
  WITH replication = {'class': 'NetworkTopologyStrategy', 'dev': 1};

CREATE ROLE IF NOT EXISTS ${OWNER_USERNAME} WITH LOGIN = true;
ALTER ROLE ${OWNER_USERNAME} WITH PASSWORD = '${OWNER_PASSWORD}';
GRANT ALL ON KEYSPACE simc TO ${OWNER_USERNAME};
CQL

cqlsh "$SCYLLA_HOST" --credentials "$creds" -f "$script"
