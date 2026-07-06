FROM golang:1.22-alpine AS build
WORKDIR /src
COPY go.mod ./
COPY main.go ./
RUN CGO_ENABLED=0 GOOS=linux go build -trimpath -ldflags="-s -w" -o /out/notification .

FROM gcr.io/distroless/static-debian12:nonroot
COPY --from=build /out/notification /notification
EXPOSE 8082
USER nonroot:nonroot
ENTRYPOINT ["/notification"]
