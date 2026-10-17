#!/bin/sh
#
# PostgreSQL (Linux)
#
# On macOS the Brewfile installs PostgreSQL, so this does nothing there. On Linux it installs it from the
# PostgreSQL project's own apt repository (apt.postgresql.org). That one has every major version for every
# supported Ubuntu release, so you get the same version as on the Mac. Ubuntu's own repositories have only
# one, older version per release.

PG_VERSION=18  # keep in sync with postgresql@<version> in the Brewfile

[ "$(uname -s)" = Linux ] && command -v apt-get >/dev/null 2>&1 || exit 0  # skip on macOS

. "${DOTFILES:-$HOME/.dotfiles}/script/output_format"

apt_install () {
  sudo env DEBIAN_FRONTEND=noninteractive apt-get install -y -qq "$@"
}

if ! dpkg-query -W -f='${Status}' "postgresql-$PG_VERSION" 2>/dev/null | grep -q 'ok installed'
then
  info "Installing PostgreSQL $PG_VERSION from apt.postgresql.org"
  # Ubuntu's postgresql-common package comes with the official script that adds that repository and its signing key
  if ! { apt_install postgresql-common &&
         sudo /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh -y &&
         apt_install "postgresql-$PG_VERSION"; }
  then
    warn "Couldn't install PostgreSQL $PG_VERSION, skipping"
    exit 0
  fi
fi

# Like on the macOS: your user is a superuser and has a database of its own name, so `psql` works without
# a password or -U. Checking needs no sudo, so once this is set up, nothing asks for your password.
me=$(id -un)
if ! psql -c '' >/dev/null 2>&1
then
  info "Creating PostgreSQL superuser and database '$me'"
  sudo -u postgres createuser --superuser "$me" 2>/dev/null
  sudo -u postgres createdb --owner "$me" "$me" 2>/dev/null
  psql -c '' >/dev/null 2>&1 || warn "Couldn't connect to PostgreSQL. Is it running? Check with: systemctl status postgresql"
fi
