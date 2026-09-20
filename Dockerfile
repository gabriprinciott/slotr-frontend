FROM ghcr.io/gmeligio/flutter-android:3.47.5 AS build

WORKDIR /app

RUN flutter config --enable-web

COPY --chown=flutter:flutter pubspec.* ./

RUN flutter pub get

COPY --chown=flutter:flutter . .

RUN flutter create . --platforms web

ARG BASE_URL=""
ARG WS_URL=""

RUN echo "BASE_URL=${BASE_URL:-}" >> .env
RUN echo "WS_URL=${WS_URL:-}" >> .env

RUN flutter build web --release \
    --dart-define=FLUTTER_WEB_USE_SKIA=false \
    --dart-define=FLUTTER_WEB_USE_SKWASM=false \
    --no-source-maps

FROM nginx:1.27-alpine

RUN rm -rf /usr/share/nginx/html/*

COPY --from=build /app/build/web /usr/share/nginx/html

COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80 3000

CMD ["nginx", "-g", "daemon off;"]