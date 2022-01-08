#!/bin/bash
cd /home/user/code/mmseg && pip install -e . --user
cd 
exec "$@"