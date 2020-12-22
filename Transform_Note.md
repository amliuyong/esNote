## create index and mappings
```
curl -XPUT "http://localhost:9200/nginx" -H 'Content-Type: application/json' -d ' \
{
  "settings": {
    "number_of_shards": 1,
    "number_of_replicas": 0
  },
  "mappings": {
    "properties": {
      "time": {
        "type": "date",
        "format": "dd/MMM/yyyy:HH:mm:ss Z"
      },
      "remote_ip": {
        "type": "ip"
      },
      "remote_user": {
        "type": "keyword"
      },
      "request": {
        "type": "keyword"
      },
      "response": {
        "type": "keyword"
      },
      "bytes": {
        "type": "long"
      },
      "referrer": {
        "type": "keyword"
      },
      "agent": {
        "type": "keyword"
      }
    }
  }
}'
'
```
#### data row sample
```json
{"time": "04/Jun/2015:07:06:16 +0000", "remote_ip": "80.91.33.133", "remote_user": "-", "request": "GET /downloads/product_1 HTTP/1.1", "response": 304, "bytes": 0, "referrer": "-", "agent": "Debian APT-HTTP/1.3 (0.8.16~exp12ubuntu10.16)"}
```
## load data to ES
```sh
awk '{print "\{\"index\":\{\}\}\n" $0}' nginx_json_logs > nginx_json_logs_bulk

curl -H "Content-Type: application/x-ndjson" -XPOST http://localhost:9200/nginx/_bulk --data-binary "@nginx_json_logs_bulk"


```

### check data to load
```
GET _cat/indices/nginx?v
```
```
GET /nginx/_search
{
  "size": 0,
  "track_total_hits": true
}

```
## _transform/_preview
POST _transform/_preview

```json
{
  "source": {
    "index": "nginx"
  },
  "pivot": {
    "group_by": {
      "ip": {
        "terms": {
          "field": "remote_ip"
        }
      }
    },
    "aggregations": {
      "bytes.avg": {
        "avg": {
          "field": "bytes"
        }
      },
      "bytes.sum": {
        "sum": {
          "field": "bytes"
        }
      },
      "requests.total": {
        "value_count": {
          "field": "_id"
        }
      },
      "requests.last": {
        "scripted_metric": {
          "init_script": "state.timestamp = 0; state.date = ''",
          "map_script": "def doc_date  = doc['time'].getValue().toInstant().toEpochMilli();if (doc_date > state.timestamp){state.timestamp = doc_date;state.date = doc['time'].getValue();}",
          "combine_script": "return state",
          "reduce_script": "def date = '';def timestamp = 0L;for (s in states) {if (s.timestamp > (timestamp)){timestamp = s.timestamp; date = s.date;}} return date"
        }
      },
      "requests.first": {
        "scripted_metric": {
          "init_script": "state.timestamp = 1609455599000L; state.date = ''",
          "map_script": "def doc_date = doc['time'].getValue().toInstant().toEpochMilli();if (doc_date < state.timestamp){state.timestamp = doc_date;state.date = doc['time'].getValue();}",
          "combine_script": "return state",
          "reduce_script": "def date = '';def timestamp = 0L;for (s in states) {if (s.timestamp > (timestamp)){timestamp = s.timestamp; date = s.date;}} return date"
        }
      }
    }
  }
}
```
output: 
```json
{
"preview" : [
    {
      "bytes" : {
        "avg" : 2584.0,
        "sum" : 5168.0
      },
      "ip" : "2.84.217.212",
      "requests" : {
        "total" : 2,
        "last" : "2015-05-17T19:05:40.000Z",
        "first" : "2015-05-17T15:05:25.000Z"
      }
    },
    {
      "bytes" : {
        "avg" : 289.77777777777777,
        "sum" : 5216.0
      },
      "ip" : "2.108.119.198",
      "requests" : {
        "total" : 18,
        "last" : "2015-05-23T14:05:53.000Z",
        "first" : "2015-05-23T14:05:00.000Z"
      }
    },
    ...
]
}
```

