import java.io.BufferedWriter;
import java.io.File;
import java.io.FileOutputStream;
import java.io.OutputStreamWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Random;

/**
 * # of users 		
 * # of categories 	
 * # of products	
 * # of sales		
 * products'categories, randomly
 * users'ages, randomly, [12,100]
 * users'states, randomly,e,g, California, New York
 * products'prices, randomly [1,100], Integer
 * quantities, randomly [1,10], integer
 * 
 **/
public class a
{
	HashMap<Integer, Integer> hm=new HashMap<Integer, Integer>();
	int MAXBuffer=1000000;
	private Connection conn = null;
	private Statement stmt=null;
	public static void main(String[] args) throws Exception
	{

		//small/medium test database
		int Num_users		=	100;
		int Num_categories	=	20; 
		int Num_products	=	10;
		int Num_sales		=	100000;
		
		 // String  usersPath		=	"//users//max/Dropbox//data_generator//data//user.txt",
	  //   		 categoriesPath	=	"//users//max/Dropbox//data_generator//data//categories.txt",
	  //   		 productsPath	=	"//users//max/Dropbox//data_generator//data//products.txt",
	  //    		 salesPath		=	"//users//max/Dropbox//data_generator//data//sales.txt";
		 String  usersPath		=	"/tmp/data/user.txt",
		 categoriesPath	=	"/tmp/data/categories.txt",
		 productsPath	=	"/tmp/data/products.txt",
 		 salesPath		=	"/tmp/data/sales.txt";
		a dg=new a();
		dg.createData(usersPath, categoriesPath, productsPath, salesPath, Num_users,Num_categories,Num_products,Num_sales);
	}
	
