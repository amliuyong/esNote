
#
# Query URL
#
GET /product/_search?q=*

GET /product/_search?q=name:Lobster

GET /product/_search?q=tags:Meat AND name:Tuna


#
# Query DSL
#
```
GET /product/_search
{
  "query": {
    "match_all": {}
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


GET  /product/_search?explain=true
{
  "query": {
    "term": {
      "name": {
        "value": "lobster"
      }
    }
  }
}

GET /product/_doc/19/_explain
{
  "query": {
    "term": {
      "name": {
        "value": "lobster"
      }
    }
  }
}
```

#
# Full text search
#
```
GET /recipe/_search
{
  "query": {
    "match": {
      "title": "Pasta or Spaghetti With Capers"
    }
  }
}

GET /recipe/_search
{
  "query": {
    "match": {
      "title": {
        "query": "Pasta Spaghetti With Capers",
        "operator": "and"
      }
    }
  }
}


GET /recipe/_search
{
  "query": {
    "match_phrase": {
      "title": "Pasta or Spaghetti With Capers"
    }
  }
}


GET /recipe/_search
{
  "query": {
    "multi_match": {
      "query": "pasta",
      "fields": ["title", "description"]
    }
  }
}

```
#
# Query with bool logic
#
```
GET /recipe/_search
{
  "query": {
    "bool": {
      "must": [
        {
          "match": {
            "ingredients.name": "parmesan"
          }
        }, 
        {
          "rage": {
            "preparation_time_minutes": {
              "lte": 15
            }
          }
        }
      ]
    }
  }
}



GET /recipe/_search
{
  "query": {
    "bool": {
      "must": [
        {
          "match": {
            "ingredients.name": "parmesan"
          }
        }
      ],
      "must_not": [
        {
          "match": {
            "ingredients.name": "tuna"
          }
        }
      ],
      "should": [
        {
          "match": {
            "ingredients.name": "parsley"
          }
        }
      ],
      "filter": [
        {
          "rage": {
            "preparation_time_minutes": {
              "lte": 15
            }
          }
        }
      ]
    }
  }
}
```

# debug of match
```
GET /recipe/_search
{
  "query": {
    "bool": {
      "must": [
        {
          "match": {
            "ingredients.name": {
              "query": "parmesan",
              "_name": "must_parmesan" 
            }
          }
        }
      ],
      "must_not": [
        {
          "match": {
            "ingredients.name": {
              "query": "tuna",
              "_name": "must_not_tuna"
            }
          }
        }
      ],
      "should": [
        {
          "match": {
            "ingredients.name": {
              "query":  "parsley",
              "_name": "should_parsley"
            }
          }
        }
      ],
      "filter": [
        {
          "rage": {
            "preparation_time_minutes": {
              "lte": 15,
              "_name": "filter_preparation_time_minutes"
            }
          }
        }
      ]
    }
  }
}


"matched_queries" : [
          "should_parsley",
          "filter_preparation_time_minutes",
          "must_parmesan"
        ]
        
```

#
# nested Query
#


## maping for nested object
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

```
## test data

POST /department/_doc/1
```json
{
  "name": "Development",
  "employees": [
    {
      "name": "Eric Green",
      "age": 39,
      "gender": "M",
      "position": "Big Data Specialist"
    },
    {
      "name": "Eric",
      "age": 40,
      "gender": "M",
      "position": "Software Developer"
    },
    {
      "name": "James Taylor",
      "age": 41,
      "gender": "F",
      "position": "Big Data Specialist"
    },
    
    {
      "name": "Gary Jenkins",
      "age": 28,
      "gender": "M",
      "position": "Senor Software Developer"
    },
    {
      "name": "Julie Powell",
      "age": 19,
      "gender": "F",
      "position": "Software Developer"
    },
    {
      "name": "Sam",
      "age": 18,
      "gender": "M",
      "position": "Intern"
    },
    {
      "name": "Smith",
      "age": 45,
      "gender": "F",
      "position": "Senor Software Developer"
    }
    
    ]
}
```


POST /department/_doc/2
```json
{
  "name": "HR & Marketing",
  "employees": [
    {
      "name": "Eric Green HR",
      "age": 39,
      "gender": "M",
      "position": "Marketing Manager"
    },
    {
      "name": "Eric HR",
      "age": 40,
      "gender": "M",
      "position": "Manager level 1"
    },
    
    {
      "name": "Gary Jenkins HR",
      "age": 28,
      "gender": "M",
      "position": "Manager level 1"
    },
    {
      "name": "Julie Powell HR",
      "age": 19,
      "gender": "F",
      "position": "Head of HR"
    },
    {
      "name": "Sam HR",
      "age": 18,
      "gender": "M",
      "position": "Intern"
    },
    {
      "name": "Smith HR",
      "age": 19,
      "gender": "F",
      "position": "Intern"
    }
    
    ]
}
```

```
GET /department/_search
{
  "query": {
    "nested": {
      "path": "employees",
      "query": {
        "bool": {
          "must": [
            {
              "match": {
                "employees.position": "intern"
              }
            },
            {
              "term": {
                "employees.gender.keyword": {
                  "value": "F"
                }
              }
            }
          ]
        }
      }
    }
  }
}

