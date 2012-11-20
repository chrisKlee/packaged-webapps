#!/bin/bash
if [ -z "$1" ]
then
        echo "Need a pub date, like '22 Nov 2012'"
       	exit 1
fi
tempfoo=`basename $0`
TMPFILE=`mktemp -q /tmp/${tempfoo}.XXXXXX`
if [ $? -ne 0 ]; then
       echo "$0: Can't create temp file, exiting..."
       exit 1
fi
anolis --pubdate="$1" --output-encoding=utf8 --omit-optional-tags --quote-attr-values --w3c-compat --w3c-shortname="widgets" --filter=".dontpublish, .now3c" --w3c-status=REC Overview.src.html $TMPFILE

git checkout gh-pages
cp $TMPFILE index.html

#dependency: html5 tidy https://github.com/w3c/tidy-html5
if command -v tidy >/dev/null 2>&1; then
	tidy -q -utf8 -i -o index.html index.html
fi

git commit -m "Regenerated file"
git push

#dependency: sudo gem install terminal-notifier
if command -v terminal-notifier >/dev/null 2>&1; then
    terminal-notifier -message "Finished processing ${PWD##*/}" -title "Anolis Processing done" -execute "open $PWD/index.html" -group "Anolis"
fi
git checkout master