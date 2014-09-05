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

		Integer c = 0; // Variable for Count Row of Result Set.
		Integer rc = 0; // Variable of Running Count.

		String TB1_1 = "";		
		/*------------------- End Set Variable -------------------*/

		try {
			Class.forName(driver).newInstance(); 
			conn = DriverManager.getConnection(connectionURL, userName, password);
			st = conn.createStatement();
			query = "Select BranchKey, BranchName, sum(UnInvoiceSOAmt) AS UnInvoiceSOAmt, sum(OpenAmt) AS OpenAmt, sum(PrepaymentAmt) AS PrepaymentAmt, sum(UnreconciledAmt) AS UnreconciledAmt, (sum(UnInvoiceSOAmt)+sum(OpenAmt)- sum(PrepaymentAmt)-sum(UnreconciledAmt)) as AwaitingAmt From (	 Select dmb.BranchKey, dmb.BranchName, sum(SalesOrderAmt)  as UnInvoiceSOAmt, 0 as OpenAmt, 0 as PrepaymentAmt, 0 as UnreconciledAmt from FactSalesOrder fso, DimBranch dmb Where fso.BranchKey = dmb.BranchKey AND (dmb.OrganizationCode = '"+ParamOrg+"' OR 'ALL' = '"+ParamOrg+"') AND (dmb.SalesRegionCode = '"+ParamSR+"' OR 'ALL' = '"+ParamSR+"') AND (dmb.BranchKey = "+ParamBranch+" OR 0 = "+ParamBranch+") AND (fso.SalesOrderDate between '"+ParamDateIFrom+"' AND '"+ParamDateITo+"') Group by BranchKey, BranchName union Select dmb.BranchKey, dmb.BranchName, 0 as UnInvoiceSOAmt, sum(OpenAmt) as OpenAmt, 0 as PrepaymentAmt, 0 as UnreconciledAmt from FactInvoice fiv, DimBranch dmb Where fiv.BranchKey = dmb.BranchKey AND (dmb.OrganizationCode = '"+ParamOrg+"' OR 'ALL' = '"+ParamOrg+"') AND (dmb.SalesRegionCode = '"+ParamSR+"' OR 'ALL' = '"+ParamSR+"') AND (dmb.BranchKey = "+ParamBranch+" OR 0 = "+ParamBranch+") AND (fiv.InvoiceDate between '"+ParamDateIFrom+"' AND '"+ParamDateITo+"') Group by BranchKey, BranchName Union Select dmb.BranchKey, dmb.BranchName, 0 as UnInvoiceSOAmt, 0 as OpenAmt, sum(PrepaymentAmt)  as PrepaymentAmt, 0 as UnreconciledAmt from FactPrepaymentSO fpp, DimBranch dmb Where fpp.BranchKey = dmb.BranchKey AND (dmb.OrganizationCode = '"+ParamOrg+"' OR 'ALL' = '"+ParamOrg+"') AND (dmb.SalesRegionCode = '"+ParamSR+"' OR 'ALL' = '"+ParamSR+"') AND (dmb.BranchKey = "+ParamBranch+" OR 0 = "+ParamBranch+") AND (fpp.PrepaymentDate between '"+ParamDateIIFrom+"' AND '"+ParamDateIITo+"') Group by BranchKey, BranchName Union Select dmb.BranchKey, dmb.BranchName, 0 as UnInvoiceSOAmt, 0 as OpenAmt, 0 as PrepaymentAmt, sum(UnreconciledAmt)  as UnreconciledAmt from FactBankStatement fbs, DimBranch dmb Where fbs.BranchKey = dmb.BranchKey AND (dmb.OrganizationCode = '"+ParamOrg+"' OR 'ALL' = '"+ParamOrg+"') AND (dmb.SalesRegionCode = '"+ParamSR+"' OR 'ALL' = '"+ParamSR+"') AND (dmb.BranchKey = "+ParamBranch+" OR 0 = "+ParamBranch+") AND (fbs.BankStatementDate between '"+ParamDateIIFrom+"' AND '"+ParamDateIITo+"') Group by BranchKey, BranchName) as AwaitingResult Group by BranchKey, BranchName Order by AwaitingAmt desc";
			rs = st.executeQuery(query);

			rs.last(); // position on last row
			c = rs.getRow(); // get row no.
			rs.beforeFirst(); // reposition on 1st row
			rc = 0;

			while(rs.next()){

				TB1_1 += "{";
				TB1_1 += "BranchKey: "+ rs.getDouble("BranchKey") +",";
				TB1_1 += "BranchName: \""+ rs.getString("BranchName") +"\",";
				TB1_1 += "UnInvoiceSOAmt: "+ rs.getDouble("UnInvoiceSOAmt") +",";
				TB1_1 += "OpenAmt: "+ rs.getDouble("OpenAmt") +",";
				TB1_1 += "PrepaymentAmt: "+ rs.getDouble("PrepaymentAmt") +",";
				TB1_1 += "UnreconciledAmt: "+ rs.getDouble("UnreconciledAmt") +",";
				TB1_1 += "AwaitingAmt: "+ rs.getDouble("AwaitingAmt");
				TB1_1 += "}";
				rc++;

				if(rc < c)
					TB1_1 += ",";
			}
			conn.close();
		}
		catch(Exception ex){
			out.print("Query: Hierarchy Table -> Awaiting Amount (First Lavel) "+ex);
		}
	/*------------------- End Query: Hierarchy Table -> Awaiting Amount (First Lavel) -------------------*/

	%>

