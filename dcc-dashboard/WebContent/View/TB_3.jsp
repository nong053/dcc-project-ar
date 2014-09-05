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

	/*------------------- Query: Hierarchy Table -> Unpaid Invoice (First Lavel) -------------------*/
		try {
			Class.forName(driver).newInstance(); 
			conn = DriverManager.getConnection(connectionURL, userName, password);
			st = conn.createStatement();
			query = "Select dmb.BranchKey, dmb.BranchName, sum(IF(fiv.DayDue>= 0, fiv.OpenAmt, 0 )) As OverDue, sum(IF(fiv.DayDue < 0, fiv.OpenAmt, 0 )) As NotDue, sum(OpenAmt) as OpenAmt from FactInvoice fiv, DimBranch dmb Where fiv.BranchKey = dmb.BranchKey AND fiv.DocStatus in ('CO','CL') AND (dmb.OrganizationCode = '"+ParamOrg+"' OR 'ALL' = '"+ParamOrg+"') AND (dmb.SalesRegionCode = '"+ParamSR+"' OR 'ALL' = '"+ParamSR+"') AND (dmb.BranchKey = "+ParamBranch+" OR 0 = "+ParamBranch+") AND (fiv.InvoiceDate between '"+ParamDateIFrom+"' AND '"+ParamDateITo+"') Group by dmb.BranchName Having OpenAmt <> 0 Order by OpenAmt Desc";
			rs = st.executeQuery(query);

			rs.last(); // position on last row
			c = rs.getRow(); // get row no.
			rs.beforeFirst(); // reposition on 1st row
			rc = 0;

			while(rs.next()){

				TB1_1 += "{";
				TB1_1 += "BranchKey: "+ rs.getDouble("BranchKey") +",";
				TB1_1 += "BranchName: \""+ rs.getString("BranchName") +"\",";
				TB1_1 += "OverDue: "+ rs.getDouble("OverDue") +",";
				TB1_1 += "NotDue: "+ rs.getDouble("NotDue") +",";
				TB1_1 += "OpenAmt: "+ rs.getDouble("OpenAmt");
				TB1_1 += "}";
				rc++;

				if(rc < c)
					TB1_1 += ",";
			}
			conn.close();
		}
		catch(Exception ex){
			out.print("Query: Hierarchy Table -> Unpaid Invoice (First Lavel) "+ex);
		}
	/*------------------- End Query: Hierarchy Table -> Unpaid Invoice (First Lavel) -------------------*/
	%>

    </head>
    <body>
	<!--------------------- Chart --------------------->

	<div id="example" class="k-content"><table style="position:absolute; top:0px; right:0px;"><tr><td>
	<h3>Unpaid Invoice</h3></td></tr>

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
					min-height: 450px;
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
							field: "OverDue",
							title: "Over Due Open Amt",
							template: '<span style="float:right">#= kendo.toString(OverDue, "n")#</span>'
						},
						{
							field: "NotDue",
							title: "Not Due Open Amt",
							template: '<span style="float:right">#= kendo.toString(NotDue, "n")#</span>'
						},
						{
							field: "OpenAmt",
							title: '<span style="color:red">Open Amt</span>',
							template: '<span style="float:right">#= kendo.toString(OpenAmt, "n")#</span>'
						}]
                    });
                });

				var conURL = "<%=connectionURL%>";
				var pw = "<%=password%>";
				var ParamDateIFrom = "<%=ParamDateIFrom%>";
				var ParamDateITo = "<%=ParamDateITo%>";

				function detailInit(e) {
					var bk = e.data.BranchKey;
					$.ajax({
						url:"TB_3-lv2.jsp?BranchKey="+bk+"&conURL="+conURL+"&pw="+pw+"&ParamDateIFrom="+ParamDateIFrom+"&ParamDateITo="+ParamDateITo+"&ParamDateIFrom="+ParamDateIFrom+"&ParamDateITo="+ParamDateITo,
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
									field: "CustomerName",
									title: "Customer Name"
								},
								{
									field: "CustomerCode",
									title: "Customer ID"
								},
								{
									field: "OverDue",
									title: "Over Due Open Amt",
									template: '<span style="float:right">#= kendo.toString(OverDue, "n")#</span>'
								},
								{
									field: "NotDue",
									title: "Not Due Open Amt",
									template: '<span style="float:right">#= kendo.toString(NotDue, "n")#</span>'
								},
								{
									field: "OpenAmt",
									title: '<span style="color:red">Open Amt</span>',
									template: '<span style="float:right">#= kendo.toString(OpenAmt, "n")#</span>'
								}]
							}).appendTo(e.detailCell);
						 } // End Function: success
					}); // End ajax
                } // End Function detailInit

				function detailInit2(e) {
					var bk = e.data.BranchKey;
					var ck = e.data.CustomerKey;
					$.ajax({
						url:"TB_3-lv3.jsp?BranchKey="+bk+"&CustomerKey="+ck+"&conURL="+conURL+"&pw="+pw+"&ParamDateIFrom="+ParamDateIFrom+"&ParamDateITo="+ParamDateITo,
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
									field: "InvoiceNo",
									title: "Invoice No",
									width: 180
								},
								{ 
									field: "InvoiceDate",
									title: "Invoice Date"
								},
								{
									field: "InvoiceAmt",
									title: "Invoice Amt",
									template: '<span style="float:right">#= kendo.toString(InvoiceAmt, "n")#</span>'
								},
								{
									field: "PaidAmt",
									title: "Paid Amt",
									template: '<span style="float:right">#= kendo.toString(PaidAmt, "n")#</span>'
								},
								{
									field: "OpenAmt",
									title: '<span style="color:red">Open Amt</span>',
									template: '<span style="float:right">#= kendo.toString(OpenAmt, "n")#</span>'
								},
								{
									field: "DayDue",
									title: "Days<br>Due",
									width: 50
								},
								{
									field: "ChatMessage",
									title: "Chat Message",
									width: 220
								}]
							}).appendTo(e.detailCell);
						 } // End Function: success
					}); // End ajax
                } // End Function detailInit2
            </script>
        </div>

	<!--------------------- End Chart --------------------->
	</div></div>
    </body>
</html>