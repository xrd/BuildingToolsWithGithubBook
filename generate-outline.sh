#!/bin/bash

rm full-outline.asciidoc
grep -h '===\s\S' *.asciidoc > full-outline.asciidoc
