# KSQL

https://www.elastic.co/guide/en/kibana/current/kuery-query.html


# Setup data

https://github.com/amliuyong/esNote/blob/master/test-data.zip

## Create index template for index: `access-logs*` and `orders*`



PUT /_template/access-logs
```json
{
  "index_patterns": ["access-logs*"],
  "settings": {
    "index.mapping.coerce": false
  }, 
  "mappings": {
    "dynamic": false,
    "properties": {
      "@timestamp": { "type": "date" },
      "message": { "type": "text" },
      "event.dataset": { "type": "keyword" },
      "hour_of_day": { "type": "short" },
      "http.request.method": { "type": "keyword" },
      "http.request.referrer": { "type": "keyword" },
      "http.response.body.bytes": { "type": "long" },
      "http.response.status_code": { "type": "long" },
      "http.version": { "type": "keyword" },
      "url.fragment": { "type": "keyword" },
      "url.path": { "type": "keyword" },
      "url.query": { "type": "keyword" },
      "url.scheme": { "type": "keyword" },
      "url.username": { "type": "keyword" },
      "url.original": {
        "type": "keyword",
        "fields": {
          "text": {
            "type": "text",
            "norms": false
          }
        }
      },
      "client.address": { "type": "keyword" },
      "client.ip": { "type": "ip" },
      "client.geo.city_name": { "type": "keyword" },
      "client.geo.continent_name": { "type": "keyword" },
      "client.geo.country_iso_code": { "type": "keyword" },
      "client.geo.country_name": { "type": "keyword" },
      "client.geo.location": { "type": "geo_point" },
      "client.geo.region_iso_code": { "type": "keyword" },
      "client.geo.region_name": { "type": "keyword" },
      "user_agent.device.name": { "type": "keyword" },
      "user_agent.name": { "type": "keyword" },
      "user_agent.version": { "type": "keyword" },
      "user_agent.original": {
        "type": "keyword",
        "fields": {
          "text": {
            "type": "text",
            "norms": false
          }
        }
      },
      "user_agent.os.version": { "type": "keyword" },
      "user_agent.os.name": {
        "type": "keyword",
        "fields": {
          "text": {
            "type": "text",
            "norms": false
          }
        }
      },
      "user_agent.os.full": {
        "type": "keyword",
        "fields": {
          "text": {
            "type": "text",
            "norms": false
          }
        }
      }
    }
  }
}
```
PUT /_template/orders
```json
{
  "index_patterns": ["orders*"],
  "settings": {
    "index.mapping.coerce": false
  }, 
  "mappings": {
    "dynamic": false,
    "properties": {
      "@timestamp": { "type": "date" },
      "id": { "type": "keyword" },
      "product": {
        "properties": {
          "id": { "type": "keyword" },
          "name": { "type": "keyword" },
          "price": { "type": "float" },
          "brand": { "type": "keyword" },
          "category": { "type": "keyword" }
        }
      },
      "customer.id": { "type": "keyword" },
      "customer.age": { "type": "short" },
      "customer.gender": { "type": "keyword" },
      "customer.name": { "type": "keyword" },
      "customer.email": { "type": "keyword" },
      "channel": { "type": "keyword" },
      "store": { "type": "keyword" },
      "salesman.id": { "type": "keyword" },
      "salesman.name": { "type": "keyword" },
      "discount": { "type": "float" },
      "total": { "type": "float" }
    }
  }
}

```
## Sample Data

