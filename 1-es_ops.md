
http://localhost:5601/app/kibana#/dev_tools/console

GET _cluster/health

GET _cat/nodes?v

GET _cat/shards?v

#
# Create index
#
```
DELETE /products

PUT /products
{
  "settings": {
    "number_of_shards": 2,
    "number_of_replicas": 2
  }
}

```
#
# Create Doc
#
```
POST /products/_doc
{
  "name": "Coffee Maker",
  "price": 64,
  "in_stock": 10
}


PUT /products/_doc/100
{
  "name": "Toaster",
  "price": 49,
  "in_stock": 4
}

```
#
# Query
#
```
GET /products/_doc/100


GET /products/_search
{
  "query": {
    "match_all": {}
  }
}


GET /product/_search
{
  "query": {
    "match": {
      "description": "TEST"
    }
  }
}
```

#
# Update Doc
#
```
POST  /products/_update/100
{
  "doc": {
    "in_stock": 3
  }
}


POST  /products/_update/100
{
  "doc": {
    "tags": ["electronics"]
  }
}



POST  /products/_update/100
{
  "script": {
    "source": "ctx._source.in_stock--"
  }
}



POST  /products/_update/100
{
  "script": {
    "source": "ctx._source.in_stock = 10"
  }
}



POST  /products/_update/100
{
  "script": {
    "source": "ctx._source.in_stock -= params.quantity",
    "params": {
      "quantity":4
    }
  }
}



POST  /products/_update/100
{
  "script": {
    "source": """
      if (ctx._source.in_stock == 0) {
        ctx.op = 'noop';
      }

      ctx._source.in_stock --;
    """
  }
}



POST  /products/_update/100
{
  "script": {
    "source": """
      if (ctx._source.in_stock > 0) {
          ctx._source.in_stock --;
      }

    """
  }
}



POST  /products/_update/100
{
  "script": {
    "source": """
      if (ctx._source.in_stock <= 1) {
        ctx.op = 'delete';
      }

      ctx._source.in_stock --;
    """
  }
}


POST  /products/_update/101
{
  "script": {
    "source": "ctx._source.in_stock++"
  },
  "upsert": {
    "name": "Balender",
    "price": 399,
    "in_stock": 5
  }
}
```

#
# Replace Doc
#

```
PUT  /products/_doc/100
{
    "price" : 4900,
    "in_stock" : 50
}

```
#
# Delete Doc
#
```
DELETE  /products/_doc/101

```

#
# Versioning Update
#
```
POST /products/_update/100?if_primary_term=1&if_seq_no=12
{
  "doc": {
    "in_stock": 12
  }
}

```
#
# Update Multiple docments
#
```
POST /products/_update_by_query
{
  "conflicts": "proceed",
  "script": {
    "source": "ctx._source.in_stock--"
  },
  "query": {
    "match_all": {

    }
  }
}
```
#
# Delete Multiple docments
#
```
POST /products/_delete_by_query
{
  "query": {
     "match_all": {}
  }
}

```
#
# _bulk request
#
```
# Content-Type: application/x-ndjson


POST /_bulk
{"index": { "_index": "products", "_id":200 } }
{ "name": "Machine", "price": 199, "in_stock": 5 }
{"create": {"_index": "products", "_id":201}}
{ "name": "Milk", "price": 149, "in_stock": 14 }



POST /products/_bulk
{"update": { "_id":201 }}
{ "doc": { "price": 129 }}
{"delete": { "_id":200 } }

```
#
# Import Data From File by Curl
#
```

{"index":{"_id":1}}
{"name":"Wine - Maipo Valle Cabernet","price":152,"in_stock":38,"sold":47,"tags":["Alcohol","Wine"],"description":"Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem. Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat. Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede. Morbi porttitor lorem id ligula.","is_active":true,"created":"2004\/05\/13"}
{"index":{"_id":2}}
{"name":"Tart Shells - Savory","price":99,"in_stock":10,"sold":430,"tags":[],"description":"Pellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.","is_active":true,"created":"2007\/10\/14"}



curl -H "Content-Type: application/x-ndjson" -XPOST \
http://localhost:9200/products/_bulk \
--data-binary "@products-bulk.json"


```
#
# Maping
#
```
GET /products/_mapping

# create index with mapping

PUT /product
{
  "mappings": {
    "properties": {
      "in_stock": {
        "type": "integer"
      },
      "is_active": {
        "type": "boolean"
      },
      "price": {
        "type": "integer"
      },
      "sold": {
        "type": "long"
      }
    }
  }
}


PUT /department
{
  "mappings": {
    "properties": {
      "name": {
        "type": "text"
      },
      "employees": {
        "type": "nested"
      }
    }
  }
}

# add new mapping

PUT /products/_mapping
{
  "properties": {
    "discount": {
      "type": "double"
    }
  }
}

PUT /product/_mapping
{
  "properties": {
    "description": {
      "type": "text"
    },
    "name": {
      "type": "text",
      "fields": {
        "keyword": {
          "type": "keyword"
        }
      }
    },
     "tags": {
      "type": "text",
      "fields": {
        "keyword": {
          "type": "keyword"
        }
      }
    }
  }
}


PUT /product/_mapping
{
  "properties": {
    "created": {
      "type": "date",
       "format": "yyyy/MM/dd HH:mm:ss||yyyy/MM/dd"
    }
  }
}

```

curl -H "Content-Type: application/x-ndjson" -XPOST \
http://localhost:9200/product/_bulk \
--data-binary "@products-bulk.json"


curl -XGET "http://localhost:9200/recipe/_search?format=yaml" \
 -H 'Content-Type: application/json' \
 -d'{  "query": {    "match": {      "title": "Pasta or Spaghetti With Capers"    }  }}'


curl -XGET "http://localhost:9200/recipe/_search?pretty" \
 -H 'Content-Type: application/json' \
 -d'{  "query": {    "match": {      "title": "Pasta or Spaghetti With Capers"    }  }}'
