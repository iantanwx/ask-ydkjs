# Introduction

This is a Rails app I hacked together over a weekend that lets you query YDKJS by [Kyle Simpson](https://twitter.com/getifyAtSocket) with natural language. It is the first Rails app I've built, so it might not be very idiomatic.

Under the hood it uses OpenAI embeddings and completions.

It is inspired by [Askmybook](https://askmybook.com/), written by Sahil Lavingia, CEO of Gumroad.

## Development

This is a typical Rails app, so you should be able to get it up and running with the following:

```shell
# install dependencies
bundle install
yarn install

# start postgres container
docker-compose up -d

# create the database for dev
rails db:create

# migrate
rails db: migrate
```

## Migrations

```shell
# deployed to railway, so make sure you have the cli installed
railway link
railway service

# get into the subshell
# ensure that PGHOST, PGPORT, PGUSER and PGPASSWORD are set in railway
railway shell

# set up the prod db
rails db:create
rails db:migrate
```