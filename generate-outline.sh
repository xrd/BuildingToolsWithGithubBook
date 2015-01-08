#!/bin/bash

rm full-outline.asciidoc
for x in `ls chapter*.asciidoc`; do 
    echo "== $x" >> full-outline.asciidoc
    grep -h '===\s\S' $x >> full-outline.asciidoc
done