```

## inner_hits, only show innter objects
```
GET /department/_search
{
  "_source": false, 
  "query": {
    "nested": {
      "path": "employees",
      "inner_hits": {}, 
      "query": {
        "bool": {
          "must": [
            {
              "match": {
                "employees.position": "intern"
              }
            },
            {
              "term": {
                "employees.gender.keyword": {
                  "value": "F"
                }
              }
            }
          ]
        }
      }
    }
  }
}
```

#
# Joining and relations
#

## mapping for join and relations
```
PUT /department2
{
  "mappings": {
    "properties": {
      "join_field": {
        "type": "join",
        "relations": {
          "department": "employee"
        }
      }
    }
  }
}

PUT /department2/_doc/1
{
  "name": "Development",
  "join_field": "department"
}



PUT /department2/_doc/2
{
  "name": "Marketing",
  "join_field": "department"
}



PUT /department2/_doc/3?routing=1
{
      "name": "Sam",
      "age": 18,
      "gender": "M",
      "position": "Intern",
      "join_field": {
        "name": "employee",
        "parent": 1
      }
      
}

PUT /department2/_doc/5?routing=1
{
      "name": "Sam Intern",
      "age": 8,
      "gender": "F",
      "position": "Intern",
      "join_field": {
        "name": "employee",
        "parent": 1
      }
      
}



PUT /department2/_doc/4?routing=2
{
      "name": "Sam Marketing",
      "age": 88,
      "gender": "F",
      "position": "Intern",
      "join_field": {
        "name": "employee",
        "parent": 2
      }
      
}
```

## search from parent
```
GET /department2/_search
{
  "query": {
    "parent_id": {
      "type": "employee",
      "id": 1
    }
  }
}


GET /department2/_search 
{
  "query": {
    "has_parent": {
      "parent_type": "department",
      "score": true,
      "query": {
        "term": {
          "name": "marketing"
        }
      }
    }
  }
}
```
## search from child 
```
GET /department2/_search
{
  "query": {
    "has_child": {
      "type": "employee",
      "score_mode": "sum", 
      "min_children": 1, 
      "max_children": 10, 
      "query": {
        "bool": {
          "must": [
            {
              "rage": {
                "age": {
                  "gte": 10
                }
              }
            }
          ],
          "should": [
            {
              "term": {
                "gender.keyword": {
                  "value": "M"
                }
              }
            }
          ]
        }
      }
    }
  }
}
```

## inner_hits
```
GET /department2/_search
{
  "query": {
    "has_parent": {
      "parent_type": "department",
      "inner_hits": {},
      "query": {
        "term": {
          "name.keyword": {
            "value": "Development"
          }
        }
      }
    }
  }
}

```

#
# Multi-level relations
#

## test data
```
PUT /company
{
  "mappings": {
    "properties": {
      "join_field": {
        "type": "join",
        "relations": {
          "company": ["department", "supplier"],
          "department": "employee"
        }
      }
    }
  }
}


PUT /company/_doc/1
{
  "name": "My Company 1 Inc",
  "join_field": "company"
}

