<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<jsp:useBean id="prod" class="product.productBean" />
<%
String contextPathday = request.getContextPath();
String fromDate = request.getParameter("fromDate");
String toDate   = request.getParameter("toDate");
if (fromDate == null || fromDate.isEmpty()) fromDate = "";
if (toDate   == null || toDate.isEmpty())   toDate   = "";

Vector vec = prod.getDayBookReport(fromDate, toDate);

double totalPaid     = 0;
double totalReceived = 0;
double totalBalance  = 0;
for (int i = 0; i < vec.size(); i++) {
    Vector row = (Vector) vec.get(i);
    try { totalPaid     += Double.parseDouble(row.get(7).toString()); } catch (Exception e) {}
    try { totalReceived += Double.parseDouble(row.get(8).toString()); } catch (Exception e) {}
    try { totalBalance  += Double.parseDouble(row.get(9).toString()); } catch (Exception e) {}
}
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Day Book Report</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <%@ include file="/assets/common/head.jsp" %>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.18.5/xlsx.full.min.js"></script>
    <style>
        body { background: #f5f7fa; }
        .print-header { display: none; }
        @media print {
            .no-print { display: none !important; }
            .print-header { display: block; text-align: center; margin-bottom: 10px; }
            body { background: #fff; }
            .container { max-width: 100% !important; padding: 0 !important; }
        }
        .badge-sale      { background-color: #198754; color: #fff; }
        .badge-cashsale  { background-color: #0d6efd; color: #fff; }
        .badge-purchase  { background-color: #dc3545; color: #fff; }
        .badge-payin     { background-color: #6610f2; color: #fff; }
        .badge-payout    { background-color: #fd7e14; color: #fff; }
        .type-badge { padding: 2px 8px; border-radius: 10px; font-size: 11px; white-space: nowrap; }
        table { font-size: 12px; }
        tfoot td, tfoot th { font-weight: 700; background: #f1f3f5; }
        .summary-card { border-left: 4px solid; }
        .summary-received { border-left-color: #198754; }
        .summary-paid     { border-left-color: #dc3545; }
        .summary-balance  { border-left-color: #fd7e14; }
    </style>
</head>
<body>
    <%@ include file="/assets/navbar/navbar.jsp" %>

    <div class="container-fluid mt-3 px-3">
        <!-- Print header -->
        <div class="print-header">
            <h5>Day Book Report | <%=fromDate%> to <%=toDate%></h5>
        </div>

        <!-- Toolbar -->
        <div class="d-flex justify-content-between align-items-center mb-3 no-print">
            <div>
                <h5 class="mb-0"><i class="fas fa-book me-2"></i>Day Book
                    <small class="text-muted fs-6 ms-2"><%=fromDate%> &nbsp;to&nbsp; <%=toDate%></small>
                </h5>
            </div>
            <div class="d-flex gap-2">
                <a href="<%=contextPathday%>/reports/dayBook/page.jsp" class="btn btn-secondary btn-sm">
                    <i class="fas fa-arrow-left me-1"></i>Back
                </a>
                <button class="btn btn-success btn-sm" onclick="exportToXLSX()">
                    <i class="fas fa-file-excel me-1"></i>Download XLSX
                </button>
                <button class="btn btn-primary btn-sm" onclick="window.print()">
                    <i class="fas fa-print me-1"></i>Print
                </button>
            </div>
        </div>

        <!-- Summary cards -->
        <div class="row g-2 mb-3 no-print">
            <div class="col-md-3">
                <div class="card summary-card summary-received p-2">
                    <div class="text-muted small">Total Received (Sales + Payment-In)</div>
                    <div class="fs-6 fw-bold text-success">&#8377; <%= String.format("%.2f", totalReceived) %></div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card summary-card summary-paid p-2">
                    <div class="text-muted small">Total Paid (Purchase + Payment-Out)</div>
                    <div class="fs-6 fw-bold text-danger">&#8377; <%= String.format("%.2f", totalPaid) %></div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card summary-card summary-balance p-2">
                    <div class="text-muted small">Total Outstanding Balance</div>
                    <div class="fs-6 fw-bold text-warning">&#8377; <%= String.format("%.2f", totalBalance) %></div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card p-2">
                    <div class="text-muted small">Total Transactions</div>
                    <div class="fs-6 fw-bold"><%=vec.size()%></div>
                </div>
            </div>
        </div>

        <!-- Main table -->
        <div class="table-responsive">
        <table id="dayBookTable" class="table table-bordered table-hover">
            <thead style="background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%); color: #fff;">
                <tr>
                    <th style="width:35px;">S.No</th>
                    <th>Date</th>
                    <th>Reference No</th>
                    <th>Party Name</th>
                    <th>Category Name</th>
                    <th>Type</th>
                    <th style="text-align:right;">Total (&#8377;)</th>
                    <th>Payment Type</th>
                    <th style="text-align:right;">Paid (&#8377;)</th>
                    <th style="text-align:right;">Received (&#8377;)</th>
                    <th style="text-align:right;">Balance (&#8377;)</th>
                    <th>Description</th>
                </tr>
            </thead>
            <tbody>
<%
int sno = 0;
for (int i = 0; i < vec.size(); i++) {
    Vector row = (Vector) vec.get(i);
    String date     = row.get(0).toString();
    String refNo    = row.get(1).toString();
    String party    = row.get(2).toString();
    String cat      = row.get(3).toString();
    String type     = row.get(4).toString();
    String total    = row.get(5).toString();
    String payType  = row.get(6).toString();
    String paid     = row.get(7).toString();
    String received = row.get(8).toString();
    String balance  = row.get(9).toString();
    String descr    = row.get(10).toString();

    String badgeClass = "badge-sale";
    if (type.equals("Cash Sale"))   badgeClass = "badge-cashsale";
    else if (type.equals("Purchase"))    badgeClass = "badge-purchase";
    else if (type.equals("Payment-In"))  badgeClass = "badge-payin";
    else if (type.equals("Payment-Out")) badgeClass = "badge-payout";

    sno++;
%>
                <tr>
                    <td><%=sno%></td>
                    <td><%=date%></td>
                    <td><%=refNo%></td>
                    <td><%=party%></td>
                    <td><%=cat%></td>
                    <td><span class="type-badge <%=badgeClass%>"><%=type%></span></td>
                    <td style="text-align:right;"><%=total%></td>
                    <td><%=payType%></td>
                    <td style="text-align:right; color: #dc3545;">
                        <% if (!paid.equals("0.00")) { %><%=paid%><% } %>
                    </td>
                    <td style="text-align:right; color: #198754;">
                        <% if (!received.equals("0.00")) { %><%=received%><% } %>
                    </td>
                    <td style="text-align:right;"><%=balance%></td>
                    <td><%=descr%></td>
                </tr>
<% } %>
            </tbody>
            <tfoot>
                <tr>
                    <td colspan="6" style="text-align:right;"><strong>Grand Total</strong></td>
                    <td></td>
                    <td></td>
                    <td style="text-align:right; color:#dc3545;"><strong><%= String.format("%.2f", totalPaid) %></strong></td>
                    <td style="text-align:right; color:#198754;"><strong><%= String.format("%.2f", totalReceived) %></strong></td>
                    <td style="text-align:right;"><strong><%= String.format("%.2f", totalBalance) %></strong></td>
                    <td></td>
                </tr>
            </tfoot>
        </table>
        </div>
    </div>

    <script>
    function exportToXLSX() {
        var wb = XLSX.utils.book_new();
        var headers = ["S.No","Date","Reference No","Party Name","Category Name","Type","Total","Payment Type","Paid","Received","Balance","Description"];
        var rows = [headers];
        var table = document.getElementById("dayBookTable");
        var tbodies = table.tBodies;
        var sno = 0;
        for (var t = 0; t < tbodies.length; t++) {
            var trows = tbodies[t].rows;
            for (var r = 0; r < trows.length; r++) {
                var cells = trows[r].cells;
                sno++;
                var row = [sno];
                for (var c = 1; c < cells.length; c++) {
                    var val = cells[c].innerText.trim();
                    var num = parseFloat(val);
                    row.push((!isNaN(num) && val !== "" && String(num) === val) ? num : val);
                }
                rows.push(row);
            }
        }
        // Totals row
        rows.push(["","","","","","Grand Total","","",
            parseFloat("<%=String.format("%.2f", totalPaid)%>"),
            parseFloat("<%=String.format("%.2f", totalReceived)%>"),
            parseFloat("<%=String.format("%.2f", totalBalance)%>"),""]);

        var ws = XLSX.utils.aoa_to_sheet(rows);
        ws['!cols'] = [
            {wch:5},{wch:12},{wch:18},{wch:25},{wch:14},{wch:14},
            {wch:12},{wch:12},{wch:12},{wch:12},{wch:12},{wch:20}
        ];
        XLSX.utils.book_append_sheet(wb, ws, "Day Book");
        var fromD = "<%=fromDate%>".replace(/-/g,'');
        var toD   = "<%=toDate%>".replace(/-/g,'');
        XLSX.writeFile(wb, "DayBook_" + fromD + "_to_" + toD + ".xlsx");
    }
    </script>
</body>
</html>
