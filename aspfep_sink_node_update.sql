UPDATE [postilion].[dbo].[tm_routes]  SET node = 'NEWASPFEPsnk' WHERE node IN ('IPDSWTsnk', 'MOBILESWTsnk',  'WEBFEESWTsnk', 'WEBMEGUGsnk', 'WEBSWTsnk');

UPDATE  [postilion].[dbo].[tm_routes_by_institution] SET  node ='NEWASPFEPsnk'  WHERE node IN ('IPDSWTsnk', 'MOBILESWTsnk',  'WEBFEESWTsnk', 'WEBMEGUGsnk', 'WEBSWTsnk');