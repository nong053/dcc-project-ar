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
		String ParamDateIIFrom = request.getParameter("ParamDateIIFrom");
		String ParamDateIITo = request.getParameter("ParamDateIITo");
		Integer c = 0;
		Integer rc = 0;
		String TB1_2 = "";
		try {Class.forName(driver).newInstance();
			conn = DriverManager.getConnection(connectionURL, userName, password);
			st = conn.createStatement();
			query = "select fbs.Branchkey, dba.BankAccountName, fbs.BankStatementName, DATE_FORMAT(fbs.BankStatementDate, '%d/%m/%Y') AS BankStatementDate, fbs.UnreconciledAmt, fbs.BankStatementDesc from FactBankStatement fbs, DimBankAccount dba where fbs.BankAccountKey = dba.BankAccountKey AND (fbs.BankStatementDate between '"+ParamDateIIFrom+"' AND '"+ParamDateIITo+"') AND fbs.UnreconciledAmt <> 0 AND fbs.Branchkey = "+BranchKey;
			rs = st.executeQuery(query);
			rs.last();
			c = rs.getRow();
			rs.beforeFirst();
			rc = 0;
			while(rs.next()){
				TB1_2 += "{";
				TB1_2 += "\"BranchKey\": \""+ rs.getDouble("BranchKey") +"\",";
				TB1_2 += "\"BankAccountName\": \""+ rs.getString("BankAccountName") +"\",";
				TB1_2 += "\"BankStatementName\": \""+ rs.getString("BankStatementName") +"\",";
				TB1_2 += "\"BankStatementDate\": \""+ rs.getString("BankStatementDate") +"\",";
				TB1_2 += "\"UnreconciledAmt\": "+ rs.getDouble("UnreconciledAmt") +",";
				TB1_2 += "\"BankStatementDesc\": \""+ rs.getString("BankStatementDesc") +"\"";
				TB1_2 += "}";
				rc++;
				if(rc < c)TB1_2 += ",";}conn.close();}catch(Exception ex){out.print("Query: Hierarchy Table -> Awaiting Amount (Second Lavel) "+ex);}
		out.print("["+TB1_2+"]");
%>