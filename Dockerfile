FROM golang:1.24 as build
WORKDIR /
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o /my-app

# Final image
FROM scratch
ENV PORT=1407
EXPOSE $PORT
COPY --from=build /my-app /my-app
ENTRYPOINT ["/my-app"]
