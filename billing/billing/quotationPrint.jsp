<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ page language="java" import="java.util.*"%>
<%@ page language="java" import="java.text.DecimalFormat"%>

<jsp:useBean id="bill" class="billing.billingBean" />
<jsp:useBean id="userBean" class="user.userBean" scope="page"/>
<%
String quotIdStr = request.getParameter("quotId");
if(quotIdStr == null || quotIdStr.trim().isEmpty()){
    out.print("Error: Missing quotation ID");
    return;
}

int quotId = Integer.parseInt(quotIdStr);

// Get quotation header
Vector quotHeader = bill.getQuotationHeader(quotId);
if (quotHeader == null || quotHeader.isEmpty()) {
    out.print("Error: Quotation not found");
    return;
}

String quotNo = quotHeader.get(0).toString();
double total = Double.parseDouble(quotHeader.get(1).toString());
double prodDisc = Double.parseDouble(quotHeader.get(2).toString());
double extraDisc = Double.parseDouble(quotHeader.get(3).toString());
double payable = Double.parseDouble(quotHeader.get(4).toString());
String cusName = quotHeader.get(5) != null ? quotHeader.get(5).toString() : "-";
String cusPhone = quotHeader.get(6) != null ? quotHeader.get(6).toString() : "-";
String quotDate = quotHeader.get(8).toString();
String quotTime = quotHeader.get(9).toString();

// Get quotation details
Vector<Vector> quotDetails = bill.getQuotationDetails(quotId);

// Fetch company details
Vector companyDetails = userBean.getCompanyDetails();
String companyName = "";
String companyAddress = "";
String companyGSTIN = "";
String companyPhone = "";
String bankDetails = "";

if (companyDetails != null && companyDetails.size() >= 4) {
    companyName = companyDetails.get(1) != null ? companyDetails.get(1).toString() : "";
    companyAddress = companyDetails.get(2) != null ? companyDetails.get(2).toString() : "";
    companyGSTIN = companyDetails.get(3) != null ? companyDetails.get(3).toString() : "";
    if (companyDetails.size() > 4) {
        companyPhone = companyDetails.get(4) != null ? companyDetails.get(4).toString() : "";
    }
    if (companyDetails.size() > 6) {
        bankDetails = companyDetails.get(6) != null ? companyDetails.get(6).toString() : "";
    }
}

DecimalFormat df = new DecimalFormat("0.00");

// Calculation variables
double totalQty = 0;
double totalAmount = 0;
double totalDiscount = 0;

for(Vector prod : quotDetails){
    double qty = Double.parseDouble(prod.get(4).toString());
    double itemTotal = Double.parseDouble(prod.get(7).toString());
    double itemDisc = Double.parseDouble(prod.get(6).toString());
    
    totalQty += qty;
    totalAmount += itemTotal;
    totalDiscount += itemDisc;
}
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Quotation - <%= quotNo %></title>
    <style>
        @page { size: A5; margin: 5mm; }
        body {
            font-family: Arial, sans-serif;
            font-size: 11px;
            margin: 0;
            padding: 5px;
            color: #000;
        }
        .container {
            width: calc(100% - 20px);
            border: 2px solid #000;
            margin: 0 auto;
            background: white;
        }
        .header-title {
            text-align: center;
            font-weight: bold;
            font-size: 12px;
            margin-bottom: 5px;
            color: #000;
            background: white;
            border-bottom: 1px solid #000;
            padding: 5px;
        }
        .quotation-badge {
            background: white;
            border: 2px dashed #000;
            padding: 3px 8px;
            text-align: center;
            font-size: 10px;
            font-weight: bold;
            color: #000;
            margin: 3px 0;
        }
        /* Header Section */
        .company-header {
            display: flex;
            flex-direction: column;
            border-bottom: 2px solid #000;
            background: white;
            padding: 8px;
            align-items: center;
            text-align: center;
        }
        .logo-area {
            width: 150px;
            height: 80px;
            background: white;
            border-radius: 8px;
            padding: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-right: 20px;
        }
        .logo-area img {
            max-width: 100%;
            max-height: 100%;
            object-fit: contain;
        }
        .company-details {
            flex: 1;
            color: #000;
            font-size: 11px;
            line-height: 1.6;
            text-align: center;
        }
        .company-name {
            font-size: 16px;
            font-weight: bold;
            text-transform: uppercase;
            margin-bottom: 3px;
            letter-spacing: 1px;
            color: #000;
        }
        .company-details div {
            margin: 2px 0;
        }
        .info-section {
            display: flex;
            justify-content: space-between;
            padding: 8px;
            border-bottom: 1px solid #000;
        }
        .info-box {
            flex: 1;
            padding: 5px;
        }
        .info-label {
            font-weight: bold;
            color: #000;
        }
        table {
            width: 100%;
            border-collapse: collapse;
        }
        th {
            background: white;
            padding: 6px 4px;
            text-align: left;
            font-weight: bold;
            border: 1px solid #000;
        }
        td {
            padding: 5px 4px;
            border: 1px solid #000;
        }
        .text-right {
            text-align: right;
        }
        .text-center {
            text-align: center;
        }
        .total-section {
            padding: 8px;
            background: white;
        }
        .total-row {
            display: flex;
            justify-content: flex-end;
            padding: 3px 0;
        }
        .total-label {
            width: 200px;
            text-align: right;
            font-weight: bold;
            padding-right: 20px;
        }
        .total-value {
            width: 120px;
            text-align: right;
        }
        .grand-total {
            font-size: 14px;
            color: #000;
            background: white;
            padding: 8px;
            border-top: 1px solid #000;
        }
        .footer {
            padding: 10px;
            text-align: center;
            font-size: 10px;
            color: #000;
            border-top: 2px solid #000;
            margin-top: 10px;
        }
        .terms {
            padding: 8px;
            font-size: 10px;
            border-top: 1px solid #000;
        }
        .bank-details {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 10px;
            border-top: 1px solid #e5e7eb;
            border-bottom: 1px solid #e5e7eb;
            background: #f9fafb;
        }
        .bank-details-text {
            flex: 1;
            font-size: 11px;
            line-height: 1.6;
        }
        .bank-details-text strong {
            color: #5b21b6;
            display: block;
            margin-bottom: 5px;
        }
        .qr-code {
            margin-left: 15px;
        }
        .qr-code img {
            width: 100px;
            height: 100px;
            border: 2px solid #5b21b6;
            border-radius: 8px;
            padding: 3px;
        }
        @media print {
            body {
                padding: 0;
                margin: 0;
               }
            .container {
                border: none;
                box-shadow: none;
            }
            @page {
                size: A5;
                margin: 5mm;
            }
        }
    </style>
