# Run

```
logstash-7.10.1/bin/logstash -f logstash-7.10.1/config/logstash-access_log.conf

```

# Apache log to logstash

```conf

input {
    file {
        path => "/Users/yongliu/Desktop/Video/elasticSearch/access_log"
        start_position => "beginning"
    }
}

filter {
    grok {
        match => { "message" => "%{COMBINEDAPACHELOG}" }
    }
    date {
        match =>  [ "timestamp", "dd/MMM/yyyy:HH:mm:ss Z" ]
    }
}

output {
    elasticsearch {
        hosts => ["localhost:9200"]
        index => "server_acc_log"
    }
    stdout {
        codec => rubydebug
    }
}


```
# Stdin to logstash
```conf
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
## output to file

```conf
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

# MySQL to logstash

https://www.elastic.co/guide/en/logstash/current/plugins-inputs-jdbc.html

## prepare data

wget http://files.grouplens.org/datasets/movielens/ml-100k.zip

```
mysql --local_infile=1 -u root -pmysqlroot movielens

```
## local data 
```sql
SET GLOBAL local_infile=1;

create database movielens;

create table movielens.movies (
     movieID int primary key not null,
     title text,
     releaseDate date
      );

load data local infile 'ml-100k/u.item' into 
 table movielens.movies fields terminated by '|' 
     (movieID, title, @var3) 
     set releaseDate = STR_TO_DATE(@var3, '%d-%M-%Y');

```
## create user 
```sql
create user 'student'@'localhost' identified by 'password';

grant all privileges on *.* to 'student'@'localhost';

flush privileges;

```
### Conf

```conf

input {
    jdbc {
        jdbc_connection_string => "jdbc:mysql://localhost:3306/movielens"
        jdbc_user => "student"
        jdbc_password => "password"
        jdbc_driver_library => "/Users/yongliu/Documents/software/elasticsearch7/jdbc/mysql-connector-java-8.0.21.jar"
        jdbc_driver_class => "com.mysql.jdbc.Driver"
        statement => "select * from movies"
    }
}


output {
    elasticsearch {
        hosts => ["localhost:9200"]
        index => "movielens-movies"
    }
    stdout {
        codec => json_lines
    }
}

```
### Another Conf

```conf
input {
  jdbc {
    jdbc_driver_library => "mysql-connector-java-8.0.21.jar"
    jdbc_driver_class => "com.mysql.jdbc.Driver"
    jdbc_connection_string => "jdbc:mysql://localhost:3306/mydb"
    jdbc_user => "mysql"
    parameters => { "favorite_artist" => "Beethoven" }
    schedule => "* * * * *"
    statement => "SELECT * from songs where artist = :favorite_artist"

    
  }
}
```

### sql_last_value
```conf
input {
  jdbc {
    statement => "SELECT id, mycolumn1, mycolumn2 FROM my_table WHERE id > :sql_last_value"
    use_column_value => true
    tracking_column => "id"
    # ... other configuration bits
  }
}
```

# CSV to logstash
wget  https://raw.githubusercontent.com/coralogix-resources/elk-course-samples/master/csv-read.conf

```conf
input {
  file {
    path => "/Users/yongliu/Desktop/Video/elasticSearch/csvData/csv-schema-short-numerical.csv"
    start_position => "beginning"
    sincedb_path => "/tmp/log_sincedb"
  }
}
filter {
  csv {
    separator => ","
    skip_header => "true"
    columns => ["id", "timestamp", "paymentType", "name", "gender", "ip_address", "purpose", "country", "age"]
  }
}
output {
  elasticsearch {
    hosts => "http://localhost:9200"
    index => "demo-csv"
  }

  stdout {
    codec => rubydebug
  }

}
```
## mutate CSV - convert and remove_field
```conf
input {
    file {
        path => "/Users/yongliu/Desktop/Video/elasticSearch/csvData/csv-schema-short-numerical.csv"
        start_position => "beginning"
        sincedb_path => "/tmp/log-demo-csv-drop"
    }
}
filter {
    csv {
        separator => ","
        skip_header => "true"
        columns => ["id", "timestamp", "paymentType", "name", "gender", "ip_address", "purpose", "country", "age"]
    }
    mutate {
        convert => {
            age => "integer"
        }
        remove_field => ["message", "@timestamp", "path", "host", "@version"]
    }
}
output {
    elasticsearch {
        hosts => "http://localhost:9200"
        index => "demo-csv-drop"
    }

    stdout {
        codec => rubydebug
    }
}

```

# JSON to logstash

wget http://media.sundog-soft.com/es/sample-json.log

```conf

input {
  file {
    path => "/Users/yongliu/Desktop/Video/elasticSearch/jsonData/sample-json.log"
    start_position => "beginning"
    sincedb_path => "/tmp/log_sincedb-json"
  }
}

filter {
  json {
    source => "message"
  }
}

output {

  elasticsearch {
    hosts => "http://localhost:9200"
    index => "demo-json"
  }

  stdout {
  }

}
```

 note the message field

