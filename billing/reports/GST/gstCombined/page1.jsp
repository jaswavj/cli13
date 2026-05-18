<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*,java.text.*" %>
<jsp:useBean id="prod" class="product.productBean" />
<%
    String fromDate = request.getParameter("startDate");
    String toDate   = request.getParameter("endDate");

    Vector salesData    = prod.getSalesGSTDetailReport(fromDate, toDate);
    Vector purchaseData = prod.getPurchaseGSTDetailReport(fromDate, toDate);

    // Merge into one list; add type ("Sale"/"Purchase") as element index 15
    // and sort_date (index 0 = date already in yyyy-MM-dd) for ordering
    Vector combined = new Vector();
    if (salesData != null) {
        for (int i = 0; i < salesData.size(); i++) {
            Vector row = (Vector) salesData.elementAt(i);
            row.addElement("Sale");
            combined.add(row);
        }
    }
    if (purchaseData != null) {
        for (int i = 0; i < purchaseData.size(); i++) {
            Vector row = (Vector) purchaseData.elementAt(i);
            row.addElement("Purchase");
            combined.add(row);
        }
    }
    // Sort by date (element 0, yyyy-MM-dd string sort works correctly)
    Collections.sort(combined, new Comparator() {
        public int compare(Object a, Object b) {
            String da = ((Vector)a).elementAt(0) != null ? ((Vector)a).elementAt(0).toString() : "";
            String db = ((Vector)b).elementAt(0) != null ? ((Vector)b).elementAt(0).toString() : "";
            return da.compareTo(db);
        }
    });

    double sTaxable=0, sTax=0, sTrans=0;
    double pTaxable=0, pTax=0, pTrans=0;
    for (int i = 0; i < combined.size(); i++) {
        Vector r = (Vector) combined.elementAt(i);
        String type = r.elementAt(15).toString();
        double taxable = 0, tax = 0, trans = 0;
        try { taxable = Double.parseDouble(r.elementAt(10).toString()); } catch (Exception e) {}
        try { tax     = Double.parseDouble(r.elementAt(13).toString()); } catch (Exception e) {}
        try { trans   = Double.parseDouble(r.elementAt(14).toString()); } catch (Exception e) {}
        if ("Sale".equals(type))     { sTaxable+=taxable; sTax+=tax; sTrans+=trans; }
        else                          { pTaxable+=taxable; pTax+=tax; pTrans+=trans; }
    }
    double gTaxable = sTaxable + pTaxable;
    double gTax     = sTax     + pTax;
    double gTrans   = sTrans   + pTrans;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>GST Combined Report</title>
