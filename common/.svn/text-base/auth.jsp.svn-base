<%@ page language="java" import="java.sql.*" %>
<%@ page language="java" import="db.Config" %>
<%
  String username = (String) session.getAttribute("username"); 
  String role = (String) session.getAttribute("role"); 

  if (Config.mode.equals("release")) {
    // authetication check
    if (username == null || role == null) {
      response.sendRedirect("login.jsp");
    }
    else {
      Connection conn = null;
      PreparedStatement pstmt = null;
      ResultSet rs = null;

      try {
        // Load JDBC Driver class file
        Class.forName(Config.jdbcDriver);

        // Open a connection to the database using DriverManager
        conn = DriverManager.getConnection(Config.connectionURL, Config.username, Config.password);

        pstmt = conn
        .prepareStatement("SELECT role FROM user WHERE name= ?");

        pstmt.setString(1, request.getParameter("name"));
        rs = pstmt.executeQuery();
        
        rs.next();
        if (rs == null) {
          response.sendRedirect("login.jsp");
        }
        if (!rs.getString("role").equals(role)) {
          response.sendRedirect("login.jsp");
        }

        // Close the ResultSet
        rs.close();

        // Close the Statement
        pstmt.close();

        // Close the Connection
        conn.close();
      } catch (SQLException e) {

        // Wrap the SQL exception in a runtime exception to propagate
        // it upwards
        throw new RuntimeException(e);
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
    }
  }
%>
