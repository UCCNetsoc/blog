FROM jguyomard/hugo-builder:0.55
LABEL maintainer="netsoc@uccsocieties.ie"
COPY . /

ENV VIRTUAL_PROTO="http"
ENV VIRTUAL_HOST="blog.netsoc.co"
ENV VIRTUAL_PORT=80

WORKDIR /
CMD hugo server --bind=0.0.0.0 --baseURL="$VIRTUAL_PROTO://$VIRTUAL_HOST" --watch=false --environment production --port $VIRTUAL_PORT
