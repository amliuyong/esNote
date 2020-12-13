# _analyze
```
POST _analyze 
{
  "tokenizer": "standard",
  "text": "I'm in the mood for drinking semi-dry red wine!"
}


POST _analyze 
{
  "filter": ["lowercase"],
  "text": "I'm in the mood for drinking semi-dry red wine!"
}

POST _analyze 
{
  "analyzer": "standard",
  "text": "I'm in the mood for drinking semi-dry red wine!"
}
```


```
PUT /existing_analyzer_config
{
  "settings": {
    "analysis": {
      "analyzer": {
        "englisth_stop": {
          "type": "standard",
          "stopwords":"_english_"
        }
      },
      "filter": {
        "my_stemmer": {
          "type": "stemmer",
          "name": "english"
        }
      }
    }
  }
}


POST /existing_analyzer_config/_analyze
{
  "analyzer": "englisth_stop",
  "text": "I'm in the mood for drinking semi-dry red  wine!"
}


POST /existing_analyzer_config/_analyze
{
  "tokenizer": "standard",
  "filter": ["my_stemmer"], 
  "text": "I'm in the mood for drinking semi-dry red  wine!"
}
```

#
# Create Index with analyzer
#
```
PUT /analyzers_test
{
  "settings": {
    "analysis": {
      "analyzer": {
        "englisth_stop": {
          "type": "standard",
          "stopwords":"_english_"
        },
        "my_analyzer": {
          "type": "custom",
          "tokenizer": "standard",
          "char_filter":[
            "html_strip"
            ],
          "filter": [
            "lowercase",
            "trim",
            "my_stemmer"
            ]
        }
      },
      "filter": {
        "my_stemmer": {
          "type": "stemmer",
          "name": "english"
        }
      }
    }
  }
}

POST /analyzers_test/_analyze
{
  "analyzer": "my_analyzer",
  "text": "I'm in the mood for drinking <strong>semi-dry</strong> red  wine!"
}

```

#
# use analyzer in mapping
#
```
POST /analyzers_test/_mapping
{
  "properties": {
    "description": {
      "type": "text",
      "analyzer": "my_analyzer"
    },
    "teaser": {
      "type": "text",
      "analyzer": "standard"
    }
  }
}


POST /analyzers_test/_doc/1
{
  "description": "drinking",
  "teaser": "drinking"
}


GET  /analyzers_test/_search
{
  "query": {
    "term": {
      "teaser": {
        "value": "drinking"
      }
    }
  }
}


GET  /analyzers_test/_search   ===> No result !!!
{
  "query": {
    "term": {
      "description": {
        "value": "drinking"
      }
    }
  }
}

GET  /analyzers_test/_search
{
  "query": {
    "match": {
      "description": "drinking"
    }
  }
}
```


#
# Add analyzer to existing index
#
```
POST /analyzers_test/_close

PUT /analyzers_test/_settings
{
  "settings": {
    "analysis": {
      "analyzer": {
        "frensh_stop": {
          "type": "standard",
          "stopwords":"_frensh_"
        }
      }
    }
  }
}
POST /analyzers_test/_open

```

#
# synonyms
#
```
DELETE  /synonyms

PUT /synonyms
{
  "settings": {
    "analysis": {
      "filter": {
        "synonym_test": {
          "type": "synonym",
          "synonyms": [
            "awful => terrible",
            "awesome => great, super",
            "elasticsearch, logstash, kibana => elk",
            "weird, strange"
          ]
        }
      },
      "analyzer": {
        "my_analyzer": {
          "tokenizer": "standard",
          "filter": [
            "lowercase",
            "synonym_test"
          ]
        }
      }
    }
  },
  "mappings": {
    "properties": {
      "description": {
        "type": "text",
        "analyzer": "my_analyzer"
      }
    }
  }
}


POST /synonyms/_analyze
{
  "analyzer": "my_analyzer",
  "text": "awesome"
}



POST /synonyms/_analyze
{
  "analyzer": "my_analyzer",
  "text": "Elasticsearch"
}


POST /synonyms/_analyze
{
  "analyzer": "my_analyzer",
  "text": "weird"
}



POST /synonyms/_analyze
{
  "analyzer": "my_analyzer",
  "text": "Elasticsearch is awesome, but can also seem weird sometimes."
}



POST /synonyms/_doc/1
{
    "description": "Elasticsearch is awesome, but can also seem weird sometimes."
}


GET /synonyms/_search
{
  "query": {
    "match": {
      "description": "Great"
    }
  }
}


GET /synonyms/_search
{
  "query": {
    "match": {
      "description": "awesome"
    }
  }
}

# force existing doc to re-index to taken new synonyms
POST /synonyms/_update_by_query



# define synonyms from file

# file: elasticsearch-7.6.0/config/synonyms.txt

awful => terrible
awesome => great, super
elasticsearch, logstash, kibana => elk
weird, strange


PUT /synonyms
{
  "settings": {
    "analysis": {
      "filter": {
        "synonym_test": {
          "type": "synonym",
          "synonyms_path": "synonyms.txt"
        }
      },
      "analyzer": {
        "my_analyzer": {
          "tokenizer": "standard",
          "filter": [
            "lowercase",
            "synonym_test"
          ]
        }
      }
    }
  },
  "mappings": {
    "properties": {
      "description": {
        "type": "text",
        "analyzer": "my_analyzer"
      }
    }
  }
}
```
