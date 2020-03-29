defmodule DivoMoto do
  @moduledoc """
  Defines a simple moto stack as a
  map compatible with divo for building a docker-compose
  file.
  """
  @behaviour Divo.Stack

  @doc """
  Implements the Divo Stack behaviour to take a
  keyword list of defined variables specific to
  the DivoMoto stack and returns a map describing the
  service definition of zookeeper and moto.
  """
  @impl Divo.Stack
  @spec gen_stack([tuple()]) :: map()
  def gen_stack(envars) do
    port = Keyword.get(envars, :port, 5000)
    service = Keyword.get(envars, :service, :all)
    aws_access_key_id = Keyword.get(envars, :aws_access_key_id, "server_key")
    aws_secret_access_key = Keyword.get(envars, :aws_secret_access_key, "server_secret")
    moto_image_version = Keyword.get(envars, :moto_image_version, "latest")

    command =
      case to_string(service) do
        "all" -> ["moto_server", "-p#{port}", "-H0.0.0.0"]
        service -> ["moto_server", "-p#{port}", "-H0.0.0.0", service]
      end

    %{
      moto_server: %{
        image: "bennyhat/moto-server:#{moto_image_version}",
        environment: [
          "PORT=#{port}",
          "AWS_ACCESS_KEY_ID=#{aws_access_key_id}",
          "AWS_SECRET_ACCESS_KEY=#{aws_secret_access_key}"
        ],
        ports: [
          "#{port}:#{port}"
        ],
        healthcheck: %{
          test: ["CMD", "curl", "-f", "http://localhost:#{port}/moto-api/"],
          interval: "5s",
          timeout: "10s",
          retries: 3
        },
        command: command
      }
    }
  end
end
