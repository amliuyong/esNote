
# Basics

Cluster --> Database server
Index  --> Schema
Type  --> Table
Document --> Row

http://localhost:5601

curl -i -XGET 'localhost:9200'

http://localhost:5601/app/dev_tools#/console


# Load data from file

```
## localhost
curl -H "Content-Type: application/x-ndjson" -XPOST http://localhost:9200/order/_bulk --data-binary "@orders-bulk.json"

## cloud
curl -H "Content-Type: application/x-ndjson" -XPOST -u elastic:your_password https://elastic-cloud-endpoint.com:9243/_bulk --data-binary "@orders.bulk.ndjson"

## by ES API
https://github.com/amliuyong/esNote/blob/master/IndexRatings.py

```


# Doc CRUD

## create/replace doc by PUT
```
PUT /blogposts/_doc/1
{
  "title": "Introdunction",
  "content": "Elasticserach is a distributed, open source search and analytics engine for all types of data ...",
  "published_date": "2020-01-02",
  "tags": [
    "elasticserach",
    "distributed",
    "storage"
  ]
}

```
Output:
```json
{
  "_index" : "blogposts",
  "_type" : "_doc",
  "_id" : "1",
  "_version" : 8,
  "result" : "updated",
  "_shards" : {
    "total" : 2,
    "successful" : 1,
    "failed" : 0
  },
  "_seq_no" : 7,
  "_primary_term" : 1
}
```

## create doc by POST with auto-gen Id
```
POST /blogposts/_doc/
{
  "title": "Introdunction for POST",
  "content": "Elasticserach is a distributed, open source search and analytics engine for all types of data ...",
  "published_date": "2020-01-02",
  "tags": [
    "elasticserach",
    "distributed",
    "storage"
  ]
}
```
Output
```json
{
  "_index" : "blogposts",
  "_type" : "_doc",
  "_id" : "p93FbnYBxXTNexya5oyJ",
  "_version" : 1,
  "result" : "created",
  "_shards" : {
    "total" : 2,
    "successful" : 1,
    "failed" : 0
  },
  "_seq_no" : 8,
  "_primary_term" : 1
}

```

## get doc
GET /blogposts/_doc/1
curl -XGET "http://localhost:9200/blogposts/_doc/1"

Output
```json
{
  "_index" : "blogposts",
  "_type" : "_doc",
  "_id" : "1",
  "_version" : 8,
  "_seq_no" : 7,
  "_primary_term" : 1,
  "found" : true,
  "_source" : {
    "title" : "Introduction",
    "content" : "Elasticserach is a distributed, open source search and analytics engine for all types of data ...",
    "published_date" : "2020-01-02",
    "tags" : [
      "elasticserach",
      "distributed",
      "storage"
    ]
  }
}
```
## check if a doc existing
HEAD /blogposts/_doc/1
Output
```
200 - OK
```
HEAD /blogposts/_doc/5
```json
{"statusCode":404,"error":"Not Found","message":"404 - Not Found"}
```

## update doc by POST
```
POST /blogposts/_update/1
{
  "doc": {
    "title": "Introduction to ES",
    "no_of_likes": 2
  }
}
```

GET /blogposts/_doc/1

```json
{
  "_index" : "blogposts",
  "_type" : "_doc",
  "_id" : "1",
  "_version" : 14,
  "_seq_no" : 14,
  "_primary_term" : 1,
  "found" : true,
  "_source" : {
    "title" : "Introduction to ES",
    "content" : "Elasticserach is a distributed, open source search and analytics engine for all types of data ...",
    "published_date" : "2020-01-02",
    "tags" : [
      "elasticserach",
      "distributed",
      "storage"
    ],
    "no_of_likes" : 2
  }
}

```

## delete doc

```
DELETE /blogposts/_doc/1
```

## Bulk

```
PUT _bulk
{"index":{"_index":"blogposts","_id":1}}
{"title":"Introduction","content":"Elasticserach is a distributed, open source search and analytics engine for all types of data ...","published_date":"2020-01-02","tags":["elasticserach","distributed","storage"]}
{"index":{"_index":"blogposts","_id":2}}
{"title":"Introduction to ES","content":"Elasticserach is a distributed, open source search and analytics engine for all types of data ...","published_date":"2020-01-02","tags":["elasticserach","distributed","storage"]}
{"update":{"_index":"blogposts","_id":"1"}}
{"doc":{"title":"Introduction ES Update"}}
{"delete":{"_index":"blogposts","_id":"2"}}
```

# Serach Basics 

## Find all the documents

`GET /blogposts/_search`



## do search

`GET /blogposts/_search?q=java`

`GET /blogposts/_search?q=java python`

`GET /blogposts/_search?q=content:java`


### search from browser
http://localhost:9200/blogposts/_search?pretty
http://localhost:9200/blogposts/_search?q=java%20python&pretty

### search mult-index:

`GET /blog*/_search`
`GET /index1, index2/_search`
`GET /_search`


## Query DSL
```

// get total count

GET /blogposts/_search 
{
 "track_total_hits":"true", 
 "size": 0
}


// match
GET /blogposts/_search 
{
  "query": {
    "match": {
      "title": "java python"
    }
  }
}

// match_phrase - exact match
GET /blogposts/_search 
{
  "query": {
    "match_phrase": {
      "title": "java python"
    }
  }
}

// match_all
GET /blogposts/_search 
{
  "query": {
    "match_all": {}
  }
}

// multi_match
GET /blogposts/_search 
{
  "query": {
    "multi_match": {
      "query": "elasticserach",
      "fields": ["title", "tags"]
    }
  }
}

// bool search - AND/Not
GET /blogposts/_search
{
  "query": {
    "bool": {
      "must": [
        {
          "match": {
            "content": "elasticserach"
          }
        }
      ],
      "must_not": [
        {
          "match": {
            "title": "java"
          }
        }
      ],
      "should": [
        {
          "match": {
            "title": "Elasticserach"
          }
        }
      ]
    }
  }
}


// query and filter
GET /blogposts/_search
{
  "query": {
    "bool": {
      "must": [
        {
          "match": {
            "tags": "elasticserach"
          }
        }
      ],
      "filter": [
        {
          "range": {
            "no_of_like": {
              "gte": 5
            }
          }
        }
      ]
    }
  }
}

// Search time anayzer

GET /blogposts/_search

{
    "query": {
       "match": {
           "title": {
               "query": "java peformance",
               "anayzer": "standard"
           }
       }
    }
}


```

## get index info

GET /blogposts
```json
{
  "blogposts" : {
    "aliases" : { },
    "mappings" : {
      "properties" : {
        "content" : {
          "type" : "text",
          "fields" : {
            "keyword" : {
              "type" : "keyword",
              "ignore_above" : 256
            }
          }
        },
        "no_of_like" : {
          "type" : "long"
        },
        "no_of_likes" : {
          "type" : "long"
        },
        "published_date" : {
          "type" : "date"
        },
        "tags" : {
          "type" : "text",
          "fields" : {
            "keyword" : {
              "type" : "keyword",
              "ignore_above" : 256
            }
          }
        },
        "title" : {
          "type" : "text",
          "fields" : {
            "keyword" : {
              "type" : "keyword",
              "ignore_above" : 256
            }
          }
        }
      }
    },
    "settings" : {
      "index" : {
        "routing" : {
          "allocation" : {
            "include" : {
              "_tier_preference" : "data_content"
            }
          }
        },
        "number_of_shards" : "1",
        "number_of_replicas" : "1",
        "provided_name" : "blogposts",
        "creation_date" : "1608175554024",
        "uuid" : "FWg3UWilR4OdI49eK8fdoA",
        "version" : {
          "created" : "7100199"
        }
      }
    }
  }
}
```

