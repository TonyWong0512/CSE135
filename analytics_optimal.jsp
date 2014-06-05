<%@ page contentType="text/html; charset=utf-8" language="java" import="java.sql.*" import="database.*"   import="java.util.*" errorPage="" %>



<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>CSE135</title>
<script type="text/javascript" src="js/js.js" language="javascript"></script>
</head>
<body>

<jsp:include page="common/topmenu-cust.jsp" />
<%@ page language="java" import="java.sql.*" %>
<%@ page language="java" import="java.util.ArrayList" %>
<%@ page language="java" import="java.util.HashMap" %>
<%@ page language="java" import="db.Config" %>
<%

int rowLimit = 19;
int colLimit = 10;
int rowOffset = 0;
int colOffset = 0;
class Pair
{
  private String state;
  private String product;
  public Pair(String state, String product){
    this.state = state;
    this.product = product;
  }
  public String getState(){
    return state;
  }
  public String getProduct(){
    return product;
  }
  public void setState(String state){
    this.state = state;
  }
  public void setProduct(String product){
    this.product = product;
  }

  public int hashCode(){
        //System.out.println("In hashcode");
        int hashcode = 0;
        hashcode = 20;
        hashcode += state.hashCode();
        return hashcode;
  }
  public boolean equals(Object obj){
        // System.out.println("In equals");
        if (obj instanceof Pair) {
            Pair pp = (Pair) obj;
            return (pp.state.equals(this.state) && pp.product.equals(this.product));
        } else {
            return false;
        }
  }
}
class Item 
{
  private int id=0;
  private String name=null;
  private float amount_price=0f;
  public int getId() {
    return id;
  }
  public void setId(int id) {
    this.id = id;
  }
  public String getName() {
    return name;
  }
  public void setName(String name) {
    this.name = name;
  }
  public float getAmount_price() {
    return amount_price;
  }
  public void setAmount_price(float amount_price) {
    this.amount_price = amount_price;
  }
}

