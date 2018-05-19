<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
         pageEncoding="ISO-8859-1" %>
<%@ include file="/common/imports.jsp" %>

<%
    String strRequesterPhone = request.getParameter("requester_phone");
    String strDestinationPhone = request.getParameter("dest_phone");
    String strOperatorID = request.getParameter("dest_operator_id");
    String strSMSText = request.getParameter("sms_text");
    String strProductAmount = request.getParameter("products_list");
    String strCostToCustomer = request.getParameter("final_price");
    Float fCostToCustomer = Float.parseFloat(strCostToCustomer);
    String strSelectedProduct = request.getParameter("selected_product");
    DecimalFormat df = new DecimalFormat("0.00");

    String userAgent = request.getHeader("User-Agent");
    boolean bAutoPrint = true;
    if (userAgent.compareToIgnoreCase("CallingCardsApp") == 0)
        bAutoPrint = false;

    Session theSession = null;
    PinLessTopupResponse theResponse = null;
    boolean bEnoughBalance = false;
    try {
        theSession = HibernateUtil.openSession();

        String strUserID = request.getRemoteUser();
        String strQuery = "from TCustomerUsers where User_Login_ID = '" + strUserID + "'";
        Query query = theSession.createQuery(strQuery);
        List listCustomerID = query.list();
        if (listCustomerID.size() > 0) {
            TCustomerUsers custUsers = (TCustomerUsers) listCustomerID.get(0);
            TMasterCustomerinfo custInfo = custUsers.getCustomer();
            TMasterCustomerGroups custGroup = custInfo.getGroup();
            float fAvailableBalance = custInfo.getCustomerBalance();

            if (fAvailableBalance > fCostToCustomer) {
                if (custGroup.getCheckAganinstGroupBalance()) {
                    if (custGroup.getCustomerGroupBalance() > 500)
                        bEnoughBalance = true;
                } else
                    bEnoughBalance = true;
            }

            int nCustomerID = custInfo.getId();

            if (bEnoughBalance) {
                TransferToServiceMain transferToService = new TransferToServiceMain(nCustomerID, strUserID);
                theResponse = transferToService.PerformTopUpOperation(strRequesterPhone,
                        strDestinationPhone, strOperatorID,
                        strSMSText, strSelectedProduct, fCostToCustomer);
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        HibernateUtil.closeSession(theSession);
    }
%>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
    <link rel="stylesheet" href="/css/print.css" type="text/css" media="print"/>
    <STYLE TYPE='text/css'>
        P.pagebreakhere {
            page-break-before: always
        }

        td.font_style {
            font-family: "Verdana";
            font-weight: bolder;
            font-size: 14px;
        }
    </STYLE>

    <%
        if (theResponse != null && theResponse.m_nErrorCode == 0) {
    %>
    <script language="javascript">
        function pausecomp(milsec) {
            milsec += new Date().getTime();
            while (new Date() < milsec) {
            }
            window.location.href = "/customer/products";
        }

        function PrintPage() {
            <%
                if (userAgent.contains("Chrome/"))
                {
            %>
            window.print();
            setTimeout("pausecomp(5000)", 5000);
            <%
                }
                else
                {
            %>
            window.location.href = "/customer/products";
            window.print();
            <%
                }
            %>
        }
        <%
        if (bAutoPrint)
        {
        %>
        window.onload = PrintPage;
        <%
        }
        %>
    </script>
    <title>Receipt</title>
</head>
<body>
<table>
    <tr>
        <td align="left"><b><%=theResponse._m_strCompanyName%>
        </b></td>
    </tr>
    <tr>
        <td align="left"><b>Transaction Number : <%=theResponse.m_nEezeeTelTransactionID%>
        </b></td>
    </tr>
    <tr>
        <td align="left"><b>Reference Number : <%=theResponse.m_nTransferToTransactionID%>
        </b></td>
    </tr>
    <tr>
        <td align="left"><b>Time : <%=theResponse.m_strTransactionTime%>
        </b></td>
    </tr>
    <tr>
        <td align="left"><b>Sender : <%=theResponse.m_strRequesterNumber%>
        </b></td>
    </tr>
    <tr>
        <td align="left"><b>Receiver : <%=theResponse.m_strDestinationNumber%>
        </b></td>
    </tr>
    <tr>
        <td align="left"><b>Operator : <%=theResponse.m_strDestinationOperator%>
        </b></td>
    </tr>
    <tr>
        <td align="left"><b>Topup Value
            : <%=theResponse.m_strDestinationCurrency%> <%=df.format(theResponse.m_fProductSent)%>
        </b></td>
    </tr>
</table>
    <%
	}
	else
	{
%>
<body>
<div id="nav">
    <%
        if (bEnoughBalance) {
    %>
    <font color="red" size="10"> Unable to process transaction. Please try again. </font>
    <%
    } else {
    %>
    <font color="red" size="10"> You do not have sufficient balance. Please request a topup and try again. </font>
    <%
        }
    %>
    <br>
    <a href="/customer/products"> Show Products </a>
</div>
<%
    }
%>
</body>
</html>