# Mappings and settings
```
PUT /blogs
{
  "settings": {
    "number_of_shards": 1,
    "number_of_replicas": 0
  }
}


GET /blogs/_settings

// update settings

PUT /blogs/_settings
{
  "number_of_replicas": 1
}

// set mappings
PUT /blogs/_mapping
{
  "properties": {
    "title": {
      "type": "text"
    },
    "content": {
      "type": "text"
    },
    "published_date": {
      "type": "date"
    }
  }
}

GET /blogs/_mapping


```

# Analyisis

### Standard Analyzer
 - Removes punctuation
 - lowercases terms
 - supports removing stop words
  
### Simple Analyzer
 - Divides text into terms whenever it encounters a char which is not a letter
 - lowercase terms
 - *Not* remove stop words

### Whitespace Analyer
 -  Divides text into terms based on whitespace
 -  *Not* lowercase terms

### Stop Analyer
 - Divides text into terms whenever it encounters a char which is not a letter
 - lowercase terms
 - remove stop words

### Keyword Analyzer
 - outputs the exact same text as single term 

### Pattern Analyzer
- uses a regular expression to split the text into terms
- lowercases terms
- supports removing stop words

### English Analyzer
 - removes punctuation
 - tokens based on whitespace
 - stop words are removal
 - stemming

### Fingerprint Analyzer
 - creates a fingerprint which can be used for duplicatie detection
 - input text is lowercased, normalized to remove extended chars, sorted, debuplicated, and concatenated into as single token

```
DELETE /blogs
PUT /blogs

PUT /blogs/_mapping
{
  "properties": {
    "title": {
      "type": "text",
      "analyzer": "simple"
    },
    "content": {
      "type": "text"
    },
    "published_date": {
      "type": "date"
    }
  }
}
GET /blogs/_mapping

```

## Analyzer processing

Document --> Character Filter  --> Tokenizer  --> Token Filter

Standard Analyzer: 
  - Standard Tokenizer
  - Lowercase Token Filter
  - Stop Token Filter

## Custom analyzer

### Custom analyzer - simple example

```
DELETE /blogposts

PUT /blogposts
{
  "settings": {
    "number_of_replicas": 1,
    "number_of_shards": 1,
    "analysis": {
      "analyzer": {
        "my_custom_analyzer": {
          "type": "custom",
          "char_filter": [
            "html_strip"
          ],
          "tokenizer": "standard",
          "filter": [
            "lowercase"
          ]
        }
      }
    }
  },
  "mappings": {
    "properties": {
      "title": {
        "type": "text"
      },
      "content": {
        "type": "text",
        "analyzer": "my_custom_analyzer"
      },
      "published_date": {
        "type": "date"
      },
      "no_of_likes": {
        "type": "long"
      },
      "tags": {
        "type": "text"
      },
      "status": {
        "type": "text"
      }
    }
  }
}

GET /blogposts

// test my_custom_analyzer
POST /blogposts/_analyze 
{
 "analyzer": "my_custom_analyzer",
 "text": "this is HTML <div> this in Div</div> content"
}

```

### Custom analyzer - complex example
```
DELETE /blogposts

PUT /blogposts
{
  "settings": {
    "number_of_replicas": 1,
    "number_of_shards": 1,
    "analysis": {
      "analyzer": {
        "my_custom_analyzer": {
          "type": "custom",
          "char_filter": [
            "symbol"
          ],
          "tokenizer": "punctuation",
          "filter": [
            "my_stop", "lowercase"
          ]
        }
      },
      "tokenizer": {
        "punctuation": {
          "type": "pattern",
          "pattern": "[ .,!?]"
        }
      },
      "char_filter": {
        "symbol": {
          "type": "mapping",
          "mappings": [
            "& => and",
            ":) => happy",
            ":( => sad"
          ]
        }
      },
      "filter": {
        "my_stop": {
          "type": "stop",
          "stopwords": "_english_"
        }
      }
    }
  },
  "mappings": {
    "properties": {
      "title": {
        "type": "text"
      },
      "content": {
        "type": "text",
        "analyzer": "my_custom_analyzer"
      },
      "published_date": {
        "type": "date"
      },
      "no_of_likes": {
        "type": "long"
      },
      "tags": {
        "type": "text"
      },
      "status": {
        "type": "text"
      }
    }
  }
}

GET /blogposts

```
### test my_custom_analyzer
```
POST /blogposts/_analyze 
{
 "analyzer": "my_custom_analyzer",
 "text": "Big Data processing with Spark & Scala :)! I like it."
}

```
output: 

```json
{
  "tokens" : [
    {
      "token" : "big",
      "start_offset" : 0,
      "end_offset" : 3,
      "type" : "word",
      "position" : 0
    },
    {
      "token" : "data",
      "start_offset" : 4,
      "end_offset" : 8,
      "type" : "word",
      "position" : 1
    },
    {
      "token" : "processing",
      "start_offset" : 9,
      "end_offset" : 19,
      "type" : "word",
      "position" : 2
    },
    {
      "token" : "spark",
      "start_offset" : 25,
      "end_offset" : 30,
      "type" : "word",
      "position" : 4
    },
    {
      "token" : "scala",
      "start_offset" : 33,
      "end_offset" : 38,
      "type" : "word",
      "position" : 6
    },
    {
      "token" : "happy",
      "start_offset" : 39,
      "end_offset" : 41,
      "type" : "word",
      "position" : 7
    },
    {
      "token" : "i",
      "start_offset" : 43,
      "end_offset" : 44,
      "type" : "word",
      "position" : 8
    },
    {
      "token" : "like",
      "start_offset" : 45,
      "end_offset" : 49,
      "type" : "word",
      "position" : 9
    }
  ]
}
```

### N-Grams tokenizer

```
DELETE /ngram_index

PUT /ngram_index
{
  "settings": {
    "analysis": {
      "analyzer": {
        "ngram_analyzer": {
          "tokenizer": "ngram_tokenizer"
        }
      },
      "tokenizer": {
        "ngram_tokenizer": {
          "type": "ngram",
          "min_gram": 2,
          "max_gram": 3
        }
      }
    }
  }
}

```
### test N-Grams tokenizer
```
POST /ngram_index/_analyze
{
  "analyzer": "ngram_analyzer",
  "text": "中文怎么样!"
}
```
Output: 

```json
{
  "tokens" : [
    {
      "token" : "中文",
      "start_offset" : 0,
      "end_offset" : 2,
      "type" : "word",
      "position" : 0
    },
    {
      "token" : "中文怎",
      "start_offset" : 0,
      "end_offset" : 3,
      "type" : "word",
      "position" : 1
    },
    {
      "token" : "文怎",
      "start_offset" : 1,
      "end_offset" : 3,
      "type" : "word",
      "position" : 2
    },
    {
      "token" : "文怎么",
      "start_offset" : 1,
      "end_offset" : 4,
      "type" : "word",
      "position" : 3
    },
    {
      "token" : "怎么",
      "start_offset" : 2,
      "end_offset" : 4,
      "type" : "word",
      "position" : 4
    },
    {
      "token" : "怎么样",
      "start_offset" : 2,
      "end_offset" : 5,
      "type" : "word",
      "position" : 5
    },
    {
      "token" : "么样",
      "start_offset" : 3,
      "end_offset" : 5,
      "type" : "word",
      "position" : 6
    },
    {
      "token" : "么样!",
      "start_offset" : 3,
      "end_offset" : 6,
      "type" : "word",
      "position" : 7
    },
    {
      "token" : "样!",
      "start_offset" : 4,
      "end_offset" : 6,
      "type" : "word",
      "position" : 8
    }
  ]
}
```


