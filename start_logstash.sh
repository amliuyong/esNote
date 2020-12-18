#!/usr/bin/env bash

export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk-11.0.1.jdk/Contents/Home

./logstash-7.10.1/bin/logstash -e 'input{stdin{}} output{stdout{}}'


