import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Statement;

public class PreComputation
{
	private Statement stmt=null;
	private Connection conn = null;
	public static void main(String[] argv) throws Exception
	{
		PreComputation pre = new PreComputation();
		pre.openConn();
		pre.init();

		//do sta_cat
		pre.doStaCat();
		pre.doCusCat();
		pre.doStaPro();
		pre.doCusPro();

	}
	public void doStaCat() throws Exception
	{
		System.out.println("doStaCat()");

	}
	public void doCusCat() throws Exception
	{
		System.out.println("doCusCat()");
	}
	public void doStaPro() throws Exception
	{
		System.out.println("doStaPro()");
	}
	public void doCusPro() throws Exception
	{
		System.out.println("doCusPro()");
	}
	public boolean openConn() throws Exception
	{
		System.out.println("openConn()");
	    try{
	    try{Class.forName("org.postgresql.Driver");}catch(Exception e){System.out.println("Driver error");}
	    String url="jdbc:postgresql://localhost:5433/test"; //database name
	    String user="postgres";							 //username
	    String password="123456";						//password
	    conn=DriverManager.getConnection(url, user, password);
	    stmt=conn.createStatement();
	    System.out.println("Successfully connected to database on url = "+url);
	    return true;
	    }
	   catch(SQLException e)
	   {
	    e.printStackTrace();
	    return false;
	   }
	}
 
	public void init() throws SQLException
	{
		System.out.println("init()");
		createTable("create table sta_cat as (select u.state, p.category, SUM(o.price*o.quantity) as amount "+
			"from user_t u, product p, order_t o "+
			"where o.username = u.id "+
			"and   o.product = p.id "+
			"group by u.state, p.category "+
			"order by amount desc);");
		
		createTable("create table cus_cat (ID SERIAL PRIMARY KEY, UID INT, CID INT, AMOUNT INT);");
		createTable("create table sta_pro (ID SERIAL PRIMARY KEY, STATE VARCHAR(30), PID INT, AMOUNT INT);");
		createTable("create table cus_pro (ID SERIAL PRIMARY KEY, UID INT, PID INT, AMOUNT INT);");
	}
	public boolean createTable(String sql)
	{
		try{
			stmt.execute(sql);
		}catch(SQLException e)
		{
			return false;
		}
		return true;
	}
}