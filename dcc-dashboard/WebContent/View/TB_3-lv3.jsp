<%@page contentType="text/html" pageEncoding="utf-8"%><%@page import="java.sql.*"%><%@page import="java.io.*"%><%@page import="java.lang.*"%>
<%String BranchKey = request.getParameter("BranchKey");
		String CustomerKey = request.getParameter("CustomerKey");
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
		String TB1_3 = "";
		try {Class.forName(driver).newInstance();
			conn = DriverManager.getConnection(connectionURL, userName, password);
			st = conn.createStatement();
			query = "Select CustomerKey, InvoiceNo, DATE_FORMAT(InvoiceDate, '%d/%m/%Y') AS InvoiceDate, InvoiceAmt, PaidAmt, OpenAmt, DayDue, ChatMessage from FactInvoice Where OpenAmt <> 0 AND DocStatus in ('CO','CL') AND (InvoiceDate between '"+ParamDateIFrom+"' AND '"+ParamDateITo+"') AND BranchKey = "+BranchKey+" AND CustomerKey = "+CustomerKey+" Order by DayDue Desc";
			rs = st.executeQuery(query);
			rs.last();
			c = rs.getRow();
			rs.beforeFirst();
			rc = 0;
			while(rs.next()){
				TB1_3 += "{";
				TB1_3 += "CustomerKey: "+ rs.getDouble("CustomerKey") +",";
				TB1_3 += "InvoiceDate: \""+ rs.getString("InvoiceDate") +"\",";
				TB1_3 += "InvoiceNo: \""+ rs.getString("InvoiceNo") +"\",";
				TB1_3 += "InvoiceAmt: "+ rs.getDouble("InvoiceAmt") +",";
				TB1_3 += "PaidAmt: "+ rs.getDouble("PaidAmt") +",";
				TB1_3 += "OpenAmt: "+ rs.getDouble("OpenAmt") +",";
				TB1_3 += "DayDue: "+ rs.getDouble("DayDue") +",";
				TB1_3 += "ChatMessage: \""+ rs.getString("ChatMessage") +"\"";
				TB1_3 += "}";
				rc++;
				if(rc < c)TB1_3 += ",";}conn.close();}catch(Exception ex){out.print("Query: Hierarchy Table -> Awaiting Amount (Second Lavel) "+ex);}
		out.print("["+TB1_3+"]");
%>