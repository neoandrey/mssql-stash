DECLARE @struct_data VARCHAR(MAX)
DECLARE @off_set INT
set @off_set = 11;
set @struct_data ='218Postilion:MetaData255211MediaTotals111212MediaBatchNr111214AdditionalInfo111211MediaTotals3249&lt;MediaTotals&gt;&lt;Total&gt;&lt;Amount&gt;000001000000&lt;/Amount&gt;&lt;Currency&gt;566&lt;/Currency&gt;&lt;MediaClass&gt;cash&lt;/MediaClass&gt;&lt;/Total&gt;&lt;/MediaTotals&gt;&lt;MediaTotals&gt;&lt;Total&gt;&lt;Amount&gt;000001000000&lt;/Amount&gt;&lt;Currency&gt;566&lt;/Currency&gt;&lt;MediaClass&gt;cards&lt;/MediaClass&gt;&lt;/Total&gt;&lt;/MediaTotals&gt;212MediaBatchNr10214AdditionalInfo3485&lt;AdditionalInfo&gt;&lt;Transaction&gt;&lt;BufferB&gt;&lt;/BufferB&gt;&lt;BufferC&gt;12606002705&lt;/BufferC&gt;&lt;CfgExtendedTrxType&gt;&lt;/CfgExtendedTrxType&gt;&lt;CfgReceivingInstitutionIDCode&gt;&lt;'
SELECT  SUBSTRING(@struct_data, CHARINDEX('BufferC&gt;',@struct_data)+@off_set, CHARINDEX('&lt;/BufferC&gt;',@struct_data) -(CHARINDEX('BufferC&gt;',@struct_data)+@off_set))

