<%@page contentType="text/html" pageEncoding="utf-8"%>
<!doctype html>
<%@page import="java.sql.*" %> 
<%@page import="java.io.*" %> 
<%@page import="java.lang.*"%> 
<html>
    <head>
        <title>A/R Status Dashboard</title>
		<link href="../ChartLib/styles/examples.css" rel="stylesheet"/>
        <link href="../ChartLib/styles/kendo.common.css" rel="stylesheet"/>
        <link href="../ChartLib/styles/kendo.black.css" rel="stylesheet"/>
        <script src="../ChartLib/js/jquery.min.js"></script>
		<script src="../ChartLib/js/kendo.all.js"></script>
		<style type="text/css">
			html,
			body {
				background-color: black;
			}
		</style>

	<%
		/*------------------- Set Connection -------------------*/
		String connectionURL = request.getParameter("conURL"); 
		String driver = "com.mysql.jdbc.Driver";
		String userName = "root"; 
		String password = request.getParameter("pw");
		String query = "";
		Connection conn = null; 
		Statement st;
		ResultSet rs;
		/*------------------- End Set Connection -------------------*/

		String ParamOrg = request.getParameter("ParamOrg");
		String ParamSR = request.getParameter("ParamSR");
		String ParamBranch = request.getParameter("ParamBranch");
		String ParamDateIFrom = request.getParameter("ParamDateIFrom");
		String ParamDateITo = request.getParameter("ParamDateITo");
		String ParamDateIIFrom = request.getParameter("ParamDateIIFrom");
		String ParamDateIITo = request.getParameter("ParamDateIITo");

		/*------------------- Set Variable -------------------*/

		Double V_UnInvSO = 0.00;
		Double V_Prepayment = 0.00;
		Double V_TotalInv = 0.00;
		Double V_OverDueUInv = 0.00;
		Double V_NotDueUInv = 0.00;
		Double V_Unreconcile = 0.00;
		/*------------------- End Set Variable -------------------*/