### edge_ngram tokenizer
```
DELETE /ngram_index

PUT /ngram_index
{
  "settings": {
    "analysis": {
      "analyzer": {
        "ngram_analyzer": {
          "tokenizer": "edge_ngram_tokenizer"
        }
      },
      "tokenizer": {
        "edge_ngram_tokenizer": {
          "type": "edge_ngram",
          "min_gram": 2,
          "max_gram": 6
        }
      }
    }
  }
}

POST /ngram_index/_analyze
{
  "analyzer": "ngram_analyzer",
  "text": "Search"
}

```
output
```json
{
  "tokens" : [
    {
      "token" : "Se",
      "start_offset" : 0,
      "end_offset" : 2,
      "type" : "word",
      "position" : 0
    },
    {
      "token" : "Sea",
      "start_offset" : 0,
      "end_offset" : 3,
      "type" : "word",
      "position" : 1
    },
    {
      "token" : "Sear",
      "start_offset" : 0,
      "end_offset" : 4,
      "type" : "word",
      "position" : 2
    },
    {
      "token" : "Searc",
      "start_offset" : 0,
      "end_offset" : 5,
      "type" : "word",
      "position" : 3
    },
    {
      "token" : "Search",
      "start_offset" : 0,
      "end_offset" : 6,
      "type" : "word",
      "position" : 4
    }
  ]
}

```

## Search Time Analysis

`GET /blogposts/_search`
```json
{
    "query": {
       "match": {
           "title": {
               "query": "java peformance",
               "anayzer": "standard"
           }
       }
    }
}
```

