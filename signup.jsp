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
  Connection conn = null;
  PreparedStatement pstmt = null;

  try {
    // Load JDBC Driver class file
    Class.forName(Config.jdbcDriver);

    // Open a connection to the database using DriverManager
    conn = DriverManager.getConnection(Config.connectionURL, Config.username, Config.password);
    
    String action = request.getParameter("action");
    
    String name = request.getParameter("username");
    String role = request.getParameter("role");
    int age;
    try {
      age = Integer.parseInt(request.getParameter("age"));
    }
    catch (NumberFormatException ex) {
      age = 0;
    }
    String state = request.getParameter("state");
    
    if(action != null){

      // Begin transaction
      conn.setAutoCommit(false);

      // Create the prepared statement and use it to
      // INSERT user values INTO the user table.
      pstmt = conn
      .prepareStatement("INSERT INTO user_t (name, role, age, state) VALUES (?, ?, ?, ?)");

      pstmt.setString(1, name);
      pstmt.setString(2, role);
      pstmt.setInt(3, age);
      pstmt.setString(4, state);
      int rowCount = pstmt.executeUpdate();

      // Commit transaction
      conn.commit();
      conn.setAutoCommit(true);
      



      // Create the prepared statement and use it to
      // INSERT user values INTO the user table.
      pstmt = conn
      .prepareStatement("select * from user_t where name = ?");

      pstmt.setString(1, name);
	  ResultSet rs = pstmt.executeQuery();
	  String id = null;
	  while(rs.next()) {
	  	id = rs.getString("id");
	  }

      // Commit transaction

      
      // Close the Statement
      pstmt.close();

      // Close the Connection
      conn.close();
      
      session.setAttribute("username", name);
      session.setAttribute("role", role);
      session.setAttribute("userid", id);

      response.setHeader("iso-8859-1","utf-8");  
      request.setCharacterEncoding("utf-8");  
      if (role.equals("owner")) {
        response.sendRedirect("categories.jsp");
        return;
      }
      else {
        response.sendRedirect("browseproducts.jsp");
        return;
      }
        
    }
%>

	<div class="container">
    <form class="form-horizontal" action="signup.jsp" method="post">
      <legend>Sign up</legend>
      <input type="hidden" value="signup" name="action">
      <div class="control-group" id="backgroundlist">
        <label class="control-label">Username</label>
          <div class="controls">
            <input type="text" value="" name="username" placeholder="xxx" autofocus="autofocus">
          </div>
      </div>
          
      <div class="control-group">
        <label class="control-label">Role</label>
        <div class="controls">
          <select name="role">
          <option value="owner">Owner</option>
          <option value="user">Customer</option>                              
          </select>  
        </div>
      </div>
          
      <div class="control-group" id="backgroundlist">
        <label class="control-label">Age</label>
        <div class="controls">
          <input type="text" value="" name="age" placeholder="22">
        </div>
      </div>
          
      <div class="control-group">
        <label class="control-label">State</label>
        <div class="controls">
          <select name="state">
          <%
            int size = Config.states.length;
            for(int i = 0; i < size; ++i){
          %>
          <option value="<%= Config.states[i]%>"><%= Config.states[i]%></option>                           
          <%
            }
          %>
          </select>  
        </div>
      </div>

      <div class="form-actions">
        <button type="submit" class="btn btn-primary" onclick="javascript:window.location.href='category.jsp'">Sign-up</button>
      </div>
    </form>
	</div>

<%-- -------- Close Connection Code -------- --%>
<%
} catch (SQLException e) {

  // Wrap the SQL exception in a runtime exception to propagate
  // it upwards
  //throw new RuntimeException(e);
  String errorMsg = e.getMessage();
  //TODO: Parse error message to display user-friendly messages.
%>
  <!-- Display error message -->
  <div class="container">
    <div class="alert alert-error">
      <button type="button" class="close" onclick="window.location.href='signup.jsp'">&times;</button>
      <strong>Error!</strong> <%= errorMsg %>
    </div>
  </div>
<%
}
finally {
  // Release resources in a finally block in reverse-order of
  // their creation
  if (pstmt != null) {
    try {
      pstmt.close();
    } catch (SQLException e) { } // Ignore
    pstmt = null;
  }
  if (conn != null) {
    try {
      conn.close();
    } catch (SQLException e) { } // Ignore
    conn = null;
  }
}
%>

  <script src="js/jquery-1.9.1.js"></script>
  <script src="js/bootstrap.min.js"></script>
</body>
</html>
