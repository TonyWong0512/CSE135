import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;

public class Database
{
	private Connection conn = null;
	private Statement stmt=null;
	
	public boolean openConn() throws Exception
	{
	   try{
	    try{Class.forName("org.postgresql.Driver");}catch(Exception e){System.out.println("Driver error");}
	    String url="jdbc:postgresql://localhost:5433/test"; //database name
	    String user="postgres";							 //username
	    String password="123456";						//password
	    conn=DriverManager.getConnection(url, user, password);
	    return true;
	    }
	   catch(SQLException e)
	   {
	    e.printStackTrace();
	    return false;
	   }
	
	}
	
	public boolean openStatement() throws SQLException
	{
	   stmt=conn.createStatement();
	   return true;
	}
	public void init()throws SQLException
	{
		dropCreateTable("DROP TABLE USER_T CASCADE;","CREATE TABLE USER_T(ID SERIAL PRIMARY KEY,NAME VARCHAR(30) UNIQUE NOT NULL,ROLE VARCHAR(30) NOT NULL,AGE INT,STATE VARCHAR(30));");
		dropCreateTable("DROP TABLE CATEGORY CASCADE;","CREATE TABLE CATEGORY(ID SERIAL PRIMARY KEY,NAME VARCHAR(30) UNIQUE NOT NULL,DESCRIPTION VARCHAR(255));");
		dropCreateTable("DROP TABLE PRODUCT CASCADE;","CREATE TABLE PRODUCT( ID	SERIAL PRIMARY KEY,NAME	VARCHAR(100) NOT NULL,SKU VARCHAR(100) UNIQUE NOT NULL,CATEGORY	INT NOT NULL,PRICE FLOAT NOT NULL,FOREIGN KEY (CATEGORY) REFERENCES CATEGORY(ID));");
		dropCreateTable("DROP TABLE ORDER_T CASCADE;","CREATE TABLE ORDER_T(ID SERIAL PRIMARY KEY,PRODUCT INT NOT NULL,USERNAME	INT NOT NULL,AMOUNT	INT,STATE VARCHAR(30),FOREIGN KEY (PRODUCT) REFERENCES PRODUCT(ID),FOREIGN KEY (USERNAME) REFERENCES USER_T(ID));");
	}
	public boolean dropCreateTable(String sql, String sql2) throws SQLException
	{
		try{
			stmt.execute(sql);
			stmt.execute(sql2);
			return true;
		}catch(SQLException e)
		{
			stmt.execute(sql2);
			return false;
		}
	}
	public void insert(String sql) throws SQLException
	{
		stmt.execute(sql);
	}
	public void insertAll(ArrayList<String> sqls) throws SQLException
	{
		for(int i=0;i<sqls.size();i++)
		{
			stmt.execute(sqls.get(i));
		}
	}
	public ResultSet getQuery(String sql) throws Exception
	{
	   ResultSet rs=null;
	   rs=stmt.executeQuery(sql);
	   return rs;
	}
	public boolean closeConn() throws SQLException
	{
	   conn.close();
	   return true;
	}
	
}