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


# grok filter - parese unstructure data

https://www.elastic.co/guide/en/logstash/current/plugins-filters-grok.html

http://grokdebug.herokuapp.com/


```conf
input {
  file {
    path => "/home/student/03-grok-examples/sample.log"
    start_position => "beginning"
    sincedb_path => "/dev/null"
  }
}

filter {
  grok {
    match => { "message" => [
              '%{TIMESTAMP_ISO8601:time} %{LOGLEVEL:logLevel} %{GREEDYDATA:logMessage}',
              '%{IP: } %{WORD:httpMethod} %{URIPATH:url}'
              ] }
  }
}

output {
   elasticsearch {
     hosts => "http://localhost:9200"
     index => "demo-grok-multiple"
  }

stdout {}

}
```
## grok for Nigx log
```
73.44.199.53 - - [01/Jun/2020:15:49:10 +0000] "GET /blog/join-in-mongodb/?relatedposts=1 HTTP/1.1" 200 131 "https://www.techstuds.com/blog/join-in-mongodb/" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.61 Safari/537.36"

```

```conf
input {
file {
   path => ["/etc/logstash/conf.d/logstash/nginx/access.log"]
   start_position => "beginning"
   sincedb_path => "/dev/null"
 }
}
filter {
      grok {
        match => { "message" => ["%{IPORHOST:remote_ip} - %{DATA:user_name} \[%{HTTPDATE:access_time}\] \"%{WORD:http_method} %{DATA:url} HTTP/%{NUMBER:http_version}\" %{NUMBER:response_code} %{NUMBER:body_sent_bytes} \"%{DATA:referrer}\" \"%{DATA:agent}\""] }
        remove_field => "message"
      }
      mutate {
        add_field => { "read_timestamp" => "%{@timestamp}" }
      }
      date {
        match => [ "timestamp", "dd/MMM/YYYY:H:m:s Z" ]
        remove_field => "timestamp"
      }
}
output{
  elasticsearch{
    hosts => ["localhost:9200"] 
    index => "nginx-access-logs-02" 
  }
  stdout { 
    codec => "rubydebug"
   }
}


```

## grok multiline - elasticsearch log
```
[2020-06-15T17:13:35,029][INFO ][o.e.x.s.s.SecurityStatusChangeListener] [node-1] Active license is now [BASIC]; Security is disabled
[2020-06-15T17:13:35,097][INFO ][o.e.g.GatewayService     ] [node-1] recovered [18] indices into cluster_state
[2020-06-15T17:13:35,457][WARN ][r.suppressed             ] [node-1] path: /.kibana/_count, params: {index=.kibana}
org.elasticsearch.action.search.SearchPhaseExecutionException: all shards failed
	at org.elasticsearch.action.search.AbstractSearchAsyncAction.onPhaseFailure(AbstractSearchAsyncAction.java:551) [elasticsearch-7.7.0.jar:7.7.0]
	at org.elasticsearch.action.search.AbstractSearchAsyncAction.executeNextPhase(AbstractSearchAsyncAction.java:309) [elasticsearch-7.7.0.jar:7.7.0]
	at org.elasticsearch.action.search.AbstractSearchAsyncAction.onPhaseDone(AbstractSearchAsyncAction.java:580) [elasticsearch-7.7.0.jar:7.7.0]
	at org.elasticsearch.action.search.AbstractSearchAsyncAction.onShardFailure(AbstractSearchAsyncAction.java:393) [elasticsearch-7.7.0.jar:7.7.0]
	at org.elasticsearch.action.search.AbstractSearchAsyncAction.lambda$performPhaseOnShard$0(AbstractSearchAsyncAction.java:223) [elasticsearch-7.7.0.jar:7.7.0]
	at org.elasticsearch.action.search.AbstractSearchAsyncAction$2.doRun(AbstractSearchAsyncAction.java:288) [elasticsearch-7.7.0.jar:7.7.0]
	at org.elasticsearch.common.util.concurrent.AbstractRunnable.run(AbstractRunnable.java:37) [elasticsearch-7.7.0.jar:7.7.0]
	at org.elasticsearch.common.util.concurrent.TimedRunnable.doRun(TimedRunnable.java:44) [elasticsearch-7.7.0.jar:7.7.0]
	at org.elasticsearch.common.util.concurrent.ThreadContext$ContextPreservingAbstractRunnable.doRun(ThreadContext.java:692) [elasticsearch-7.7.0.jar:7.7.0]
	at org.elasticsearch.common.util.concurrent.AbstractRunnable.run(AbstractRunnable.java:37) [elasticsearch-7.7.0.jar:7.7.0]
	at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1130) [?:?]
	at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:630) [?:?]
	at java.lang.Thread.run(Thread.java:832) [?:?]

```

