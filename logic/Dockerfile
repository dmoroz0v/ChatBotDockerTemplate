FROM swift
RUN apt-get update
RUN apt-get install sqlite3 libsqlite3-dev
WORKDIR /app
COPY . ./
WORKDIR App
CMD swift package clean
CMD swift run