<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<!DOCTYPE html>
<html>
<jsp:include page="common/auth.jsp" />
<jsp:include page="common/header.jsp" />
<body>
  <jsp:include page="common/topmenu-owner.jsp" />

<%@ page language="java" import="java.sql.*" %>
<%@ page language="java" import="java.util.ArrayList" %>
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
      // INSERT product values INTO the product table.
      pstmt = conn
      .prepareStatement("INSERT INTO product (name, sku, category, price) VALUES (?, ?, ?, ?)");

      pstmt.setString(1, request.getParameter("name"));
      pstmt.setString(2, request.getParameter("sku"));
      pstmt.setInt(3, Integer.parseInt(request.getParameter("category")));
      float price;
      try {
        price = Float.parseFloat(request.getParameter("price"));
      }
      catch (NumberFormatException ex) {
        price = 0.0f;
      }
      pstmt.setFloat(4, price);
      int rowCount = pstmt.executeUpdate();

      // Commit transaction
      conn.commit();
      conn.setAutoCommit(true);
    }

    if (action != null && action.equals("update")) {

      conn.setAutoCommit(false);

      // Create the prepared statement and use it to
      // UPDATE product values in the product table.
      pstmt = conn
          .prepareStatement("UPDATE product SET name = ?, sku = ?, category = ?, price = ? WHERE id = ?");

      pstmt.setString(1, request.getParameter("name"));
      pstmt.setString(2, request.getParameter("sku"));
      pstmt.setInt(3, Integer.parseInt(request.getParameter("category")));
      float price;
      try {
        price = Float.parseFloat(request.getParameter("price"));
      }
      catch (NumberFormatException ex) {
        price = 0.0f;
      }
      pstmt.setFloat(4, price);
      pstmt.setInt(5, Integer.parseInt(request.getParameter("id")));
      int rowCount = pstmt.executeUpdate();

      // Commit transaction
      conn.commit();
      conn.setAutoCommit(true);
    }

    if (action != null && action.equals("delete")) {

      // Begin transaction
      conn.setAutoCommit(false);

      // Create the prepared statement and use it to
      // DELETE product FROM the product table.
      pstmt = conn
          .prepareStatement("DELETE FROM product WHERE id = ?");

      pstmt.setInt(1, Integer.parseInt(request.getParameter("id")));
      int rowCount = pstmt.executeUpdate();

      // Commit transaction
      conn.commit();
      conn.setAutoCommit(true);
    }
%>
<%
    ArrayList<String> idList = new ArrayList<String>();
    ArrayList<String> nameList = new ArrayList<String>();
    pstmt = conn.prepareStatement("SELECT id, name FROM category");
    rs = pstmt.executeQuery();
    while ( rs.next() ) {
      idList.add(rs.getString("id"));
      nameList.add(rs.getString("name"));
    }
