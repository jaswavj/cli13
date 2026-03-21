$enc = [System.Text.UTF8Encoding]::new($false)
$f = "d:\JASXBILL\CLIENTS\13 mohana electric pudukottai\JASXBILL\billing\WEB-INF\classes\product\productBean.java"
$c = [System.IO.File]::ReadAllText($f, [System.Text.Encoding]::UTF8)

# 1. getProductFullDetails: add convertion_unit + calculation to SQL
$old1 = "COALESCE(u.name,'') AS unitName FROM prod_product a JOIN prod_category b ON a.category_id=b.id JOIN prod_brands c ON a.brand_id=c.id JOIN prod_batch d ON a.id=d.product_id LEFT JOIN prod_units u ON u.id=a.unit_id WHERE a.name=?"
$new1 = "COALESCE(u.name,'') AS unitName,COALESCE(u.convertion_unit,'') AS convertion_unit,COALESCE(u.convertion_calculation,1) AS convertion_calculation FROM prod_product a JOIN prod_category b ON a.category_id=b.id JOIN prod_brands c ON a.brand_id=c.id JOIN prod_batch d ON a.id=d.product_id LEFT JOIN prod_units u ON u.id=a.unit_id WHERE a.name=?"
$c = $c.Replace($old1, $new1)
Write-Output ("1 SQL applied: " + $c.Contains("AS convertion_unit,COALESCE(u.convertion_calculation"))

# 2. getProductFullDetails: update return string
$old2 = "productDetails`t`t= prodName+`"<#>`"+catName+`"<#>`"+brandName+`"<#>`"+batchNo+`"<#>`"+cost+`"<#>`"+mrp+`"<#>`"+prodsId+`"<#>`"+catId+`"<#>`"+brandId+`"<#>`"+batchId+`"<#>`"+unitName+`"<#>`";"
$new2 = "String convertionUnit`t= rs.getString(12);" + "`r`n`t`t`t" + "String convertionCalc`t= rs.getString(13);" + "`r`n`t`t`t" + "productDetails`t`t= prodName+`"<#>`"+catName+`"<#>`"+brandName+`"<#>`"+batchNo+`"<#>`"+cost+`"<#>`"+mrp+`"<#>`"+prodsId+`"<#>`"+catId+`"<#>`"+brandId+`"<#>`"+batchId+`"<#>`"+unitName+`"<#>`"+convertionUnit+`"<#>`"+convertionCalc+`"<#>`";"
Write-Output ("2 old found: " + $c.Contains($old2))
$c = $c.Replace($old2, $new2)
Write-Output ("2 applied: " + $c.Contains("convertionUnit+`"<#>`"+convertionCalc"))

# 3. standalone savePurchaseBill: add convertionCalc after tax
$old3a = "                double tax = Double.parseDouble(fields[8]);" + "`r`n                int purid = 0;"
$new3a = "                double tax = Double.parseDouble(fields[8]);" + "`r`n                double convertionCalc = fields.length > 10 ? Double.parseDouble(fields[10]) : 1.0;" + "`r`n                if (convertionCalc <= 0) convertionCalc = 1.0;" + "`r`n                int purid = 0;"
Write-Output ("3 old found: " + $c.Contains($old3a))
$c = $c.Replace($old3a, $new3a)

# 4. PO savePurchaseBill: add convertionCalc after poDetailId + blank line
$old4 = "                int poDetailId = fields.length > 9 ? Integer.parseInt(fields[9]) : 0;" + "`r`n                " + "`r`n                int purid = 0;"
$new4 = "                int poDetailId = fields.length > 9 ? Integer.parseInt(fields[9]) : 0;" + "`r`n                double convertionCalc = fields.length > 10 ? Double.parseDouble(fields[10]) : 1.0;" + "`r`n                if (convertionCalc <= 0) convertionCalc = 1.0;" + "`r`n                " + "`r`n                int purid = 0;"
Write-Output ("4 old found: " + $c.Contains($old4))
$c = $c.Replace($old4, $new4)

# 5. Both overloads: change BigDecimal stock to use convertionCalc
$old5 = "BigDecimal stock = BigDecimal.valueOf(totQty + freeQty);"
$new5 = "BigDecimal stock = BigDecimal.valueOf((totQty + freeQty) * convertionCalc);" + "`r`n                double convertedCost = convertionCalc > 1 ? cost / convertionCalc : cost;" + "`r`n                double convertedMrp = convertionCalc > 1 ? mrp / convertionCalc : mrp;"
Write-Output ("5 old count: " + ([regex]::Matches($c, [regex]::Escape($old5))).Count)
$c = $c.Replace($old5, $new5)

# 6a. standalone: change prod_batch UPDATE (no pt.close after executeUpdate)
$old6a = "                // Update stock in ph_batch table" + "`r`n                pt = con.prepareStatement(`"UPDATE prod_batch SET stock = stock + ? WHERE product_id = ?`");" + "`r`n                pt.setBigDecimal(1, stock);  // Update stock" + "`r`n                pt.setInt(2, prodsid);  // Product ID" + "`r`n                pt.executeUpdate();" + "`r`n`r`n                int prodTotId"
$new6a = "                // Update stock, cost and mrp in prod_batch" + "`r`n                pt = con.prepareStatement(`"UPDATE prod_batch SET stock = stock + ?, cost = ?, mrp = ? WHERE product_id = ?`");" + "`r`n                pt.setBigDecimal(1, stock);  // Update stock (converted units)" + "`r`n                pt.setDouble(2, convertedCost);  // Update cost per base unit" + "`r`n                pt.setDouble(3, convertedMrp);  // Update mrp per base unit" + "`r`n                pt.setInt(4, prodsid);  // Product ID" + "`r`n                pt.executeUpdate();" + "`r`n`r`n                int prodTotId"
Write-Output ("6a old found: " + $c.Contains($old6a))
$c = $c.Replace($old6a, $new6a)

# 6b. PO: change prod_batch UPDATE (has pt.close after executeUpdate)
$old6b = "                // Update stock in ph_batch table" + "`r`n                pt = con.prepareStatement(`"UPDATE prod_batch SET stock = stock + ? WHERE product_id = ?`");" + "`r`n                pt.setBigDecimal(1, stock);  // Update stock" + "`r`n                pt.setInt(2, prodsid);  // Product ID" + "`r`n                pt.executeUpdate();" + "`r`n                pt.close();" + "`r`n`r`n                int prodTotId"
$new6b = "                // Update stock, cost and mrp in prod_batch" + "`r`n                pt = con.prepareStatement(`"UPDATE prod_batch SET stock = stock + ?, cost = ?, mrp = ? WHERE product_id = ?`");" + "`r`n                pt.setBigDecimal(1, stock);  // Update stock (converted units)" + "`r`n                pt.setDouble(2, convertedCost);  // Update cost per base unit" + "`r`n                pt.setDouble(3, convertedMrp);  // Update mrp per base unit" + "`r`n                pt.setInt(4, prodsid);  // Product ID" + "`r`n                pt.executeUpdate();" + "`r`n                pt.close();" + "`r`n`r`n                int prodTotId"
Write-Output ("6b old found: " + $c.Contains($old6b))
$c = $c.Replace($old6b, $new6b)

[System.IO.File]::WriteAllText($f, $c, $enc)
Write-Output "productBean.java saved"