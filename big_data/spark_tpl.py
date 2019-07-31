## Spark Application - execute with spark-submit
 
## Imports
from pyspark import SparkConf, SparkContext
from operator import add
 
## Module Constants
APP_NAME = "My Spark Application"
 
## Closure Functions
def tokenize(text):
    return text.split()

 
## Main functionality
 
def main(sc):
    pass
    text = sc.textFile("spark_tpl.py")
    words = text.flatMap(tokenize)
    wc = words.map(lambda x: (x,1))
    counts = wc.reduceByKey(add)
    counts.saveAsTextFile("wc")
 
if __name__ == "__main__":
    # Configure Spark
    conf = SparkConf().setAppName(APP_NAME)
    conf = conf.setMaster("local[*]")
    sc   = SparkContext(conf=conf)
 
    # Execute Main functionality
    main(sc)