	public void createData(String usersPath, String categoriesPath, String productsPath, String salesPath, int Num_users,int Num_categories, int Num_products,int Num_sales ) throws Exception
	{
		System.out.println("createData");
		try{
    		File file1 = new File(usersPath),
    		     file2 = new File(categoriesPath),
    			 file3 = new File(productsPath),
    			 file4 = new File(salesPath);
    		file1.delete();file2.delete();file3.delete();file4.delete();
    	}
        catch(Exception e)
    	{
    		System.out.println("It is your first time to run this code, enjoy it.");
    	}
	     openConn();
	     init();//create tables
	     
	     long start=System.currentTimeMillis();
	     generateUsers(usersPath,Num_users);
	     generateCategories(categoriesPath,Num_categories);
	     generateProducts(productsPath,Num_categories,Num_products);
	     generateSales(salesPath,Num_users,Num_products, Num_sales );
	     long end=System.currentTimeMillis();
	     System.out.println("Finish, running time:"+(end-start)+"ms");
	     
	     long start2=System.currentTimeMillis();	
	     copy(usersPath,categoriesPath,productsPath,salesPath);
	     long end2=System.currentTimeMillis();
	     System.out.println("Finish, running time:"+(end2-start2)+"ms");
		 closeConn();
	}
	public boolean openConn() throws Exception
	{
		System.out.println("openConn()");
	    try{
	    try{Class.forName("org.postgresql.Driver");}catch(Exception e){System.out.println("Driver error");}
	    String url="jdbc:postgresql://localhost:5433/small"; //database name
	    System.out.println("This is the right file");
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
	public void init()throws SQLException
	{
		System.out.println("init()");
		dropCreateTable("DROP TABLE USER_T CASCADE;","CREATE TABLE USER_T(ID SERIAL PRIMARY KEY,NAME VARCHAR(30) UNIQUE NOT NULL,ROLE VARCHAR(30) NOT NULL,AGE INT,STATE VARCHAR(30));");
		dropCreateTable("DROP TABLE CATEGORY CASCADE;","CREATE TABLE CATEGORY(ID SERIAL PRIMARY KEY,NAME VARCHAR(30) UNIQUE NOT NULL,DESCRIPTION VARCHAR(255));");
		dropCreateTable("DROP TABLE PRODUCT CASCADE;","CREATE TABLE PRODUCT( ID	SERIAL PRIMARY KEY,NAME	VARCHAR(100) NOT NULL,SKU VARCHAR(100) UNIQUE NOT NULL,CATEGORY	INT NOT NULL,PRICE INT NOT NULL,FOREIGN KEY (CATEGORY) REFERENCES CATEGORY(ID));");
		dropCreateTable("DROP TABLE ORDER_T CASCADE;","CREATE TABLE ORDER_T(ID SERIAL PRIMARY KEY,PRODUCT INT NOT NULL,USERNAME	INT NOT NULL,QUANTITY INT,PRICE INT NOT NULL,STATE VARCHAR(30),FOREIGN KEY (PRODUCT) REFERENCES PRODUCT(ID),FOREIGN KEY (USERNAME) REFERENCES USER_T(ID));");

		// createIndex("CREATE INDEX order_user_idx ON order_t (username);");
		// createIndex("CREATE INDEX order_product_idx ON sales (product););");

	}
	public boolean createIndex(String sql) throws SQLException
	{
		try{
			stmt.execute(sql);
			System.out.println("Successfully craeted index");
			return true;
		}catch(SQLException e)
		{
			System.out.println("error creating index with message "+e);
			return false;
		}
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
	public void copy(String usersPath,String categoriesPath,String productsPath, String salesPath) throws SQLException
	{
		System.out.println("==========================================================");
		System.out.println("Inserting user_t data.....");
		stmt.execute("COPY user_t(name,role,age,state) FROM '"+usersPath+"' USING DELIMITERS ',';");
		System.out.println("Successfully inserting user_t data into database");
		System.out.println("Inserting category data.....");
		stmt.execute("COPY category (name,description) FROM '"+categoriesPath+"' USING DELIMITERS ',';");
		System.out.println("Successfully inserting category data into database");
		System.out.println("Inserting product data.....");
		stmt.execute("COPY product(category,name,sku,price) FROM '"+productsPath+"' USING DELIMITERS ',';");
		System.out.println("Successfully inserting product data into database");
		System.out.println("Inserting order_t data.....");
		stmt.execute("COPY order_t(username,product,quantity,price,state) FROM '"+salesPath+"' USING DELIMITERS ',';");
		System.out.println("Successfully inserting order_t data into database");
	}
	public boolean closeConn() throws SQLException
	{
	   conn.close();
	   return true;
	}
	
	
	//INSERT INTO users table
	public void generateUsers(String usersPath,int Num_users)
	{
		ArrayList<String> SQLs=new ArrayList<String>();
		
		int age=0;
		String name="",state="";
		String SQL="";
		String[] states={"Alabama","Alaska","Arizona","Arkansas","California","Colorado","Connecticut","Delaware","Florida","Georgia",
				"Hawaii","Idaho","Illinois","Indiana","Iowa","Kansas","Kentucky","Louisiana","Maine","Maryland","Massachusetts",
				"Michigan","Minnesota","Mississippi","Missouri","Montana","Nebraska","Nevada","New Hampshire","New Jersey",
				"New Mexico","New York","North Carolina","North Dakota","Ohio","Oklahoma","Oregon","Pennsylvania","Rhode Island",
				"South Carolina","South Dakota","Tennessee","Texas","Utah","Vermont","Virginia","Washington","West Virginia","Wisconsin","Wyoming"};
		String[] nameList={"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"};
		Random r=new Random();
		int flag=0;
		SQLs.add("CSE,owner,35,california");
		while(flag<Num_users)
		{
			age=r.nextInt(88)+12;
			// state=states[r.nextInt(states.length)];
			state=states[r.nextInt(states.length)].substring(0,2).toUpperCase();
			name=nameList[r.nextInt(nameList.length)];
			flag++;
			// SQL=name+"_user_"+flag+",customer,"+age+","+state;
			SQL=name+"_user_"+flag+",user,"+age+","+state;
			SQLs.add(SQL);
			if(SQLs.size()>MAXBuffer)
			{	writeToFile(usersPath, SQLs);
				SQLs.clear();
			}
		}
		writeToFile(usersPath, SQLs);
		SQLs.clear();
		System.out.println("Successfully generating users data");
	}
	//INSERT INTO categories table
	public void generateCategories(String categoriesPath,int Num_categories )
	{
		ArrayList<String> SQLs=new ArrayList<String>();
		String SQL="";
		int flag=0;
		while(flag<Num_categories)
		{
			flag++;
			SQL="C"+flag+",This is the number "+flag+" category";
			SQLs.add(SQL);
			if(SQLs.size()>MAXBuffer)
			{
				writeToFile(categoriesPath, SQLs);
				SQLs.clear();
			}
		}
		writeToFile(categoriesPath, SQLs);
		SQLs.clear();
		System.out.println("Successfully generating categories data");
	}
	//INSERT INTO products table
	public void generateProducts(String productsPath,int Num_categories,int Num_products )
	{
		String[] nameList={"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"};
		ArrayList<String> SQLs=new ArrayList<String>();
		String name="",SQL="";
		int flag=0;
		Random r=new Random();
		int cid=0;
		int price=0;
		while(flag<Num_products)
		{
			flag++;
			cid=r.nextInt(Num_categories)+1;
			name=nameList[r.nextInt(nameList.length)];
			price=r.nextInt(100)+1;
			SQL=cid+","+name+"_P"+flag+",SKU_"+flag+","+price;
			hm.put(flag, price);
			SQLs.add(SQL);
			if(SQLs.size()>MAXBuffer)
			{
				writeToFile(productsPath, SQLs);
				SQLs.clear();
			}
		}
		writeToFile(productsPath, SQLs);
		SQLs.clear();
		System.out.println("Successfully generating products data");
	}
	//INSERT INTO sales table
	public void generateSales(String salesPath,int Num_users, int Num_products,int Num_sales )
	{
		ArrayList<String> SQLs=new ArrayList<String>();
		String SQL="";
		int flag=0,price=0;
		Random r=new Random();
		int uid=0,pid=0,quantity=0;
		String state = "done";
		
		while(flag<Num_sales)
		{
			flag++;
			uid=r.nextInt(Num_users)+1;
			pid=r.nextInt(Num_products)+1;
			price=(Integer)hm.get(pid);
			quantity=r.nextInt(10)+1;
			
			// SQL=uid+","+pid+","+quantity+","+price;
			SQL=uid+","+pid+","+quantity+","+price+","+state;
			SQLs.add(SQL);
			if(SQLs.size()>MAXBuffer)
			{
				writeToFile(salesPath, SQLs);
				SQLs.clear();
			}
		}
		writeToFile(salesPath, SQLs);
		SQLs.clear();
		System.out.println("Successfully generating sales data");
	}
	
	public void  writeToFile(String path, ArrayList<String> al)
	{
		BufferedWriter out = null;    
		try 
		{                                                                        
        	out = new BufferedWriter(new OutputStreamWriter( 
        		new FileOutputStream(path, true)));                              
            
      	   		for(int i=0;i<al.size();i++)
      	   		{
          	   		out.write(al.get(i));
          	   		out.newLine();
      	   		}
      	   		out.close();
      	 }
		catch (Exception e) 
        {                                                     
            e.printStackTrace();                                                    
        }
	}
	
}