<!--------------------- Function --------------------->
	<script type="text/javascript">
	</script>

    </head>
    <body>
	<!--------------------- Table --------------------->

	<div id="example" class="k-content"><table style="position:absolute; top:0px; right:0px;"><tr><td>
	<h3>Awaiting Amount</h3></td></tr>

          <tr><td><div id="grid"></div></td></tr></table>

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
					width: 934px;
					min-height:450px;
					position: relative;
				}
			</style>

			<script>
                $(document).ready(function() {
                    var element = $("#grid").kendoGrid({
                        dataSource: {
                            data:[<%out.print(TB1_1);%>],
                            pageSize: 10
                        },
                        height: 440,
                        sortable: true,
                        pageable: true,
                        detailInit: detailInit,
                        dataBound: function() {},
                        columns:
						[{
							field: "BranchName",
							title: "Branch Name"
						},
						{
							field: "UnInvoiceSOAmt",
							title: '<span style="color:#FFB90F">UnInvoice SO Amt (1)</span>',
							template: '<span style="float:right">#= kendo.toString(UnInvoiceSOAmt, "n")#</span>'
						},
						{
							field: "OpenAmt",
							title: '<span style="color:red">Open Amt (2)</span>',
							template: '<span style="float:right">#= kendo.toString(OpenAmt, "n")#</span>'
						},
						{
							field: "PrepaymentAmt",
							title: '<span style="color:green">Prepayment (3)</span>',
							template: '<span style="float:right">#= kendo.toString(PrepaymentAmt, "n") #</span>'
						},
						{
							field: "UnreconciledAmt",
							title: "UnReconciled Amt (4)",
							template: '<span style="float:right">#= kendo.toString(UnreconciledAmt, "n")#</span>'
						},
						{
							field: "AwaitingAmt",
							title: "Awaiting Amt</br>(1)+(2)-(3)-(4)",
							template: '<span style="float:right">#= kendo.toString(AwaitingAmt, "n")#</span>'
						}]
                    });
                });

                function detailInit(e) {
					var bk = e.data.BranchKey;
					var conURL = "<%=connectionURL%>";
					var pw = "<%=password%>";
					var ParamDateIIFrom = "<%=ParamDateIIFrom%>";
					var ParamDateIITo = "<%=ParamDateIITo%>";
					$.ajax({
						url:"TB_1-lv2.jsp?BranchKey="+bk+"&conURL="+conURL+"&pw="+pw+"&ParamDateIIFrom="+ParamDateIIFrom+"&ParamDateIITo="+ParamDateIITo,
						dataType:"html",
						success:function(data)
						{
							 var TB1_2 = eval("(" + data + ")");
							 var sharedDataSource = new kendo.data.DataSource({
								data: TB1_2,
								pageSize:5,
								filter: { field: "BranchKey", operator: "eq", value: e.data.BranchKey }
							});

							$("<div/>").kendoGrid({
								dataSource: sharedDataSource,
								scrollable: false,
								sortable: true,
								pageable: true,
								columns:
								[{
									field: "BankAccountName",
									title: "Bank",
									width: 150
								},
								{
									field: "BankStatementName",
									title: "Bank Statement Name"
								},
								{
									field: "BankStatementDate",
									title: "Statement Line Date",
									width: 150
								},
								{
									field: "UnreconciledAmt",
									title: "UnReconciled Amt",
									template: '<span style="float:right">#= kendo.toString(UnreconciledAmt, "n")#</span>',
									width: 150
								},
								{
									field: "BankStatementDesc",
									title: "Description"
								}]
							}).appendTo(e.detailCell);
						 } // End Function: success
					}); // End ajax
                } // End Function detailInit
            </script>
        </div>

	<!--------------------- End Table --------------------->
	</div></div>
    </body>
</html>