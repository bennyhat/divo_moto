defmodule DivoMotoTest do
  use ExUnit.Case

  @zookeeper %{
    zookeeper: %{
      image: "wurstmeister/zookeeper:latest",
      ports: ["2181:2181"],
      healthcheck: %{
        test: ["CMD-SHELL", "echo ruok | nc -w 2 zookeeper 2181"],
        interval: "5s",
        timeout: "10s",
        retries: 3
      }
    }
  }

  describe "produces a moto stack map" do
    test "produces a moto stack map with no specified environment variables" do
      expected =
        %{
          moto: %{
            image: "wurstmeister/moto:latest",
            ports: ["9092:9092"],
            environment: [
              "moto_AUTO_CREATE_TOPICS_ENABLE=true",
              "moto_ADVERTISED_LISTENERS=INSIDE://:9094,OUTSIDE://localhost:9092",
              "moto_LISTENER_SECURITY_PROTOCOL_MAP=INSIDE:PLAINTEXT,OUTSIDE:PLAINTEXT",
              "moto_LISTENERS=INSIDE://:9094,OUTSIDE://:9092",
              "moto_INTER_BROKER_LISTENER_NAME=INSIDE",
              "moto_CREATE_TOPICS=clusterready:1:1",
              "moto_ZOOKEEPER_CONNECT=zookeeper:2181"
            ],
            depends_on: ["zookeeper"],
            healthcheck: %{
              test: ["CMD-SHELL", "moto-topics.sh --zookeeper zookeeper:2181 --list | grep clusterready || exit 1"],
              interval: "10s",
              timeout: "20s",
              retries: 3
            }
          }
        }
        |> Map.merge(@zookeeper)

      actual = DivoMoto.gen_stack([])

      assert actual == expected
    end

    test "produces a moto stack map with supplied environment config" do
      expected =
        %{
          moto: %{
            image: "wurstmeister/moto:latest",
            ports: ["9092:9092"],
            environment: [
              "moto_AUTO_CREATE_TOPICS_ENABLE=true",
              "moto_ADVERTISED_LISTENERS=INSIDE://:9094,OUTSIDE://ci-host:9092",
              "moto_LISTENER_SECURITY_PROTOCOL_MAP=INSIDE:PLAINTEXT,OUTSIDE:PLAINTEXT",
              "moto_LISTENERS=INSIDE://:9094,OUTSIDE://:9092",
              "moto_INTER_BROKER_LISTENER_NAME=INSIDE",
              "moto_CREATE_TOPICS=streaming-data:1:1",
              "moto_ZOOKEEPER_CONNECT=zookeeper:2181"
            ],
            depends_on: ["zookeeper"],
            healthcheck: %{
              test: ["CMD-SHELL", "moto-topics.sh --zookeeper zookeeper:2181 --list | grep streaming-data || exit 1"],
              interval: "10s",
              timeout: "20s",
              retries: 3
            }
          }
        }
        |> Map.merge(@zookeeper)

      actual = DivoMoto.gen_stack(auto_topic: true, outside_host: "ci-host", create_topics: "streaming-data:1:1")

      assert actual == expected
    end
  end
end
