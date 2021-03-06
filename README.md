[![Master](https://github.com/bennyhat/divo_moto/workflows/Master/badge.svg)](https://github.com/bennyhat/divo_moto/actions?query=workflow%3AMaster)
[![Hex.pm Version](http://img.shields.io/hexpm/v/divo_moto.svg?style=flat)](https://hex.pm/packages/divo_moto)

# Divo moto

A library implementing the Divo Stack behaviour, providing a pre-configured moto server via docker-compose for integration testing Elixir apps. The cluster is a
multi-service moto compose stack that can be configured with all or specific services.

Requires inclusion of the Divo library in your mix project.

## Installation

The package can be installed by adding `divo` and `divo_moto` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:divo, "~> 1.1"},
    {:divo_moto, "~> 0.1.1"}
  ]
end
```

## Use

In your Mix environment exs file (i.e. config/integration.exs), include the following:
```elixir
config :myapp,
  divo: [
    {DivoMoto, [port: 5000, service: :all, aws_access_key_id: "access_key_id", aws_secret_access_key: "secret_key" ]}
  ]
```

In your integration test specify that you want to use Divo:
```elixir
use Divo
...
```

The resulting stack will create a multi-service moto server exposing port 5000 to the host.

### Configuration

You may omit the configuration arguments to DivoMoto and still have a working stack.

* `port`: An integer that tells moto what port to listen on. Defaults to `5000`

* `service`: An atom representing the service (or all of them) you would like moto to serve for you. See [moto](https://github.com/spulec/moto/blob/master/IMPLEMENTATION_COVERAGE.md) for a full list of services (the names for each section are the service name/atom). Defaults to `:all`.

* `aws_access_key_id`: A string representing the access key id that moto will use to restrict access to its local API. Defaults to `"server_key"`.

* `aws_secret_access_key`: A string representing the secret key that moto will use to restrict access to its local API. Defaults to `"server_secret"`.

* `moto_image_version`: A string representing the moto image ([bennyhat/moto-server](https://hub.docker.com/r/bennyhat/moto-server)) version to use. A list of available versions can be found on their [dockerhub tags page](https://hub.docker.com/r/bennyhat/moto-server/tags). Defaults to `"latest"`.

See [Divo GitHub](https://github.com/smartcitiesdata/divo) or [Divo Hex Documentation](https://hexdocs.pm/divo) for more instructions on using and configuring the Divo library.
See [bennyhat/moto-server](https://hub.docker.com/r/bennyhat/moto-server) for further documentation
on using and configuring the features of this image.

### Example
Below is an example configuration file that configures `Divo` and `DivoMoto` to stand up a multi-service moto server and then configures [ExAws](https://github.com/ex-aws/ex_aws) to point to it.
```elixir
use Mix.Config

access_key_id = "server_key"
secret_access_key = "server_secret"
port = 5000

config :alb_ingress, divo: [
  {DivoMoto,
   [
     port: port,
     service: :all,
     aws_access_key_id: access_key_id,
     aws_secret_access_key: secret_access_key
   ]
  }
]

config :ex_aws,
  debug_requests: true,
  access_key_id: access_key_id,
  secret_access_key: secret_access_key,
  ec2: [
    scheme: "http://",
    host: "localhost",
    port: port
  ],
  elasticloadbalancing: [
    scheme: "http://",
    host: "localhost",
    port: port
  ]
```

## License
Released under [Apache 2 license](https://github.com/bennyhat/divo_moto/blob/master/LICENSE).
