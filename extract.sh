#!/bin/bash

EXTRACT_SKINS=0
EXTRACT_PLUGINS=0

default_opt_skin=1
default_opt_plugin=1

use_default_opt=1

function usage {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  --help     Show this help message"
    echo "  --skins    Extract skins"
    echo "  --plugins  Extract plugins"
    echo "  --all      Extract skins and plugins"
    exit 1
}

while [ $# -gt 0 ]; do
    case "$1" in
        --skins)
            EXTRACT_SKINS=1
            use_default_opt=0
            shift
            ;;
        --plugins)
            EXTRACT_PLUGINS=1
            use_default_opt=0
            shift
            ;;
        --all)
            EXTRACT_SKINS=1
            EXTRACT_PLUGINS=1
            use_default_opt=0
            shift
            ;;
        --help)
            usage
            exit 0
            ;;
        -*)
            echo "Unknown option: $1"
            exit 1
            ;;
        *)
            echo "Unknown parameter: $1"
            exit 1
    esac
done

if [ $use_default_opt -eq 1 ]; then
    EXTRACT_SKINS=$default_opt_skin
    EXTRACT_PLUGINS=$default_opt_plugin
fi

function print_warning {
    echo -e "\033[33mWarning: \033[0m$1"
}

function color_cyan {
    echo -e "\033[36m$1\033[0m"
}

function hash_timestamp {
    echo $(date +%s | sha256sum | base64 | head -c 16 ; echo)
}

function image_exists {
    local image_name=$1
    local image_tag=$2
    local image_full_name=$image_name:$image_tag
    local image_id=$(docker images -q $image_full_name)
    if [ -n "$image_id" ]; then
        echo 1
    else
        echo 0
    fi
}

image_name=b3log/solo
image_tag=latest
tmp_container_name=tmp_solo_$(hash_timestamp)
destination_dir=/opt/solo

image_already=$(image_exists $image_name $image_tag)

function create_temp_container {
    echo "Creating temporary container..."
    echo -e "\033[90m$(docker run --detach --name $tmp_container_name --entrypoint tail $image_name:$image_tag -f /dev/null)\033[0m"
}

function extract_skins {
    echo "Extracting skins..."
    mkdir -p $destination_dir
    if [ -d "$destination_dir/skins" ]; then
        print_warning "Skin directory $(color_cyan $destination_dir/skins) already exists, please remove it first"
    else
        docker cp "$tmp_container_name":/opt/solo/skins $destination_dir
    fi
}

function extract_plugins {
    echo "Extracting plugins..."
    mkdir -p $destination_dir
    if [ -d "$destination_dir/plugins" ]; then
        print_warning "Plugin directory $(color_cyan $destination_dir/plugins) already exists, please remove it first"
    else
        docker cp "$tmp_container_name":/opt/solo/plugins $destination_dir
    fi
}

function main() {
    [ $EXTRACT_SKINS -eq 1 ] && extract_skins
    [ $EXTRACT_PLUGINS -eq 1 ] && extract_plugins
    echo "All done"
}

function cleanup() {
    echo "Cleaning up..."
    docker rm -f "$tmp_container_name" > /dev/null
    [ $image_already -eq 0 ] && docker rmi $image_name:$image_tag > /dev/null
}

create_temp_container

main

cleanup