```json
        "_source" : {
          "ip_address" : "77.72.239.47",
          "@version" : "1",
          "host" : "YongLius-MacBook-Pro.local",
          "country" : "Poland",
          "path" : "/Users/yongliu/Desktop/Video/elasticSearch/jsonData/sample-json.log",
          "gender" : "Female",
          "message" : """{"id":2,"timestamp":"2019-08-11T17:55:56Z","paymentType":"Visa","name":"Darby Dacks","gender":"Female","ip_address":"77.72.239.47","purpose":"Shoes","country":"Poland","age":55}""",
          "timestamp" : "2019-08-11T17:55:56Z",
          "@timestamp" : "2020-12-20T03:44:45.984Z",
          "name" : "Darby Dacks",
          "id" : 2,
          "age" : 55,
          "paymentType" : "Visa",
          "purpose" : "Shoes"
        }
      }
```

### drop record and remove_field

```conf
input {
  file {
    path => "/Users/yongliu/Desktop/Video/elasticSearch/jsonData/sample-json.log"
    start_position => "beginning"
    sincedb_path => "/tmp/log_sincedb-json-drop"
  }
}

filter {

  json {
    source => "message"
  }
  
  if [paymentType] == "Mastercard" {
      drop {}
  }
  
  mutate {
       remove_field => ["message", "@timestamp", "path", "host", "@version"]
  }

}

output {

  elasticsearch {
    hosts => "http://localhost:9200"
    index => "demo-json-drop"
  }

  stdout {
  }

}

```

### split array

 input json
```json
{"id":1,"timestamp":"2019-06-19T23:04:47Z","paymentType":"Mastercard","name":"Ardis Shimuk","gender":"Female","ip_address":"91.33.132.38","purpose":"Home","country":"France","pastEvents":[{"eventId":1,"transactionId":"trx14224"},{"eventId":2,"transactionId":"trx23424"}],"age":34}
{"id":2,"timestamp":"2019-11-26T15:40:56Z","paymentType":"Amex","name":"Benoit Urridge","gender":"Male","ip_address":"26.71.230.228","purpose":"Shoes","country":"Brazil","pastEvents":[{"eventId":3,"transactionId":"63323-064"},{"eventId":4,"transactionId":"0378-3120"}],"age":51}

```


```conf
input {
  file {
    path => "/Users/yongliu/Desktop/Video/elasticSearch/jsonData/sample-json-split.log"
    start_position => "beginning"
    sincedb_path => "/tmp/log_sincedb-json-split"
  }
}

filter {

  json {
    source => "message"
  }
  
  split {
      field  => "[pastEvents]"
  }
  
  mutate {
       remove_field => ["message", "@timestamp", "path", "host", "@version"]
  }

}

output {

  elasticsearch {
    hosts => "http://localhost:9200"
    index => "demo-json-split"
  }

  stdout {
  }

}

```
output: 
```json
{
        "_index" : "demo-json-split",
        "_type" : "_doc",
        "_id" : "PCpMfnYBGjuqqR2HsEyw",
        "_score" : 1.0,
        "_source" : {
          "gender" : "Female",
          "timestamp" : "2019-06-19T23:04:47Z",
          "purpose" : "Home",
          "pastEvents" : {
            "eventId" : 1,
            "transactionId" : "trx14224"
          },
          "age" : 34,
          "country" : "France",
          "paymentType" : "Mastercard",
          "name" : "Ardis Shimuk",
          "id" : 1,
          "ip_address" : "91.33.132.38"
        }
},

{
        "_index" : "demo-json-split",
        "_type" : "_doc",
        "_id" : "PSpMfnYBGjuqqR2HsEyw",
        "_score" : 1.0,
        "_source" : {
          "gender" : "Female",
          "timestamp" : "2019-06-19T23:04:47Z",
          "purpose" : "Home",
          "pastEvents" : {
            "eventId" : 2,
            "transactionId" : "trx23424"
          },
          "age" : 34,
          "country" : "France",
          "paymentType" : "Mastercard",
          "name" : "Ardis Shimuk",
          "id" : 1,
          "ip_address" : "91.33.132.38"
}


```

## add `pastEvents` to top level

```conf

input {
  file {
    path => "/Users/yongliu/Desktop/Video/elasticSearch/jsonData/sample-json-split.log"
    start_position => "beginning"
    sincedb_path => "/tmp/log_sincedb-json-split-structured"
  }
}

filter {

  json {
    source => "message"
  }
  
  split {
      field  => "[pastEvents]"
  }
  
  mutate {
        add_field => {
            "eventId" => "%{[pastEvents][eventId]}"
            "transactionId" => "%{[pastEvents][transactionId]}"
        }
       remove_field => ["message", "@timestamp", "path", "host", "@version", "pastEvents"]
  }

}

output {

  elasticsearch {
    hosts => "http://localhost:9200"
    index => "demo-json-split-structured"
  }

  stdout {
  }
}

```

output

```json
{
        "_index" : "demo-json-split-structured",
        "_type" : "_doc",
        "_id" : "TypYfnYBGjuqqR2HCUyQ",
        "_score" : 1.0,
        "_source" : {
          "purpose" : "Computers",
          "age" : 41,
          "country" : "Brazil",
          "gender" : "Female",
          "ip_address" : "159.148.102.98",
          "paymentType" : "Visa",
          "timestamp" : "2020-02-18T12:27:35Z",
          "transactionId" : "55154-3330",
          "name" : "Betteanne Diament",
          "id" : 5,
          "eventId" : "10"
        }
      }

```
