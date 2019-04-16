CREATE RESOURCE POOL IssuerProcessingPool
WITH
( 
	MIN_CPU_PERCENT=0,
	MAX_CPU_PERCENT= 75,
	MIN_MEMORY_PERCENT= 0,
	MAX_MEMORY_PERCENT= 75
)
GO

CREATE WORKLOAD GROUP IssuerProcessingGroup
USING IssuerProcessingPool ;
GO

CREATE RESOURCE POOL AcquirerProcessingPool
WITH
( 
	MIN_CPU_PERCENT=0,
	MAX_CPU_PERCENT= 30,
	MIN_MEMORY_PERCENT= 0,
	MAX_MEMORY_PERCENT= 30
)
GO

CREATE WORKLOAD GROUP AcquirerProcessingGroup
USING AcquirerProcessingPool ;
GO


CREATE RESOURCE POOL SettlementPool
WITH
( 
	MIN_CPU_PERCENT=0,
	MAX_CPU_PERCENT= 20,
	MIN_MEMORY_PERCENT= 0,
	MAX_MEMORY_PERCENT= 20
)
GO

CREATE WORKLOAD GROUP SettlementGroup
USING SettlementPool ;
GO

CREATE RESOURCE POOL GeneralPool
WITH
( 
	MIN_CPU_PERCENT=0,
	MAX_CPU_PERCENT= 10,
	MIN_MEMORY_PERCENT= 0,
	MAX_MEMORY_PERCENT= 10
)
GO

CREATE WORKLOAD GROUP GeneralGroup
USING GeneralPool ;
GO

CREATE RESOURCE POOL OneViewPool
WITH
( 
	MIN_CPU_PERCENT=0,
	MAX_CPU_PERCENT= 10,
	MIN_MEMORY_PERCENT= 0,
	MAX_MEMORY_PERCENT= 10
)
GO

CREATE WORKLOAD GROUP OneViewGroup
USING OneViewPool ;
GO

CREATE RESOURCE POOL AdminPool
WITH
( 
	MIN_CPU_PERCENT=50,
	MAX_CPU_PERCENT= 100,
	MIN_MEMORY_PERCENT= 50,
	MAX_MEMORY_PERCENT= 100
)
GO

CREATE WORKLOAD GROUP  AdminGroup
USING  AdminPool ;
GO

CREATE RESOURCE POOL ReportingPool
WITH
( 
	MIN_CPU_PERCENT=0,
	MAX_CPU_PERCENT= 75,
	MIN_MEMORY_PERCENT= 0,
	MAX_MEMORY_PERCENT= 75
)
GO

CREATE WORKLOAD GROUP  ReportingGroup
USING  ReportingPool ;
GO


CREATE FUNCTION dbo.UserWorkloadClassifier()
	RETURNS SYSNAME