### access-logs
```json
{"index":{"_index":"access-logs-2020-03"}}
{"@timestamp":"2020-03-01T10:22:00.000Z","http":{"version":"2.0","request":{"method":"get","referrer":"https://example.com/products/craftsman-v60-cordless-lawn-mower"},"response":{"body":{"bytes":5769},"status_code":200}},"client":{"geo":{"country_name":"China","region_iso_code":"JS","region_name":"Jiangsu","location":{"lat":32.0617,"lon":118.7778},"country_iso_code":"CN"},"address":"58.220.152.212","ip":"58.220.152.212"},"message":"58.220.152.212 - - [01/Mar/2020:10:22:00 +0000] \"GET /products/craftsman-v20-cordless-chainsaw HTTP/2.0\" 200 5769 \"https://example.com/products/craftsman-v60-cordless-lawn-mower\" \"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/59.0.3071.115 Safari/537.36\"","dataset":"nginx.access","url":{"path":"/products/craftsman-v20-cordless-chainsaw","original":"/products/craftsman-v20-cordless-chainsaw","username":"-"},"user_agent":{"name":"Chrome","original":"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/59.0.3071.115 Safari/537.36","os":{"name":"Mac OS X","version":"10.12","full":"Mac OS X 10.12"},"version":"59.0.3071","device":{"name":"Other"}},"hour_of_day":10}
```
```json
{
    "@timestamp": "2020-03-01T10:22:00.000Z",
    "http": {
        "version": "2.0",
        "request": {
            "method": "get",
            "referrer": "https://example.com/products/craftsman-v60-cordless-lawn-mower"
        },
        "response": {
            "body": {
                "bytes": 5769
            },
            "status_code": 200
        }
    },
    "client": {
        "geo": {
            "country_name": "China",
            "region_iso_code": "JS",
            "region_name": "Jiangsu",
            "location": {
                "lat": 32.0617,
                "lon": 118.7778
            },
            "country_iso_code": "CN"
        },
        "address": "58.220.152.212",
        "ip": "58.220.152.212"
    },
    "message": "58.220.152.212 - - [01/Mar/2020:10:22:00 +0000] \"GET /products/craftsman-v20-cordless-chainsaw HTTP/2.0\" 200 5769 \"https://example.com/products/craftsman-v60-cordless-lawn-mower\" \"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/59.0.3071.115 Safari/537.36\"",
    "dataset": "nginx.access",
    "url": {
        "path": "/products/craftsman-v20-cordless-chainsaw",
        "original": "/products/craftsman-v20-cordless-chainsaw",
        "username": "-"
    },
    "user_agent": {
        "name": "Chrome",
        "original": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/59.0.3071.115 Safari/537.36",
        "os": {
            "name": "Mac OS X",
            "version": "10.12",
            "full": "Mac OS X 10.12"
        },
        "version": "59.0.3071",
        "device": {
            "name": "Other"
        }
    },
    "hour_of_day": 10
}

```

### orders
```json
{"index":{"_index":"orders"}}
{"@timestamp":"2020-01-01T00:00:00+00:00","id":"6hWtxnYfrwjixlNg","channel":"online","product":{"id":"44805907","name":"Stanley 194749 Waterproof Toolbox","price":29.99,"brand":"Stanley","category":"Toolboxes"},"total":29.99,"customer":{"id":"BEsecBC1u5jQ65E5","name":"Scott Mcbride","age":51,"gender":"M","email":"scott.mcbride@gmail.com"}}
```
```json
{
    "@timestamp": "2020-01-01T00:00:00+00:00",
    "id": "6hWtxnYfrwjixlNg",
    "channel": "online",
    "product": {
        "id": "44805907",
        "name": "Stanley 194749 Waterproof Toolbox",
        "price": 29.99,
        "brand": "Stanley",
        "category": "Toolboxes"
    },
    "total": 29.99,
    "customer": {
        "id": "BEsecBC1u5jQ65E5",
        "name": "Scott Mcbride",
        "age": 51,
        "gender": "M",
        "email": "scott.mcbride@gmail.com"
    }
}
```
### Kibana and the `nested` datatype

- kibana has limited support for the `nested` datatype
- full support is a highly requested feature
- on hte roadmap, but won't be added anytime soon
- without it, we would get incorrect results in some scenarios
- repmapping documents might not be feasible
- `nested` fields can be used, but there is limited visualization support
- our documents don't use `nested` fields for these reasons

### load data by curl
```bash
cd elasticSearch/test-data

 nginx-access-logs-2020-01.bulk.ndjson
 nginx-access-logs-2020-02.bulk.ndjson
 nginx-access-logs-2020-03.bulk.ndjson
 orders.bulk.ndjson


curl -H "Content-Type: application/x-ndjson" -XPOST http://localhost:9200/order/_bulk --data-binary "@orders.bulk.ndjson"
curl -H "Content-Type: application/x-ndjson" -XPOST http://localhost:9200/order/_bulk --data-binary "@nginx-access-logs-2020-01.bulk.ndjson"
curl -H "Content-Type: application/x-ndjson" -XPOST http://localhost:9200/order/_bulk --data-binary "@nginx-access-logs-2020-02.bulk.ndjson"
curl -H "Content-Type: application/x-ndjson" -XPOST http://localhost:9200/order/_bulk --data-binary "@nginx-access-logs-2020-03.bulk.ndjson"

```
## show all indeices
```
GET /_cat/indices
```

## Create index patterns

http://localhost:5601/app/management/kibana/indexPatterns


