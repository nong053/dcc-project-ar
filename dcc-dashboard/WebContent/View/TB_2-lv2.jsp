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
		String ParamDateIIFrom = request.getParameter("ParamDateIIFrom");
		String ParamDateIITo = request.getParameter("ParamDateIITo");
		Integer c = 0;
		Integer rc = 0;
		String TB1_2 = "";
		try {Class.forName(driver).newInstance();
			conn = DriverManager.getConnection(connectionURL, userName, password);
			st = conn.createStatement();
			query = "Select BranchKey, CustomerKey, CustName, CustID, sum(UnInvoiceSOAmt) AS UnInvoiceSOAmt, sum(PrepaymentAmt) AS PrepaymentAmt, (sum(UnInvoiceSOAmt)- sum(PrepaymentAmt)) as UnpaidSOAmt from (Select fso.BranchKey, dcs.CustomerKey, dcs.CustomerName as CustName, dcs.CustomerCode as CustID, sum(SalesOrderAmt)  as UnInvoiceSOAmt, 0 as PrepaymentAmt from FactSalesOrder fso, DimCustomer dcs Where fso.CustomerKey = dcs.CustomerKey And (fso.SalesOrderDate between '"+ParamDateIFrom+"' AND '"+ParamDateITo+"') AND fso.BranchKey = "+BranchKey+" Group by CustName, CustID Union Select fpp.BranchKey, dcs.CustomerKey, dcs.CustomerName as CustName, dcs.CustomerCode as CustID, 0 as UnInvoiceSOAmt, sum(PrepaymentAmt) as PrepaymentAmt from FactPrepaymentSO fpp, DimCustomer dcs Where fpp.CustomerKey = dcs.CustomerKey And (fpp.PrepaymentDate between '"+ParamDateIIFrom+"' AND '"+ParamDateIITo+"') AND fpp.BranchKey = "+BranchKey+" Group by CustName, CustID ) as UnpaidSOCust Group by CustName, CustID Having UnpaidSOAmt <> 0 Order by CustName";
			rs = st.executeQuery(query);
			rs.last();
			c = rs.getRow();
			rs.beforeFirst();
			rc = 0;
			while(rs.next()){
				TB1_2 += "{";
				TB1_2 += "BranchKey: "+ rs.getDouble("BranchKey") +",";
				TB1_2 += "CustomerKey: "+ rs.getDouble("CustomerKey") +",";
				TB1_2 += "CustName: \""+ rs.getString("CustName") +"\",";
				TB1_2 += "CustID: \""+ rs.getString("CustID") +"\",";
				TB1_2 += "UnInvoiceSOAmt: "+ rs.getDouble("UnInvoiceSOAmt") +",";
				TB1_2 += "PrepaymentAmt: "+ rs.getDouble("PrepaymentAmt") +",";
				TB1_2 += "UnpaidSOAmt: "+ rs.getDouble("UnpaidSOAmt");
				TB1_2 += "}";
				rc++;
				if(rc < c)TB1_2 += ",";}conn.close();}catch(Exception ex){out.print("Query: Hierarchy Table -> Awaiting Amount (Second Lavel) "+ex);}
		out.print("["+TB1_2+"]");
%>