/****************************************** BAR CHART ***********************************************/
	/*------------------- Query: Bar Chart -> Un Invoice SO -------------------*/
		try {
			Class.forName(driver).newInstance(); 
			conn = DriverManager.getConnection(connectionURL, userName, password);
			st = conn.createStatement();
			query = "Select sum(SalesOrderAmt) AS SalesOrderAmt from FactSalesOrder fso, DimBranch dmb Where fso.BranchKey = dmb.BranchKey And (dmb.OrganizationCode = '"+ParamOrg+"' OR 'ALL' = '"+ParamOrg+"') And (dmb.SalesRegionCode = '"+ParamSR+"' OR 'ALL' = '"+ParamSR+"') And (dmb.BranchKey = "+ParamBranch+" OR 0 = "+ParamBranch+") And (fso.SalesOrderDate between '"+ParamDateIFrom+"' AND '"+ParamDateITo+"')";
			rs = st.executeQuery(query);
			while(rs.next()){
				V_UnInvSO = rs.getDouble("SalesOrderAmt");
			}
			conn.close();
		}
		catch(Exception ex){
			out.print("Query: Bar Chart -> Un Invoice SO "+ex);
		}
	/*------------------- End Query: Bar Chart -> Un Invoice SO -------------------*/

	/*------------------- Query: Bar Chart -> Prepayment -------------------*/
		try {
			Class.forName(driver).newInstance(); 
			conn = DriverManager.getConnection(connectionURL, userName, password);
			st = conn.createStatement();
			query = "SELECT SUM(PrepaymentAmt) AS PrepaymentAmt FROM FactPrepaymentSO fpp, DimBranch dmb WHERE fpp.BranchKey = dmb.BranchKey AND (dmb.OrganizationCode = '"+ParamOrg+"' OR 'ALL' = '"+ParamOrg+"') AND (dmb.SalesRegionCode = '"+ParamSR+"' OR 'ALL' = '"+ParamSR+"') AND (dmb.BranchKey = "+ParamBranch+" OR 0 = "+ParamBranch+") AND (fpp.PrepaymentDate between '"+ParamDateIIFrom+"' AND '"+ParamDateIITo+"')";
			rs = st.executeQuery(query);
			while(rs.next()){
				V_Prepayment = rs.getDouble("PrepaymentAmt");
			}
			conn.close();
		}
		catch(Exception ex){
			out.print("Query: Bar Chart -> Prepayment "+ex);
		}
	/*------------------- End Query: Bar Chart -> Prepayment -------------------*/



		/*------------------- Query: Bar Chart -> Unreconcile -------------------*/
		try {
			Class.forName(driver).newInstance(); 
			conn = DriverManager.getConnection(connectionURL, userName, password);
			st = conn.createStatement();
			query = "SELECT SUM(UnReconciledAmt) AS UnReconciledAmt FROM FactBankStatement fbs, DimBranch dmb WHERE fbs.BranchKey = dmb.BranchKey AND (dmb.OrganizationCode = '"+ParamOrg+"' OR 'ALL' = '"+ParamOrg+"') AND (dmb.SalesRegionCode = '"+ParamSR+"' OR 'ALL' = '"+ParamSR+"') AND (dmb.BranchKey = "+ParamBranch+" OR 0 = "+ParamBranch+") AND (fbs.BankStatementDate between '"+ParamDateIIFrom+"' AND '"+ParamDateIITo+"')";
			rs = st.executeQuery(query);
			while(rs.next()){
				V_Unreconcile =  rs.getDouble("UnreconciledAmt");
			}
			conn.close();
		}
		catch(Exception ex){
			out.print("Query: Bar Chart -> Unreconcile "+ex);
		}
	/*------------------- End Query: Bar Chart -> Unreconcile -------------------*/
	//out.print("V_Unreconcile"+V_Unreconcile);

	/*------------------- Query: Bar Chart -> TotalUnpaidInvoice -------------------*/
		try {
			Class.forName(driver).newInstance(); 
			conn = DriverManager.getConnection(connectionURL, userName, password);
			st = conn.createStatement();
			query = "SELECT sum(OpenAmt) as TotalUnpaidInvoice FROM FactInvoice fiv, DimBranch dmb WHERE fiv.BranchKey = dmb.BranchKey AND fiv.DocStatus in ('CO','CL') AND (dmb.OrganizationCode = '"+ParamOrg+"' OR 'ALL' = '"+ParamOrg+"') AND (dmb.SalesRegionCode = '"+ParamSR+"' OR 'ALL' = '"+ParamSR+"') AND (dmb.BranchKey = "+ParamBranch+" OR 0 = "+ParamBranch+") AND (fiv.InvoiceDate between '"+ParamDateIFrom+"' AND '"+ParamDateITo+"')";
			rs = st.executeQuery(query);
			while(rs.next()){
				V_TotalInv = rs.getDouble("TotalUnpaidInvoice");
			}
			conn.close();
		}
		catch(Exception ex){
			out.print("Query: Bar Chart -> TotalUnpaidInvoice "+ex);
		}
	/*------------------- End Query: Bar Chart -> TotalUnpaidInvoice -------------------*/

	/*------------------- Query: Bar Chart -> Over Due Unpaid Invoice -------------------*/
		try {
			Class.forName(driver).newInstance(); 
			conn = DriverManager.getConnection(connectionURL, userName, password);
			st = conn.createStatement();
			query = "Select sum(OpenAmt) as OverDueUInv from FactInvoice fiv, DimBranch dmb Where fiv.BranchKey = dmb.BranchKey AND fiv.DocStatus in ('CO','CL') AND (dmb.OrganizationCode = '"+ParamOrg+"' OR 'ALL' = '"+ParamOrg+"') AND (dmb.SalesRegionCode = '"+ParamSR+"' OR 'ALL' = '"+ParamSR+"') AND (dmb.BranchKey = "+ParamBranch+" OR 0 = "+ParamBranch+") AND (fiv.InvoiceDate between '"+ParamDateIFrom+"' AND '"+ParamDateITo+"') And fiv.DayDue >= 0";
			rs = st.executeQuery(query);
			while(rs.next()){
				V_OverDueUInv = rs.getDouble("OverDueUInv");
			}
			conn.close();
		}
		catch(Exception ex){
			out.print("Query: Bar Chart -> Over Due Unpaid Invoice "+ex);
		}
	/*------------------- End Query: Bar Chart -> Over Due Unpaid Invoice -------------------*/

	/*------------------- Query: Bar Chart -> Not Due Unpaid Invoice -------------------*/
		try {
			Class.forName(driver).newInstance(); 
			conn = DriverManager.getConnection(connectionURL, userName, password);
			st = conn.createStatement();
			query = "Select sum(OpenAmt) as NotDueUInv from FactInvoice fiv, DimBranch dmb Where fiv.BranchKey = dmb.BranchKey AND fiv.DocStatus in ('CO','CL') And fiv.DayDue < 0 AND (dmb.OrganizationCode = '"+ParamOrg+"' OR 'ALL' = '"+ParamOrg+"') AND (dmb.SalesRegionCode = '"+ParamSR+"' OR 'ALL' = '"+ParamSR+"') AND (dmb.BranchKey = "+ParamBranch+" OR 0 = "+ParamBranch+") AND (fiv.InvoiceDate between '"+ParamDateIFrom+"' AND '"+ParamDateITo+"')";
			rs = st.executeQuery(query);
			while(rs.next()){
				V_NotDueUInv = rs.getDouble("NotDueUInv");
			}
			conn.close();
		}
		catch(Exception ex){
			out.print("Query: Bar Chart -> Not Due Unpaid Invoice "+ex);
		}
	/*------------------- End Query: Bar Chart -> Not Due Unpaid Invoice -------------------*/

	%>

