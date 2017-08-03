package dzr.java_demo;

/*
 * 使用slf4j作为日志库的例子，这里bind的是slf4j-simple
 * 使用时可以通过System.setProperty来设置日志的配置项
 * 也可以使用指定的配置文件来配置:simplelogger.properties，这个文件要放在classpath的根目录下
 * */
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class DemoSlf4j 
{
    public static void main( String[] args )
    {
//    	System.setProperty(org.slf4j.simple.SimpleLogger.DEFAULT_LOG_LEVEL_KEY, "DEBUG");
    	final Logger logger = LoggerFactory.getLogger(DemoSlf4j.class);
    	
        System.out.println( "Hello World!" );

        Integer t1 = 100;
        logger.debug("Integer set to {}.", t1);
        
        Object[] arguments = {
        	    new Integer(7),
        	    "test string"
        	};
        logger.info("main args: {}, {}.", arguments);
    }
}