#!/bin/sh
set -e

if [ "$1" = 'nginx' ]; then
	echo "Testing for Google API Key"
	if [ -z "$GOOGLE_API_KEY" ]; then
		echo "No Google API Key found"
		exit 2
	fi
	envsubst < /usr/share/nginx/html/index.html > /usr/share/nginx/html/index.subst
	cp /usr/share/nginx/html/index.subst /usr/share/nginx/html/index.html
fi

exec "$@"
