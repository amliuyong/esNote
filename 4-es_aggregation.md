# laod test data from file

```
curl -H "Content-Type: application/x-ndjson" -XPOST http://localhost:9200/order/_bulk --data-binary "@orders-bulk.json"

```

```
PUT /order/_mapping {
    "properties": {
        "status": {
            "type": "text",
            "fielddata": true
        }
    }
}

```
## One doc 
```json
{
    "purchased_at": "2016-07-10T16:52:43Z",
    "lines": [{
            "product_id": 6,
            "amount": 71.32,
            "quantity": 1
        },
        {
            "product_id": 3,
            "amount": 58.96,
            "quantity": 3
        },
        {
            "product_id": 1,
            "amount": 29.8,
            "quantity": 3
        }
    ],
    "total_amount": 160.08,
    "salesman": {
        "id": 11,
        "name": "Matthus Mitkcov"
    },
    "sales_channel": "store",
    "status": "processed"
}
```


## sum /avg /max /min
```
GET /order/_search {
    "size": 0,
    "aggs": {
        "total_sales": {
            "sum": {
                "field": "total_amount"
            }
        },
        "avg_sales": {
            "avg": {
                "field": "total_amount"
            }
        },
        "max_sales": {
            "max": {
                "field": "total_amount"
            }
        },
        "min_sales": {
            "min": {
                "field": "total_amount"
            }
        }
    }
}
```

## cardinality - distinct count()
```
GET /order/_search {
    "size": 0,
    "aggs": {
        "total_salesmen ": {
            "cardinality": {
                "field": "salesman.id"
            }
        }
    }
}
```


## value count
```
GET /order/_search {
    "size": 0,
    "aggs": {
        "value_count": {
            "value_count": {
                "field": "total_amount"
            }
        }
    }
}
```


## stats
```
GET /order/_search {
        "size": 0,
        "aggs": {
            "amount_stats": {
                "stats": {
                    "field": "total_amount"
                }
            }
        }
    } 
    
==>

aggregations " : {
"amount_stats": {
    "count": 1000,
    "min": 10.270000457763672,
    "max": 281.7699890136719,
    "avg": 109.20960997009277,
    "sum": 109209.60997009277
}
}
```


#
# Bucket aggs
#

### set status to fielddata 
```
PUT /order/_mapping 
{
    "properties": {
        "status": {
            "type": "text",
            "fielddata": true
        }
    }
}
```
## group by status

```
GET /order/_search 
{
        "size": 0,
        "aggs": {
            "status_terms": {
                "terms": {
                    "field": "status"
                }
            }
        }
    }

    ==>

    {
        "buckets": [{
                "key": "processed",
                "doc_count": 209
            },
            {
                "key": "completed",
                "doc_count": 204
            },
            {
                "key": "pending",
                "doc_count": 199
            },
            {
                "key": "cancelled",
                "doc_count": 196
            },
            {
                "key": "confirmed",
                "doc_count": 192
            }
        ]
    }
```

### handle missing value
```
GET /order/_search
{
  "size": 0,
  "aggs": {
    "status_terms": {
      "terms": {
        "field": "status",
        "missing": "N/A",
        "min_doc_count": 0,
        "order": {
          "_key": "asc"
        }
      }
    }
  }
}

===>
{
"aggregations" : {
    "status_terms" : {
      "doc_count_error_upper_bound" : 0,
      "sum_other_doc_count" : 0,
      "buckets" : [
        {
          "key" : "N/A",
          "doc_count" : 0
        },
        {
          "key" : "cancelled",
          "doc_count" : 196
        },
        {
          "key" : "completed",
          "doc_count" : 204
        },
        {
          "key" : "confirmed",
          "doc_count" : 192
        },
        {
          "key" : "pending",
          "doc_count" : 199
        },
        {
          "key" : "processed",
          "doc_count" : 209
        }
      ]
    }
  }
}

```

## sub aggs
```
GET /order/_search
{
  "size": 0,
  "aggs": {
    "status_terms": {
      "terms": {
        "field": "status"
      },
      "aggs": {
        "status_stats": {
          "stats": {
            "field": "total_amount"
          }
        }
      }
    }
  }
}

==> 

{
    "buckets" : [
        {
          "key" : "processed",
          "doc_count" : 209,
          "status_stats" : {
            "count" : 209,
            "min" : 10.270000457763672,
            "max" : 281.7699890136719,
            "avg" : 109.30703350231408,
            "sum" : 22845.170001983643
          }
        },
        ....
]
}
```

