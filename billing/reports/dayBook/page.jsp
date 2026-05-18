<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.text.SimpleDateFormat, java.util.Date" %>
<%
String contextPathday = request.getContextPath();
String today = new SimpleDateFormat("yyyy-MM-dd").format(new Date());
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Day Book - Billing App</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <%@ include file="/assets/common/head.jsp" %>
</head>
<body>
    <%@ include file="/assets/navbar/navbar.jsp" %>
    <div class="container mt-4">
        <h4 class="mb-4"><i class="fas fa-book me-2"></i>Day Book Report</h4>
        <div class="card shadow-sm">
            <div class="card-body">
                <form action="<%=contextPathday%>/reports/dayBook/page1.jsp" method="get" class="row g-3">
                    <div class="col-md-4">
                        <label for="fromDate" class="form-label fw-semibold">From Date</label>
                        <input type="date" id="fromDate" name="fromDate" value="<%=today%>" class="form-control" required>
                    </div>
                    <div class="col-md-4">
                        <label for="toDate" class="form-label fw-semibold">To Date</label>
                        <input type="date" id="toDate" name="toDate" value="<%=today%>" class="form-control" required>
                    </div>
                    <div class="col-md-4 d-flex align-items-end">
                        <button type="submit" class="btn btn-primary w-100">
                            <i class="fas fa-search me-1"></i> Generate Report
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</body>
</html>
