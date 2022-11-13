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

Then run it with `bootup` (just like rackup):

```ruby
chmod +x ./bin/bootup
./bin/bootup
```
