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
		String connectionURL = "jdbc:mysql://localhost:3307/DCC_DWH"; 
		String driver = "com.mysql.jdbc.Driver";
		String userName = "root"; 
		String password = "010535546";
		String query = "";
		Connection conn = null; 
		Statement st;
		ResultSet rs;
		/*------------------- End Set Connection -------------------*/

		Integer rc = 0;

		/*------------------- Set Variable -------------------*/

		String StartDate = "";
		String startD = "";
		String endD = "";

		String V_Org = "<option value=\"ALL\">ALL</option>"; // Values of Parameter Organization
		String V_SR = "<option class=\"ALL\" value=\"ALL-ALL\">ALL</option>"; // Values of Parameter Sales Region
		String V_Branch = "<option class=\"ALL-ALL\" value=\"0\">ALL</option>"; // Values of Parameter Branch

		/*------------------- End Set Variable -------------------*/

		/*------------------- Query: Default Parameter Date -------------------*/
		try {
			Class.forName(driver).newInstance(); 
			conn = DriverManager.getConnection(connectionURL, userName, password);
			st = conn.createStatement();
			query = "SELECT CONCAT(DATE_FORMAT(SYSDATE(), '%m/01/%Y'), '') AS StartDate, CONCAT(DATE_FORMAT(SYSDATE(), '%Y-%m-01'), '') AS startD, CONCAT(DATE_FORMAT(SYSDATE(), '%Y-%m-%d'), '') AS endD";
			rs = st.executeQuery(query);
			while(rs.next()){
				StartDate = rs.getString("StartDate");
				startD = rs.getString("startD");
				endD = rs.getString("endD");
			}
			conn.close();
		}
		catch(Exception ex){
			out.print("Query: Default Parameter Date "+ex);
		}
		/*------------------- End Query: Default Parameter Date -------------------*/

		/*------------------- Query: Organization Parameter -------------------*/
		try {
			Class.forName(driver).newInstance(); 
			conn = DriverManager.getConnection(connectionURL, userName, password);
			st = conn.createStatement();
			query = "SELECT DISTINCT OrganizationCode, Organization FROM DimBranch ORDER BY Organization";
			rs = st.executeQuery(query);
			while(rs.next()){
				// Class Organization =  AND OrganizationCode Value = OrganizationCode
				V_Org += "<option value=\""+ rs.getString("OrganizationCode") +"\">" + rs.getString("Organization") + "</option>";

				// Class Sales Region = OrganizationCode AND Value -> OrganizationCode-ALL (Class-Value)
				V_SR += "<option class=\"" + rs.getString("OrganizationCode") +"\" value=\"" + rs.getString("OrganizationCode") + "-ALL\">ALL</option>";

				// Class Branch -> OrganizationCode-ALL (ParamOrg-ParamSR) AND Value = 0
				V_Branch += "<option class=\""+ rs.getString("OrganizationCode") + "-ALL\" value=\"0\">ALL</option>";
			}
			conn.close();
		}
		catch(Exception ex){
			out.print("Query: Organization Parameter "+ex);
		}
	/*------------------- End Query: Organization Parameter -------------------*/

	/*------------------- Query: Sales Region Parameter -------------------*/
		try {
			Class.forName(driver).newInstance(); 
			conn = DriverManager.getConnection(connectionURL, userName, password);
			st = conn.createStatement();
			query = "SELECT DISTINCT OrganizationCode, SalesRegionCode, SalesRegion FROM DimBranch ORDER BY SalesRegion";
			rs = st.executeQuery(query);
			while(rs.next()){
				// Class Sales Region = OrganizationCode AND Value -> OrganizationCode-SalesRegionCode (Class-Value)
				V_SR += "<option class=\""+ rs.getString("OrganizationCode") +"\" value=\""+ rs.getString("OrganizationCode") +"-"+ rs.getString("SalesRegionCode") +"\">"+ rs.getString("SalesRegion") +"</option>";

				// Class Branch -> OrganizationCode-SalesRegionCode (ParamOrg-ParamSR) AND Value = 0
				V_Branch += "<option class=\""+ rs.getString("OrganizationCode") + "-" + rs.getString("SalesRegionCode") +"\" value=\"0\">ALL</option>";
			}
			conn.close();
		}
		catch(Exception ex){
			out.print("Query: Sales Region Parameter "+ex);
		}
	/*------------------- End Query: Sales Region Parameter -------------------*/

	/*------------------- Query: Sales Region Parameter -------------------*/
		try {
			Class.forName(driver).newInstance(); 
			conn = DriverManager.getConnection(connectionURL, userName, password);
			st = conn.createStatement();
			query = "SELECT DISTINCT SalesRegionCode, SalesRegion FROM DimBranch ORDER BY SalesRegion";
			rs = st.executeQuery(query);
			while(rs.next()){
				// Class Sales Regoin = ALL AND Value -> ALL-SalesRegionCode (Class-Value)
				V_SR += "<option class=\"ALL\" value=\"ALL-"+ rs.getString("SalesRegionCode") +"\">"+ rs.getString("SalesRegion") +"</option>";

				// Class Branch -> ALL-SalesRegionCode (PaaramOrg-ParamSR) AND Value = 0
				V_Branch += "<option class=\"ALL-" + rs.getString("SalesRegionCode") + "\" value=\"0\">ALL</option>";
			}
			conn.close();
		}
		catch(Exception ex){
			out.print("Query: Sales Region Parameter "+ex);
		}
	/*------------------- End Query: Sales Region Parameter -------------------*/

	/*------------------- Query: Branch Parameter -------------------*/
		try {
			Class.forName(driver).newInstance(); 
			conn = DriverManager.getConnection(connectionURL, userName, password);
			st = conn.createStatement();
			query = "SELECT CONCAT(OrganizationCode, '-', SalesRegionCode) AS SalesRegionCode, BranchKey, BranchName FROM DimBranch ORDER BY BranchName";
			rs = st.executeQuery(query);
			while(rs.next()){
				// Class Branch -> OrganizationCode-SalesRegionCode (ParamOrg-ParamSR) Value = BranchKey
				V_Branch += "<option class=\""+ rs.getString("SalesRegionCode") +"\" value=\""+ rs.getString("BranchKey") +"\">"+ rs.getString("BranchName") + "</option>";
			}
			conn.close();
		}
		catch(Exception ex){
			out.print("Query: Branch Parameter "+ex);
		}
	/*------------------- End Query: Branch Parameter -------------------*/

	/*------------------- Query: Branch Parameter -------------------*/
		try {
			Class.forName(driver).newInstance(); 
			conn = DriverManager.getConnection(connectionURL, userName, password);
			st = conn.createStatement();
			query = "SELECT BranchKey, BranchName FROM DimBranch ORDER BY BranchName";
			rs = st.executeQuery(query);
			while(rs.next()){
				// Class Branch -> ALL-ALL (ParamOrg-ParamSR) -> Value = BranchKey
				V_Branch += "<option class=\"ALL-ALL\" value=\""+ rs.getString("BranchKey") +"\">"+ rs.getString("BranchName") + "</option>";
			}
			conn.close();
		}
		catch(Exception ex){
			out.print("Query: Branch Parameter "+ex);
		}
	/*------------------- End Query: Branch Parameter -------------------*/

	/*------------------- Query: Branch Parameter -------------------*/
		try {
			Class.forName(driver).newInstance(); 
			conn = DriverManager.getConnection(connectionURL, userName, password);
			st = conn.createStatement();
			query = "SELECT DISTINCT SalesRegionCode, BranchKey, BranchName FROM DimBranch ORDER BY BranchName";
			rs = st.executeQuery(query);
			while(rs.next()){
				// Class Branch -> ALL-SalesRegionCode (ParamOrg-ParamSR) -> Value = BranchKey
				V_Branch += "<option class=\"ALL-"+ rs.getString("SalesRegionCode") +"\" value=\""+ rs.getString("BranchKey") +"\">"+ rs.getString("BranchName") + "</option>";
			}
			conn.close();
		}
		catch(Exception ex){
			out.print("Query: Branch Parameter "+ex);
		}
	/*------------------- End Query: Branch Parameter -------------------*/

	/*------------------- Query: Branch Parameter -------------------*/
		try {
			Class.forName(driver).newInstance(); 
			conn = DriverManager.getConnection(connectionURL, userName, password);
			st = conn.createStatement();
			query = "SELECT DISTINCT OrganizationCode, BranchKey, BranchName FROM DimBranch ORDER BY BranchName";
			rs = st.executeQuery(query);
			while(rs.next()){
				// Class Branch -> OrganizationCode-ALL (ParamOrg-ParamSR) -> Value = BranchKey
				V_Branch += "<option class=\""+ rs.getString("OrganizationCode") +"-ALL\" value=\""+ rs.getString("BranchKey") +"\">"+ rs.getString("BranchName") + "</option>";
			}
			conn.close();
		}
		catch(Exception ex){
			out.print("Query: Branch Parameter "+ex);
		}
	/*------------------- End Query: Branch Parameter -------------------*/

	%>

