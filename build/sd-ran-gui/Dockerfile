FROM nginx:stable-alpine
COPY web/sd-ran-gui/dist/sd-ran-gui /usr/share/nginx/html
COPY build/sd-ran-gui/docker-entrypoint.sh /usr/local/bin
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["nginx", "-g daemon off;"]
EXPOSE 80
