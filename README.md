# Introduction

This is a Rails app I hacked together over a weekend that lets you query YDKJS by [Kyle Simpson](https://twitter.com/getifyAtSocket) with natural language. It is the first Rails app I've built, so it might not be very idiomatic.

Under the hood it uses OpenAI embeddings and completions.

It is inspired by [Askmybook](https://askmybook.com/), written by Sahil Lavingia, CEO of Gumroad.

## Generating embeddings

A Python script is used to generate embeddings for arbitrary PDF files. You can use it to make a QA app over your own content, too.

```shell
# make sure you set your openai key in .env
echo "OPENAI_API_KEY=YOUR_KEY" > .env

./scripts/generate_embeddings.py --pdf /path/to/pdf
```

This will write a file called `your_file_name.embeddings.csv` to the current directory. 

The file is a CSV with the following columns:

```csv
title,token,content,0...4095
Page1,50,This is the content of page 1,...,0.123
```

where `0...4095` are the 4096 dimensions of the embedding vector. If you don't use OpenAI's embeddings, you might get a different number of dimensions.

The other columns store the title of the page (page 1...n), the token count, and the actual content of the page, respectively.

Once you have these you can just load them up in QuestionController and it takes cares of the rest, (computing dot product wrt a question embedding).

## Development

This is a typical Rails app, so you should be able to get it up and running locally with the following:

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

## Deployment

I deployed the app to [Railway](https://railway.app) and highly recommend them. You'll also need to spin up a Postgres instance.

Then, ensure that you've set the following environment variables in your Railway service:

```dotenv
OPENAI_API_KEY=generate_me
RAILS_ENV=production
# type rails secret to generate the key. it will be in config/master.key. don't commit this!
RAILS_MASTER_KEY=generate_me
```

The variables used to connect to the DB are set by Railway, so you don't need to worry about them. Just reference them in your Rails service.

Then, run migrations:

```shell
# deployed to railway, so make sure you have the cli installed
railway link
railway service

# get into the subshell
railway shell

# ensure that PGHOST, PGPORT, PGUSER and PGPASSWORD are set
# set up the prod db
rails db:create
rails db:migrate
```
