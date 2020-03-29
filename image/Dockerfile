FROM python:3

RUN pip install moto[server]==1.3.14

ENV TEST_SERVER_MODE=true
ENV AWS_ACCESS_KEY_ID=server_key
ENV AWS_SECRET_ACCESS_KEY=server_secret
ENV PORT=5000

EXPOSE ${PORT}

CMD ["moto_server", "-p${PORT}", "-H0.0.0.0"]