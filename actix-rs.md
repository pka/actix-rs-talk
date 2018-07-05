% actix.rs
% Pirmin Kalberer @implgeo
% Rust Zurich, 11. Juli 2018

# About me

## My language timeline

## Sourcepole

* Geospatial software
  (C++, Python, React, Ruby on Rails, ...)
* Creating maps with Rust!

# actix.rs

##

![](https://actix.rs/img/logo-large.png)

## actix-web

* Supported HTTP/1.x and HTTP/2.0 protocols
* Streaming and pipelining
* Keep-alive and slow requests handling
* Client/server WebSockets support
* Transparent content compression/decompression (br, gzip, deflate)
* Configurable request routing

## actix-web

* Graceful server shutdown
* Multipart streams
* Static assets
* SSL support with OpenSSL or native-tls
* Middlewares (Logger, Session, Redis sessions, DefaultHeaders, CORS, CSRF)
* Includes an asynchronous HTTP client
* Built on top of Actix actor framework

## Sample application

```Rust
extern crate actix_web;
use actix_web::{server, App, HttpRequest, Responder};

fn greet(req: HttpRequest) -> impl Responder {
    let to = req.match_info().get("name").unwrap_or("World");
    format!("Hello {}!", to)
}

fn main() {
    server::new(|| {
        App::new()
            .resource("/", |r| r.f(greet))
            .resource("/{name}", |r| r.f(greet))
    })
    .bind("127.0.0.1:8000")
    .expect("Can not bind to port 8000")
    .run();
}
```

## Responders

```Rust
#[derive(Serialize)]
struct Measurement {
    temperature: f32,
}

fn hello_world() -> impl Responder {
    "Hello World!"
}

fn current_temperature(_req: HttpRequest) -> impl Responder {
    Json(Measurement { temperature: 42.3 })
}
```

## Extractors

```Rust
#[derive(Deserialize)]
struct Event {
    timestamp: f64,
    kind: String,
    tags: Vec<String>,
}

fn capture_event(evt: Json<Event>) -> impl Responder {
    let id = store_event_in_db(evt.timestamp, evt.kind, evt.tags);
    format!("got event {}", id)
}
```

## Form handling

```Rust
#[derive(Deserialize)]
struct Register {
    username: String,
    country: String,
}

fn register(data: Form<Register>) -> impl Responder {
    format!("Hello {} from {}!", data.username, data.country)
}
```

## Request routing

```Rust
fn index(req: HttpRequest) -> impl Responder {
    "Hello from the index page"
}

fn hello(path: Path<String>) -> impl Responder {
    format!("Hello {}!", *path)
}

fn main() {
    App::new()
        .resource("/", |r| r.method(Method::Get).with(index))
        .resource("/hello/{name}", |r| r.method(Method::Get).with(hello))
        .finish();
}
```

## actix

## Actors

## Asyncronous vs. Multi-Threading

....
