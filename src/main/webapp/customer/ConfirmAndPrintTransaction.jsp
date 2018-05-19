<%@ page import="com.eezeetel.customerapp.ProcessTransaction" %>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
         pageEncoding="ISO-8859-1" %>
<%@ include file="/common/imports.jsp" %>
<%@ include file="/common/SessionCheck.jsp" %>

<%
    response.addHeader("Pragma", "no-cache");
    response.addHeader("Expires", "-1");

    long nTransactionID = 0;
    Object objTransactionID = request.getSession().getAttribute("CurrentTransactionID");
    if (objTransactionID != null) {
        String strTransactionID = objTransactionID.toString();
        if (strTransactionID != null && strTransactionID.length() > 0)
            nTransactionID = (Long.parseLong(strTransactionID));
    }

    if (nTransactionID > 0) {
        ProcessTransaction processTransaction = new ProcessTransaction();
        boolean bProcessed = processTransaction.confirm(nTransactionID);
        if (bProcessed)
            response.sendRedirect(ksContext + "PrintTransaction.jsp");
        else {
            response.getWriter().printf("<font color=red>Could not complete transaction</font>");
            response.getWriter().printf("<a href='/customer/products'> Show Products </a>");
            request.getSession().setAttribute("CurrentTransactionID", 0);
        }
    } else
        response.sendRedirect("/customer/products");
%>
