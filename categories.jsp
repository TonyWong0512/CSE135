<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<!DOCTYPE html>
<html>
<jsp:include page="common/auth.jsp" />
<jsp:include page="common/header.jsp" />
<body>
  <jsp:include page="common/topmenu-owner.jsp" />

<%@ page language="java" import="java.sql.*" %>
<%@ page language="java" import="db.Config" %>
<%-- -------- Open Connection Code -------- --%>
<%
  Connection conn = null;
  PreparedStatement pstmt = null;
  ResultSet rs = null;

  String role = (String) session.getAttribute("role");
  if (role == null)
    role = "user";

  try {
    // Load JDBC Driver class file
    Class.forName(Config.jdbcDriver);

    // Open a connection to the database using DriverManager
    conn = DriverManager.getConnection(Config.connectionURL, Config.username, Config.password);

    String action = request.getParameter("action");

    if (action != null && action.equals("insert")) {

      // Begin transaction
      conn.setAutoCommit(false);

      // Create the prepared statement and use it to
      // INSERT category values INTO the category table.
      pstmt = conn
      .prepareStatement("INSERT INTO category (name, description) VALUES (?, ?)");

      pstmt.setString(1, request.getParameter("name"));
      pstmt.setString(2, request.getParameter("description"));
      int rowCount = pstmt.executeUpdate();

      // Commit transaction
      conn.commit();
      conn.setAutoCommit(true);
    }

    if (action != null && action.equals("update")) {

      conn.setAutoCommit(false);

      // Create the prepared statement and use it to
      // UPDATE category values in the category table.
      pstmt = conn
          .prepareStatement("UPDATE category SET name = ?, description = ? WHERE id = ?");

      pstmt.setString(1, request.getParameter("name"));
      pstmt.setString(2, request.getParameter("description"));
      pstmt.setInt(3, Integer.parseInt(request.getParameter("id")));
      int rowCount = pstmt.executeUpdate();

      // Commit transaction
      conn.commit();
      conn.setAutoCommit(true);
    }

    if (action != null && action.equals("delete")) {

      // Begin transaction
      conn.setAutoCommit(false);

      // Create the prepared statement and use it to
      // DELETE category FROM the category table.
      pstmt = conn
          .prepareStatement("DELETE FROM category WHERE id = ?");

      pstmt.setInt(1, Integer.parseInt(request.getParameter("id")));
      int rowCount = pstmt.executeUpdate();

      // Commit transaction
      conn.commit();
      conn.setAutoCommit(true);
    }
%>

  <div class="container-fluid">
    <div class="row-fluid">
      <div class="span10">
        <table class="table table-hover">
          <tr>
            <th>#</th>
            <th>Name</th>
            <th>Description</th>
            <th colspan=2>Action</th>
          </tr>
          <%
            pstmt = conn.prepareStatement("SELECT * FROM category");
            rs = pstmt.executeQuery();
            while ( rs.next() ) {
              int id = rs.getInt("id");
              String name = rs.getString("name");
              String description = rs.getString("description");
          %>
          <tr>
            <form action="categories.jsp" method="post">
              <input type="hidden" value="update" name="action">
              <input type="hidden" value="<%= id %>" name="id">
              <td>
              </td>
              <td>
                <input type="text" value="<%= name %>" name="name">
              </td>
              <td>
                <input type="text" value="<%= description %>" name="description">
              </td>
              <td>
                <button type="submit" class="btn btn-primary">Update</button>
              </td>
            </form>
            <%
              pstmt = conn.prepareStatement("SELECT COUNT(*) AS count FROM product WHERE category = ?");
              pstmt.setInt(1, id);
              ResultSet rs2 = pstmt.executeQuery();
              rs2.next();
              int count = rs2.getInt("count");
              if (count == 0) {
            %>
            <form action="categories.jsp" method="post">
              <input type="hidden" value="delete" name="action">
              <input type="hidden" value="<%= id %>" name="id">
              <td>
                <button type="submit" class="btn btn-primary">Delete</button>
              </td>
            </form>
            <%
              }
              rs2.close();
            %>
          </tr>
          <%
            }
          %>
          <tr>
            <form action="categories.jsp" method="post">
              <input type="hidden" value="insert" name="action">
              <td></td>
              <td>
                <input type="text" value="" name="name">
              </td>
              <td>
                <input type="text" value="" name="description">
              </td>
              <td>
                <button type="submit" class="btn btn-primary">Add</button>
              </td>
            </form>
          </tr>
        </table>
      </div>
    </div>
  </div>

<%-- -------- Close Connection Code -------- --%>
<%
  // Close the ResultSet
  rs.close();

  // Close the Statement
  pstmt.close();

  // Close the Connection
  conn.close();
} catch (SQLException e) {
  
  // Wrap the SQL exception in a runtime exception to propagate
  // it upwards
  String errorMsg = e.getMessage();
  //TODO: Parse error message to display user-friendly messages.
%>
  <!-- Display error message -->
  <div class="container">
    <div class="alert alert-error">
      <button type="button" class="close" onclick="window.location.href='categories.jsp'">&times;</button>
      <strong>Error!</strong> <%= errorMsg %>
    </div>
  </div>
<%
}
finally {
  // Release resources in a finally block in reverse-order of
  // their creation

  if (rs != null) {
    try {
      rs.close();
    } catch (SQLException e) { } // Ignore
    rs = null;
  }
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
  <script>
    $(document).ready(function() {
      $('#nav-categories').addClass('active');
    });
  </script>
</body>
</html>
