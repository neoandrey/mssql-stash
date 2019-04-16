UPDATE [postilion].[dbo].[tm_routes]  SET node = 'NEWASPFEPsnk' 
WHERE node IN ('IPDSWTsnk', 'MOBILESWTsnk',  'WEBFEESWTsnk', 'WEBMEGUGsnk', 'WEBSWTsnk');

UPDATE  [postilion].[dbo].[tm_routes_by_institution] SET  node ='NEWASPFEPsnk'  
WHERE node IN ('IPDSWTsnk', 'MOBILESWTsnk',  'WEBFEESWTsnk', 'WEBMEGUGsnk', 'WEBSWTsnk');

--SELECT * INTO tm_routes_backup FROM [postilion].[dbo].[tm_routes](NOLOCK)

--SELECT * INTO tm_routes_by_institution_backup FROM [postilion].[dbo].[tm_routes_by_institution](NOLOCK)

--SELECT * FROM tm_routes_backup

--SELECT * FROM tm_routes_by_institution_backup