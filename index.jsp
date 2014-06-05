<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<!DOCTYPE html>
<html>
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <link href="css/bootstrap.min.css" rel="stylesheet" media="screen">
  <link href="css/style.css" rel="stylesheet">
  <link rel="shortcut icon" href="favicon.ico" >
<title>XQL - Home</title>
</head>

<%@ page language="java" import="java.sql.*" %>
<%@ page language="java" import="java.util.ArrayList" %>
<%@ page language="java" import="db.Config" %>
<%-- -------- Open Connection Code -------- --%>
<%
  response.sendRedirect("login.jsp");
  try {
    // Load JDBC Driver class file
    Class.forName(Config.jdbcDriver);

    // Open a connection to the database using DriverManager
    Connection conn = DriverManager.getConnection(Config.connectionURL, Config.username, Config.password);

    //Statement statement;

    //ResultSet rs;
%>
<body>
    <div class="container-fluid">
        <div class="row-fluid">
            <div class="span10">
                <form class="form-horizontal" action="studentlist.jsp" method="post">
                    <input type="hidden" value="insert" name="action">
                    <fieldset>
                        <legend>Basic Information</legend>
                        <div class="control-group">
                            <label class="control-label">Identity</label>
                            <div class="controls">
                                <label class="radio inline">
                                    <input type="radio" name="identity" value="undergraduate" onchange="showUndergraduateForm()">Undergraduate
                                </label>
                                <label class="radio inline">
                                    <input type="radio" name="identity" value="graduate" onchange="showGraduateForm()">Graduate
                                </label>
                            </div>
                        </div>
                        

                        <div class="control-group">
                            <label class="control-label">Residency</label>
                            <div class="controls">
                                <select name="residency">
                                  <option value="California resident">California resident</option>
                                  <option value="Foreign student">Foreign student</option>
                                  <option value="Non-CA US student">Non-CA US student</option>
                                </select>  
                            </div>
                        </div>

                        <div class="control-group" id="backgroundlist">
                            <label class="control-label">University 1</label>
                            <div class="controls">
                                <input type="text" value="" name="university" placeholder="University name">
                            </div>
                        </div>

                        <div class="form-actions">
                            <button type="submit" class="btn btn-primary">Save</button>
                            <button type="button" class="btn">Cancel</button>
                        </div>
                      </fieldset>
                    </form>
                    
                        <table class="table table-hover">
                            <tr>
                                <th>Student ID</th>
                                <th>SSN</th>
                                <th>First Name</th>
                                <th>Middle Name</th>
                                <th>Last Name</th>
                                <th>Residency</th>
                                <th>Enrollment</th>
                                <th>Attendances</th>
                                <th>Hold Degrees</th>
                                <th>Department</th>
                                <th>Degree</th>
                                <th>State</th>
                            </tr>
                        <%
                            //while ( rs.next() ) {
                            //    String studentId = rs.getString("student_id");
                            //    int ssn = rs.getInt("ssn");
                            //    String firstname = rs.getString("firstname");
                            //    String middlename = rs.getString("middlename");
                            //    String lastname = rs.getString("lastname");
                            //    String residency = rs.getString("residency");
                            //    String attendances = rs.getString("attendances");
                            //    String holdDegrees = rs.getString("hold_degrees");
                            //    String isEnrolled = rs.getBoolean("is_enrolled")? "yes" : "no";
                            //    String department = rs.getString("department");
                            //    String degree = rs.getString("degree_type");
                            //    String state = rs.getString("state");
                            //    if (state == null)
                            //        state = "";
                        %>
                        <%
                            //}
                        %>
                        </table>
                  </div>
                </div>


Hello world!
</body>
</html>
<%-- -------- Close Connection Code -------- --%>
<%
    // Close the ResultSet
    //rs.close();

    // Close the Statement
    //statement.close();

    // Close the Connection
    conn.close();
  } catch (SQLException sqle) {
      out.println(sqle.getMessage());
  } catch (Exception e) {
      out.println(e.getMessage());
  }
%>
