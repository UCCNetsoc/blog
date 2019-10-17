FROM jguyomard/hugo-builder:0.55
LABEL maintainer="netsoc@uccsocieties.ie"
COPY . /src


ENV VIRTUAL_HOST="blog.netsoc.co"


WORKDIR /src
CMD hugo server --bind=0.0.0.0 --baseURL="${VIRTUAL_HOST}" --environment production --port 80
