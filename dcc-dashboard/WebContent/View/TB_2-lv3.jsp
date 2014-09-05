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
		String ParamDateIIFrom = request.getParameter("ParamDateIIFrom");
		String ParamDateIITo = request.getParameter("ParamDateIITo");
		Integer c = 0;
		Integer rc = 0;
		String TB1_3 = "";
		try {Class.forName(driver).newInstance();
			conn = DriverManager.getConnection(connectionURL, userName, password);
			st = conn.createStatement();
			query = "Select BranchKey, CustomerKey, DocNo, DATE_FORMAT(d, '%d/%m/%Y') AS OPDate, sum(UnInvoiceSOAmt) AS UnInvoiceSOAmt, sum(PrepaymentAmt) AS PrepaymentAmt from (Select fso.BranchKey, fso.CustomerKey, fso.SalesOrderNo as DocNo, SalesOrderDate AS d, SalesOrderAmt  as UnInvoiceSOAmt, 0 as PrepaymentAmt from FactSalesOrder fso Where (fso.SalesOrderDate between '"+ParamDateIFrom+"' AND '"+ParamDateITo+"') AND fso.BranchKey = "+BranchKey+" AND fso.CustomerKey = "+CustomerKey+" and SalesOrderAmt <> 0 Union Select fpp.BranchKey, fpp.CustomerKey, fpp.PrepaymentNo as DocNo, PrepaymentDate AS d, 0 as UnInvoiceSOAmt, PrepaymentAmt as PrepaymentAmt from FactPrepaymentSO fpp Where (fpp.PrepaymentDate between '"+ParamDateIIFrom+"' AND '"+ParamDateIITo+"') AND fpp.BranchKey = "+BranchKey+" AND fpp.CustomerKey = "+CustomerKey+" and PrepaymentAmt <> 0) as UnpaidSODetail GROUP BY BranchKey, CustomerKey, DocNo, OPDate Order by DocNo";
			rs = st.executeQuery(query);
			rs.last();
			c = rs.getRow();
			rs.beforeFirst();
			rc = 0;
			while(rs.next()){
				TB1_3 += "{";
				TB1_3 += "BranchKey: "+ rs.getDouble("BranchKey") +",";
				TB1_3 += "CustomerKey: "+ rs.getDouble("CustomerKey") +",";
				TB1_3 += "DocNo: \""+ rs.getString("DocNo") +"\",";
				TB1_3 += "OPDate: \""+ rs.getString("OPDate") +"\",";
				TB1_3 += "UnInvoiceSOAmt: "+ rs.getDouble("UnInvoiceSOAmt") +",";
				TB1_3 += "PrepaymentAmt: "+ rs.getDouble("PrepaymentAmt");
				TB1_3 += "}";
				rc++;
				if(rc < c)TB1_3 += ",";}conn.close();}catch(Exception ex){out.print("Query: Hierarchy Table -> Awaiting Amount (Second Lavel) "+ex);}
		out.print("["+TB1_3+"]");
%>