PUT /company/_doc/2?routing=1
{
  "name": "Development",
  "join_field": {
    "name": "department",
    "parent": 1
  }
}

PUT /company/_doc/3?routing=1
{
  "name": "Bo Andrsen",
  "join_field": {
    "name": "employee",
    "parent": 2
  }
}

PUT /company/_doc/4
{
  "name": "Another Commany, Inc",
  "join_field": "company"
}

PUT /company/_doc/5?routing=4
{
  "name": "Marking",
  "join_field": {
    "name": "department",
    "parent": 4
  }
}

PUT /company/_doc/6?routing=4
{
  "name": "John Doe",
  "join_field": {
    "name": "employee",
    "parent": 5
  }
}



GET /company/_search 
{
  "query": {
    "has_child": {
      "type": "department",
      "query": {
        "has_child": {
          "type": "employee",
          "query": {
            "term": {
              "name.keyword": {
                "value": "John Doe"
              }
            }
          }
        }
      }
    }
  }
}

```


#
# terms lookup
# Serach another index from a index 
#

```
PUT /users/_doc/1
{
  "name": "John Roberts",
  "following": [2,3]
}

PUT /users/_doc/2
{
  "name": "Elizabeth Ross",
  "following": []
}


PUT /users/_doc/3
{
  "name": "Jeremy Brooks",
  "following": [1, 2]
}

PUT /users/_doc/4
{
  "name": "Diana Moore",
  "following": [3, 1]
}


PUT /stories/_doc/1
{
  "user": 3,
  "content": "Wow look, a penguin!"
}


PUT /stories/_doc/2
{
  "user": 1,
  "content": "Just another day at the office: #coffee"
}


PUT /stories/_doc/3
{
  "user": 2,
  "content": "Boo Foo!"
}



GET /stories/_search
{
  "query": {
    "terms": {
      "user": {
        "index": "users",
        "id": 1,
        "path": "following"
      }
    }
  }
}
```










#
# Control the output
#

## _source  
```
GET /recipe/_search?format=yaml
{
  "_source": false, 
  "query": {
    "match": {
      "title": "Pasta or Spaghetti With Capers"
    }
  }
}


GET /recipe/_search?pretty
{
  "_source": "created", 
  "query": {
    "match": {
      "title": "Pasta or Spaghetti With Capers"
    }
  }
}

GET /recipe/_search
{
  "_source": "ingredients.name", 
  "query": {
    "match": {
      "title": "Pasta or Spaghetti With Capers"
    }
  }
}

GET /recipe/_search
{
  "_source": "ingredients.*", 
  "query": {
    "match": {
      "title": "Pasta or Spaghetti With Capers"
    }
  }
}

GET /recipe/_search
{
  "_source":  ["ingredients.*", "created" ], 
  "query": {
    "match": {
      "title": "Pasta or Spaghetti With Capers"
    }
  }
}

GET /recipe/_search
{
  "_source": {
    "includes": "ingredients.*",
    "excludes": "ingredients.name"
  },
  "query": {
    "match": {
      "title": "Pasta or Spaghetti With Capers"
    }
  }
}

```

## size and from
## pagination: from = size * (page_num -1)
```
GET /recipe/_search?size=2
{
  "_source": false, 
  "query": {
    "match": {
      "title": "Pasta"
    }
  }
}

GET /recipe/_search
{
  "size": 2, 
  "_source": false, 
  "query": {
    "match": {
      "title": "Pasta"
    }
  }
}

GET /recipe/_search
{
  "size": 2, 
  "from":2,
  "_source": false, 
  "query": {
    "match": {
      "title": "Pasta"
    }
  }
}
```

## sort result
```
GET /recipe/_search
{
  "query": {
    "match_all": {}
  },
  "sort": [
     { "preparation_time_minutes": "desc"}
  ]
}