# Set Search Data
```

DELETE /blogposts

PUT /blogposts
{
  "settings": {
    "number_of_replicas": 1,
    "number_of_shards": 1,
    "analysis": {
      "analyzer": {
        "my_custom_analyzer": {
          "type": "custom",
          "char_filter": [
            "symbol"
          ],
          "tokenizer": "punctuation",
          "filter": [
           "lowercase", "my_stop"
          ]
        }
      },
      "tokenizer": {
        "punctuation": {
          "type": "pattern",
          "pattern": "[ .,!?]"
        }
      },
      "char_filter": {
        "symbol": {
          "type": "mapping",
          "mappings": [
            "& => and",
            ":) => happy",
            ":( => sad"
          ]
        }
      },
      "filter": {
        "my_stop": {
          "type": "stop",
          "stopwords": "_english_"
        }
      }
    }
  },
  "mappings": {
    "properties": {
      "title": {
        "type": "text",
        "analyzer": "my_custom_analyzer",
        "fields": {
            "keyword": {
                "type": "keyword"
            }
        }
      },
      "content": {
        "type": "text",
        "analyzer": "my_custom_analyzer"
      },
      "published_date": {
        "type": "date"
      },
      "no_of_likes": {
        "type": "long"
      },
      "tags": {
        "type": "text",
        "fields": {
            "keyword": {
                "type": "keyword"
            }
        }
      },
      "status": {
        "type": "text",
        "fields": {
            "keyword": {
                "type": "keyword"
            }
        }
      }
    }
  }
}


POST _bulk
{ "index" : { "_index" : "blogposts", "_id" : "1" } }
{ "title" : "Introduction to elasticsearch", "content" : "Elasticsearch is a distributed, open source search and analytics engine for all types of data", "published_date" : "2020-01-02", "tags" : ["elasticsearch", "distributed", "storage" ], "no_of_likes" : 21, "status" : "published" }
{ "index" : { "_index" : "blogposts", "_id" : "2" } }
{ "title" : "Why is Elasticsearch fast?", "content" : "It is able to achieve fast search responses because, instead of searching the text directly, it searches an index instead", "tags" : ["elasticsearch", "fast", "index" ], "no_of_likes" : 10,"status" : "draft"}
{ "index" : { "_index" : "blogposts", "_id" : "3" } }
{ "title" : "Introducing the New React DevTools", "content" : "We are excited to announce a new release of the React Developer Tools, available today in Chrome, Firefox, and (Chromium) Edge", "published_date" : "2019-08-25", "tags" : ["react", "devtools" ], "no_of_likes" : 2, "status" : "published"}
{ "index" : { "_index" : "blogposts", "_id" : "4" } }
{ "title" : "Angular Tools for High Performance", "content" : "This post, contains a list of new tools and practices that can help us build faster Angular apps and monitor their performance over time", "published_date" : "2014-03-22", "tags" : ["angular", "performance","fast"], "no_of_likes" : 35, "status" : "published"}
{ "index" : { "_index" : "blogposts", "_id" : "5" } }
{ "title" : "The new features in Java 14", "content" : "Oracle on September 17 said switch expressions are expected to go final in Java Development Kit 14 (JDK 14). ", "published_date" : "2019-07-20", "tags" : ["java"], "no_of_likes" : 11, "status" : "published"}
{ "index" : { "_index" : "blogposts", "_id" : "6" } }
{ "title" : "Thread behavior in the JVM", "content" : "Threading refers to the practice of executing programming processes concurrently to improve application performance.", "tags" : ["java","jvm"], "no_of_likes" : 3, "status" : "draft"}
{ "index" : { "_index" : "blogposts", "_id" : "7" } }
{ "title" : "Stacks and Queues", "content" : "The main operations of a stack are push, pop, & isEmpty and for queue enqueue, dequeue, & isEmpty., ", "published_date" : "2016-12-12", "tags" : ["stack","queue","datastructures"], "no_of_likes" : 43, "status" : "published"}
{ "index" : { "_index" : "blogposts", "_id" : "8" } }
{ "title" : "How are big data and ai changing the business world?","content" : "Today’s businesses are ruled by data. Specifically, big data and AI that have gradually been evolving to shape day-to-day business processes and playing as the key driver in business Intelligence decision-making","published_date" : "2020-01-01","tags" :["big data","ai"],"no_of_likes" :120,"status" : "published"}
{ "index" : { "_index" : "blogposts", "_id" : "9" } }
{ "title" : "Hash Tables", "content" : "A hash table is a data structure used to implement symbol table (associative array), a structure that can map keys to values", "published_date" : "2017-08-12", "tags" :[ "hash", "datastructures" ], "no_of_likes" :13, "status" : "published" }
{ "index" : { "_index" : "blogposts", "_id" : "10" } }
{ "title" : "Go vs Python: How to choose", "content" : "Python and Go share a reputation for being convenient to work with. Both languages have a simple and straightforward syntax and a small and easily remembered feature set", "tags" :[ "go", "python" ], "no_of_likes" :134, "status" : "draft" }
{ "index" : { "_index" : "blogposts", "_id" : "11" } }
{ "title" : "Android Studio 4.0 backs native UI toolkit", "content" : "Now available in a preview release, the Android Studio 4.0 ‘Canary’ upgrade works with the JetPack Compose UI toolkit and improves Java 8 support", "tags" :[ "android", "nativeui" ], "no_of_likes" :113, "status" : "draft" }
{ "index" : { "_index" : "blogposts", "_id" : "12" } }
{ "title" : "JSON tools you don’t want to miss", "content" : "Developers can choose from many great free and online tools for JSON formatting, validating, editing, and converting to other formats", "published_date" : "2018-02-13", "tags" :[ "json" ], "no_of_likes" :23, "status" : "published" }
{ "index" : { "_index" : "blogposts", "_id" : "13" } }
{ "title" : "Get started with method references in Java", "content" : "Use method references to simplify functional programming in Java", "tags" :[ "java", "references" ], "no_of_likes" :102, "status" : "draft" }
{ "index" : { "_index" : "blogposts", "_id" : "14" } }
{ "title" : "How to choose a database for your application", "content" : "From performance to programmability, the right database makes all the difference. Here are 12 key questions to help guide your selection", "published_date" : "2009-02-12", "tags" :[ "database" ], "no_of_likes" :229, "status" : "published" }
{ "index" : { "_index" : "blogposts", "_id" : "15" } }
{ "title" : "10 reasons to Learn Scala Programming Language", "content" : "One of the questions my reader often ask me is, shall I learn Scala? Does Scala has a better future than Java, or why Java developer should learn Scala and so on", "published_date" : "2009-02-12", "tags" :[ "scala", "language" ], "no_of_likes" :136, "status" : "draft" }
{ "index" : { "_index" : "blogposts", "_id" : "16" } }
{ "title" : "ways to declare and initialize Two-dimensional (2D) String and Integer Array in Java", "content" : "Declaring a two-dimensional array is very interesting in Java as Java programming language provides many ways to declare a 2D array and each one of them has some special things to learn about", "published_date" : "2009-02-12", "tags" :[ "jaava", "datastructure", "array" ], "no_of_likes" :342, "status" : "published" }
{ "index" : { "_index" : "blogposts", "_id" : "17" } }
{ "title" : "Hibernate Tip: How to customize the association mappings using a composite key", "content" : "Hibernate provides lots of mapping features that allow you to map complex domain and table models. But the availability of these features doesn't mean that you should use them in all of your applications", "tags" :[ "hibernate", "compositekey" ], "no_of_likes" :112, "status" : "draft" }
{ "index" : { "_index" : "blogposts", "_id" : "18" } }
{ "title" : "Getting started with Python on Spark", "content" : "At my current project I work a lot with Apache Spark and running PySpark jobs on it.", "tags" :[ "python", "spark" ], "no_of_likes" :86, "status" : "draft" }
{ "index" : { "_index" : "blogposts", "_id" : "19" } }
{ "title" : "Relationship between IOT, big data, and cloud computing", "content" : "Big data analytics is the basis of decision making in an organization. It involves the examination of a large number of data sets in order to identify the hidden patterns that result in their existence.", "published_date" : "2018-11-10", "tags" :[ "iot", "big data", "cloud computing" ], "no_of_likes" :12, "status" : "published" }
{ "index" : { "_index" : "blogposts", "_id" : "20" } }
{ "title" : "Get started with lambda expressions in Java", "content" : "Learn how to use lambda expressions and functional programming techniques in your Java programs.", "tags" :[ "java", "lambda", "functional programming" ], "no_of_likes" :128, "status" : "draft" }
{ "index" : { "_index" : "blogposts", "_id" : "21" } }
{ "title" : "Securing access to our Elasticsearch Service deployment", "content" : "Before we configure all of our systems to send data to our Elasticsearch Service deployment", "published_date" : "2019-11-16", "tags" :[ "elasticsearch", "deployment" ], "no_of_likes" :100, "status" : "published" }
{ "index" : { "_index" : "blogposts", "_id" : "22" } }
{ "title" : "Using parallel Logstash pipelines to improve persistent queue throughput", "content" : "By default, Logstash uses in-memory bounded queues between pipeline stages (inputs → pipeline workers) to buffer events", "published_date" : "2019-11-20", "tags" :[ "elasticsearch", "logstash" ], "no_of_likes" :110, "status" : "published" }
{ "index" : { "_index" : "blogposts", "_id" : "23" } }
{ "title" : "Boosting the power of Elasticsearch with synonyms", "content" : "Using synonyms is undoubtedly one of the most important techniques in a search engineer's tool belt.", "published_date" : "2019-11-28", "tags" :[ "elasticsearch", "synonyms" ], "no_of_likes" :235, "status" : "published" }
{ "index" : { "_index" : "blogposts", "_id" : "24" } }
{ "title" : "How to keep Elasticsearch synchronized with a relational database using Logstash and JDBC", "content" : "Using synonyms is undoubtedly one of the most important techniques in a search engineer's tool belt.", "tags" :[ "elasticsearch", "database", "logstash", "jdbc" ], "no_of_likes" :153, "status" : "draft" }
{ "index" : { "_index" : "blogposts", "_id" : "25" } }
{ "title" : "Monitoring Kafka with Elasticsearch, Kibana, and Beats", "content" : "We first posted about monitoring Kafka with Filebeat in 2016. Since the 6.5 release, the Beats team has been supporting a Kafka module.", "tags" :[ "elasticsearch", "kibana", "Beats", "Kafka" ], "no_of_likes" :117, "status" : "draft" }
{ "index" : { "_index" : "blogposts", "_id" : "26" } }
{ "title" : "Defending your organization with the Elastic Stack", "content" : "Does your team analyze security data with the Elastic Stack? If so, come check out Elastic SIEM, the first big step in building our vision of what a SIEM should be.", "published_date" : "2019-11-28", "tags" :[ "elasticsearch", "elastic stack", "siem" ], "no_of_likes" :145, "status" : "published" }
{ "index" : { "_index" : "blogposts", "_id" : "27" } }
{ "title" : "What Is Elasticsearch – Getting Started With No Constraints Search Engine", "content" : "In today’s IT world, a voluminous amount of data sizing approx 2.5 Quintillion bytes is generated every day.,", "published_date" : "2019-11-28", "tags" :[ "elasticsearch", "search engine" ], "no_of_likes" :174, "status" : "published" }
{ "index" : { "_index" : "blogposts", "_id" : "28" } }
{ "title" : "Why the Rust language is on the rise", "content" : "Rust may not be easy to learn, but developers love the speed, the tools, the ‘guard rails,‘ and the community.,", "published_date" : "2019-11-28", "tags" :[ "rust", "language" ], "no_of_likes" :15, "status" : "published" }
{ "index" : { "_index" : "blogposts", "_id" : "29" } }
{ "title" : "Machine learning algorithms explained", "content" : "Machine learning uses algorithms to turn a data set into a predictive model. Which algorithm works best depends on the problem.,", "tags" :[ "machine learning", "algorithms" ], "no_of_likes" :156, "status" : "draft" }
{ "index" : { "_index" : "blogposts", "_id" : "30" } }
{ "title" : "Java tip: When to use composition vs inheritance", "content" : "There's more than one way to establish relationships between classes.,", "tags" :[ "Java", "composition", "inheritance" ], "no_of_likes" :443, "status" : "draft" }
{ "index" : { "_index" : "blogposts", "_id" : "31" } }
{ "title" : "Building Great User Experiences with Concurrent Mode and Suspense", "content" : "At React Conf 2019 we announced an experimental release of React that supports Concurrent Mode and Suspense..,", "published_date" : "2019-01-18", "tags" :[ "react" ], "no_of_likes" :167, "status" : "published" }
{ "index" : { "_index" : "blogposts", "_id" : "32" } }
{ "title" : "React v16.8: The One With Hooks", "content" : "Hooks let you use state and other React features without writing a class. You can also build your own Hooks to share reusable stateful logic between components..,", "published_date" : "2019-01-18", "tags" :[ "react", "hooks" ], "no_of_likes" :184, "status" : "published" }



```