%>

  <div class="container-fluid">
    <div class="row-fluid">
      <!-- side bar -->
      <div class="span2">
        <div class="well sidebar-nav">
          <ul class="nav nav-list">
            <li class="nav-header">Categories</li>
            <%
              int size = idList.size();
              for (int i = 0; i < size; ++i) {
            %>
            <li id = "sub-sectionlist"><a href="products.jsp?browseCategory=<%= idList.get(i) %>"><%= nameList.get(i) %></a></li>
            <%
              }
            %>
            <li class="divider"></li>
            <li id = "sub-roster"><a href="products.jsp?browseCategory=all">All products</a></li>
          </ul>
        </div><!--/.well -->
      </div><!--/span-->

      <div class="span10">
        <form action="products.jsp" method="post">
          <input type="hidden" value="search" name="action">
          <div class="input-prepend input-append">
            <select class="input-small" name="searchCategory">
              <option selected="selected" value="all">All</option>
            <%
              size = idList.size();
              for (int i = 0; i < size; ++i) {
            %>
              <option value="<%= idList.get(i) %>"><%= nameList.get(i) %></option>
            <%
              }
            %>
            </select>
            <input type="text" class="span10" value="" name="name" >
            <button class="btn" type="submit">Search</button>
          </div>
        </form>
        <table class="table table-hover">
          <tr>
            <th>#</th>
            <th>Name</th>
            <th>SKU</th>
            <th>Category</th>
            <th>Price</th>
            <th colspan=2>Action</th>
          </tr>
          <%
            if (action != null && action.equals("search")) {
              String searchCategory = request.getParameter("searchCategory");
              String keyword = request.getParameter("name");
              if (keyword != null) {
                keyword = keyword.toLowerCase();
                if (searchCategory == null || searchCategory.equals("all")) {
                  pstmt = conn.prepareStatement("SELECT * FROM product WHERE LOWER(name) LIKE ?");
                  pstmt.setString(1, "%" + keyword + "%");
                }
                else {
                  pstmt = conn.prepareStatement("SELECT * FROM product WHERE category = ? AND LOWER(name) LIKE ?");
                  pstmt.setInt(1, Integer.parseInt(searchCategory));
                  pstmt.setString(2, "%" + keyword + "%");
                }
              }
              else
                pstmt = conn.prepareStatement("SELECT * FROM product");
            }
            else {
              String browseCategory = request.getParameter("browseCategory");
              if (browseCategory == null || browseCategory.equals("all")) 
                pstmt = conn.prepareStatement("SELECT * FROM product");
              else {
                pstmt = conn.prepareStatement("SELECT * FROM product WHERE category = ?");
                pstmt.setInt(1, Integer.parseInt(browseCategory));
              }
            }

            rs = pstmt.executeQuery();
            while ( rs.next() ) {
              int id = rs.getInt("id");
              String name = rs.getString("name");
              String sku= rs.getString("sku");
              String category = rs.getString("category");
              String price = rs.getString("price");
          %>
          <tr>
            <form action="products.jsp" method="post">
              <input type="hidden" value="update" name="action">
              <input type="hidden" value="<%= id %>" name="id">
              <td>
              </td>
              <td>
                <input type="text" value="<%= name %>" name="name">
              </td>
              <td>
                <input type="text" value="<%= sku %>" name="sku">
              </td>
              <td>
                <select name="category">
                <%
                  size = idList.size();
                  for (int i = 0; i < size; ++i) {
                    if (category.equals(idList.get(i))) {
                %>
                      <option selected="selected" value="<%= idList.get(i) %>"><%= nameList.get(i) %></option>
                <%
                    } else {
                %>
                      <option value="<%= idList.get(i) %>"><%= nameList.get(i) %></option>
                <%
                      }
                    }
                %>
                </select>
              </td>
              <td>
                <div class="input-prepend">
                  <span class="add-on">$</span>
                  <input class="input-small" type="text" value="<%= price %>" name="price">
                </div>
              </td>
              <td>
                <button type="submit" class="btn btn-primary">Update</button>
              </td>
            </form>
            <form action="products.jsp" method="post">
              <input type="hidden" value="delete" name="action">
              <input type="hidden" value="<%= id %>" name="id">
              <td>
                <button type="submit" class="btn btn-primary">Delete</button>
              </td>
            </form>
          </tr>
          <%
            }
          %>
          <tr>
            <form action="products.jsp" method="post">
              <input type="hidden" value="insert" name="action">
              <td></td>
              <td>
                <input type="text" value="" name="name">
              </td>
              <td>
                <input type="text" value="" name="sku">
              </td>
              <td>
                <select name="category">
                <%
                  size = idList.size();
                  for (int i = 0; i < size; ++i) {
                %>
                    <option value="<%= idList.get(i) %>"><%= nameList.get(i) %></option>
                <%
                  }
                %>
                </select>
              </td>
              <td>
                <div class="input-prepend">
                  <span class="add-on">$</span>
                  <input class="input-small" type="text" value="" name="price">
                </div>
              </td>
              <td colspan=2>
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
  //throw new RuntimeException(e);
  String errorMsg = e.getMessage();
  //TODO: Parse error message to display user-friendly messages.
%>
  <!-- Display error message -->
  <div class="container">
    <div class="alert alert-error">
      <button type="button" class="close" onclick="window.location.href='products.jsp'">&times;</button>
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
	<script src="js/fancybox/jquery.fancybox-1.3.4_patch.js"></script>
  <script>
    $(document).ready(function() {
      $('#nav-products').addClass('active');

			$("#cart").fancybox({
	            'width'             : 800,
	            'height'            : 520,
	            'autoScale'         : false,
	            'transitionIn'      : 'elastic',
	            'transitionOut'     : 'elastic',
	            'type'              : 'iframe',
	            'href'              : "cart.jsp"
	    });
    });
  </script>
</body>
</html>
