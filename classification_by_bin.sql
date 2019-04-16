CASE 

WHEN LEFT(pan, 3)= '506' THEN 'Verve Card'

WHEN LEFT(pan, 2)IN ('62','63','90','60') THEN 'Magstripe Card'

WHEN LEFT(pan, 2) IN ('51','52','53','54','55') AND LEFT(pan, 6) NOT IN ('539945','528649','521090','551609','559453','519615','528668') THEN 'MasterCard'

WHEN LEFT(pan, 6) IN ('539945','528649','521090','551609','559453','519615','528668') THEN 'MasterCard Verve Card'

WHEN LEFT(pan,1) ='4' THEN 'VisaCard'

ELSE 'Unknown Card'  
END card_brand,