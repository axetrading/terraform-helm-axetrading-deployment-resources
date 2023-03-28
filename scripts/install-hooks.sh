#!/bin/bash

rm -f .git/hooks/pre-commit
ln -s ../../scripts/pre-commit .git/hooks/pre-commit