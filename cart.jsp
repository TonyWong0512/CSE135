<%@ page language="java" contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"%>
<!DOCTYPE html>
<html>
<jsp:include page="common/auth.jsp" />
<jsp:include page="common/header.jsp" />

<%@ page language="java" import="java.sql.*"%>
<%@ page language="java" import="java.util.ArrayList"%>
<%@ page language="java" import="db.Config"%>
<%-- -------- Open Connection Code -------- --%>
<%
	final String save = "Save";
	final String pay = "Pay";
	final String receipt = "Receipt";
	final String cancel = "Cancel";
	final String checkout = "Checkout";

	final String welcomeMessage = "welcome to your shopping cart";
	final String confirmMessage = "please confirm what you want to buy";
	final String receiptMessage = "thank you for your payment, here is your receipt";

	Connection conn = null;
	PreparedStatement pstmt = null;
	ResultSet rs = null;

	String stateFlag = save;
	String greetingMessage = welcomeMessage;
	String receiptStr = "";

	try {
		// Load JDBC Driver class file
		Class.forName(Config.jdbcDriver);

		// Open a connection to the database using DriverManager
		conn = DriverManager.getConnection(Config.connectionURL,
				Config.username, Config.password);

		// get the username from session
		String username = (String) session.getAttribute("username");
		String userid = (String) session.getAttribute("userid");

		// get the action of the request
		String action = request.getParameter("action");
		if (action != null) {
			stateFlag = action;
		}
		// just for test and debug
		if (username == null) {
			username = "Alice";
		}

		String saveAction = request.getParameter("Save");
		String checkoutAction = request.getParameter("Checkout");
		String payAction = request.getParameter("Pay");
		String cancelAction = request.getParameter("Cancel");

		String checkType = "submit";
		String payType = "hidden";
		String creditLabel = "display:none";
		String creditInput = "hidden";
		String disable = "";

		/*out.println(saveAction);
		out.println(checkoutAction);
		out.println(payAction);
		out.println(cancelAction);
		out.println(stateFlag);
		out.println(username);
		 */
		if (action != null && action.equals("addToCart")) {
			pstmt = conn
					.prepareStatement("SELECT product FROM order_t WHERE product = ? AND username = ? AND state = 'in_cart'");
			pstmt.setInt(1, Integer.parseInt(request.getParameter("id")));
			pstmt.setInt(2, Integer.parseInt(userid));
			rs = pstmt.executeQuery();
			System.out.println("I am here");
			conn.setAutoCommit(false);
			if (rs.next()) {
				pstmt = conn
						.prepareStatement("UPDATE order_t SET amount = amount+1 WHERE product = ? AND username = ? AND state = 'in_cart'");

				pstmt.setInt(1, Integer.parseInt(request.getParameter("id")));
				pstmt.setInt(2, Integer.parseInt(userid));
				int rowCount = pstmt.executeUpdate();
				System.out.println("I am here");
			} else {
				pstmt = conn
						.prepareStatement("INSERT INTO order_t (product, username, amount, state) VALUES (?, ?, 1, 'in_cart')");
				pstmt.setInt(1, Integer.parseInt(request.getParameter("id")));
				pstmt.setInt(2, Integer.parseInt(userid));
				int rowCount = pstmt.executeUpdate();
				System.out.println("I am here");
			}

			// Commit transaction	
			conn.commit();

			conn.setAutoCommit(true);
			stateFlag = save;
		}
		// if the action is submit, 
		if (action != null && !action.equals("addToCart")) {
			conn.setAutoCommit(false);
			if (action.equals(save)) {
				// find out all the products the user has added to his cart
				pstmt = conn
						.prepareStatement("SELECT product FROM order_t,user_t WHERE order_t.username = user_t.id And user_t.name = ? AND order_t.state = 'in_cart'");
				pstmt.setString(1, username);
				ResultSet productResultSet = pstmt.executeQuery();

				// update all the product amount of the order
				while (productResultSet.next()) {
					int pid = productResultSet.getInt("product");
					//out.println("Debug::pid:" + pid);
					String pamountStr = request.getParameter("" + pid);
					int pamount = 0;
					//out.println("Debug::pamount:" + pamount);
					try {
						pamount = Integer.parseInt(pamountStr);
					} catch (Exception e) {
						//should be some sort of conversion exception
						e.printStackTrace();
					}
					// if the amount is smaller or equal to 0, that means the 
					if (pamount <= 0) {
						pstmt = conn
								.prepareStatement("DELETE FROM order_t WHERE EXISTS "
										+ "( SELECT * FROM user_t"
										+ " WHERE user_t.id = order_t.username and user_t.name = ? and product = ?)");
						pstmt.setString(1, username);
						pstmt.setInt(2, pid);
					} else {
						pstmt = conn
								.prepareStatement("UPDATE order_t SET amount = ? WHERE product = ?");
						pstmt.setInt(1, pamount);
						pstmt.setInt(2, pid);
					}
					int rowCount = pstmt.executeUpdate();
					//out.println("Debug:" + rowCount);
					stateFlag = save;
					payType = "hidden";
					checkType = "submit";
					greetingMessage = welcomeMessage;
				}
				if (checkoutAction != null
						&& checkoutAction.equals(checkout)) {
					stateFlag = pay;
					payType = "submit";
					checkType = "hidden";
					creditLabel = "";
					creditInput = "text";
					disable = "disabled";
					greetingMessage = confirmMessage;
				}
			} else if (action.equals(pay)) {
			
				if (payAction != null && payAction.equals(pay)) {
					pstmt = conn
							.prepareStatement("SELECT product.name, product.price, order_t.amount "
									+ "FROM order_t,user_t,product "
									+ "WHERE order_t.username = user_t.id And user_t.name = ? "
									+ "AND order_t.state = 'in_cart' AND product.ID = order_t.product");
					
					pstmt.setString(1, username);
					ResultSet boughtResultSet = pstmt.executeQuery();
					float sumTotal = 0;
					// update all the product amount of the order
					while (boughtResultSet.next()) {
						String pname = boughtResultSet
								.getString("name");
						float pprice = boughtResultSet
								.getFloat("price");
						int pamount = boughtResultSet.getInt("amount");
						receiptStr += ("" + pamount + " " + pname
								+ " with $" + (pprice * pamount) + "</br>");
						sumTotal += pprice * pamount;
					}
					receiptStr += ("Total:" + sumTotal + "</br>");
					// set all the state of the items to done
					pstmt = conn
							.prepareStatement("UPDATE order_t SET state = 'done' where username = (select id from user_t where name = ?) ");
					pstmt.setString(1, username);
					int countDone = pstmt.executeUpdate();
					System.out.println("I reach here");
					//out.println("Debug:" + countDone);
					stateFlag = receipt;
					payType = "hidden";
					checkType = "hidden";
					greetingMessage = receiptMessage;
				} else if (cancelAction != null
						&& cancelAction.equals(cancel)) {
					stateFlag = save;
					payType = "hidden";
					checkType = "submit";
					creditLabel = "display:none";
					creditInput = "hidden";
					disable = "";
					greetingMessage = welcomeMessage;
				}
			}

			// Commit transaction	
			conn.commit();

			conn.setAutoCommit(true);
		}
%>

<body>
	<div class="container-fluid">
		<div class="row-fluid">
			<div class="span12">
				<h4 class="TopWelcome span7">
					Hi
					<%=username%>,
					<%=greetingMessage%>:
				</h4>
				<%
					
					pstmt = conn
								.prepareStatement("SELECT product.id, product.name, product.price, order_t.amount "
										+ "FROM order_t,product,user_t "
										+ "WHERE order_t.username = user_t.id And user_t.name = ? AND order_t.product = product.id AND order_t.state = 'in_cart'");
						
						pstmt.setString(1, username);						
						ResultSet result = pstmt.executeQuery();
						float sum = 0;
						if (result.next()) {
				%>
				<form action="cart.jsp" method="post">

					<table class="MiddleData table table-hover">
						<tr>
							<th>Product Name</th>
							<th>Product Price</th>
							<th>Amount</th>
							<%
								if (stateFlag.equals(pay) || stateFlag.equals(receipt)) {
							%>
							<th>Price</th>
							<%
								}
							%>
						</tr>
						<%
							do {										
										int pid = result.getInt("id");
										String pname = result.getString("name");
										float pprice = result.getFloat("price");
										int pamount = result.getInt("amount");
						%>
						<tr>
							<input id="stateAction" type="hidden" value=<%=stateFlag%>
								name="action" />
							<td><%=pname%></td>
							<td>$<%=pprice%></td>
							<td><input class="input-mini" type="text" name="<%=pid%>"
								id="ProductAmount" value="<%=pamount%>" <%=disable%> /></td>
							<%
								if (stateFlag.equals(pay) || stateFlag.equals(receipt)) {
							%>
							<td>$<%=pprice * pamount%></td>
							<%
								}
							%>
						</tr>
						<%
							sum += pprice * pamount;
										//out.println(sum);
									} while (result.next());
						%>
					</table>
					<div class="span12">
            <label class="span2" style=<%=creditLabel%>>Credit Card:</label>
            <input class="span4" type=<%=creditInput%> placeholder="XXXX-XXXX-XXXX-XXXX" />
            <label
							class="span4 offset8">Total Price: <%=sum%></label>
					</div>
					<div class="BottomButtons span4 offset8">
						<input class="btn btn-primary" type=<%=checkType%> name="Checkout"
							value="Checkout" /> 
						<input class="btn btn-primary"
							type=<%=checkType%> name="Save" value="Save" /> 
						<input
							class="btn btn-primary" type=<%=payType%> id="Pay" name="Pay"
							value="Pay" /> 
						<input class="btn btn-warning" type=<%=payType%>
							name="Cancel" value="Cancel" />
					</div>

				</form>
				<%
					} else {
							//not after just payed the bill
							if (stateFlag.equals(receipt)) {
				%>
				<p class="span12"><%=receiptStr%></p>
				<%
					stateFlag = save;
								payType = "hidden";
								checkType = "submit";
								greetingMessage = welcomeMessage;
								//just finished payment, display thank you message
							} else {
				%>
				<h5 class="span8 offset4">Your shopping cart is empty, go grab
					something!</h5>
				<%
					}
						}
				%>
			</div>

		</div>
	</div>
	<script src="js/jquery-1.9.1.js"></script>
	<script src="js/bootstrap.min.js"></script>
	<script>
		$(document)
				.ready(
						//ask for comfirmation of payment
						function() {
							$("#Pay")
									.click(
											function() {
												return confirm("Are you sure you want to pay the bill and checkout?");
											});
						});
	</script>
</body>
</html>

<%-- -------- Close Connection Code -------- --%>
<%
	// Close the ResultSet
		rs.close();
		// Close the Statement
		pstmt.close();
		// Close the Connection
		conn.close();
	} catch (SQLException e) {

		//out.println("Caught SQLException");
		// Wrap the SQL exception in a runtime exception to propagate
		// it upwards
		//throw new RuntimeException(e);
	} catch (NullPointerException e) {
		// rs or pstmt are null, no worries
		//out.println("Caught Null Pointer Exception");
		e.printStackTrace();
	} catch (Exception e) {
		out.println("Caught unknown exception!");
		e.printStackTrace();
	} finally {
		// Release resources in a finally block in reverse-order of
		// their creation

		if (rs != null) {
			try {
				rs.close();
			} catch (SQLException e) {
			} // Ignore
			rs = null;
		}
		if (pstmt != null) {
			try {
				pstmt.close();
			} catch (SQLException e) {
			} // Ignore
			pstmt = null;
		}
		if (conn != null) {
			try {
				conn.close();
			} catch (SQLException e) {
			} // Ignore
			conn = null;
		}
	}
%>
