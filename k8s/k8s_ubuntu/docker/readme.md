
## ELK docker compose

https://github.com/acidDrain/elk-docker-compose

## elasticsearch docker file
```dockerfile
FROM docker.elastic.co/elasticsearch/elasticsearch:7.4.1

COPY --chown=elasticsearch:elasticsearch elasticsearch.yml /usr/share/elasticsearch/config/

USER root
RUN chmod -R 777 /usr/share/elasticsearch/data
USER elasticsearch

```