GET /recipe/_search
{
  "_source": [
    "preparation_time_minutes",
    "created"
  ],
  "query": {
    "match_all": {}
  },
  "sort": [
    {
      "created": "desc"
    },
    {
      "preparation_time_minutes": "desc"
    }
  ]
}
```
## sort by array value
```
GET /recipe/_search
{
  "_source": [
    "ratings"
  ],
  "query": {
    "match_all": {}
  },
  "sort": [
    {
      "ratings": {
        "order": "desc",
        "mode": "avg"
      }
    }
  ]
}
```
## filter
```
GET /recipe/_search
{
  "_source": "preparation_time_minutes", 
  "query": {
    "bool": {
      "must": [
        {
          "match": {
            "title": "pasta"
          }
        }
      ],
      "filter": [
        {
          "rage": {
            "preparation_time_minutes": {
              "lte": 15
            }
          }
        }
      ]
    }
  }
}
```

#
# Advance Search
#

```
PUT /proximity/_doc/1
{
  "title": "Spicy Sauce"
}

PUT /proximity/_doc/2
{
  "title": "Spicy Tomato Sauce"
}

PUT /proximity/_doc/3
{
  "title": "Spicy Tomato and Garlic Sauce"
}

PUT /proximity/_doc/4
{
  "title": "Tomato Sauce (spicy)"
}

PUT /proximity/_doc/5
{
  "title": "Spicy and very delicious Tomato Sauce"
}
```

## proximity search
```
GET /proximity/_search
{
  "query": {
    "match_phrase": {
      "title": {
        "query": "spicy sauce",
        "slop": 1
      }
    }
  }
}

==> 

hits" : [
      {
        "_index" : "proximity",
        "_type" : "_doc",
        "_id" : "1",
        "_score" : 0.17972642,
        "_source" : {
          "title" : "Spicy Sauce"
        }
      },
      {
        "_index" : "proximity",
        "_type" : "_doc",
        "_id" : "2",
        "_score" : 0.10375118,
        "_source" : {
          "title" : "Spicy Tomato Sauce"
        }
      }
    ]

```

```
GET /proximity/_search
{
  "query": {
    "bool": {
      "must": [
        {
          "match": {
            "title": {
              "query": "spicy sauce"
            }
          }
        }
      ],
      "should": [
        {
          "match_phrase": {
            "title": {
              "query": "spicy sauce",
              "slop": 5
            }
          }
        }
      ]
    }
  }
}

```

## fuzzy match - typo
```
GET /product/_search
{
  "_source": "name", 
  "query": {
    "match": {
      "name": {
        "query": "l0bster",
        "fuzziness": "auto"
      }
    }
  }
}

GET /product/_search
{
  "_source": "name", 
  "query": {
    "match": {
      "name": {
        "query": "l0bster love",
        "operator": "and", 
        "fuzziness": 1
      }
    }
  }
}


GET /product/_search
{
  "query": {
    "fuzzy": {
      "name": {
        "value": "l0bster",
        "fuzziness": "auto"
      }
    }
  }
}
```

#
# synonyms
#

see file: es_analyze.txt


#
# highlighting
#
```
POST /highlighting/_doc/1
{
  "description": "The elk or wapiti is one of the largest species within the deer family, Cervidae, and one of the largest terrestrial mammals in North America and Northeast Asia. This animal should not be confused with the still larger Alces alces, known as the moose in America, but as the elk in British English and in reference to populations in Eurasia."
}
GET /highlighting/_search
{
  "_source": false,
  "query": {
    "match": {
      "description": "America"
    }
  },
  "highlight": {
    "pre_tags": [
      "<strong>"
    ],
    "post_tags": [
      "</strong>"
    ],
    "fields": {
      "description": {}
    }
  }
}

```

#
# stemming - english
# 
```
PUT /stemming_test
{
  "settings": {
    "analysis": {
      "filter": {
        "synonym_test": {
          "type": "synonym",
          "synonyms": [
            "firm => company",
            "love, enjoy"
          ]
        },
        "stemmer_test": {
          "type": "stemmer",
          "name": "english"
        }
      },
      "analyzer": {
        "my_analyzer": {
          "tokenizer": "standard",
          "filter": [
            "lowercase",
            "synonym_test",
            "stemmer_test"
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
```
POST /stemming_test/_doc/1
{
  "description": "I love working for my firm!"
}


GET /stemming_test/_search
{
  "query": {
    "match": {
      "description": "enjoying work"
    }
  }
}
```
