#!/bin/bash
echo "Hi,"
echo ""
echo "Select as entrypoint one of these scripts:"
find ./bin/* -printf "%f\n" | sort
echo ""
echo "You might find one of the sample config files useful:"
find /etc/ -name *.properties | sort
echo ""