# Search In Depth

```
// by default only return the first 10 document

GET /blogposts/_search
{
  "query": {
    "match_all": {}
  }
}

// get total count
GET /blogposts/_search 
{
 "track_total_hits":"true", 
 "size": 0
}


// top N document - size

GET /blogposts/_search
{
  "query": {
    "match_all": {}
  },
  "size": 20
}

// from and size

GET /blogposts/_search
{
  "query": {
    "match_all": {}
  },
  "from": 5,
  "size": 5
}


// projection

GET /blogposts/_search
{
  "query": {
    "match_all": {}
  },
  "from": 5,
  "size": 5,
  "_source": ["title", "content"]
}

GET /blogposts/_search
{
  "query": {
    "match_all": {}
  },
  "from": 5,
  "size": 5,
  "_source": ["ti*", "content"]
}

GET /blogposts/_search
{
  "query": {
    "match_all": {}
  },
  "from": 5,
  "size": 5,
  "_source": {
      "excludes": "status"
  }
}


// sort

GET /blogposts/_search
{
  "query": {
    "match": {
      "title": "java"
    }
  },
  "sort": [
    {
      "no_of_likes": {
        "order": "desc"
      }
    }
  ]
}


// sort by analyzed field

GET /blogposts/_search
{
  "query": {
    "match": {
      "title": "java"
    }
  },
  "sort": [
    {
      "title.keyword": {
        "order": "asc"
      }
    }
  ]
}




GET /blogposts/_search 
{
  "query": {
    "match": {
      "title": "Introduction to elasticsearch"
    }
  }
}

// match_phrase - exact match
GET /blogposts/_search 
{
  "query": {
    "match_phrase": {
      "title": "Introduction to elasticsearch"
    }
  }
}

// below match_phrase query matches "Introduction to elasticsearch"
GET /blogposts/_search 
{
  "query": {
    "match_phrase": {
      "title": {
       "query":  "Introduction elasticsearch",
        "slop": 1
      }
    }
  }
}


GET /blogposts/_search
{
  "query": {
    "match_phrase_prefix": {
      "title": "introduction"
    }
  }
}

GET /blogposts/_search 
{
  "query": {
    "prefix": {
      "title": {
       "value":  "introduction"
      }
    }
  }
}


GET /blogposts/_search 
{
  "query": {
    "wildcard": {
      "title": {
       "value":  "ki*a"
      }
    }
  }
}


// match operator
GET /blogposts/_search
{
  "query": {
    "match": {
      "title": {
        "query": "Introduction to elasticsearch",
        "operator": "and"
      }
    }
  }
}

// match minimum_should_match

GET /blogposts/_search
{
  "query": {
    "match": {
      "title": {
        "query": "Introduction to elasticsearch",
        "minimum_should_match": 2
      }
    }
  }
}

// match vs. term search

// get 2 doc
GET  /blogposts/_search
{
  "query": {
    "match": {
      "title": "React"
    }
  }
}

// 0 doc returned, term query will not send to query analyzer

GET  /blogposts/_search
{
  "query": {
    "term": {
      "title": "React"
    }
  }
}


```

## bool search example

template

```json
{
  "query": {
    "bool": {
      "must": [
        {}
      ],
      "must_not": [
        {}
      ],
      "filter": [
        {}
      ],
      "should": [
        {}
      ]
    }
  }
}
```
must and filter

```json
{
  "query": {
    "bool": {
      "must": [
        {
          "match": {
            "title": {
              "query": "Introduction to elasticsearch"
            }
          }
        }
      ],
      "filter": [
        {
          "term": {
            "status": "published"
          }
        }
      ]
    }
  }
}
```
doc has tags: elasticsearch or java
```json
{
  "query": {
    "bool": {
      "filter": {
        "terms": {
          "tags": [
            "elasticsearch",
            "java"
          ]
        }
      }
    }
  }
}
```

A complex example
 - must about elastic search
 - must be in draft status
 - must have 100 likes and published after 2010-11-20
 - nice to related to react but not necessarily

GET /blogposts/_search

```json
{
  "query": {
    "bool": {
      "must": [
        {
          "match": {
            "title": "elasticsearch"
          }
        }
      ],
      "must_not": [
        {
          "term": {
            "status": {
              "value": "draft"
            }
          }
        }
      ],
      "filter": [
        {
          "range": {
            "no_of_likes": {
              "gte": 100
            }
          }
        },
        {
          "range": {
            "published_date": {
              "gte": "2019-11-20"
            }
          }
        }
      ],
      "should": [
        {
          "match": {
            "tags": "synonyms"
          }
        }
      ]
    }
  }
}
```

## KQL 
 - how to map `and`
 - how to map `or`
 - how to map `range`

`url.path:/ and user_agent.os.name : ("Windows"  or "Mac OS X")` 

```json

{
  "version": true,
  "size": 500,
  "sort": [
    {
      "@timestamp": {
        "order": "desc",
        "unmapped_type": "boolean"
      }
    }
  ],
  "aggs": {
    "2": {
      "date_histogram": {
        "field": "@timestamp",
        "calendar_interval": "1d",
        "time_zone": "Asia/Shanghai",
        "min_doc_count": 1
      }
    }
  },
  "stored_fields": [
    "*"
  ],
  "script_fields": {},
  "docvalue_fields": [
    {
      "field": "@timestamp",
      "format": "date_time"
    }
  ],
  "_source": {
    "excludes": []
  },
  "query": {
    "bool": {
      "must": [],
      "filter": [
        {
          "bool": {
            "should": [
              {
                "bool": {
                  "should": [
                    {
                      "match_phrase": {
                        "user_agent.os.name": "Mac OS X"
                      }
                    }
                  ],
                  "minimum_should_match": 1
                }
              },
              {
                "bool": {
                  "should": [
                    {
                      "match_phrase": {
                        "user_agent.os.name": "Windows"
                      }
                    }
                  ],
                  "minimum_should_match": 1
                }
              }
            ],
            "minimum_should_match": 1
          }
        },
        {
          "match_phrase": {
            "url.path": "/"
          }
        },
        {
          "range": {
            "@timestamp": {
              "gte": "2020-01-01T11:48:31.278Z",
              "lte": "2020-04-01T12:03:48.910Z",
              "format": "strict_date_optional_time"
            }
          }
        }
      ],
      "should": [],
      "must_not": []
    }
  },
  "highlight": {
    "pre_tags": [
      "@kibana-highlighted-field@"
    ],
    "post_tags": [
      "@/kibana-highlighted-field@"
    ],
    "fields": {
      "*": {}
    },
    "fragment_size": 2147483647
  }
}

```

`url.path:/ user_agent.os.name : ("Mac OS X"  or "Windows") and user_agent.name : "Chrome" `