<!--------------------- Function --------------------->
	<script type="text/javascript">

		var ParamOrg = "ALL";
		var ParamSR = "ALL";
		var ParamBranch = 0;

	///////////////////////////////////////////////////////////
	//Applies cascading behavior for the specified dropdowns
		function applyCascadingDropdown(sourceId, targetId) {
			var source = document.getElementById(sourceId);
			var target = document.getElementById(targetId);
			var tg = document.getElementById("ParamBranch");
			if (source && target) {
				
				source.onchange = function() {
					if(sourceId=="ParamOrg"){
						ParamOrg = source.value;
						ParamSR = "ALL";
					}
					if(sourceId=="ParamSR"){
						var text = source.value;
						var cutS = text.indexOf('-')+1;
						ParamSR = text.substring(cutS,text.length);
						ParamBranch = 0;
					}
					displayOptionItemsByClass(target, source.value);
					displayOptionItemsByClass(tg, ParamOrg+"-"+ParamSR);
				}
				displayOptionItemsByClass(target, source.value);
			}
		}

		//Displays a subset of a dropdown's options
		function displayOptionItemsByClass(selectElement, className) {
			if (!selectElement.backup) {
				selectElement.backup = selectElement.cloneNode(true);
			}
			var options = selectElement.getElementsByTagName("option");
			for(var i=0, length=options.length; i<length; i++) {
				selectElement.removeChild(options[0]);
			}
			var options = selectElement.backup.getElementsByTagName("option");
			for(var i=0, length=options.length; i<length; i++) {
				if (options[i].className==className)
					selectElement.appendChild(options[i].cloneNode(true));
			}
		}

		//Binds dropdowns
		function applyCascadingDropdowns() {
			applyCascadingDropdown("ParamOrg", "ParamSR");
			//We could even bind items to another dropdown
			applyCascadingDropdown("ParamSR", "ParamBranch");
		}

		//execute when the page is ready
		window.onload=applyCascadingDropdowns;
	///////////////////////////////////////////////////////////
	
		var firstDate = new Date("<%out.print(StartDate);%>");
		var today = new Date();

		$(document).ready(function(){

			// DatePicker of Parameter SO/Invoice Date
			var DateIFrom = $("#ParamDateIFrom").kendoDatePicker({
				value: firstDate,
				max: today,
				format: "dd/MM/yyyy",
				change: startChangeI
			}).data("kendoDatePicker");
			
			var DateITo = $("#ParamDateITo").kendoDatePicker({
				value: today,
				min: firstDate,
				format: "dd/MM/yyyy",
				change: endChangeI
			}).data("kendoDatePicker");

			function startChangeI() {
				DateITo.min(DateIFrom.value());
			}

			function endChangeI() {
				DateIFrom.max(DateITo.value());
			}

			// Bank Stmt/Prepayment/Payment Date
			var DateIIFrom = $("#ParamDateIIFrom").kendoDatePicker({
				value: firstDate,
				max: today,
				format: "dd/MM/yyyy",
				change: startChangeII
			}).data("kendoDatePicker");
			
			var DateIITo = $("#ParamDateIITo").kendoDatePicker({
				value: today,
				min: firstDate,
				format: "dd/MM/yyyy",
				change: endChangeII
			}).data("kendoDatePicker");

			function startChangeII() {
				DateIITo.min(DateIIFrom.value());
			}

			function endChangeII() {
				DateIIFrom.max(DateIITo.value());
			}

			$("#get").click(function(){});
		});

		var conURL = "<%=connectionURL%>";
		var pw = "<%=password%>";

		
		var ParamDateIFrom = "<%=startD%>";
		var ParamDateITo = "<%=endD%>";
		var ParamDateIIFrom = "<%=startD%>";
		var ParamDateIITo = "<%=endD%>";

		function getParamBranch(value)
		{
			ParamBranch = value;
		}

		function getParamDateIFrom(value)
		{
			ParamDateIFrom = value.substring(6) + "-" + value.substring(3,5) + "-" + value.substring(0,2);
		}

		function getParamDateITo(value)
		{
			ParamDateITo = value.substring(6) + "-" + value.substring(3,5) + "-" + value.substring(0,2);
		}

		function getParamDateIIFrom(value)
		{
			ParamDateIIFrom = value.substring(6) + "-" + value.substring(3,5) + "-" + value.substring(0,2);
		}

		function getParamDateIITo(value)
		{
			ParamDateIITo = value.substring(6) + "-" + value.substring(3,5) + "-" + value.substring(0,2);
		}

		function goUrl(iFrameID1, iFrameID2, iFrameID3, iFrameID4)
		{
			var objFrame=document.getElementById(iFrameID1);
			objFrame.src='Dashboard_Chart.jsp?conURL='+conURL+'&pw='+pw+'&ParamOrg='+ParamOrg+'&ParamSR='+ParamSR+'&ParamBranch='+ParamBranch+'&ParamDateIFrom='+ParamDateIFrom+'&ParamDateITo='+ParamDateITo+'&ParamDateIIFrom='+ParamDateIIFrom+'&ParamDateIITo='+ParamDateIITo;

			objFrame=document.getElementById(iFrameID2);
			objFrame.src='TB_1.jsp?conURL='+conURL+'&pw='+pw+'&ParamOrg='+ParamOrg+'&ParamSR='+ParamSR+'&ParamBranch='+ParamBranch+'&ParamDateIFrom='+ParamDateIFrom+'&ParamDateITo='+ParamDateITo+'&ParamDateIIFrom='+ParamDateIIFrom+'&ParamDateIITo='+ParamDateIITo;

			objFrame=document.getElementById(iFrameID3);
			objFrame.src='TB_2.jsp?conURL='+conURL+'&pw='+pw+'&ParamOrg='+ParamOrg+'&ParamSR='+ParamSR+'&ParamBranch='+ParamBranch+'&ParamDateIFrom='+ParamDateIFrom+'&ParamDateITo='+ParamDateITo+'&ParamDateIIFrom='+ParamDateIIFrom+'&ParamDateIITo='+ParamDateIITo;

			objFrame=document.getElementById(iFrameID4);
			objFrame.src='TB_3.jsp?conURL='+conURL+'&pw='+pw+'&ParamOrg='+ParamOrg+'&ParamSR='+ParamSR+'&ParamBranch='+ParamBranch+'&ParamDateIFrom='+ParamDateIFrom+'&ParamDateITo='+ParamDateITo+'&ParamDateIIFrom='+ParamDateIIFrom+'&ParamDateIITo='+ParamDateIITo;
		}

	</script>

    </head>
    <body>
	<!--------------------------- HEADER --------------------------->
	<br/><h2><center><!--<font color="black">-->A/R Status Dashboard</center></h2>

	<div align="center">
		<div id="Main-Panel" class="k-content">
		<!--------------------------- Parameter --------------------------->
			<div id="Parameter-Panel" class="k-header">
				<table width=100%>
				<!--------- Parameter: Row 1 --------->
				<tr>
					<td><label for="ParamOrg">Organization:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</label>
					<select name="ParamOrg" id="ParamOrg">
						<%out.print(V_Org);%>
					</select>
					</td>

					<td><label for="ParamSR">Sales Region:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</label>
					<select name="ParamSR" id="ParamSR">
						<%out.print(V_SR);%>
					</select>
					</td>

					<td colspan="2">Branch:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
					<select name="ParamBranch" id="ParamBranch" onChange="getParamBranch(this.value);">
						<%out.print(V_Branch);%>
					</select>
					</td>
				</tr>
				<!--------- End Parameter: Row 1 --------->

				<!--------- Parameter: Row 2 --------->
				<tr>
					<td>SO/Invoice Date From</td>
					<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
					<input id="ParamDateIFrom" onChange="getParamDateIFrom(this.value);"/>
					</td>
					
					<td>&nbsp;&nbsp;&nbsp;&nbsp;To&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
					<input id="ParamDateITo" onChange="getParamDateITo(this.value);"/>
					</td>

					<td></td>

				</tr>
				<!--------- End Parameter: Row 2 --------->

				<!--------- Parameter: Row 3 --------->
				<tr>
					<td>Bank Stmt/Prepayment/Payment Date From</td>
					<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
					<input id="ParamDateIIFrom" onChange="getParamDateIIFrom(this.value);"/>
					</td>
					
					<td>&nbsp;&nbsp;&nbsp;&nbsp;To&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
					<input id="ParamDateIITo" onChange="getParamDateIITo(this.value);"/>
					</td>

					<td><button class="k-button" id="get" onClick="goUrl('Details_Chart', 'TB1', 'TB2', 'TB3')">&nbsp;&nbsp;&nbsp;OK&nbsp;&nbsp;&nbsp;</button></td>

				</tr>
				<!--------- End Parameter: Row 3 --------->
				</table>
			</div>
		<!--------------------------- End Parameter --------------------------->

		<!--------------------------- Configuration --------------------------->
			<style scoped>
				#Main-Panel{
					font-family: Arial, Helvetica, sans-serif;
					margin:1em 0 0;
					padding: 45px 20px 20px;
					border: 1px solid #dedede;
					-webkit-border-radius: 5px;
					-moz-border-radius: 5px;
					border-radius: 5px;
					text-align: left;
					min-height: 100px;
					width: 934px;
					position: relative;
				}

				#Parameter-Panel {
					position: absolute;
					top: 0px;
					border-radius: 10px 10px 10px 10px;
					border-style: solid;
					border-width: 1px;
					width: 94%;
					padding: 10px 10px 10px 10px;
					margin: 20px auto;
					background-position: 0 -255px;
				}
				#Detail-Panel{
					font-family: Arial, Helvetica, sans-serif;
					margin:1em 0 0;
					padding: 50px 20px 20px;
					border: 1px solid #dedede;
					-webkit-border-radius: 5px;
					-moz-border-radius: 5px;
					border-radius: 5px;
					text-align: left;
					min-height: 1000px;
					width: 934px;
					position: relative;
				}
			</style>

		<!--------------------------- End Configuration --------------------------->
		</div>

		<!--------------------------- Detail: Chart --------------------------->
		<table width=100% style="position:absolute; top:220px;"><tr><td align="center">
			<iframe name="Details_Chart" id="Details_Chart" width="976" height="400" src="./bg.html" marginwidth="0" marginheight="0" vspace="0" hspace="0" frameborder="0" align="middle" scrolling="no"></iframe>
		</td></tr></table>
		<!--------------------------- End Detail: Chart --------------------------->

		<!--------------------------- Detail: Table -> Awaiting Amount --------------------------->
		<table width=100% style="position:absolute; top:600px;"><tr><td align="center">
			<iframe name="TB1" id="TB1" width="976" height="535" src="./bg.html" marginwidth="0" marginheight="0" vspace="0" hspace="0" frameborder="0" align="middle" scrolling="no"></iframe>
		</td></tr></table>
		<!--------------------------- End Detail: Table -> Awaiting Amount --------------------------->

		<!--------------------------- Detail: Table -> Unpaid SO --------------------------->
		<table width=100% style="position:absolute; top:1130px;"><tr><td align="center">
			<iframe name="TB2" id="TB2" width="976"  height="535" src="./bg.html" marginwidth="0" marginheight="0" vspace="0" hspace="0" frameborder="0" align="middle" scrolling="no"></iframe>
		</td></tr></table>
		<!--------------------------- End Detail: Table -> Unpaid SO --------------------------->

		<!--------------------------- Detail: Table -> Unpaid Invoice --------------------------->
		<table width=100% style="position:absolute; top:1660px;"><tr><td align="center">
			<iframe name="TB3" id="TB3" width="976"  height="535" src="./bg.html" marginwidth="0" marginheight="0" vspace="0" hspace="0" frameborder="0" align="middle" scrolling="no"></iframe>
		</td></tr></table>
		<!--------------------------- End Detail: Table -> Unpaid Invoice --------------------------->
	</div>
	</body>
</html>