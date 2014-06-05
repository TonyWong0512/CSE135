<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<!DOCTYPE html>
<html>
<jsp:include page="common/header.jsp" />

<body>

<%@ page language="java" import="java.sql.*" %>
<%@ page language="java" import="java.util.ArrayList" %>
<%@ page language="java" import="db.Config" %>
<%-- -------- Open Connection Code -------- --%>
<%
  try {
    // Load JDBC Driver class file
    Class.forName(Config.jdbcDriver);

    // Open a connection to the database using DriverManager
    Connection conn = DriverManager.getConnection(Config.connectionURL, Config.username, Config.password);
    
    String name = request.getParameter("username");
    
    Statement statement = conn.createStatement();;

    ResultSet rs = statement.executeQuery("select * from user_t where name='" + name + "'");
    
    if(name != null){
   
      response.setCharacterEncoding("utf-8");  
      response.setHeader("iso-8859-1","utf-8");  
      request.setCharacterEncoding("utf-8");  
		 
		if(rs.next()){
      session.setAttribute("username", name);
      session.setAttribute("userid", rs.getString("id"));
      session.setAttribute("role", rs.getString("role"));
      if (rs.getString("role").equals("owner"))
        response.sendRedirect("categories.jsp");
      else
        response.sendRedirect("browseproducts.jsp");
		}
    else 
      response.sendRedirect("login.jsp");   
    }
%>
	
	<div class="container">
    <div class="span10">
      <form class="form-horizontal" action="login.jsp" method="post">
        <legend>Login</legend>
        <div class="control-group" id="username">
          <label class="control-label">username</label>
          <div class="controls">
            <input type="text" value="" name="username" placeholder="username" autofocus="autofocus">
          </div>
        </div>

        <div class="form-actions">
          <input type="submit" class="btn btn-primary" value="Login">
          <input type="button" class="btn" value="Sign-up" onclick= "javascript:window.location.href = 'signup.jsp'">
        </div>
      </form>
		</div>
	</div>

<%-- -------- Close Connection Code -------- --%>
<%
    // Close the ResultSet
    rs.close();

    // Close the Statement
    statement.close();

    // Close the Connection
    conn.close();
  } catch (SQLException sqle) {
      out.println(sqle.getMessage());
  } catch (Exception e) {
      out.println(e.getMessage());
  }
%>

  <script src="js/jquery-1.9.1.js"></script>
  <script src="js/bootstrap.min.js"></script>
</body>
</html>