</head>
<body>
    
    <div class="container">
        <!-- Header -->
        <div class="company-header">
            
            <div class="company-details">
                <% if (!companyName.isEmpty()) { %>
                    <div class="company-name"><%= companyName %></div>
                <% } %>
                <% if (!companyAddress.isEmpty()) { %>
                    <% 
                    // Split address by newlines and display each line
                    String[] addressLines = companyAddress.split("\\r?\\n");
                    for (String line : addressLines) {
                        if (line != null && !line.trim().isEmpty()) {
                    %>
                        <div><%= line.trim() %></div>
                    <% 
                        }
                    } 
                    %>
                <% } %>
                <% if (!companyGSTIN.isEmpty()) { %>
                    <div>GSTIN: <%= companyGSTIN %></div>
                <% } %>
                
            </div>
        </div>
        
        <div class="quotation-badge">
            QUOTATION <br> NO: <%= quotNo %>
        </div>
        
        <div class="info-section">
            <div class="info-box">
                <div><span class="info-label">Customer Name:</span> <%= cusName %></div>
                <div><span class="info-label">Phone:</span> <%= cusPhone %></div>
            </div>
            <div class="info-box" style="text-align: right;">
                <div><span class="info-label">Date:</span> <%= quotDate %></div>
                <div><span class="info-label">Time:</span> <%= quotTime %></div>
            </div>
        </div>
        
        <table>
            <thead>
                <tr>
                    <th style="width: 5%">#</th>
                    <th style="width: 10%">Code</th>
                    <th style="width: 35%">Product Name</th>
                    <th style="width: 10%" class="text-right">Qty</th>
                    <th style="width: 12%" class="text-right">Price</th>
                    <th style="width: 12%" class="text-right">Discount</th>
                    <th style="width: 16%" class="text-right">Total</th>
                </tr>
            </thead>
            <tbody>
                <%
                int rowNum = 1;
                for(Vector prod : quotDetails){
                    String prodName = prod.get(2).toString();
                    String code = prod.get(3).toString();
                    double qty = Double.parseDouble(prod.get(4).toString());
                    double price = Double.parseDouble(prod.get(5).toString());
                    double disc = Double.parseDouble(prod.get(6).toString());
                    double itemTotal = Double.parseDouble(prod.get(7).toString());
                %>
                <tr>
                    <td class="text-center"><%= rowNum++ %></td>
                    <td><%= code %></td>
                    <td><%= prodName %></td>
                    <td class="text-right"><%= df.format(qty) %></td>
                    <td class="text-right"><%= df.format(price) %></td>
                    <td class="text-right"><%= df.format(disc) %></td>
                    <td class="text-right"><%= df.format(itemTotal) %></td>
                </tr>
                <%
                }
                %>
            </tbody>
        </table>
        
        <div class="total-section">
            <div class="total-row">
                <div class="total-label">Total Items:</div>
                <div class="total-value"><%= quotDetails.size() %></div>
            </div>
            <div class="total-row">
                <div class="total-label">Total Quantity:</div>
                <div class="total-value"><%= df.format(totalQty) %></div>
            </div>
            <div class="total-row">
                <div class="total-label">Subtotal:</div>
                <div class="total-value">₹ <%= df.format(total) %></div>
            </div>
            <div class="total-row">
                <div class="total-label">Product Discount:</div>
                <div class="total-value">₹ <%= df.format(prodDisc) %></div>
            </div>
            <div class="total-row">
                <div class="total-label">Extra Discount:</div>
                <div class="total-value">₹ <%= df.format(extraDisc) %></div>
            </div>
            <div class="total-row grand-total">
                <div class="total-label">QUOTATION AMOUNT:</div>
                <div class="total-value"><strong>₹ <%= df.format(payable) %></strong></div>
            </div>
        </div>
        
        <div class="terms">
            <strong>Terms & Conditions:</strong><br>
            1. This is a quotation and not a tax invoice.<br>
            2. Prices are subject to change without notice.<br>
            3. This quotation is valid for 30 days from the date of issue.<br>
            4. Payment terms and delivery schedule to be discussed upon order confirmation.
        </div>
        
        <div class="footer">
            <div>This is a computer-generated quotation and does not require a signature.</div>
            <div style="margin-top: 5px;">Thank you for your interest in our products!</div>
        </div>
    </div>
    
    <script>
        window.onload = function() {
            window.print();
        };
        
        // Close window after print dialog is closed (either printed or cancelled)
        window.onafterprint = function() {
            window.close();
        };
    </script>
</body>
</html>
