
# Hadoop to ES

## install hadoop
```sh
# add user
sudo adduser hadoop

# add `hadoop` user to sudo mod
sudo usermod -aG sudo hadoop

su - hadoop

wget https://downloads.apache.org/hadoop/common/hadoop-3.2.1/hadoop-3.2.1.tar.gz

tar xvzf hadoop-3.2.1.tar.gz

sudo mv hadoop-3.2.1 /usr/local/hadoop

sudo chown -R hadoop:hadoop /usr/local/hadoop

export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk-11.0.1.jdk/Contents/Home
export HADOOP_HOME=/usr/local/hadoop
export HADOOP_HOME=/Users/yongliu/Documents/software/hadoop-3.2.1
export HADOOP_INSTALL=$HADOOP_HOME
export HADOOP_MAPRED_HOME=$HADOOP_HOME
export HADOOP_COMMON_HOME=$HADOOP_HOME
export HADOOP_HDFS_HOME=$HADOOP_HOME
export YARN_HOME=$HADOOP_HOME
export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native
export PATH=$PATH:$HADOOP_HOME/sbin:$HADOOP_HOME/bin
export HADOOP_OPTS="-Djava.library.path=$HADOOP_HOME/lib/native"


# open $HADOOP_HOME/etc/hadoop/hadoop-env.sh
add `export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk-11.0.1.jdk/Contents/Home` to the file
```

## ES index
```
curl -H 'Content-Type: application/json' -XPUT "localhost:9200/hadoop-to-es-logs" -d '
{
   "mappings" : {
      "properties" : {
        "dateTime" : {
          "type" : "date",
          "format" : "dd/MMM/yyyy:HH:mm:ss"
        },
        "httpStatus" : {
          "type" : "keyword"
        },
        "ip" : {
          "type" : "keyword"
        },
        "responseCode" : {
          "type" : "keyword"
        },
        "size" : {
          "type" : "integer"
        },
        "url" : {
          "type" : "keyword"
        }
      }
}
'
```

## hadoop to ES - mapper

https://github.com/amliuyong/elasticsearch-with-hadoop-mr-lesson

```java
public class AccessLogIndexIngestion {

    public static class AccessLogMapper extends Mapper {
        @Override
        protected void map(Object key, Object value, Context context) throws IOException, InterruptedException {

            String logEntry = value.toString();
            // Split on space
            String[] parts = logEntry.split(" ");
            Map<String, String> entry = new LinkedHashMap<>();

            // Combined LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-agent}i\"" combined
            entry.put("ip", parts[0]);
            // Cleanup dateTime String
            entry.put("dateTime", parts[3].replace("[", ""));
            // Cleanup extra quote from HTTP Status
            entry.put("httpStatus", parts[5].replace("\"",  ""));
            entry.put("url", parts[6]);
            entry.put("responseCode", parts[8]);
            // Set size to 0 if not present
            entry.put("size", parts[9].replace("-", "0"));

            context.write(NullWritable.get(), WritableUtils.toWritable(entry));
        }
    }


    public static void main(String[] args) throws IOException, ClassNotFoundException, InterruptedException {
        Configuration conf = new Configuration();
        conf.setBoolean("mapred.map.tasks.speculative.execution", false);
        conf.setBoolean("mapred.reduce.tasks.speculative.execution", false);
        conf.set("es.nodes", "127.0.0.1:9200");
        conf.set("es.resource", "hadoop-to-es-logs");

        Job job = Job.getInstance(conf);
        job.setInputFormatClass(TextInputFormat.class);
        job.setOutputFormatClass(EsOutputFormat.class);
        job.setMapperClass(AccessLogMapper.class);
        job.setNumReduceTasks(0);

        FileInputFormat.addInputPath(job, new Path(args[0]));
        System.exit(job.waitForCompletion(true) ? 0 : 1);
    }

}
```

## run hadoop
```sh
hadoop jar eswithmr-1.0-SNAPSHOT.jar access.log
```