```json
{
"query": {
    "bool": {
      "must": [],
      "filter": [
        {
          "bool": {
            "filter": [
              {
                "bool": {
                  "should": [
                    {
                      "bool": {
                        "should": [
                          {
                            "match_phrase": {
                              "user_agent.os.name": "Mac OS X"
                            }
                          }
                        ],
                        "minimum_should_match": 1
                      }
                    },
                    {
                      "bool": {
                        "should": [
                          {
                            "match_phrase": {
                              "user_agent.os.name": "Windows"
                            }
                          }
                        ],
                        "minimum_should_match": 1
                      }
                    }
                  ],
                  "minimum_should_match": 1
                }
              },
              {
                "bool": {
                  "should": [
                    {
                      "match_phrase": {
                        "user_agent.name": "Chrome"
                      }
                    }
                  ],
                  "minimum_should_match": 1
                }
              }
            ]
          }
        },
        {
          "match_phrase": {
            "url.path": "/"
          }
        },
        {
          "range": {
            "@timestamp": {
              "gte": "2020-01-01T11:48:31.278Z",
              "lte": "2020-04-01T12:03:48.910Z",
              "format": "strict_date_optional_time"
            }
          }
        }
      ],
      "should": [],
      "must_not": []
    }
  }
}  
```


### validate query

```
GET /blogposts/_validate/query?explain
{
  "query": {
    "filter": {
      "must_not": {
        "term": {
          "status": {
            "value": "draft"
          }
        }
      }
    }
  }
}

```

### highlight query
```
GET /blogposts/_search
{
  "query": {
    "match_phrase_prefix": {
      "title": "Angular Tools"
    }
  },
  "highlight": {
    "fields": {
      "title": {}
    }
  }
}
```
output: 
```json
{
  "took" : 82,
  "timed_out" : false,
  "_shards" : {
    "total" : 1,
    "successful" : 1,
    "skipped" : 0,
    "failed" : 0
  },
  "hits" : {
    "total" : {
      "value" : 1,
      "relation" : "eq"
    },
    "max_score" : 6.3341346,
    "hits" : [
      {
        "_index" : "blogposts",
        "_type" : "_doc",
        "_id" : "4",
        "_score" : 6.3341346,
        "_source" : {
          "title" : "Angular Tools for High Performance",
          "content" : "This post, contains a list of new tools and practices that can help us build faster Angular apps and monitor their performance over time",
          "published_date" : "2014-03-22",
          "tags" : [
            "angular",
            "performance",
            "fast"
          ],
          "no_of_likes" : 35,
          "status" : "published"
        },
        "highlight" : {
          "title" : [
            "<em>Angular</em> <em>Tools</em> for High Performance"
          ]
        }
      }
    ]
  }
}

```
### exists query
```
GET /blogposts/_search
{
  "query": {
    "exists": {
      "field": "published_date"
    }
  }
}
```


## Boost

### boost in query
```
GET /blogposts/_search
{
  "query": {
    "bool": {
      "should": [
        {
          "match": {
            "title": {
              "query": "elasticsearch",
              "boost": 2
            }
          }
        },
        {
          "match": {
            "content": {
              "query": "elasticsearch"
            }
          }
        }
      ]
    }
  }
}

```
### boost one filed in multi_match
```
GET /blogposts/_search
{
  "query": {
    "multi_match": {
      "query": "elasticsearch",
      "fields": [
        "title^2",
        "content"
      ]
    }
  }
}


```
### boost in mappings
PUT /blogposts

```json

{
  "settings": {
    "number_of_replicas": 1,
    "number_of_shards": 1,
    "analysis": {
      "analyzer": {
        "my_custom_analyzer": {
          "type": "custom",
          "char_filter": [
            "symbol"
          ],
          "tokenizer": "punctuation",
          "filter": [
           "lowercase", "my_stop"
          ]
        }
      },
      "tokenizer": {
        "punctuation": {
          "type": "pattern",
          "pattern": "[ .,!?]"
        }
      },
      "char_filter": {
        "symbol": {
          "type": "mapping",
          "mappings": [
            "& => and",
            ":) => happy",
            ":( => sad"
          ]
        }
      },
      "filter": {
        "my_stop": {
          "type": "stop",
          "stopwords": "_english_"
        }
      }
    }
  },
  "mappings": {
    "properties": {
      "title": {
        "type": "text",
        "analyzer": "my_custom_analyzer",
        "boost": 2,
        "fields": {
            "keyword": {
                "type": "keyword"
            }
        }
      },
      "content": {
        "type": "text",
        "analyzer": "my_custom_analyzer"
      },
      "published_date": {
        "type": "date"
      },
      "no_of_likes": {
        "type": "long"
      },
      "tags": {
        "type": "text"
      },
      "status": {
        "type": "text"
      }
    }
  }
}
```


# Aggregation

### aggs on all doc - count(*) by tag

`count(*) group by each tag`


```
GET /blogposts/_search
{
  "aggs": {
    "tog_tag": {
      "terms": {
        "field": "tags.keyword",
        "size": 10
      }
    }
  }
}

```

### aggs based on query


```
GET /blogposts/_search
{
  "query": {
    "term": {
      "status": {
        "value": "published"
      }
    }
  }, 
  "aggs": {
    "tog_tag": {
      "terms": {
        "field": "tags.keyword",
        "size": 10
      }
    }
  }
}

GET /blogposts/_search
{
  "query": {
    "bool": {
      "filter": [
        {
          "range": {
            "no_of_likes": {
              "gte": 100
            }
          }
        }
      ]
    }
 
  }, 
  "aggs": {
    "tog_tag": {
      "terms": {
        "field": "tags.keyword",
        "size": 10
      }
    }
  }
}

```
output: 
```json
{
"aggregations" : {
    "tog_tag" : {
      "doc_count_error_upper_bound" : 0,
      "sum_other_doc_count" : 21,
      "buckets" : [
        {
          "key" : "elasticsearch",
          "doc_count" : 6
        },
        {
          "key" : "react",
          "doc_count" : 3
        },
        {
          "key" : "big data",
          "doc_count" : 2
        },
        
        ...
      ]
    }
  }
}

```
### post_filter
  `1.query --> 2.aggs --> 3.post_filter`

  aggs only apply on the result of query

```
GET /blogposts/_search
{
  "query": {
    "term": {
      "status": {
        "value": "published"
      }
    }
  },
  
  "aggs": {
    "tog_tag": {
      "terms": {
        "field": "tags.keyword",
        "size": 10
      }
    }
  },
  "post_filter": {
    "range": {
      "no_of_likes": {
        "gte": 100
      }
    }
  }
}

```
```json
{
  "took" : 2,
  "timed_out" : false,
  "_shards" : {
    "total" : 1,
    "successful" : 1,
    "skipped" : 0,
    "failed" : 0
  },
  "hits" : {
    "total" : {
      "value" : 10,
      "relation" : "eq"
    },
    "max_score" : 0.5260931,
    "hits" : [
      {
        "_index" : "blogposts",
        "_type" : "_doc",
        "_id" : "8",
        "_score" : 0.5260931,
        "_source" : {
          "title" : "How are big data and ai changing the business world?",
          "content" : "Today’s businesses are ruled by data. Specifically, big data and AI that have gradually been evolving to shape day-to-day business processes and playing as the key driver in business Intelligence decision-making",
          "published_date" : "2020-01-01",
          "tags" : [
            "big data",
            "ai"
          ],
          "no_of_likes" : 120,
          "status" : "published"
        }
      },
      {
        "_index" : "blogposts",
        "_type" : "_doc",
        "_id" : "14",
        "_score" : 0.5260931,
        "_source" : {
          "title" : "How to choose a database for your application",
          "content" : "From performance to programmability, the right database makes all the difference. Here are 12 key questions to help guide your selection",
          "published_date" : "2009-02-12",
          "tags" : [
            "database"
          ],
          "no_of_likes" : 229,
          "status" : "published"
        }
      },
      ...
      
    ]
  },
  "aggregations" : {
    "tog_tag" : {
      "doc_count_error_upper_bound" : 0,
      "sum_other_doc_count" : 21,
      "buckets" : [
        {
          "key" : "elasticsearch",
          "doc_count" : 6
        },
        {
          "key" : "react",
          "doc_count" : 3
        },
        {
          "key" : "big data",
          "doc_count" : 2
        },
        {
          "key" : "datastructures",
          "doc_count" : 2
        },
       ...
      ]
    }
  }
}

```

