"""
SimpleApp.py
run: spark-submit --master local[4] SimpleApp.py
local:表示在本地执行，[4]表示启用4个CPU CORE
"""
from pyspark.sql import SparkSession

logFile = "D:/big_data/spark-2.4.3-bin-hadoop2.7/README.md" # Should be some file on your system
spark = SparkSession.builder.appName("SimpleApp").master("local[*]").getOrCreate()
logData = spark.read.text(logFile).cache()

numAs = logData.filter(logData.value.contains('a')).count()
numBs = logData.filter(logData.value.contains('b')).count()
print("Lines with a: %i, lines with b: %i" % (numAs, numBs))
spark.stop()