## combine query and aggs
```
GET /order/_search
{
  "size": 0,
  "query": {
    "rage": {
      "total_amount": {
        "gte": 100
      }
    }
  },
  "aggs": {
    "status_terms": {
      "terms": {
        "field": "status"
      },
      "aggs": {
        "status_stats": {
          "stats": {
            "field": "total_amount"
          }
        }
      }
    }
  }
}

```

## combine filter and aggs

```
GET /order/_search
{
  "size": 0,
  "aggs": {
    "low_value": {
      "filter": {
        "range": {
          "total_amount": {
            "lt": 50
          }
        }
      },
      "aggs": {
        "avg_amount": {
          "avg": {
            "field": "total_amount"
          }
        }
      }
    }
  }
}

===> 
{
  "aggregations" : {
    "low_value" : {
      "doc_count" : 164,
      "avg_amount" : {
        "value" : 32.59371952894257
      }
    }
  }
 } 

```

## combine filters and aggs

```
GET /recipe/_search
{
  "size": 0,
  "aggs": {
    "my_filter": {
      "filters": {
        "filters": {
          "pasta": {
            "match": {
              "title": "pasta"
            }
          },
          "spaghetti": {
            "match": {
              "title": "spaghetti"
            }
          }
        }
      },
      "aggs": {
        "avg_rating": {
          "avg": {
            "field": "ratings"
          }
        }
      }
    }
  }
}

==>

{
    "aggregations" : {
    "my_filter" : {
      "buckets" : {
        "pasta" : {
          "doc_count" : 9,
          "avg_rating" : {
            "value" : 3.4125
          }
        },
        "spaghetti" : {
          "doc_count" : 4,
          "avg_rating" : {
            "value" : 2.3684210526315788
          }
        }
      }
    }
  }
}
```

#
## range aggs
#

```
GET /order/_search
{
  "size": 0,
  "aggs": {
    "amout_distribution": {
      "rage": {
        "field": "total_amount",
        "rages": [
          {
            "to": 50
          },
          {
            "from": 50,
            "to": 100
          },
          {
            "from": 100,
            "to": 200
          },
          {
            "from": 200
          }
        ]
      }
    }
  }
}


==> 
{
    "aggregations" : {
    "amout_distribution" : {
      "buckets" : [
        {
          "key" : "*-50.0",
          "to" : 50.0,
          "doc_count" : 164
        },
        {
          "key" : "50.0-100.0",
          "from" : 50.0,
          "to" : 100.0,
          "doc_count" : 347
        },
        {
          "key" : "100.0-200.0",
          "from" : 100.0,
          "to" : 200.0,
          "doc_count" : 409
        },
        {
          "key" : "200.0-*",
          "from" : 200.0,
          "doc_count" : 80
        }
      ]
    }
  }
}
```


## date_range
```
GET /order/_search
{
  "size": 0,
  "aggs": {
    "purchaed_rages": {
      "date_range": {
        "field": "purchased_at",
        "ranges": [
          {
            "from": "2016-01-01",
            "to": "2016-01-01||+6M"
          },
          {
            "from": "2016-01-01||+6M",
            "to": "2016-01-01||+1y"
          }
        ]
      }
    }
  }
}

===> 
{
    "aggregations" : {
    "purchaed_rages" : {
      "buckets" : [
        {
          "key" : "2016-01-01T00:00:00.000Z-2016-07-01T00:00:00.000Z",
          "from" : 1.4516064E12,
          "from_as_string" : "2016-01-01T00:00:00.000Z",
          "to" : 1.4673312E12,
          "to_as_string" : "2016-07-01T00:00:00.000Z",
          "doc_count" : 481
        },
        {
          "key" : "2016-07-01T00:00:00.000Z-2017-01-01T00:00:00.000Z",
          "from" : 1.4673312E12,
          "from_as_string" : "2016-07-01T00:00:00.000Z",
          "to" : 1.4832288E12,
          "to_as_string" : "2017-01-01T00:00:00.000Z",
          "doc_count" : 519
        }
      ]
    }
  }
}
```

