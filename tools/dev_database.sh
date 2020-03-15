#!/bin/bash -e

sudo -u postgres createuser $USER || true
for db in development test; do
    sudo -u postgres dropdb solidarity_$db || true
    sudo -u postgres createdb solidarity_$db
    sudo -u postgres psql -c "grant all on database solidarity_$db to $USER"
    sudo -u postgres psql -c "create extension pgcrypto;" solidarity_$db
done
