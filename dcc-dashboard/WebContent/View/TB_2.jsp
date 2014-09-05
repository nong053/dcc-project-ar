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
		String TB1_2 = "";
		String TB1_3 = "";
		
		/*------------------- End Set Variable -------------------*/

	/*------------------- Query: Hierarchy Table -> Unpaid SO (First Lavel) -------------------*/
		try {
			Class.forName(driver).newInstance(); 
			conn = DriverManager.getConnection(connectionURL, userName, password);
			st = conn.createStatement();
			query = "Select BranchKey, BranchName, sum(UnInvoiceAmt) AS UnInvoiceAmt, sum(PrepaymentAmt) AS PrepaymentAmt, (sum(UnInvoiceAmt) - sum(PrepaymentAmt)) AS UnpaidSOAmt From (Select dmb.BranchKey, dmb.BranchName, sum(SalesOrderAmt)  as UnInvoiceAmt, 0 as PrepaymentAmt from FactSalesOrder fso, DimBranch dmb Where fso.BranchKey = dmb.BranchKey AND (dmb.OrganizationCode = '"+ParamOrg+"' OR 'ALL' = '"+ParamOrg+"') AND (dmb.SalesRegionCode = '"+ParamSR+"' OR 'ALL' = '"+ParamSR+"') AND (dmb.BranchKey = "+ParamBranch+" OR 0 = "+ParamBranch+") AND (fso.SalesOrderDate between '"+ParamDateIFrom+"' AND '"+ParamDateITo+"') Group by BranchKey union Select dmb.BranchKey, dmb.BranchName, 0 as UnInvoiceAmt, sum(PrepaymentAmt)  as PrepaymentAmt from FactPrepaymentSO fpp, DimBranch dmb Where fpp.BranchKey = dmb.BranchKey AND (dmb.OrganizationCode = '"+ParamOrg+"' OR 'ALL' = '"+ParamOrg+"') AND (dmb.SalesRegionCode = '"+ParamSR+"' OR 'ALL' = '"+ParamSR+"') AND (dmb.BranchKey = "+ParamBranch+" OR 0 = "+ParamBranch+") AND (fpp.PrepaymentDate between '"+ParamDateIIFrom+"' AND '"+ParamDateIITo+"') Group by BranchKey) as UnpaidSOResult Group by BranchKey Having UnpaidSOAmt <> 0 Order by UnpaidSOAmt desc";
			rs = st.executeQuery(query);

			rs.last(); // position on last row
			c = rs.getRow(); // get row no.
			rs.beforeFirst(); // reposition on 1st row
			rc = 0;

			while(rs.next()){

				TB1_1 += "{";
				TB1_1 += "BranchKey: "+ rs.getDouble("BranchKey") +",";
				TB1_1 += "BranchName: \""+ rs.getString("BranchName") +"\",";
				TB1_1 += "UnInvoiceAmt: "+ rs.getDouble("UnInvoiceAmt") +",";
				TB1_1 += "PrepaymentAmt: "+ rs.getDouble("PrepaymentAmt") +",";
				TB1_1 += "UnpaidSOAmt: "+ rs.getDouble("UnpaidSOAmt");
				TB1_1 += "}";
				rc++;

				if(rc < c)
					TB1_1 += ",";
			}
			conn.close();
		}
		catch(Exception ex){
			out.print("Query: Hierarchy Table -> Unpaid SO (First Lavel) "+ex);
		}
	/*------------------- End Query: Hierarchy Table -> Unpaid SO (First Lavel) -------------------*/
	%>
    </head>
    <body>
	<!--------------------- Table --------------------->

	<div id="example" class="k-content"><table style="position:absolute; top:0px; right:0px;"><tr><td>
	<h3>Uninvoiced SO/Prepayment</h3></td></tr>

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
                        dataBound: function() {
                        },
                        columns:
						[{
							field: "BranchName",
							title: "Branch Name"
						},
						{
							field: "UnInvoiceAmt",
							title: '<span style="color:#FFB90F">UnInvoice Amt (OrderAmt)</span>',
							template: '<span style="float:right">#= kendo.toString(UnInvoiceAmt, "n")#</span>'
						},
						{
							field: "PrepaymentAmt",
							title: '<span style="color:green">Prepayment Amt</span>',
							template: '<span style="float:right">#= kendo.toString(PrepaymentAmt, "n")#</span>'
						},
						{
							field: "UnpaidSOAmt",
							title: "Unpaid SO Amt",
							template: '<span style="float:right">#= kendo.toString(UnpaidSOAmt, "n")#</span>'
						}]
                    });
                });
				
				var conURL = "<%=connectionURL%>";
				var pw = "<%=password%>";
				var ParamDateIFrom = "<%=ParamDateIFrom%>";
				var ParamDateITo = "<%=ParamDateITo%>";
				var ParamDateIIFrom = "<%=ParamDateIIFrom%>";
				var ParamDateIITo = "<%=ParamDateIITo%>";

				function detailInit(e) {
					var bk = e.data.BranchKey;
					$.ajax({
						url:"TB_2-lv2.jsp?BranchKey="+bk+"&conURL="+conURL+"&pw="+pw+"&ParamDateIFrom="+ParamDateIFrom+"&ParamDateITo="+ParamDateITo+"&ParamDateIIFrom="+ParamDateIIFrom+"&ParamDateIITo="+ParamDateIITo,
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
								detailInit: detailInit2,
								dataBound: function() {},
								columns:
								[{
									field: "CustName",
									title: "Customer Name"
								},
								{
									field: "CustID",
									title: "Customer ID"
								},
								{
									field: "UnInvoiceSOAmt",
									title: '<span style="color:#FFB90F">UnInvioce SO Amt</span>',
									template: '<span style="float:right">#= kendo.toString(UnInvoiceSOAmt, "n")#</span>'
								},						
								{
									field: "PrepaymentAmt",
									title: '<span style="color:green">Prepayment Amt</span>',
									template: '<span style="float:right">#= kendo.toString(PrepaymentAmt, "n")#</span>'
								},
								{
									field: "UnpaidSOAmt",
									title: "Unpaid SO Amt",
									template: '<span style="float:right">#= kendo.toString(UnpaidSOAmt, "n")#</span>'
								}]
							}).appendTo(e.detailCell);
						 } // End Function: success
					}); // End ajax
                } // End Function detailInit

				function detailInit2(e) {
					var bk = e.data.BranchKey;
					var ck = e.data.CustomerKey;
					$.ajax({
						url:"TB_2-lv3.jsp?BranchKey="+bk+"&CustomerKey="+ck+"&conURL="+conURL+"&pw="+pw+"&ParamDateIFrom="+ParamDateIFrom+"&ParamDateITo="+ParamDateITo+"&ParamDateIIFrom="+ParamDateIIFrom+"&ParamDateIITo="+ParamDateIITo,
						dataType:"html",
						success:function(data)
						{
							 var TB1_3 = eval("(" + data + ")");
							 var sharedDataSource = new kendo.data.DataSource({
								data: TB1_3,
								pageSize:5,
								filter: { field: "CustomerKey", operator: "eq", value: e.data.CustomerKey }
							});

							$("<div/>").kendoGrid({
								dataSource: sharedDataSource,
								scrollable: false,
								sortable: true,
								pageable: true,
								columns:
								[{
									field: "DocNo",
									title: "Order/Prepayment No"
								},
								{
									field: "OPDate",
									title: "Order/Prepayment Date"
								},
								{
									field: "UnInvoiceSOAmt",
									title: '<span style="color:#FFB90F">UnInvioce SO Amt</span>',
									template: '<span style="float:right">#= kendo.toString(UnInvoiceSOAmt, "n")#</span>'
								},						
								{
									field: "PrepaymentAmt",
									title: '<span style="color:green">Prepayment Amt</span>',
									template: '<span style="float:right">#= kendo.toString(PrepaymentAmt, "n")#</span>'
								}]
							}).appendTo(e.detailCell);
						 } // End Function: success
					}); // End ajax
                } // End Function detailInit2
            </script>
        </div>

	<!--------------------- End Table --------------------->
	</div></div>
    </body>
</html>