<%@ include file="/assets/common/head.jsp" %>
<!-- SheetJS for proper XLSX multi-sheet export -->
<script src="https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.18.5/xlsx.full.min.js"></script>
<style>
.report-header { background: #624b88; color: white; padding: 0.5rem 0.75rem; font-size: 0.85rem; font-weight: 600; }
.section-title { background: linear-gradient(135deg,#624b88,#4a3566); color:#fff; padding:0.6rem 1rem; border-radius:6px 6px 0 0; font-size:1rem; font-weight:600; margin-bottom:0; }
.gst-table th { background:#624b88; color:#fff; font-size:0.78rem; padding:0.4rem 0.45rem; white-space:nowrap; }
.gst-table td { font-size:0.78rem; padding:0.3rem 0.45rem; }
.gst-table tfoot td { background:#3a2860; color:#fff; font-weight:700; font-size:0.8rem; padding:0.4rem 0.45rem; }
.section-card { border:1px solid #dee2e6; border-radius:0 0 6px 6px; }
@media print {
    @page { size: landscape; margin:0.4cm; }
    body { font-size:7px; }
    .no-print { display:none !important; }
    body * { visibility: hidden; }
    #printArea, #printArea * { visibility: visible; }
    #printArea { position:absolute;left:0;top:0;width:100%; }
    .gst-table th, .gst-table td { font-size:6px !important; padding:1px 2px !important; }
    .section-title { font-size:8px !important; padding:2px 4px !important; }
    .container { max-width:100% !important; padding:0 4px !important; }
}
</style>
</head>
<body>
<%@ include file="/assets/navbar/navbar.jsp" %>

<div class="container-fluid mt-4 px-4" id="printArea">

    <!-- Page Header -->
    <div class="d-flex justify-content-between align-items-center mb-3 no-print">
        <div>
            <h4 class="mb-0">GST Combined Report &mdash; Sales &amp; Purchase</h4>
            <small class="text-muted">Period: <strong><%=fromDate%></strong> to <strong><%=toDate%></strong></small>
        </div>
        <div class="d-flex gap-2">
            <a href="<%=contextPath%>/reports/GST/gstCombined/page.jsp" class="btn btn-secondary btn-sm">&#8592; Back</a>
            <button class="btn btn-primary btn-sm" onclick="printReport()">&#128424; Print</button>
            <button class="btn btn-success btn-sm" onclick="exportToXLSX()">&#128202; Download XLSX</button>
        </div>
    </div>

    <!-- Print Header (only visible on print) -->
    <div class="d-none d-print-block text-center mb-2">
        <h5>GST Combined Report &mdash; Sales &amp; Purchase</h5>
        <small>Period: <%=fromDate%> to <%=toDate%></small>
    </div>

    <!-- ============ COMBINED GST TABLE ============ -->
    <!-- Summary row -->
    <div class="row g-2 mb-3 no-print">
        <div class="col-md-3">
            <div class="card p-2" style="border-left:4px solid #624b88;">
                <div class="text-muted small">Sales Taxable</div>
                <div class="fw-bold">&#8377; <%=String.format("%.2f",sTaxable)%></div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="card p-2" style="border-left:4px solid #2e6930;">
                <div class="text-muted small">Purchase Taxable</div>
                <div class="fw-bold">&#8377; <%=String.format("%.2f",pTaxable)%></div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="card p-2" style="border-left:4px solid #0d6efd;">
                <div class="text-muted small">Grand Tax Amount</div>
                <div class="fw-bold">&#8377; <%=String.format("%.2f",gTax)%></div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="card p-2" style="border-left:4px solid #fd7e14;">
                <div class="text-muted small">Grand Trans Amount</div>
                <div class="fw-bold">&#8377; <%=String.format("%.2f",gTrans)%></div>
            </div>
        </div>
    </div>

    <div class="section-title" style="background:linear-gradient(135deg,#1a1a2e,#16213e);">&#128203; GST Report &mdash; Sales &amp; Purchase (Date-wise)</div>
    <div class="section-card">
        <div class="table-responsive">
            <table id="gstCombinedTable" class="table table-hover table-bordered mb-0 gst-table">
                <thead>
                    <tr>
                        <th>S.No</th>
                        <th>Type</th>
                        <th>Date</th>
                        <th>Invoice No./Txn No</th>
                        <th>Party Name</th>
                        <th>Item Name</th>
                        <th>Item Code</th>
                        <th>HSN/SAC</th>
                        <th>Category</th>
                        <th>Challan/Order No.</th>
                        <th>Quantity</th>
                        <th>Unit</th>
                        <th style="text-align:right;">Taxable (&#8377;)</th>
                        <th style="text-align:right;">UnitPrice (&#8377;)</th>
                        <th style="text-align:right;">Tax %</th>
                        <th style="text-align:right;">Tax (&#8377;)</th>
                        <th style="text-align:right;">Trans Amount (&#8377;)</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                    if (combined != null && combined.size() > 0) {
                        for (int i = 0; i < combined.size(); i++) {
                            Vector row = (Vector) combined.elementAt(i);
                            String type = row.elementAt(15).toString();
                            String rowStyle = "Sale".equals(type)
                                ? "background:#f5f0ff;"
                                : "background:#f0fff4;";
                            String typeBadge = "Sale".equals(type)
                                ? "<span style='background:#624b88;color:#fff;padding:1px 7px;border-radius:10px;font-size:11px;'>Sale</span>"
                                : "<span style='background:#2e6930;color:#fff;padding:1px 7px;border-radius:10px;font-size:11px;'>Purchase</span>";
                    %>
                    <tr style="<%=rowStyle%>">
                        <td><%=i+1%></td>
                        <td><%=typeBadge%></td>
                        <td><%=row.elementAt(0)%></td>
                        <td><%=row.elementAt(1)%></td>
                        <td><%=row.elementAt(2)%></td>
                        <td><%=row.elementAt(3)%></td>
                        <td><%=row.elementAt(4)%></td>
                        <td><%=row.elementAt(5)%></td>
                        <td><%=row.elementAt(6)%></td>
                        <td><%=row.elementAt(7)%></td>
                        <td><%=row.elementAt(8)%></td>
                        <td><%=row.elementAt(9)%></td>
                        <td style="text-align:right;"><%=row.elementAt(10)%></td>
                        <td style="text-align:right;"><%=row.elementAt(11)%></td>
                        <td style="text-align:right;"><%=row.elementAt(12)%></td>
                        <td style="text-align:right;"><%=row.elementAt(13)%></td>
                        <td style="text-align:right;"><%=row.elementAt(14)%></td>
                    </tr>
                    <%
                        }
                    } else {
                    %>
                    <tr><td colspan="17" class="text-center text-muted py-3">No data found for the selected period.</td></tr>
                    <% } %>
                </tbody>
                <% if (combined != null && combined.size() > 0) { %>
                <tfoot>
                    <tr>
                        <td colspan="2" style="text-align:center;">Sales Total</td>
                        <td colspan="10"></td>
                        <td style="text-align:right;"><%=String.format("%.2f",sTaxable)%></td>
                        <td></td><td></td>
                        <td style="text-align:right;"><%=String.format("%.2f",sTax)%></td>
                        <td style="text-align:right;"><%=String.format("%.2f",sTrans)%></td>
                    </tr>
                    <tr>
                        <td colspan="2" style="text-align:center;">Purchase Total</td>
                        <td colspan="10"></td>
                        <td style="text-align:right;"><%=String.format("%.2f",pTaxable)%></td>
                        <td></td><td></td>
                        <td style="text-align:right;"><%=String.format("%.2f",pTax)%></td>
                        <td style="text-align:right;"><%=String.format("%.2f",pTrans)%></td>
                    </tr>
                    <tr style="background:#1a1a2e;">
                        <td colspan="2" style="text-align:center;">GRAND TOTAL</td>
                        <td colspan="10"></td>
                        <td style="text-align:right;"><%=String.format("%.2f",gTaxable)%></td>
                        <td></td><td></td>
                        <td style="text-align:right;"><%=String.format("%.2f",gTax)%></td>
                        <td style="text-align:right;"><%=String.format("%.2f",gTrans)%></td>
                    </tr>
                </tfoot>
                <% } %>
            </table>
        </div>
    </div>

</div><!-- /container-fluid -->

<script>
function printReport() {
    fetch('<%=contextPath%>/printHeader.jsp')
        .then(r => r.text())
        .then(headerHtml => {
            var printArea = document.createElement('div');
            printArea.innerHTML = headerHtml;
            var clone = document.getElementById('printArea').cloneNode(true);
            clone.querySelectorAll('.no-print').forEach(function(el){ el.remove(); });
            printArea.appendChild(clone);
            document.body.appendChild(printArea);
            window.print();
            document.body.removeChild(printArea);
        })
        .catch(function(){ window.print(); });
}

function exportToXLSX() {
    var wb = XLSX.utils.book_new();
    var headers = ["S.No","Type","Date","Invoice No./Txn No","Party Name","Item Name","Item Code","HSN/SAC","Category","Challan/Order No.","Quantity","Unit","Taxable (INR)","UnitPrice (INR)","Tax %","Tax (INR)","Trans Amount (INR)"];
    var rows = [headers];

    var tbl  = document.getElementById('gstCombinedTable');
    var tbody = tbl.querySelector('tbody');
    tbody.querySelectorAll('tr').forEach(function(tr) {
        var cells = tr.querySelectorAll('td');
        if (cells.length > 1) {
            var row = [];
            cells.forEach(function(td, idx) {
                var val = td.innerText.trim();
                if (idx === 0) { row.push(parseInt(val) || val); return; }
                var num = parseFloat(val);
                row.push((!isNaN(num) && val !== "" && String(num) === val) ? num : val);
            });
            rows.push(row);
        }
    });
    // Footer totals
    rows.push(["","Sales Total","","","","","","","","","","",
        <%=String.format("%.2f",sTaxable)%>,"","",<%=String.format("%.2f",sTax)%>,<%=String.format("%.2f",sTrans)%>]);
    rows.push(["","Purchase Total","","","","","","","","","","",
        <%=String.format("%.2f",pTaxable)%>,"","",<%=String.format("%.2f",pTax)%>,<%=String.format("%.2f",pTrans)%>]);
    rows.push(["","GRAND TOTAL","","","","","","","","","","",
        <%=String.format("%.2f",gTaxable)%>,"","",<%=String.format("%.2f",gTax)%>,<%=String.format("%.2f",gTrans)%>]);

    var ws = XLSX.utils.aoa_to_sheet(rows);
    var widths = [5,10,12,18,22,28,12,12,18,16,10,8,14,14,8,12,16];
    ws['!cols'] = widths.map(function(w){ return {wch:w}; });
    XLSX.utils.book_append_sheet(wb, ws, "GST Combined");

    XLSX.writeFile(wb, 'GST_Combined_<%=fromDate%>_to_<%=toDate%>.xlsx');
}
</script>

</body>
</html>