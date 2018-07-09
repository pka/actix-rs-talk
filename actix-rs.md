% actix.rs
% Pirmin Kalberer @implgeo
% Rust Zurich, 11. Juli 2018

# About me

## My language timeline

..

## Sourcepole

* Geospatial software
  (C++, Python, React, Ruby on Rails, ...)
* Creating maps with Rust!

# Rust Web Frameworks

## Rust Web Frameworks

* Rocket
  - Nice API
  - Requires Nightly
* XXX
  - Asynchrounous

## Sync vs. Async

...

## Benchmark 1/5

* Bench 1

## Actix Results

* xxx

## Benchmark 2/5

* Bench 1

## ...


# actix.rs

##

`![](https://actix.rs/img/logo-large.png)`

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

## HTTP Client API

```Rust
use actix_web::client;

fn main() {
    tokio::run({
        client::get("http://www.rust-lang.org")   // <- Create request builder
            .header("User-Agent", "Actix-web")
            .finish().unwrap()
            .send()                               // <- Send http request
            .map_err(|_| ())
            .and_then(|response| {                // <- server http response
                println!("Response: {:?}", response);
                Ok(())
            })
    });
}
```


## Middleware - CORS

```Rust
let app = App::new().configure(|app| {
    Cors::for_app(app) // <- Construct CORS middleware builder
        .allowed_origin("https://www.rust-lang.org/")
        .allowed_methods(vec!["GET", "POST"])
        .allowed_headers(vec![http::header::AUTHORIZATION, http::header::ACCEPT])
        .allowed_header(http::header::CONTENT_TYPE)
        .max_age(3600)
        .resource(/* ... */)
        .register()
});
```

## Middleware - CORS (allow all)

```Rust
let app = App::new().configure(|app| {
    Cors::for_app(app) // <- Construct CORS middleware builder
        .allowed_origin("https://www.rust-lang.org/")
FIXME
        .resource(/* ... */)
        .register()
});
```

## Middleware - CSRF

```Rust
let app = App::new()
    .middleware(
        csrf::CsrfFilter::new().allowed_origin("https://www.example.com"),
    )
    .resource("/", |r| {

```

Origin Header based.

## Middleware - User Sessions

```Rust
fn index(req: HttpRequest) -> Result<&'static str> {
    // access session data
    if let Some(count) = req.session().get::<i32>("counter")? {
        println!("SESSION value: {}", count);
        req.session().set("counter", count+1)?;
    } else {
        req.session().set("counter", 1)?;
    }

    Ok("Welcome!")
}

fn main() {
    actix::System::run(|| {
        server::new(
          || App::new().middleware(
              SessionStorage::new(          // <- create session middleware
                CookieSessionBackend::signed(&[0; 32]) // <- create signed cookie session backend
                    .secure(false)
             )))
            .bind("127.0.0.1:59880").unwrap()
            .start();
    });
}

```

* Built-in: Session Cookie
* Other implementations must implement `SessionBackend`

## Middleware - Identity handling

```Rust
fn index(req: HttpRequest) -> Result<String> {
    // access request identity
    if let Some(id) = req.identity() {
        Ok(format!("Welcome! {}", id))
    } else {
        Ok("Welcome Anonymous!".to_owned())
    }
}

fn login(mut req: HttpRequest) -> HttpResponse {
    req.remember("User1".to_owned()); // <- remember identity
    HttpResponse::Ok().finish()
}

fn logout(mut req: HttpRequest) -> HttpResponse {
    req.forget(); // <- remove identity
    HttpResponse::Ok().finish()
}

fn main() {
    let app = App::new().middleware(IdentityService::new(
        // <- create identity middleware
        CookieIdentityPolicy::new(&[0; 32])    // <- create cookie session backend
              .name("auth-cookie")
              .secure(false),
    ));
}
```

* Built-in: Cookie based identity
* Other implementations must implement `RequestIdentity`

## Static file handler

```Rust
use actix_web::{fs, App};

fn main() {
    let app = App::new()
        .handler("/static", fs::StaticFiles::new("."))
        .finish();
}
```

## Testing support

```Rust
fn index(req: HttpRequest) -> HttpResponse {
    if let Some(hdr) = req.headers().get(header::CONTENT_TYPE) {
        HttpResponse::Ok().into()
    } else {
        HttpResponse::BadRequest().into()
    }
}

fn main() {
    let resp = TestRequest::with_header("content-type", "text/plain")
        .run(index)
        .unwrap();
    assert_eq!(resp.status(), StatusCode::OK);

    let resp = TestRequest::default().run(index).unwrap();
    assert_eq!(resp.status(), StatusCode::BAD_REQUEST);
}
```

## JSON in requests

```Rust
#[derive(Deserialize)]
struct Info {
    username: String,
}

/// deserialize `Info` from request's body
fn index(info: Json<Info>) -> Result<String> {
    Ok(format!("Welcome {}!", info.username))
}

fn main() {
    let app = App::new().resource(
       "/index.html",
       |r| r.method(http::Method::POST).with(index));  // <- use `with` extractor
}
```

## JSON in responses

```Rust
#[derive(Serialize)]
struct MyObj {
    name: String,
}

fn index(req: HttpRequest) -> Result<Json<MyObj>> {
    Ok(Json(MyObj {
        name: req.match_info().query("name")?,
    }))
}
```

## Path info extraction

```Rust
/// extract path info from "/{username}/{count}/index.html" url
/// {username} - deserializes to a String
/// {count} -  - deserializes to a u32
fn index(info: Path<(String, u32)>) -> Result<String> {
    Ok(format!("Welcome {}! {}", info.0, info.1))
}

fn main() {
    let app = App::new().resource(
        "/{username}/{count}/index.html", // <- define path parameters
        |r| r.method(http::Method::GET).with(index),
    ); // <- use `with` extractor
}
```

## Path info extraction with structs

```Rust
#[derive(Deserialize)]
struct Info {
    username: String,
}

/// extract path info using serde
fn index(info: Path<Info>) -> Result<String> {
    Ok(format!("Welcome {}!", info.username))
}

```


## Query parameter extraction


```Rust
#[derive(Deserialize)]
struct Info {
    username: String,
}

// use `with` extractor for query info
// this handler get called only if request's query contains `username` field
fn index(info: Query<Info>) -> String {
    format!("Welcome {}!", info.username)
}

fn main() {
    let app = App::new().resource(
       "/index.html",
       |r| r.method(http::Method::GET).with(index)); // <- use `with` extractor
}
```


## .

```Rust
```


## .

```Rust
```


## .

```Rust
```


## actix

## Actors


# Real World Applications

## Fundstelleninventar

* JsonAPI served with Actix
* DB access with Diesel
* React client app

## Time tracking UI

* JsonAPI served with Actix
* DB access with Diesel
* React client app

## t-rex

* Vector Tile Server
* Command line and web server
* Actix-Web + Actix (planned)
* Integrated web app
* PostGIS + GDAL data sources
* https://t-rex.tileserver.ch/
