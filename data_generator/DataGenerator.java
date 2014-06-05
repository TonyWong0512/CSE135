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
public class DataGenerator 
{
	HashMap<Integer, Integer> hm=new HashMap<Integer, Integer>();

	public static void main(String[] args) throws Exception
	{
		int Num_users		=	100;
		int Num_categories	=	10;
		int Num_products	=	1000;
		int Num_sales		=	100000;
		DataGenerator dg=new DataGenerator();
		dg.createData(Num_users,Num_categories,Num_products,Num_sales);
		System.out.println("-------------finish-----------");
	}
	public void createData(int Num_users,int Num_categories, int Num_products,int Num_sales ) throws Exception
	{
		 Database db=new Database();
	     db.openConn();
	     System.out.println("Successfully openConn");
	     db.openStatement();
	     System.out.println("Successfully openStatement");
	     db.init();//create tables
	     ArrayList<String> a1=generateUsers(Num_users);
	     ArrayList<String> a2=generateCategories(Num_categories);
	     ArrayList<String> a3=generateProducts(Num_categories,Num_products);
	     ArrayList<String> a4=generateSales(Num_users,Num_products, Num_sales );
		 db.insertAll(a1);a1.clear();
		 System.out.println("-------------insert successfully into users table-----------");
		 db.insertAll(a2);a2.clear();
		 System.out.println("-------------insert successfully into categories table-----------");
		 db.insertAll(a3);a3.clear();
		 System.out.println("-------------insert successfully into products table-----------");
		 db.insertAll(a4);a4.clear();
		 System.out.println("-------------insert successfully into Sales table-----------");
		 db.closeConn();
	}
	
	//INSERT INTO users table
	public ArrayList<String> generateUsers(int Num_users)
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
		SQLs.add("INSERT INTO USER_T (NAME,ROLE,AGE,STATE) VALUES('CSE','owner',35,'california');");
		while(flag<Num_users)
		{
			age=r.nextInt(88)+12;
			state=states[r.nextInt(states.length)].substring(0,2).toUpperCase();
			name=nameList[r.nextInt(nameList.length)];
			flag++;
			SQL="INSERT INTO USER_T (NAME,ROLE,AGE,STATE) VALUES('"+name+"_user_"+flag+"','user',"+age+",'"+state+"');";
			SQLs.add(SQL);
		}
		return SQLs;
	}
	//INSERT INTO categories table
	public ArrayList<String> generateCategories(int Num_categories )
	{
		ArrayList<String> SQLs=new ArrayList<String>();
		String SQL="";
		int flag=0;
		while(flag<Num_categories)
		{
			flag++;
			SQL="INSERT INTO CATEGORY (NAME, DESCRIPTION) VALUES('C"+flag+"','This is the number "+flag+" category.');";
			SQLs.add(SQL);
		}
		return SQLs;
	}
	//INSERT INTO products table
	public ArrayList<String> generateProducts(int Num_categories,int Num_products )
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
			SQL="INSERT INTO PRODUCT (CATEGORY, NAME, SKU, PRICE) VALUES("+cid+", '"+name+"_P"+flag+"','SKU_"+flag+"',"+price+");";
			hm.put(flag, price);
			SQLs.add(SQL);
		}
		return SQLs;
	}
	//INSERT INTO sales table
	public ArrayList<String> generateSales(int Num_users, int Num_products,int Num_sales )
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
			
			SQL="INSERT INTO ORDER_T (USERNAME, PRODUCT, AMOUNT,STATE) VALUES("+uid+", "+pid+" , "+quantity+", '"+state+"');";
			SQLs.add(SQL);
		}
		return SQLs;
	}
	
}
