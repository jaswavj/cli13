# Fix stock reports - add convertion_unit to bean methods
$enc = [System.Text.UTF8Encoding]::new($false)

# ===== productBean.java =====
$prodBean = "d:\JASXBILL\CLIENTS\13 mohana electric pudukottai\JASXBILL\billing\WEB-INF\classes\product\productBean.java"
$c = [System.IO.File]::ReadAllText($prodBean, [System.Text.Encoding]::UTF8)
$origLen = $c.Length

# 1a. getCurrentStockDetailsWithCategory: add convertion_unit to SQL
$found1a = $c.Contains("AS category_name ")
$c = $c.Replace(("AS category_name " + '"' + "`r`n`t`t`t`t`t`t+`"`tFROM ``prod_batch`` a " + '"'), ("AS category_name,IFNULL(u.convertion_unit,'') AS convertion_unit " + '"' + "`r`n`t`t`t`t`t`t+`"`tFROM ``prod_batch`` a " + '"'))
Write-Output ("1a SQL: " + $found1a + " -> now contains convertion_unit: " + $c.Contains("AS convertion_unit"))

# 1b. getCurrentStockDetailsWithCategory: add convertion_unit to Vector (2 tabs indent)
$marker1b = "vec.addElement(rs.getString(12) ); // category_name"
$found1b = $c.Contains($marker1b)
$c = $c.Replace(($marker1b + "`r`n`t`tvec.addElement(rs.getString(8) ); // cost total"), ($marker1b + "`r`n`t`tvec.addElement(rs.getString(13) ); // convertion_unit`r`n`t`tvec.addElement(rs.getString(8) ); // cost total"))
Write-Output ("1b Vec: " + $found1b + " -> now contains getString(13): " + $c.Contains("rs.getString(13) ); // convertion_unit"))

# 2a. getStockAdjReport: add convertion_unit to SQL SELECT
$marker2a = "psa.uid, u.user_name "
$found2a = $c.Contains($marker2a)
$c = $c.Replace(($marker2a + '"' + " +" + "`r`n                     " + '"' + "FROM prod_stock_adjustment psa"), ("psa.uid, u.user_name, IFNULL(pu.convertion_unit,'') AS convertion_unit " + '"' + " +" + "`r`n                     " + '"' + "FROM prod_stock_adjustment psa"))
Write-Output ("2a SQL SELECT: " + $found2a + " -> " + $c.Contains("IFNULL(pu.convertion_unit"))

# 2b. getStockAdjReport: add LEFT JOIN prod_units
$marker2b = '"JOIN users u ON psa.uid = u.id " +' 
$old2b = $marker2b + "`r`n                     " + '"WHERE psa.date BETWEEN ? AND ? ";'
$found2b = $c.Contains($old2b)
$c = $c.Replace($old2b, ($marker2b + "`r`n                     " + '"LEFT JOIN prod_units pu ON pu.id = p.unit_id " +' + "`r`n                     " + '"WHERE psa.date BETWEEN ? AND ? ";'))
Write-Output ("2b JOIN: " + $found2b + " -> " + $c.Contains("LEFT JOIN prod_units pu"))

# 2c. getStockAdjReport: add convertion_unit to Vector (12 spaces indent)
$marker2c = "vec1.addElement(rs.getString(11)); // user_name"
$found2c = $c.Contains($marker2c)
$c = $c.Replace(($marker2c + "`r`n`r`n            vec.addElement(vec1);"), ($marker2c + "`r`n            vec1.addElement(rs.getString(12)); // convertion_unit`r`n`r`n            vec.addElement(vec1);"))
Write-Output ("2c Vec: " + $found2c + " -> " + $c.Contains("rs.getString(12)); // convertion_unit"))

Write-Output ("productBean length change: " + ($c.Length - $origLen))
[System.IO.File]::WriteAllText($prodBean, $c, $enc)
Write-Output "productBean.java saved"

# ===== billingBean.java =====
$billBean = "d:\JASXBILL\CLIENTS\13 mohana electric pudukottai\JASXBILL\billing\WEB-INF\classes\billing\billingBean.java"
$b = [System.IO.File]::ReadAllText($billBean, [System.Text.Encoding]::UTF8)
$bOrigLen = $b.Length

# 3a. getStockAdj: add convertion_unit to SQL
$marker3a = "IFNULL(u.name,'') AS unit_name "
$found3a = $b.Contains($marker3a)
$b = $b.Replace($marker3a, "IFNULL(u.name,'') AS unit_name,IFNULL(u.convertion_unit,'') AS convertion_unit ")
Write-Output ("3a SQL: " + $found3a + " -> " + $b.Contains("IFNULL(u.convertion_unit,'') AS convertion_unit "))

# 3b. getStockAdj: add convertion_unit to Vector (12 spaces indent)
$marker3b = "vec1.addElement(rs.getString(9)); // unit_name"
$found3b = $b.Contains($marker3b)
$b = $b.Replace(($marker3b + "`r`n            vec.addElement(vec1);"), ($marker3b + "`r`n            vec1.addElement(rs.getString(10)); // convertion_unit`r`n            vec.addElement(vec1);"))
Write-Output ("3b Vec: " + $found3b + " -> " + $b.Contains("rs.getString(10)); // convertion_unit"))

Write-Output ("billingBean length change: " + ($b.Length - $bOrigLen))
[System.IO.File]::WriteAllText($billBean, $b, $enc)
Write-Output "billingBean.java saved"