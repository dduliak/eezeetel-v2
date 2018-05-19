<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
         pageEncoding="ISO-8859-1" %>
<%@ include file="/common/imports.jsp" %>

<%
    response.setContentType("text/html");
    String strDestinationNumber = request.getParameter("dest_phone");
    String strRequesterNumber = request.getParameter("requester_phone");

    String errString = "Failed to get available product information ";
    if (strDestinationNumber == null || strDestinationNumber.isEmpty()) {
        errString += ".  Please enter a valid destination phone number along with country code.";
        response.getWriter().println(errString);
        return;
    }

    if (strRequesterNumber == null || strRequesterNumber.isEmpty()) {
        errString += ".  Please enter a valid requester phone number along with country code.";
        response.getWriter().println(errString);
        return;
    }
    String strCompanyName = "You";

    Session theSession = null;
    MSISDNResponse theResponse = null;
    try {
        theSession = HibernateUtil.openSession();

        String strUserID = request.getRemoteUser();
        String strQuery = "from TCustomerUsers where User_Login_ID = '" + strUserID + "'";
        Query query = theSession.createQuery(strQuery);
        List listCustomerID = query.list();
        if (listCustomerID.size() > 0) {
            TCustomerUsers custUsers = (TCustomerUsers) listCustomerID.get(0);
            TMasterCustomerinfo custInfo = custUsers.getCustomer();
            strCompanyName = custInfo.getCompanyName();
            TransferToServiceMain transferToService = new TransferToServiceMain(custInfo.getId(), strUserID);
            theResponse = transferToService.PerformMSISDNInfo(strDestinationNumber, null);
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        HibernateUtil.closeSession(theSession);
    }

    if (theResponse != null) {
%>
<table align="center">
    <tr>
        <td align="right">
            <span class="Normal-C0">Sender Mobile Number</span><br>
            <font color="#980009" size="3">(Diraha lambarkiisa)</font>
        </td>
        <td align="left">
            <input type="text" name="requester_phone" size="20" maxlength="20" readonly
                   value="<%=strRequesterNumber%>"/>
        </td>
    </tr>

    <tr>
        <td align="right"><span class="Normal-C0"> Receiver's Mobile Number</span><br><font color="#980009" size="3">
            (Qaataha lamberkiisa) </font></td>
        <td align="left"><input type="text" id="dest_phone_id" name="dest_phone" size="20" maxlength="20" readonly
                                value="<%=theResponse.m_strDestinationNumber%>"/></td>
    </tr>

    <tr>
        <td align="right">
            <span class="Normal-C0">Country</span>
        </td>
        <td align="left">
            <input type="text" name="dest_country" size="20" maxlength="20"
                   value="<%=theResponse.m_strCountry%>" readonly/>
        </td>
    </tr>

    <tr>
        <td align="right"><span class="Normal-C0">Country Code</span></td>
        <td align="left"><input type="text" name="dest_country_code" size="3" maxlength="3"
                                value="<%=theResponse.m_strCountryID%>" readonly/></td>
    </tr>

    <tr>
        <td align="right">
            <span class="Normal-C0">Operator</span>
        </td>
        <td align="left">
            <input type="text" name="dest_operator" size="20" maxlength="20"
                   value="<%=theResponse.m_strOperator%>" readonly/>
        </td>
    </tr>

    <tr>
        <td align="right">
            <span class="Normal-C0">Operator ID</span>
        </td>
        <td align="left">
            <input type="text" name="dest_operator_id" size="3" maxlength="3"
                   value="<%=theResponse.m_strOperatorID%>" readonly/>
        </td>
    </tr>

    <tr>
        <td align="right">
            <span class="Normal-C0">Country Currency</span><br>
            <font color="#980009" size="3">(Lacagta waddanka)</font>
        </td>
        <td align="left">
            <input type="text" name="dest_currency" size="20" maxlength="20"
                   value="<%=theResponse.m_strCurrency%>" readonly/>
        </td>
    </tr>

    <tr>
        <td align="right">
            <span class="Normal-C1">Amount</span><br>
            <font color="#980009" size="3">(Qiimaha)</font>
        </td>
        <td align="left">
            <select name="products_list" onchange="change_final_price(this.value)"
                    style="width:160px; height:40px;font-size:20px;">
                <%
                    String strXMLMap = "<pmap>";
                    String strFirstProduct = "";
                    float fFirstPrice = 0.0f;
                    float fFirstRetailPrice = 0.0f;
                    DecimalFormat df = new DecimalFormat("0.00");

                    Map<Float, MSISDNResponse.PriceMapObject> prodMap = new TreeMap<Float, MSISDNResponse.PriceMapObject>(theResponse.m_priceMap);
                    if (prodMap != null) {
                        Iterator it = prodMap.entrySet().iterator();
                        String strSelected = "selected";

                        while (it.hasNext()) {
                            Map.Entry prodPair = (Map.Entry) it.next();
                            if (prodPair == null) continue;
                            MSISDNResponse.PriceMapObject priceMap = (MSISDNResponse.PriceMapObject) prodPair.getValue();
                            if (priceMap != null) {
                                if (!strSelected.isEmpty()) {
                                    strFirstProduct = priceMap.m_strProduct;
                                    fFirstPrice = priceMap.m_fCostToCustomer;
                                    fFirstRetailPrice = priceMap.m_fSuggestedRetailprice;
                                }

                                strXMLMap += "<prod val='" + priceMap.m_strProduct + "' ctc='" + df.format(priceMap.m_fCostToCustomer) +
                                        "' rp='" + df.format(priceMap.m_fSuggestedRetailprice) + "' />";
                %>
                <option value="<%=priceMap.m_strProduct%>"
                "<%=strSelected%>"><%=priceMap.m_strProduct%></option>
                <%
                                strSelected = "";
                            }
                        }
                    }
                    strXMLMap += "</pmap>";
                %>
            </select>
            <input type="hidden" name="selected_product" value="<%=strFirstProduct%>">
            <input type="hidden" name="complete_product_list" value="<%=strXMLMap%>">
        </td>
    </tr>

    <tr>
        <td align="right"><span class="Normal-C0"> Cost to <%=strCompanyName%> </span></td>
        <td align="left"><input type="text" name="final_price" value="<%=df.format(fFirstPrice)%>"/>
    </tr>

    <tr>
        <td align="right">
            <span class="Normal-C0">Suggested Retail Sale Price</span><br>
            <font color="#980009" size="3">(Qiimaha dukaanka)</font>
        </td>
        <td align="left">
            <input type="text" name="retail_price" value="<%=df.format(fFirstRetailPrice)%>" readonly/>
        </td>
    </tr>

    <tr>
        <td align="right">
            <span class="Normal-C1">SMS Message To Receiver</span><br>
            <font color="#980009" size="3">(Ogaysiis isla markaas ah)</font>
        </td>
        <td align="left">
            <input type="text" name="sms_text" size="30" maxlength="29"
                   style="width:200px; height:40px;font-size:18px;"/>
        </td>
    </tr>

    <tr>
        <td></td>
        <td align="left">
            <input type="button" name="topup_mobile" value="Topup Mobile"
                   onClick="validateAndSubmitMobileTopup()"/>
        </td>
    </tr>

</table>
<%
    } else {
        errString += "for the destination phone number : " + strDestinationNumber;
        errString += ".  Please enter a valid destination phone number along with country code.";

        response.getWriter().println(errString);
    }
%>