## avg

`avg(avg_no_of_likes) group by each tag`

```
GET /blogposts/_search
{
  "aggs": {
    "tog_tag": {
      "terms": {
        "field": "tags.keyword",
        "size": 10
      },
      "aggs": {
        "avg_no_of_likes": {
          "avg": {
            "field": "no_of_likes"
          }
        }
      }
    }
  }
}
```
output:
```json
{
"aggregations" : {
    "tog_tag" : {
      "doc_count_error_upper_bound" : 0,
      "sum_other_doc_count" : 43,
      "buckets" : [
        {
          "key" : "elasticsearch",
          "doc_count" : 9,
          "avg_no_of_likes" : {
            "value" : 118.33333333333333
          }
        },
        {
          "key" : "java",
          "doc_count" : 4,
          "avg_no_of_likes" : {
            "value" : 61.0
          }
        },
        {
          "key" : "react",
          "doc_count" : 3,
          "avg_no_of_likes" : {
            "value" : 117.66666666666667
          }
        },
        
       ....
      ]
    }
  }
}
```
## avg/min/max

```
GET /blogposts/_search
{
  "aggs": {
    "tog_tag": {
      "terms": {
        "field": "tags.keyword",
        "size": 10
      },
      "aggs": {
        "avg_no_of_likes": {
          "avg": {
            "field": "no_of_likes"
          }
        },
        "minimu_no_likes": {
          "min": {
            "field": "no_of_likes"
          }
        },
        "maximu_no_likes": {
          "max": {
            "field": "no_of_likes"
          }
        }
      }
    }
  }
}
```
output:
```json
{
"aggregations" : {
    "tog_tag" : {
      "doc_count_error_upper_bound" : 0,
      "sum_other_doc_count" : 43,
      "buckets" : [
        {
          "key" : "elasticsearch",
          "doc_count" : 9,
          "avg_no_of_likes" : {
            "value" : 118.33333333333333
          },
          "minimu_no_likes" : {
            "value" : 10.0
          },
          "maximu_no_likes" : {
            "value" : 235.0
          }
        },
        ....
      ]
    }      

```
## stats
```
GET /blogposts/_search
{
  "aggs": {
    "tog_tag": {
      "terms": {
        "field": "tags.keyword",
        "size": 10
      },
      "aggs": {
        "stats_likes": {
          "stats": {
            "field": "no_of_likes"
          }
        }
        
      }
    }
  }
}
```
output:
```json
{
 "aggregations" : {
    "tog_tag" : {
      "doc_count_error_upper_bound" : 0,
      "sum_other_doc_count" : 43,
      "buckets" : [
        {
          "key" : "elasticsearch",
          "doc_count" : 9,
          "stats_likes" : {
            "count" : 9,
            "min" : 10.0,
            "max" : 235.0,
            "avg" : 118.33333333333333,
            "sum" : 1065.0
          }
        },
        {
          "key" : "java",
          "doc_count" : 4,
          "stats_likes" : {
            "count" : 4,
            "min" : 3.0,
            "max" : 128.0,
            "avg" : 61.0,
            "sum" : 244.0
          }
        },
        ...
      ]
    }        

```

## extended_stats

```
GET /blogposts/_search
{
  "aggs": {
    "tog_tag": {
      "terms": {
        "field": "tags.keyword",
        "size": 10
      },
      "aggs": {
        "stats_likes": {
          "extended_stats": {
            "field": "no_of_likes"
          }
        }
        
      }
    }
  }
}
```
output:
```json
{
"aggregations" : {
    "tog_tag" : {
      "doc_count_error_upper_bound" : 0,
      "sum_other_doc_count" : 43,
      "buckets" : [
        {
          "key" : "elasticsearch",
          "doc_count" : 9,
          "stats_likes" : {
            "count" : 9,
            "min" : 10.0,
            "max" : 235.0,
            "avg" : 118.33333333333333,
            "sum" : 1065.0,
            "sum_of_squares" : 166265.0,
            "variance" : 4471.111111111111,
            "variance_population" : 4471.111111111111,
            "variance_sampling" : 5030.0,
            "std_deviation" : 66.86636756330579,
            "std_deviation_population" : 66.86636756330579,
            "std_deviation_sampling" : 70.92249290598858,
            "std_deviation_bounds" : {
              "upper" : 252.06606845994492,
              "lower" : -15.399401793278244,
              "upper_population" : 252.06606845994492,
              "lower_population" : -15.399401793278244,
              "upper_sampling" : 260.17831914531047,
              "lower_sampling" : -23.511652478643825
            }
          }
        },
      ...
      ]
}
```

## number range aggs
```
GET /blogposts/_search
{
  "aggs": {
    "range_aggs": {
      "range": {
        "field": "no_of_likes",
        "ranges": [
          {
            "from": 0,
            "to": 50
          },
          {
            "from": 50,
            "to": 100
          },
          {
            "from": 50,
            "to": 200
          }
        ]
      }
    }
  }
}
```
output:

```json
{
"aggregations" : {
    "range_aggs" : {
      "buckets" : [
        {
          "key" : "0.0-50.0",
          "from" : 0.0,
          "to" : 50.0,
          "doc_count" : 11
        },
        {
          "key" : "50.0-100.0",
          "from" : 50.0,
          "to" : 100.0,
          "doc_count" : 1
        },
        {
          "key" : "50.0-200.0",
          "from" : 50.0,
          "to" : 200.0,
          "doc_count" : 17
        }
      ]
    }
  }
}
```

## stats base on range
```
GET /blogposts/_search
{
  "size": 0, 
  "aggs": {
    "range_aggs": {
      "range": {
        "field": "no_of_likes",
        "ranges": [
          {
            "from": 0,
            "to": 50
          },
          {
            "from": 50,
            "to": 100
          },
          {
            "from": 100
          }
        ]
      },
      "aggs": {
        "range_stats": {
          "stats": {
            "field": "no_of_likes"
          }
        }
      }
    }
  }
}

```
output:
```json
{
    "aggregations" : {
    "range_aggs" : {
      "buckets" : [
        {
          "key" : "0.0-50.0",
          "from" : 0.0,
          "to" : 50.0,
          "doc_count" : 11,
          "range_stats" : {
            "count" : 11,
            "min" : 2.0,
            "max" : 43.0,
            "avg" : 17.09090909090909,
            "sum" : 188.0
          }
        },
        ...
      ]
}
```

## only get aggs result, no query result

set `"size": 0`

```
GET /blogposts/_search
{
  "size": 0, 
  "query": {
    "term": {
      "status": {
        "value": "published"
      }
    }
  }, 
  "aggs": {
    "tog_tag": {
      "terms": {
        "field": "tags.keyword",
        "size": 10
      }
    }
  }
}
```

