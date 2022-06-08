#!/bin/bash

time docker build -f Dockerfile -t tkchia/ia16:latest "${@}" .