```conf

input {
  file {
    path => "/etc/logstash/conf.d/logstash/elasticsearch_logs/elasticsearch.log"
    type => "elasticsearch"
    start_position => "beginning" 
    sincedb_path => "/dev/null"
    codec => multiline {
      pattern => "^\["
      negate => true
      what => "previous"
    }
  }
}

filter {
  if [type] == "elasticsearch" {
    grok {
      match => [ "message", "\[%{TIMESTAMP_ISO8601:timestamp}\]\[%{DATA:severity}%{SPACE}\]\[%{DATA:source}%{SPACE}\]%{SPACE}(?<message>(.|\r|\n)*)" ]
      overwrite => [ "message" ]
    }

    if "_grokparsefailure" not in [tags] {
      grok {  
        match => [
          "message", "^\[%{DATA:node}\] %{SPACE}\[%{DATA:index}\]%{SPACE}(?<short_message>(.|\r|\n)*)",
          "message", "^\[%{DATA:node}\]%{SPACE}(?<short_message>(.|\r|\n)*)" ]
        tag_on_failure => []
      }
    }
  }
}

output {
  elasticsearch {
            hosts => [ "localhost:9200"]
            index => "es-test-logs"
        }
  stdout { codec => rubydebug }
}
```

## grok multiline - mysql-slow log

```
# Time: 2020-06-03T06:03:33.675799Z
# User@Host: root[root] @ localhost []  Id:     4
# Query_time: 2.064824  Lock_time: 0.000000 Rows_sent: 1  Rows_examined: 0
SET timestamp=1591164213;
SELECT SLEEP(2);
# Time: 2020-06-03T06:04:09.582225Z
# User@Host: root[root] @ localhost []  Id:     4
# Query_time: 3.000192  Lock_time: 0.000000 Rows_sent: 1  Rows_examined: 0
SET timestamp=1591164249;
SELECT SLEEP(3);

```

```conf

input {
file {
   path => ["/etc/logstash/conf.d/logstash/mysql_slowlogs/mysql-slow.log"]
   start_position => "beginning"
   sincedb_path => "/dev/null"
   codec => multiline {
          pattern => "^# Time: %{TIMESTAMP_ISO8601}"
          negate => true
          what => "previous"
        }
 }
}
filter {
      mutate {
        gsub => [
          "message", "#", "",
          "message", "\n", " "
        ]
        remove_field => "host"
      }
      grok {
        match => { "message" => [
              "Time\:%{SPACE}%{TIMESTAMP_ISO8601:timestamp}%{SPACE}User\@Host\:%{SPACE}%{WORD:user}\[%{NOTSPACE}\] \@ %{NOTSPACE:host} \[\]%{SPACE}Id\:%{SPACE}%{NUMBER:sql_id}%{SPACE}Query_time\:%{SPACE}%{NUMBER:query_time}%{SPACE}Lock_time\:%{SPACE}%{NUMBER:lock_time}%{SPACE}Rows_sent\:%{SPACE}%{NUMBER:rows_sent}%{SPACE}Rows_examined\:%{SPACE}%{NUMBER:rows_examined}%{SPACE}%{GREEDYDATA}; %{GREEDYDATA:command}\;%{GREEDYDATA}" 
       ] }
      }
      
      mutate {
        add_field => { "read_timestamp" => "%{@timestamp}" }
        #remove_field => "message"
      }
}
output {
  elasticsearch {
            hosts => [ "localhost:9200"]
            index => "mysql-slowlogs-01"
        }
  stdout { codec => rubydebug }
}

```

# Input plugin

## heartbeat

```conf

input {
  heartbeat {
    message => "epoch"
    # message => "sequence"
    # message => "ok"
    interval => 5
    type => "heartbeat"
  }
}

output {
  if [type] == "heartbeat" {
     elasticsearch {
     hosts => "http://localhost:9200"
     index => "heartbeat-epoch"
 	 }
  }
 stdout {
  codec => "rubydebug"
  }
 
}
```
## generator - gen test data

```conf
  input {
      generator {
        lines => [
          '{"id": 1,"first_name": "Ford","last_name": "Tarn","email": "ftarn0@go.com","gender": "Male","ip_address": "112.29.200.6"}', 
          '{"id": 2,"first_name": "Kalila","last_name": "Whitham","email": "kwhitham1@wufoo.com","gender": "Female","ip_address": "98.98.248.37"}'
        ]
        count => 0
        codec =>  "json"
      }
    }

output {
     elasticsearch {
     hosts => "http://localhost:9200"
     index => "generator"
  } 
  stdout {
  codec => "rubydebug"
}
}
```

## http poller 

```conf
input {
    http_poller {
        urls => {
            external_api => {
                method => post
                url => "https://jsonplaceholder.typicode.com/posts"
                body => '{ "title": "foo", "body": "bar", "userId": "1"}'
                headers => {
                    "content-type" => "application/json"
                }
            }
        }
        tags => "external-api"
        request_timeout => 100
        schedule => {
            "every" => "5s"
        }
        codec => "json"
        metadata_target => "http_poller_metadata"
    }
    http_poller {
        urls => {
            es_health_status => {
                method => get
                url => "http://localhost:9200/_cluster/health"
                headers => {
                    Accept => "application/json"
                }
            }
        }
        tags => "es_health"
        request_timeout => 60
        schedule => {
            cron => "* * * * * UTC"
        }
        codec => "json"
        metadata_target => "http_poller_metadata"
    }
}

output {
    if "es_health" in [tags] {
        elasticsearch {
            hosts => ["localhost:9200"]
            index => "http-poller-es-health"
        }
    }
    if "external-api" in [tags] {
        elasticsearch {
            hosts => ["localhost:9200"]
            index => "http-poller-api"
        }
    }
    stdout {
        codec => "rubydebug"
    }
}

```