## date_range aggs
```
GET /blogposts/_search
{
  "size": 0,
  "aggs": {
    "daterange_aggs": {
      "date_range": {
        "field": "published_date",
        "ranges": [
          {
            "from": "now-24M/M",
            "to": "now"
          },
          {
            "from": "2015-12-31",
            "to": "2016-12-31"
          },
          {
            "from": "2016-12-31"
          }
        ]
      },
      "aggs": {
        "stats_aggs": {
          "stats": {
            "field": "no_of_likes"
          }
        }
      }
    }
  }
}
```
output:
```json
{
  "took" : 1,
  "timed_out" : false,
  "_shards" : {
    "total" : 1,
    "successful" : 1,
    "skipped" : 0,
    "failed" : 0
  },
  "hits" : {
    "total" : {
      "value" : 32,
      "relation" : "eq"
    },
    "max_score" : null,
    "hits" : [ ]
  },
  "aggregations" : {
    "daterange_aggs" : {
      "buckets" : [
        {
          "key" : "2015-12-31T00:00:00.000Z-2016-12-31T00:00:00.000Z",
          "from" : 1.45152E12,
          "from_as_string" : "2015-12-31T00:00:00.000Z",
          "to" : 1.4831424E12,
          "to_as_string" : "2016-12-31T00:00:00.000Z",
          "doc_count" : 1,
          "stats_aggs" : {
            "count" : 1,
            "min" : 43.0,
            "max" : 43.0,
            "avg" : 43.0,
            "sum" : 43.0
          }
        },
        {
          "key" : "2016-12-31T00:00:00.000Z-*",
          "from" : 1.4831424E12,
          "from_as_string" : "2016-12-31T00:00:00.000Z",
          "doc_count" : 15,
          "stats_aggs" : {
            "count" : 15,
            "min" : 2.0,
            "max" : 235.0,
            "avg" : 88.8,
            "sum" : 1332.0
          }
        },
        {
          "key" : "2018-12-01T00:00:00.000Z-2020-12-18T03:28:38.955Z",
          "from" : 1.5436224E12,
          "from_as_string" : "2018-12-01T00:00:00.000Z",
          "to" : 1.608262118955E12,
          "to_as_string" : "2020-12-18T03:28:38.955Z",
          "doc_count" : 12,
          "stats_aggs" : {
            "count" : 12,
            "min" : 2.0,
            "max" : 235.0,
            "avg" : 107.0,
            "sum" : 1284.0
          }
        }
      ]
    }
  }
}

```
## aggs by range - histogram

```
GET /blogposts/_search
{
  "size": 0,
  "aggs": {
    "hist_aggs": {
      "histogram": {
        "field": "no_of_likes",
        "interval": 50
      }
    }
  }
}
```
output:
```json
{
  "took" : 7,
  "timed_out" : false,
  "_shards" : {
    "total" : 1,
    "successful" : 1,
    "skipped" : 0,
    "failed" : 0
  },
  "hits" : {
    "total" : {
      "value" : 32,
      "relation" : "eq"
    },
    "max_score" : null,
    "hits" : [ ]
  },
  "aggregations" : {
    "hist_aggs" : {
      "buckets" : [
        {
          "key" : 0.0,
          "doc_count" : 11
        },
        {
          "key" : 50.0,
          "doc_count" : 1
        },
        {
          "key" : 100.0,
          "doc_count" : 11
        },
        {
          "key" : 150.0,
          "doc_count" : 5
        },
        {
          "key" : 200.0,
          "doc_count" : 2
        },
        ...
      ]
    }
  }
}

```

## aggs by range - date_histogram
```

GET /blogposts/_search
{
  "size": 0,
  "aggs": {
    "hist_aggs": {
      "date_histogram": {
        "field": "published_date",
        "interval": "year"
      }
    }
  }
}

```

```
GET /blogposts/_search
{
  "size": 0,
  "aggs": {
    "hist_aggs": {
      "date_histogram": {
        "field": "published_date",
        "interval": "year"
      },
      "aggs": {
        "tag_aggs": {
          "terms": {
            "field": "tags.keyword",
            "size": 10
          }
        }
      }
    }
  }
}
```
output:
```json
{
"aggregations" : {
    "hist_aggs" : {
      "buckets" : [
        {
          "key_as_string" : "2009-01-01T00:00:00.000Z",
          "key" : 1230768000000,
          "doc_count" : 3,
          "tag_aggs" : {
            "doc_count_error_upper_bound" : 0,
            "sum_other_doc_count" : 0,
            "buckets" : [
              {
                "key" : "array",
                "doc_count" : 1
              },
              {
                "key" : "database",
                "doc_count" : 1
              },
              {
                "key" : "datastructure",
                "doc_count" : 1
              },
              {
                "key" : "jaava",
                "doc_count" : 1
              },
              {
                "key" : "language",
                "doc_count" : 1
              },
              {
                "key" : "scala",
                "doc_count" : 1
              }
            ]
          }
        }
        ....
    ]
}
```
## sum
```
GET /blogposts/_search
{
  "size": 0,
  "aggs": {
    "hist_aggs": {
      "date_histogram": {
        "field": "published_date",
        "interval": "year"
      },
      "aggs": {
        "tag_aggs": {
          "terms": {
            "field": "tags.keyword",
            "size": 10
          },
          "aggs": {
            "sum_agges": {
              "sum": {
                "field": "no_of_likes"
              }
            }
          }
        }
      }
    }
  }
}
```
output: 
```json
{
     "aggregations" : {
    "hist_aggs" : {
      "buckets" : [
          ...

         {
          "key_as_string" : "2019-01-01T00:00:00.000Z",
          "key" : 1546300800000,
          "doc_count" : 10,
          "tag_aggs" : {
            "doc_count_error_upper_bound" : 0,
            "sum_other_doc_count" : 3,
            "buckets" : [
              {
                "key" : "elasticsearch",
                "doc_count" : 5,
                "sum_agges" : {
                  "value" : 764.0
                }
              },
              {
                "key" : "react",
                "doc_count" : 3,
                "sum_agges" : {
                  "value" : 353.0
                }
              },
              {
                "key" : "deployment",
                "doc_count" : 1,
                "sum_agges" : {
                  "value" : 100.0
                }
              },
              ...
            ]
          }
        },
        ....
      ]
}
```
# Logtash

https://www.elastic.co/guide/en/logstash/current/index.html

## input from stdin => elasticsearch

```config
input{
    stdin{
        codec => json
    }
}

filter{
    mutate {
        rename => ["age", "person_age"]
    }
}

output{
    stdout{}
    file{
        path => "output.txt"
    }
    elasticsearch{
        hosts => "localhost:9200"
        index => "person"
        document_type => "_doc"
    }
}
```

## input from file => elasticsearch

```config
input{
   file{
       path => [ "/Users/yongliu/Documents/software/elasticsearch7/logstash-7.10.1/input.txt" ]
       start_position => "beginning"
       sincedb_path => "/Users/yongliu/Documents/software/elasticsearch7/logstash-7.10.1/sincedb_file"
       codec => json
   }
}

filter{
    mutate {
        rename => ["age", "person_age"]
    }
}

output{
    stdout{}
    file{
        path => "output.txt"
    }
    elasticsearch{
        hosts => "localhost:9200"
        index => "person"
        document_type => "_doc"
    }
}

```
## run logstash
```
./bin/logstash -f config/logstash_inputfromfile.conf

./bin/logstash -e 'input{stdin{}} output{stdout{}}'

```

