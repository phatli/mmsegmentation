#!/bin/bash
cd mmseg && pip install -e . --user
cd 
exec "$@"