<!--------------------- Function --------------------->
	<script type="text/javascript">
	</script>

    </head>
    <body>
	<!--------------------- Chart --------------------->
	 
	 <div id="example" class="k-content">
		<table style="position:absolute; top:0px;"><tr>
			<td><div id="Pie-Chart"></div></td>
			<td><div id="chart"></div></td>
		</tr></table>
	<!--------------------- End Chart --------------------->

	<!--------------------- Function Chart --------------------->
		<style scoped>
			#example{
				font-family: Arial, Helvetica, sans-serif;
				margin:1em 0 0;
				padding: 45px 20px 20px;
				border: 1px solid #dedede;
				-webkit-border-radius: 5px;
				-moz-border-radius: 5px;
				border-radius: 5px;
				text-align: left;
				min-height: 300px;
				width: 934px;
				position: relative;
			}

			#Pie-Chart{
				width: 450px;
				height: 350px;
			}

			#chart{
				width: 450px;
				height: 340px;
			}
		</style>
		<script>
			$(document).ready(function(){
				$("#Pie-Chart").kendoChart({
					theme: $(document).data("kendoSkin") || "black",
					legend: {
						position: "bottom"
					},
					seriesDefaults: {
						labels: {
							visible: true,
							format: "{0:N}"
						},
					},
					series: [{
						type: "pie",
						data: [
							{
								category: "Not Due Unpaid Invoice",
								value: <%out.print(V_NotDueUInv);%>
							},
							{
								category: "Over Due Unpaid Invoice",
								value: <%out.print(V_OverDueUInv);%>
							}
						]
					}],
					tooltip: {
						visible: true,
						
						template: "#= kendo.format('{0:P}', percentage)#"
					}
				});

				$("#chart").kendoChart({
					theme: $(document).data("kendoSkin") || "black",
					legend: {
						position: "bottom"
					},
					seriesDefaults: {
						type: "column"
					},
					series: [
						{
							name: "Not Due Unpaid Invoice",
							data: [<%out.print(V_NotDueUInv);%>]
						},
						{
							name: "Over Due Unpaid Invoice",
							data: [<%out.print(V_OverDueUInv);%>]
						},
						{
							name: "Total Unpaid Invoice",
							data: [<%out.print(V_TotalInv);%>]
						},
						{
							name: "UnInvoice SO",
							data: [<%out.print(V_UnInvSO);%>]
						},
						{
							name: "Prepayment",
							data: [<%out.print(V_Prepayment);%>]
						},
						{
							name: "Unreconcile",
							data: [<%out.print(V_Unreconcile);%>]
						}
					],
					valueAxis: {
						labels: {
							format: "{0:N0}"
							 
						}
					},
					tooltip: {
						visible: true,
						format: "{0:N}"
						//format format: "{0:N0}" 0:N0 ��������ҷȹ���  0:N �����ҷȹ���
					}
				});
			});
		</script>
	<!--------------------- End Function Chart --------------------->
	</div>
    </body>
</html>