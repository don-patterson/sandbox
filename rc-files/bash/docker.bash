#!/bin/bash

function d {
    case "$1" in
        up)     docker-compose up -d --remove-orphans && d logs ;;
        down)   docker-compose down -v --remove-orphans ;;
        start)  docker-compose start && d logs ;;
        stop)   docker-compose stop ;;
        logs)   docker-compose logs -f --tail=0 ;;
        build)  docker-compose pull && docker-compose build --pull ;;
        stats)  docker stats --format 'table {{.Name}}\t{{.CPUPerc}}\t{{.MemPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}' ;;
        scorch)
            docker ps -aq|xargs docker kill
            docker ps -aq|xargs docker rm -fv
            docker image ls -q|xargs docker rmi -f
            docker volume ls -q|xargs docker volume rm
            ;;
        *)
            docker ps -a
            ;;
    esac
}

function _d_run {
    container=$1
    shift
    docker exec -it "$container" "$@"
}

function _d_copy {
    container=$1
    shift
    docker cp "$1" $container:"$2"
}

function my_favourite_container {
    return  # just an example!
    container='my_container'

    [ "$1" = init ] && {
        _d_run "$container" pip install ipython
        _d_run "$container" mkdir -p /root/.ipython/profile_default/startup/
        _d_copy "$container" ~/.ipython/profile_default/ipython_config.py /root/.ipython/profile_default/ipython_config.py
        _d_copy "$container" ~/.pdbrc /root/
        return
    }

    [ "$1" = test ] && {
        _d_run "$container" bash -c 'cd somewhere; py.test -k "not lint" "$@"' "$@"
        return
    }

    [ "$1" ] || set -- 'manage.py' 'shell'
    _d_run "$container" "$@"
}
