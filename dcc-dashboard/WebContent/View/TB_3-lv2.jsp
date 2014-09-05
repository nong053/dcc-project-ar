<%@page contentType="text/html" pageEncoding="utf-8"%><%@page import="java.sql.*"%><%@page import="java.io.*"%><%@page import="java.lang.*"%>
<%String BranchKey = request.getParameter("BranchKey");
		String connectionURL = request.getParameter("conURL");
		String driver = "com.mysql.jdbc.Driver";
		String userName = "root";
		String password = request.getParameter("pw");
		String query = "";
		Connection conn = null;
		Statement st;
		ResultSet rs;
		String ParamDateIFrom = request.getParameter("ParamDateIFrom");
		String ParamDateITo = request.getParameter("ParamDateITo");
		Integer c = 0;
		Integer rc = 0;
		String TB1_2 = "";
		try {Class.forName(driver).newInstance();
			conn = DriverManager.getConnection(connectionURL, userName, password);
			st = conn.createStatement();
			query = "Select fiv.BranchKey, fiv.CustomerKey, dcs.CustomerName, dcs.CustomerCode, sum(IF(fiv.DayDue>= 0, fiv.OpenAmt, 0 )) As OverDue, sum(IF(fiv.DayDue < 0, fiv.OpenAmt, 0 )) As NotDue, sum(fiv.OpenAmt) as OpenAmt from FactInvoice fiv, DimCustomer dcs Where fiv.CustomerKey = dcs.CustomerKey AND fiv.DocStatus in ('CO','CL') AND (fiv.InvoiceDate between '"+ParamDateIFrom+"' AND '"+ParamDateITo+"') AND fiv.BranchKey = "+BranchKey+" Group by dcs.CustomerName, dcs.CustomerCode, dcs.CustomerKey Having OpenAmt <> 0 Order by OpenAmt Desc";
			rs = st.executeQuery(query);
			rs.last();
			c = rs.getRow();
			rs.beforeFirst();
			rc = 0;
			while(rs.next()){
				TB1_2 += "{";
				TB1_2 += "BranchKey: "+ rs.getDouble("BranchKey") +",";
				TB1_2 += "CustomerKey: "+ rs.getDouble("CustomerKey") +",";
				TB1_2 += "CustomerName: \""+ rs.getString("CustomerName") +"\",";
				TB1_2 += "CustomerCode: \""+ rs.getString("CustomerCode") +"\",";
				TB1_2 += "OverDue: "+ rs.getDouble("OverDue") +",";
				TB1_2 += "NotDue: "+ rs.getDouble("NotDue") +",";
				TB1_2 += "OpenAmt: "+ rs.getDouble("OpenAmt");
				TB1_2 += "}";
				rc++;
				if(rc < c)TB1_2 += ",";}conn.close();}catch(Exception ex){out.print("Query: Hierarchy Table -> Awaiting Amount (Second Lavel) "+ex);}
		out.print("["+TB1_2+"]");
%>