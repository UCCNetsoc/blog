FROM jguyomard/hugo-builder:0.55
LABEL maintainer="netsoc@uccsocieties.ie"
COPY . /

ENV BASE_URL="http://blog.netsoc.co:80"

WORKDIR /
CMD hugo server --bind=0.0.0.0 --baseURL="$BASE_URL" --watch=false --appendPort=false --environment production --port 80
