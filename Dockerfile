# Stage 1 - Build base image with nginx
ARG BASE_REGISTRY=registry.access.redhat.com
ARG BASE_IMAGE=ubi8/ubi-minimal
ARG BASE_TAG=latest

FROM ${BASE_REGISTRY}/${BASE_IMAGE}:${BASE_TAG} as base

ARG BASE_REGISTRY
ARG BASE_IMAGE

RUN if [ "$BASE_REGISTRY/$BASE_IMAGE" == "registry.access.redhat.com/ubi8/ubi-minimal" ]; then \
        microdnf install nginx && \
        microdnf clean all && \
        rm -f \
            /usr/share/nginx/modules/mod-http-image-filter.conf \
            /usr/share/nginx/modules/mod-http-perl.conf \
            /usr/share/nginx/modules/mod-http-xslt-filter.conf \
            /usr/share/nginx/modules/mod-mail.conf && \
        rm -f \
            /usr/share/nginx/modules/ngx_http_image_filter_module.so \
            /usr/share/nginx/modules/ngx_http_perl_module.so \
            /usr/share/nginx/modules/ngx_http_xslt_filter_module.so \
            /usr/share/nginx/modules/2019 ngx_mail_module.so && \
        ln -sf /dev/stdout /var/log/nginx/access.log && \
        ln -sf /dev/stderr /var/log/nginx/error.log && \
        chmod -R o-rwx /etc/nginx && \
        rm -rf /usr/share/nginx/html/ && \
        echo 'OK' > /usr/share/nginx/html/index.html && \
        echo 'The page you are looking for is temporarily unavailable. Please try again later.' > /usr/share/nginx/html/50x.html && \
        echo 'The page you are looking for is not found.' > /usr/share/nginx/html/40x.html; \
    fi

COPY nginx.conf /etc/nginx/
RUN chmod -R ug-x,o-rwx /etc/nginx/nginx.conf

# Stage 2 - Build and Copy files

# Stage 3 - the production environment
FROM base as final

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