## give a name to data range
```

GET /order/_search
{
  "size": 0,
  "aggs": {
    "purchaed_ranges": {
      "date_range": {
        "field": "purchased_at",
        "format": "yyy-MM-dd",
        "keyed": true,
        "ranges": [
          {
            "from": "2016-01-01",
            "to": "2016-01-01||+6M",
            "key": "first_half"
          },
          {
            "from": "2016-01-01||+6M",
            "to": "2016-01-01||+1y"
          }
        ]
      }
    }
  }
}

==> 
{
    "aggregations" : {
    "purchaed_ranges" : {
      "buckets" : {
        "first_half" : {
          "from" : 1.4516064E12,
          "from_as_string" : "2016-01-01",
          "to" : 1.4673312E12,
          "to_as_string" : "2016-07-01",
          "doc_count" : 481
        },
        "2016-07-01-2017-01-01" : {
          "from" : 1.4673312E12,
          "from_as_string" : "2016-07-01",
          "to" : 1.4832288E12,
          "to_as_string" : "2017-01-01",
          "doc_count" : 519
        }
      }
    }
  }
}
```

#
## Histogram - range
#
```
GET /order/_search
{
  "size": 0,
  "aggs": {
    "amout_distribution": {
      "histogram": {
        "field": "total_amount"
        , "interval": 100
      }
    }
  }
}

==> 

{
    "aggregations" : {
    "amout_distribution" : {
      "buckets" : [
        {
          "key" : 0.0,
          "doc_count" : 511
        },
        {
          "key" : 100.0,
          "doc_count" : 409
        },
        {
          "key" : 200.0,
          "doc_count" : 80
        }
      ]
    }
  }
}
```

```
GET /order/_search
{
  "size": 0,
  "query": {
    "rage": {
      "total_amount": {
        "gte": 101
      }
    }
  }, 
  "aggs": {
    "amout_distribution": {
      "histogram": {
        "field": "total_amount", 
        "interval": 50,
        "min_doc_count": 1, 
        "extended_bounds": {
          "min": 0,
          "max": 500
        }
      }
    }
  }
}
```

## date_histogram

```
GET /order/_search
{
  "size": 0,
  "aggs": {
    "orders_over_time": {
      "date_histogram": {
        "field": "purchased_at",
        "calendar_interval": "month"
      }
    }
  }
}
```

#
# global aggs, which ignore the query
#

```
GET /order/_search
{
  "size": 0,
  "query": {
    "range": {
      "total_amount": {
        "gte": 100
      }
    }
  },
  "aggs": {
    "stats_expensive": {
      "stats": {
        "field": "total_amount"
      }
    },
    "all_orders": {
      "global": {},
      "aggs": {
        "stats_amout": {
          "stats": {
            "field": "total_amount"
          }
        }
      }
    }
  }
}


==> 

{
    "aggregations" : {
    "all_orders" : {
      "doc_count" : 1000,
      "stats_amout" : {
        "count" : 1000,
        "min" : 10.270000457763672,
        "max" : 281.7699890136719,
        "avg" : 109.20960997009277,
        "sum" : 109209.60997009277
      }
    },
    "stats_expensive" : {
      "count" : 489,
      "min" : 100.05000305175781,
      "max" : 281.7699890136719,
      "avg" : 157.32703472987762,
      "sum" : 76932.91998291016
    }
  }
}
```

#
# missing value (null) -  aggs
#
```
PUT /order/_doc/10001
{
  "total_amount": 100
}

PUT /order/_doc/10002
{
  "total_amount": 200,
  "status": null
}


GET /order/_search
{
  "size": 0,
  "aggs": {
    "orders_without_status": {
      "missing": {
        "field": "status.keyword"
      }
    }
  }
}

==> 

{
    "aggregations" : {
    "orders_without_status" : {
      "doc_count" : 2
    }
  }
}


DELETE /order/_doc/10001
DELETE /order/_doc/10002
```

#
# nested aggs for nested object
#
```
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


GET /department/_search
{
  "size": 0,
  "aggs": {
    "employees": {
      "nested": {
        "path": "employees"
      },
      "aggs": {
        "minimum_age": {
          "min": {
            "field": "employees.age"
          }
        }
      }
    }
  }
}

```
