# Laravel Docker Starter

> An Laravel framework starter kit featuring 
[Laravel](https://laravel.com/) and 
[Docker](https://www.docker.com/) 
([PHP], 
[MySQL], 
[Memcached],
and [Nginx])

This seed repo serves as an Laravel framework starter for anyone looking to get up and running with Laravel and PHP fast. Using Docker for building our environment.

* Ready to go development environment using Docker for working with Laravel.
* A great Laravel seed repo for anyone who wants to start their project.

### Quick start
**Make sure you have Docker version >= 17.04.0**

```bash
# clone our repo
# --depth 1 removes all but one .git commit history
git clone --depth 1 --recursive https://github.com/NicklasWallgren/laravel-docker-starter.git laravel-docker-starter

# change directory to our repo
cd laravel-docker-starter

# start the docker containers. The first boot will take some time
make
```
go to [http://localhost](http://localhost) or [http://<docker-machine>](http://<docker-machine>)

# Getting Started

## Commands

### Start containers
```bash
make

```
### Stop containers
```bash
make halt

```
### Start individual container
```bash
make start [php-fpm|php-cli|nginx|mysql|memcached]

```
### Stop individual container
```bash
make stop [php-fpm|php-cli|nginx|mysql|memcached]

```
### Update composer dependencies
```bash
make update-project

```
### Access artisan cli
```bash
# Access the php container
make bash-cli
    
# Launch the artisan cli
cd laravel && php artisan
```
### Access MySQL cli
```bash
make mysql-cli

```
### Access PHP container bash
```bash
make bash-php

```
### Access Nginx container bash
```bash
make bash-nginx

```
### Access PHP-FPM container bash
```bash
make bash-fpm

```
### Access Memcached container bash
```bash
make bash-memcached

```
### Access MySQL container bash
```bash
make bash-mysql

```
### Check container status
```bash
make status

```
# Contributing
I'll accept pretty much everything so feel free to open a Pull-Request





