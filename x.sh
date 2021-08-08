#!/bin/bash
# set -e; set -u; set -o pipefail
R='\033[0;31m'; LR='\033[1;31m'; G='\033[0;32m'; LG='\033[1;32m'
P='\033[0;35m'; LP='\033[1;35m'; C='\033[0;36m'; LC='\033[1;36m'
Y='\033[0;33m'; LY='\033[1;33m'; B='\033[0;34m'; LB='\033[1;34m'; N='\033[0m'

function print_help() {
    echo -e "$G USAGE:"
}

function build_small() {
    zig build -Drelease-small true
    zig build -Dtarget wam32-wasi -Drelease-small true
}
function build_fast() {
    zig build -Drelease-fast true
    zig build -Dtarget wam32-wasi -Drelease-fast true
}
function build_safe() {
    zig build -Drelease-safe true
    zig build -Dtarget wam32-wasi -Drelease-safe true
}
function build_wasm() {
    zig build-exe -target wasm32-wasi -O ReleaseSmall ./src/main.zig
}

function clean() {
    rm -rf zig-out/bin/*
    rm -rf zig-cache
}

function run() {
    zig build run
}

function test() {
    zig test src/main.zig
}

function run_wasm() {
    wasmer zig-out/bin/iz.wasm
}
function gpush() {
    git push gh master
}
function publish() {
    wapm publish
}


case $1 in
    r|run) 
	case $2 in
	    w|wasm) run_wasm;;
	    *) run;;
	esac
	;;
    r|test) 
	case $2 in
	    *) test;;
	esac
	;;
    rc|runc) 
	case $2 in
	    h|help)    zig build run -- help ;;
	    n|new)     zig build run -- new ;;
	    l|log)     zig build run -- log ;;
	    ls|list)   zig build run -- ls ;;
	    rm|remove) zig build run -- rm ;;
	    R|repl)    zig build run -- repl ;;
	    i|init)    zig build run -- init ;;
	esac
	;;
    c|clean) clean;;
    cc|ccache) rm -rf zig-cache;;
    gp|push) gpush;;
    p|publish) wapm_publish;;
    w|wasm) run_wasm;;
    b|build) 
	case $2 in
	    f|fast) build_fast;;
	    sm|small) build_small;;
	    sa|safe) build_safe;;
	esac
	;;
    h|help) print_help;;
    i|install) zig build -Drelease-fast true install;;
    u|uninstall) zig build uninstall

esac    

main() {
    run
    return 0
}

((!$#)) && main