class Query
{
  public  String getQuery(String customerOrState, String state, String category, String age)  {
    if(!state.equals("All"))
        System.out.println("state = " + state);
    if(!category.equals("All"))
        System.out.println("category = "+category);
    if(!age.equals("All"))
        System.out.println("age = "+age);
    String sql = "select * from user_t where state = "+state+" and actegory = "+category;
    return sql;
  }
  public String getProductWhereClause(String category)
  {
    String whereClause = "where p.category = c.id ";
    System.out.println("category = " +category);
    if(!category.equals("All") && !category.equals(""))
      whereClause += "and c.name = '"+category+"' ";
    //System.out.println("WhereClause = "+whereClause);
    return whereClause;
  }
  public String getUserWhereClause(String state, String age)
  {
    System.out.println("getUserWhereClaus --- state = "+state+" age = "+age);
    String whereClause = "";
    //neither is filtered
    if((state.equals("All")||state.equals("")) && (age.equals("All")||age.equals("")))
    {
      System.out.println("no user filter applied");
      return whereClause;
    }
      
    else
    {
      System.out.println("There is some user filter selected ");
      //only state is filtered
      if(!state.equals("All")&&!state.equals("") && age.equals("All")|| age.equals(""))
      {
        whereClause += "where state = '" + state +"' ";
      }
      //only age is filtered
      else if(!age.equals("All")&&!age.equals("") && state.equals("All")|| state.equals(""))
      {
        whereClause += "where ";
        whereClause += getAgeClause(age);
      }  
      //both are filtered
      else
      {
        whereClause += "where state = '" + state + "' " +
            "and " +
            getAgeClause(age);
      }
    }
    return whereClause;
  }
  public String getAgeClause(String age)
  {
    String ageClause = "";
    if(age.equals("12-18"))
    {
      ageClause += "age >= 12 and age <=18 ";
    }
    else if(age.equals("18-45"))
    {
      ageClause += "age >=18 and age <=45 ";
    }
    else if(age.equals("45-65"))
    {
      ageClause += "age >= 45 and age <= 65 ";
    }
    else if(age.equals("65-"))
    {
      ageClause += "age >= 65 ";
    }
    return ageClause;
  }
}
Query q = new Query();
ArrayList<Item> p_list=new ArrayList<Item>();
ArrayList<Item> s_list=new ArrayList<Item>();
Item item=null;
Connection conn=null;
PreparedStatement pstmt = null;
Statement stmt,stmt_2,stmt_3, stmt_4, stmt_5;
ResultSet rs=null,rs_2=null,rs_3=null, rs_4 = null, rs_5 = null;
String SQL=null;
try
{
  Class.forName(Config.jdbcDriver);

  conn = DriverManager.getConnection(Config.connectionURL, Config.username, Config.password);

  String action = request.getParameter("action");


  stmt =conn.createStatement();
  stmt_2 =conn.createStatement();
  stmt_3 =conn.createStatement();
  stmt_4 =conn.createStatement();
  stmt_5 =conn.createStatement();
  /**SQL_1 for (state, amount)**/

  String category = "";
  String customerOrState = "";
  String state = "";
  String age = "";
  if (action != null && action.equals("search")) 
  {
      category = request.getParameter("category");
      customerOrState = request.getParameter("customerOrState");
      state = request.getParameter("state");
      age = request.getParameter("age");
      
      String query = q.getQuery(customerOrState,state,category,age);
      System.out.println(query);
  }

  String TEMP_STATE = "create temporary table temp_state as ("+
        "select distinct state "+
        "from user_t u "+
        "order by u.state asc "+
        "offset "+rowOffset+" "+
        "limit "+rowLimit+");";
  String TEMP_PRODUCT = "create temporary table temp_product as ("+
          "select * "+
        "from PRODUCT p "+
        "order by p.name asc "+
        "offset "+colOffset+" "+
        "limit "+colLimit+");";

  String PERM_STATE = "create temporary table perm_state as ("+
        "select distinct state "+
        "from user_t u "+
        "order by u.state asc "+
        "offset "+rowOffset+" "+
        "limit "+rowLimit+");";


  String productWhereClause = q.getProductWhereClause(category);
  String PERM_PRODUCT = "create temporary table perm_product as ("+
          "select p.id, p.name, p.price "+
        "from PRODUCT p, CATEGORY c ";
  PERM_PRODUCT += productWhereClause;
  PERM_PRODUCT += 
        "order by p.name asc "+
        "offset "+colOffset+" "+
        "limit "+colLimit+");";
  System.out.println("PERM PRODUCT QUERY = " + PERM_PRODUCT);


  String userWhereClause = q.getUserWhereClause(state, age);
  String PERM_USER = "create temporary table perm_user as ("+
        "select * "+
        "from user_t ";
  PERM_USER +=  userWhereClause + ");";
  System.out.println("PERM USER QUERY = "+ PERM_USER);


  String SQL_1="select p.id, p.name, sum(c.quantity*c.price) as amount from PERM_PRODUCT p, ORDER_T c, PERM_USER pu "+
         "where c.product=p.id "+
         "and pu.id = c.username "+
         "group by p.name,p.id ";
  String SQL_2="select  u.state, sum(c.quantity*c.price) as amount from PERM_STATE s, USER_T u, ORDER_T c,  PERM_PRODUCT p, PERM_USER pu "+
          "where c.username=u.id and c.product=p.id and s.state = u.state "+ 
          "and pu.id = c.username "+
          "group by u.state " +
          "order by u.state asc ";


  //pstmt = conn.prepareStatement(TEMP_PRODUCT);
  //pstmt.execute();
  //stmt_5.execute(TEMP_STATE);


  stmt_5.execute(PERM_STATE);
  stmt_5.execute(PERM_PRODUCT);
  stmt_5.execute(PERM_USER);
  
  //rs = stmt_5.executeQuery("select * from TEMP_STATE");
  //while(rs.next())
  //{
  //  System.out.println("temp states are : ");
  //  System.out.println(rs.getString("state"));
  //}
  //rs = stmt_5.executeQuery("select * from TEMP_PRODUCT");
  //  while(rs.next())
  //{
  //  System.out.println("temp products are : ");
  //  System.out.println(rs.getString("name"));
  //}
  //stmt_5.executeQuery(TEMP_PRODUCT);
  System.out.println("Ready to execute SQL_1");
  rs=stmt.executeQuery(SQL_1);
  System.out.println("Done executing SQL_1");
  int p_id=0;
  String p_name=null;
  float p_amount_price=0;
  while(rs.next())
  {
    p_id=rs.getInt(1);
    p_name=rs.getString(2);
    p_amount_price=rs.getFloat(3);
    item=new Item();
    item.setId(p_id);
    item.setName(p_name);
    item.setAmount_price(p_amount_price);
    p_list.add(item);
  
  }
  
  System.out.println("Ready to execute SQL_2");
  rs_2=stmt_2.executeQuery(SQL_2);//state not id, many users in one state
  System.out.println("Ready to execute SQL_2");
  String s_name=null;
  float s_amount_price=0;
  while(rs_2.next())
  {
    s_name=rs_2.getString(1);
    s_amount_price=rs_2.getFloat(2);
    item=new Item();
    item.setName(s_name);
    item.setAmount_price(s_amount_price);
    s_list.add(item);
  } 
//    out.println("product #:"+p_list.size()+"<br>state #:"+s_list.size()+"<p>");
  int i=0,j=0;
  String SQL_3="";  
  float amount=0;
%>
 <form action = "analytics_optimal.jsp" method = "post">
  <input type="hidden" value="search" name="action">
  <select class="input-small" name="customerOrState">
    <option value="Customers">Customers</option>
    <option value="State">State</option>
  </select>

  <select name="state">
          <option value = "All">All</option>
          <%
            int size = Config.states.length;
            for(int k = 0; k < size; ++k){
          %>
          <option value="<%= Config.states[k]%>"><%= Config.states[k]%></option>                           
          <%
            }
          %>
  </select>  
  <select name = "category">
    <option value = "All">All</option>
    <%
      stmt_4 =conn.createStatement();
      String getStateSQL = "SELECT * FROM category";
      System.out.println("Ready to execute getStateSQL");
      rs_4 = stmt_4.executeQuery(getStateSQL);
      System.out.println("Done executing getStateSQL");
      while(rs_4.next()) {
        String cname = rs_4.getString("name");
    
    %>
    <option value = "<%= cname %>"><%= cname %></option>
    <%
    }
    %>  
  </select>

  <select name="age">
          <option value = "All">All</option>

          <option value="12-18">12-18</option>  
          <option value="18-45">18-45</option>                         
          <option value="45-65">45-65</option>  
          <option value="65-">65-</option> 

  </select>  

  <button class="btn" type="submit">Run Query</button>
</form>

  <table align="center" width="98%" border="1">
    <tr align="center">
      <td><strong><font color="#FF0000">STATE</font></strong></td>
<%  
  for(i=0;i<p_list.size();i++)
  {
    p_id      =   p_list.get(i).getId();
    p_name      = p_list.get(i).getName();
    p_amount_price  = p_list.get(i).getAmount_price();
    out.print("<td> <strong>"+p_name+"<br>["+p_amount_price+"]</strong></td>");
  }
%>
    </tr>
<%  

  HashMap<Pair,String> h = new HashMap<Pair,String>(rowLimit*colLimit);
  SQL_3 = "select perm_state.state, perm_product.name, SUM(order_t.price*order_t.quantity) as amount "+
        "from perm_state, perm_product, order_t, user_t, perm_user "+
        "where order_t.username = user_t.id "+
        "and perm_user.id = order_t.username "+
        "and perm_state.state = user_t.state "+
        "and perm_product.id = order_t.product "+
        "group by perm_state.state, perm_product.name;";
  System.out.println("Ready to execute SQL_3");
  rs_3 = stmt_3.executeQuery(SQL_3);
  System.out.println("Done executing SQL_3");
  int count = 0;
  while(rs_3.next())
  {
      Pair p = new Pair(rs_3.getString("state"), rs_3.getString("name"));
      System.out.println(rs_3.getString("state")+ " "+rs_3.getString("name"));
      String stateProductAmount = rs_3.getString("amount");
      h.put(p,stateProductAmount);
      count++;
  }
    
  System.out.println("There are "+ count+ " tuples retrieved");

  for(i=0;i<s_list.size();i++)
  {
    s_name      = s_list.get(i).getName();
    s_amount_price  = s_list.get(i).getAmount_price();
    out.println("<tr  align=\"center\">");
    out.println("<td><strong>"+s_name+"["+s_amount_price+"]</strong></td>");
    for(j = 0;j<p_list.size();j++)
    {
      Pair p = new Pair(s_name, p_list.get(j).getName());
      //System.out.println(s_name+ " "+p_list.get(j).getName());
      String output = "0";
      if(h.get(p)!=null)
        output = h.get(p);
      out.print("<td><font color='#0000ff'>"+output+"</font></td>");
    }
  }
  session.setAttribute("TOP_10_Products",p_list);
%>
    <tr><td colspan="10"><input type="button" value="Next 20 States"></td></tr>
  </table>
<%
}
catch(Exception e)
{
  //out.println("<font color='#ff0000'>Error.<br><a href=\"login.jsp\" target=\"_self\"><i>Go Back to Home Page.</i></a></font><br>");
  out.println(e.getMessage());
}
finally
{
  conn.close();
} 
%>  
</body>
</html>