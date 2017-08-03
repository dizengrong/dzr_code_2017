package dzr.java_demo;

import java.util.List;

import org.hibernate.Session;
/*
 * */
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class HibernateDemo 
{
    public static void main( String[] args )
    {
//    	System.setProperty(org.slf4j.simple.SimpleLogger.DEFAULT_LOG_LEVEL_KEY, "DEBUG");
    	final Logger logger = LoggerFactory.getLogger(DemoSlf4j.class);
    	
        System.out.println( "Hello World!" );
        Session session = HibernateUtil.getSessionFactory().openSession();
        
        session.beginTransaction();

		List<Fund> result = session.createQuery( "from Fund" ).list();
		logger.debug("==============");
        for ( Fund fund : (List<Fund>) result ) {
            System.out.println( "uid:" + fund.getUid() + ", fetched:" + fund.getFetched_list());
        }
        session.getTransaction().commit();
        session.close();
        
        
    }
}