# Mack

Minimum viable rack clone that uses WEBrick as a server. Helpful for knowing the inner workings of rack.

## Usage

Create an app that responds to `call` with a status, headers, and body, exactly like the rack spec.

```ruby
require_relative "./lib/mack"

class App
  def call(env)
    [200, {"Content-Type" => "text/plain"}, ["Hello World"]]
  end
end
```

Configure `./bin/bootup` to use your app.

```ruby
require_relative '../lib/mack'
require_relative '../app'

Mack::Server.start(
  :app => App.new,
  :server => "webrick",
  :host => "localhost",
  :port => 8080
)
```

Only accepts webrick for now, although you can add adapters within `Mack::Adapter`.

Then run it with `bootup` (just like rackup):

```ruby
chmod +x ./bin/bootup
./bin/bootup
```
