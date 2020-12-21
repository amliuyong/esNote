 
# Spark to ES

## install Spark

1. download `spark-2.4.7-bin-hadoop2.7`

2. meavn

https://mvnrepository.com/artifact/org.elasticsearch/elasticsearch-spark-20

```xml
<dependency>
    <groupId>org.elasticsearch</groupId>
    <artifactId>elasticsearch-spark-20_2.11</artifactId>
    <version>7.10.1</version>
</dependency>
```

## run spark-shell

```
# must use jdk1.8 fro spark /spark-2.x.x

export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.8.0_171.jdk/Contents/Home

export SPARK_HOME=/Users/yongliu/Documents/software/spark-2.4.7-bin-hadoop2.7
$SPARK_HOME/bin/spark-shell --packages org.elasticsearch:elasticsearch-spark-20_2.11:7.10.1
```

## DF to ES

https://spark.apache.org/docs/latest/quick-start.html

```scala

import org.elasticsearch.spark.sql._

case class Person(ID:int, name:String, age:Int, numFriends:Int)

def mapper(line: String): Person = {
   val fields = line.split(',')
   val person: Persion = Person(fields(0).toInt, fields(1), fields(2).toInt, fields(3).toInt )
   return person
}

import spark.implicits._

val lines = spark.sparkContext.textFile("fakefriends.csv")

val people = lines.map(mapper).toDF()

people.saveToEs("spark-friends")


```
### ratings.csv to ES
```scala
import org.elasticsearch.spark.sql._

case class Rating(userID:Int, movieID: Int, rating:Float, timestamp:Int)

def mapper(line:String):Rating = {
    val fields = line.split(',')
    val rating: Rating = Rating(fields(0).toInt, fields(1).toInt, fields(2).toFloat, fields(3).toInt)
    return rating
}

import spark.implicits._

val lines = spark.sparkContext.textFile("/Users/yongliu/Desktop/Video/elasticSearch/esNote/data/ml-latest-small/ratings.csv")
val header = lines.first();
val data = lines.filter(row => row != header)

val ratings = data.map(mapper).toDF()
ratings.saveToEs("ratings")

```
