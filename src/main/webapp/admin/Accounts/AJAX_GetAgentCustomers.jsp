<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
         pageEncoding="ISO-8859-1" %>
<%@ include file="/common/imports.jsp" %>

<%
    String strQuery = "", strResult = "<The_Data>";
    String strAgentName = request.getParameter("agent_id");
    if (strAgentName == null || strAgentName.isEmpty()) {
        strResult = "<The_Data></The_Data>";
        response.setContentType("text/xml");
        response.getWriter().println(strResult);
        return;
    }

    Session theSession = null;
    try {
        theSession = HibernateUtil.openSession();

        Integer nCustomerGroupID = (Integer) session.getAttribute("GROUP_ID");

        strQuery = "from TMasterCustomerinfo where Active_Status = 1 and Customer_Introduced_By = '" + strAgentName +
                "' and Customer_Group_ID = " + nCustomerGroupID + " order by Customer_Company_Name";
        Query query = theSession.createQuery(strQuery);
        List records = query.list();

        for (int i = 0; i < records.size(); i++) {
            TMasterCustomerinfo custInfo = (TMasterCustomerinfo) records.get(i);
            if (custInfo.getGroup().getId().intValue() == nCustomerGroupID)
                strResult += ("<customer id=\"" + custInfo.getId() + "\" name=\"" + custInfo.getCompanyName() + "\"/>");
        }

        strResult += ("</The_Data>");
        response.setContentType("text/xml");
        response.getWriter().println(strResult);
    } catch (Exception e) {
        e.printStackTrace();
        strResult = "<The_Data></The_Data>";
        response.setContentType("text/xml");
        response.getWriter().println(strResult);
    } finally {
        HibernateUtil.closeSession(theSession);
    }
%>