WITH SCHEMABINDING
AS
	BEGIN
	
	DECLARE @WorkloadGroup AS SYSNAME;
	
	IF(SUSER_NAME() = 'alayo.mukaila')

	SET @WorkloadGroup = 'AdminGroup'

	ELSE IF(SUSER_NAME() = 'aspextraswitchcopy')
	
	SET @WorkloadGroup = 'IssuerProcessingGroup'
	
	ELSE IF(SUSER_NAME() = 'imiemike.ameh')
		
	SET @WorkloadGroup = 'IssuerProcessingGroup'
	
	ELSE IF(SUSER_NAME() = 'Bababode.Adesanya')
	
	SET @WorkloadGroup = 'IssuerProcessingGroup'
	
	ELSE IF(SUSER_NAME() = 'babatunde.ogunlade')
	
	SET @WorkloadGroup = 'AdminGroup'
	
	ELSE IF(SUSER_NAME() = 'ebashiru.usman')
	
	SET @WorkloadGroup = 'ReportingPool'
	
	ELSE IF(SUSER_NAME() = 'eloho.ogude')
	
	SET @WorkloadGroup = 'SettlementGroup'
	
	ELSE IF(SUSER_NAME() = 'Eseosa.bashiru-usman')
	
	SET @WorkloadGroup = 'ReportingPool'
	
	ELSE IF(SUSER_NAME() = 'fomah.joshua')
	
	SET @WorkloadGroup = 'ReportingPool'
	
	ELSE IF(SUSER_NAME() = 'frank.umeh')

	SET @WorkloadGroup = 'OneViewGroup'
	
	ELSE IF(SUSER_NAME() = 'irene.okocha')

	SET @WorkloadGroup = 'OneViewGroup'
	
	ELSE IF(SUSER_NAME() = 'james.etim-okon')
	
	SET @WorkloadGroup = 'ReportingPool'
	
	ELSE IF(SUSER_NAME() = 'irene.okocha')

	SET @WorkloadGroup = 'OneViewGroup'

	ELSE IF(SUSER_NAME() = 'Michael.Adebo')

	SET @WorkloadGroup = 'OneViewGroup'

	ELSE IF(SUSER_NAME() = 'ogunkoya.kofoworola')

	SET @WorkloadGroup = 'ReportingGroup'
	
	ELSE IF(SUSER_NAME() = 'adedotun.adeoye')

	SET @WorkloadGroup = 'OneViewGroup'
	
	ELSE IF(SUSER_NAME() = 'Adedapo.Adeniyi')
	
		SET @WorkloadGroup = 'OneViewGroup'
		
	ELSE IF (SUSER_NAME() = 'adeola.fadahunsi')
	
		SET @WorkloadGroup = 'SettlementGroup'
		
	ELSE IF (SUSER_NAME() = 'aspoffice_normalizer')
	
		SET @WorkloadGroup = 'AdminGroup'
		
	ELSE IF (SUSER_NAME() = 'chikeka.joseph')
	
		SET @WorkloadGroup = 'OneViewGroup'
		
	ELSE IF (SUSER_NAME() = 'chioma.odiaka')
	
		SET @WorkloadGroup = 'SettlementGroup'
		
	ELSE IF (SUSER_NAME() = 'cornelius.olubunmi')
	
		SET @WorkloadGroup = 'AcquirerProcessingGroup'
		
	ELSE IF (SUSER_NAME() = 'dcc_norm_account')
	
		SET @WorkloadGroup = 'AdminGroup'
		
	ELSE IF (SUSER_NAME() = 'ebun.reffell')
	
		SET @WorkloadGroup = 'SettlementGroup'
		
	ELSE IF (SUSER_NAME() = 'efi.okomayin')
	
		SET @WorkloadGroup = 'OneViewGroup'
		
	ELSE IF (SUSER_NAME() = 'eric.udoaka')
	
		SET @WorkloadGroup = 'AdminGroup'
		
	ELSE IF (SUSER_NAME() = 'eseosa.osaikhuiwu')
	
		SET @WorkloadGroup = 'IssuerProcessingGroup'
		
	ELSE IF (SUSER_NAME() = 'joseph.fakayode')
	
		SET @WorkloadGroup = 'OneViewGroup'
		
	ELSE IF (SUSER_NAME() = 'mariam.olatunji')
	
		SET @WorkloadGroup = 'SettlementGroup'
		
	ELSE IF (SUSER_NAME() = 'mobolaji.aina')
	
		SET @WorkloadGroup = 'AdminGroup'
		
	ELSE IF (SUSER_NAME() = 'olasupo.ogunsanya')
	
		SET @WorkloadGroup = 'AdminGroup'
		
	ELSE IF (SUSER_NAME() = 'osifo.elder')
	
		SET @WorkloadGroup = 'OneViewGroup'
		
	ELSE IF (SUSER_NAME() = 'owolabi.akala')
	
		SET @WorkloadGroup = 'AcquirerProcessingGroup'
		
	ELSE IF (SUSER_NAME() = 'portal_admin')
	
		SET @WorkloadGroup = 'AdminGroup'
		
	ELSE IF (SUSER_NAME() = 'reportadmin')
	
		SET @WorkloadGroup = 'ReportingGroup'
		
	ELSE IF (SUSER_NAME() = 'okezie.ilona')

	SET @WorkloadGroup = 'ReportingGroup'
	
	ELSE IF (SUSER_NAME() = 'chikeka.joseph')
	
	SET @WorkloadGroup = 'OneViewGroup'

	ELSE IF (SUSER_NAME() IN  ('ololade.olaleye','olubukola.oladunni','oluwaseun.ogundele','oluwaseun.sodunke','omotoyosi.odele','seidu.temitolani'))

	SET @WorkloadGroup = 'OneViewGroup'
		
	ELSE IF (SUSER_NAME() = 'samuel.sopeju')
		
		SET @WorkloadGroup = 'AdminGroup'
	
	ELSE IF (SUSER_NAME() = 'kofoworola.ogunkoya')

	SET @WorkloadGroup = 'ReportingGroup' 
	ELSE IF (SUSER_NAME() = 'mdynamix')

	SET @WorkloadGroup = 'ReportingGroup' 

	ELSE IF (SUSER_NAME() = 'temilolu.adebola')
		
		SET @WorkloadGroup = 'OneViewGroup'
		
	ELSE IF (SUSER_NAME() = 'tolulope.obianwu')
		
		SET @WorkloadGroup = 'IssuerProcessingGroup'
	ELSE IF (SUSER_NAME() = 'Onome.Areghan')
			
		SET @WorkloadGroup = 'IssuerProcessingGroup'
		
	ELSE IF (SUSER_NAME() = 'tracy.ojaigho')
		
		SET @WorkloadGroup = 'AdminGroup'
		
	ELSE IF (SUSER_NAME() = 'uriri.ukrakpor')

		SET @WorkloadGroup = 'AdminGroup'
	
	ELSE IF (SUSER_NAME() = 'MEGAOFFICE64\Administrator')
		
		SET @WorkloadGroup = 'AdminGroup'
	
	ELSE IF (SUSER_NAME() = 'NT AUTHORITY\LOCAL SERVICE')
		
		SET @WorkloadGroup = 'AdminGroup'
		
	ELSE IF (SUSER_NAME() = 'NT AUTHORITY\SYSTEM')
		
		SET @WorkloadGroup = 'AdminGroup'
	
	ELSE IF (SUSER_NAME() = 'xls_user')

	SET @WorkloadGroup = 'ReportingGroup' 
	ELSE IF (SUSER_NAME() = 'Victor.Aku')
		
		SET @WorkloadGroup = 'OneViewGroup'
		
	ELSE IF (SUSER_NAME() = 'yemi.sulaiman')
		
		SET @WorkloadGroup = 'AcquirerProcessingGroup'
		
	ELSE IF (SUSER_NAME() = 'sa')
			
		SET @WorkloadGroup = 'AdminGroup'
	ELSE
		
		SET @WorkloadGroup = 'GeneralGroup'
		
	RETURN @WorkloadGroup
END
GO

ALTER RESOURCE GOVERNOR WITH (CLASSIFIER_FUNCTION=dbo.UserWorkloadClassifier);
GO
ALTER RESOURCE GOVERNOR RECONFIGURE
GO