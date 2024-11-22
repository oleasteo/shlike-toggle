#!/bin/bash

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
SNAP_DIR="$ROOT_DIR/__snapshots__"

mkdir -p "$SNAP_DIR"

WORK_FILE="$ROOT_DIR/.work.tmp"
OUT_FILE="$ROOT_DIR/.out.tmp"
RUN_OUT_FILE="$ROOT_DIR/.run-out.tmp"

_NAME=
_SNAP_WORK_FILE=
_SNAP_OUT_FILE=
_SNAP_RUN_OUT_FILE=

_setup() {
    _clear

    sample_file="$ROOT_DIR/$1"
    _NAME="$2"
    _SNAP_WORK_FILE="$SNAP_DIR/$2.snap.txt"
    _SNAP_OUT_FILE="$SNAP_DIR/$2.out.txt"
    _SNAP_RUN_OUT_FILE="$SNAP_DIR/$2.run-out.txt"
    
    cp "$sample_file" "$WORK_FILE"
}

_act() {
    echo "### CMD: $@" >>"$OUT_FILE"
    echo >>"$OUT_FILE"
    "$ROOT_DIR/../pkg/shlike-toggle" "$WORK_FILE" "$@" &>>"$OUT_FILE"
    echo -e "\n---\n">>"$OUT_FILE"
}

_act_exec_result() {
    chmod +x "$WORK_FILE"
    echo "### NEXT RUN" >>"$RUN_OUT_FILE"
    if [ $# -gt 0 ]; then
        echo "### $@" >>"$RUN_OUT_FILE"
    fi
    echo >>"$RUN_OUT_FILE"
    ("$WORK_FILE" &>>"$RUN_OUT_FILE")
    echo >>"$RUN_OUT_FILE"
}

_check_snapshots() {
    if [ -f "$_SNAP_WORK_FILE" ]; then
        snapshot="$(cat "$_SNAP_WORK_FILE")"
        result="$(cat "$WORK_FILE")"
        
        if [ "$snapshot" = "$result" ]; then
            echo "[info] snapshot passed: $_NAME"
        else
            echo "[ERROR] snapshot FAILED: $_NAME" >&2
            diff "$_SNAP_WORK_FILE" "$WORK_FILE"
            exit 5
        fi
    else
        cp "$WORK_FILE" "$_SNAP_WORK_FILE"
    fi
    
    _check_output
    _check_run_output
}

_check_output() {
    if [ -f "$_SNAP_OUT_FILE" ]; then
        snapshot="$(cat "$_SNAP_OUT_FILE")"
        result="$(cat "$OUT_FILE")"
        
        if [ "$snapshot" = "$result" ]; then
            echo "[info] output snapshot passed: $_NAME"
        else
            echo "[ERROR] output snapshot failed: $_NAME" >&2
            diff "$_SNAP_OUT_FILE" "$OUT_FILE"
            exit 5
        fi
    else
        echo "[info] output snapshot created: $_NAME"
        mv "$OUT_FILE" "$_SNAP_OUT_FILE"
    fi
}

_check_run_output() {
    if [ -f "$_SNAP_RUN_OUT_FILE" ]; then
        result="$(cat "$RUN_OUT_FILE")"
        snapshot="$(cat "$_SNAP_RUN_OUT_FILE")"
        
        if [ "$snapshot" = "$result" ]; then
            echo "[info] run-output snapshot passed: $_NAME"
        else
            echo "[ERROR] run-output snapshot failed: $_NAME" >&2
            diff "$_SNAP_RUN_OUT_FILE" "$RUN_OUT_FILE"
            exit 5
        fi
    elif [ -f "$RUN_OUT_FILE" ]; then
        echo "[info] run-output snapshot created: $_NAME"
        mv "$RUN_OUT_FILE" "$_SNAP_RUN_OUT_FILE"
    fi
}

_clear() {
  rm -f -- "$WORK_FILE" "$OUT_FILE" "$RUN_OUT_FILE"
}

###
### TESTS
###

_setup sample-a.sh "set-feat-a--change"
_act get feat/a
_act set feat/a second
_act_exec_result It should be feat/a:second
_act set feat/a second
_act get feat/a
_check_snapshots

_setup sample-a.sh "set-dark--noop"
_act get dark
_act set dark off
_act get dark
_check_snapshots

_setup sample-a.sh "set-dark--toggle"
_act get dark
_act set dark on
_act_exec_result It should be dark:on
_act get dark
_act set dark off
_act_exec_result It should be dark:off
_act get dark
_check_snapshots

_setup sample-a.sh "set-feat-a-unknown--fail"
_act get feat/a
_act set feat/a unknown
_act_exec_result It should still be feat/a:first
_act get feat/a
_check_snapshots

_setup sample-a.sh "list"
_act list feat/a
_act list dark
_act list unknown
_act list
_check_output

_setup sample-a.sh "groups"
_act groups
_check_output

###
### TEARDOWN
###

_clear
