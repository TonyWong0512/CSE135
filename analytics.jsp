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
<%@ page language="java" import="db.Config" %>
<%

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
ArrayList<Item> p_list=new ArrayList<Item>();
ArrayList<Item> s_list=new ArrayList<Item>();
Item item=null;
Connection conn=null;
Statement stmt,stmt_2,stmt_3;
ResultSet rs=null,rs_2=null,rs_3=null;
String SQL=null;
try
{
  Class.forName(Config.jdbcDriver);

  conn = DriverManager.getConnection(Config.connectionURL, Config.username, Config.password);
  stmt =conn.createStatement();
  stmt_2 =conn.createStatement();
  stmt_3 =conn.createStatement();
  /**SQL_1 for (state, amount)**/
  String SQL_1="select p.id, p.name, sum(c.quantity*p.price) as amount from PRODUCT p, ORDER_T c "+
         "where c.product=p.id "+
         "group by p.name,p.id "+
         "order by  p.name asc "+
         "limit 9;";
  String SQL_2="select  u.state, sum(c.quantity*p.price) as amount from USER_T u, ORDER_T c,  PRODUCT p "+
          "where c.username=u.id and c.product=p.id "+ 
          "group by u.state "+ 
          "order by u.state asc "+
          "limit 19;";

  rs=stmt.executeQuery(SQL_1);
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
  
  rs_2=stmt_2.executeQuery(SQL_2);//state not id, many users in one state
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
  for(i=0;i<s_list.size();i++)
  {
    s_name      = s_list.get(i).getName();
    s_amount_price  = s_list.get(i).getAmount_price();
    out.println("<tr  align=\"center\">");
    out.println("<td><strong>"+s_name+"["+s_amount_price+"]</strong></td>");
    for(j=0;j<p_list.size();j++)
    {
      p_id      =   p_list.get(j).getId();
      p_name      = p_list.get(j).getName();
      p_amount_price  = p_list.get(j).getAmount_price();
      
      SQL_3="select sum(c.quantity*p.price) as amount from USER_T u, PRODUCT p, ORDER_T c "+
         "where c.username=u.id and c.product=p.id and u.state='"+s_name+"' and p.id='"+p_id+"' group by u.state, p.name";

       rs_3=stmt_3.executeQuery(SQL_3);
       if(rs_3.next())
       {
         amount=rs_3.getFloat(1);
         out.print("<td><font color='#0000ff'>"+amount+"</font></td>");
       }
       else
       {
        out.println("<td><font color='#ff0000'>0</font></td>");
       }

    }
    out.println("</tr>");
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