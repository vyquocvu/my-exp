Get file from [Dockerfile](https://github.com/docker-library/rails)
```
FROM ruby:2.3

RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
		postgresql-client \
	&& rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src/app
COPY Gemfile* ./
RUN bundle install
COPY . .

EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]
```
Save it to directory and run command ` sudo docker build . `

Show docker image `sudo docker images`



