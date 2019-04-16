USE [postilion_office]
GO

/****** Object:  View [dbo].[sstl_journal_all]    Script Date: 05/04/2016 18:10:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


		CREATE VIEW [dbo].[sstl_journal_custom]
		AS
		
			SELECT
				adj_id,
				entry_id,
				config_set_id,
				session_id,
				post_tran_id,
				post_tran_cust_id,
				sdi_tran_id,
				acc_post_id,
				nt_fee_acc_post_id,
				coa_id,
				coa_se_id,
				se_id,
				amount,
				amount_id,
				amount_value_id,
				fee,
				fee_id,
				fee_value_id,
				nt_fee,
				nt_fee_id,
				nt_fee_value_id,
				debit_acc_nr_id,
				debit_acc_id,
				debit_cardholder_acc_id,
				debit_cardholder_acc_type,
				credit_acc_nr_id,
				credit_acc_id,
				credit_cardholder_acc_id,
				credit_cardholder_acc_type,
				business_date,
				granularity_element,
				tag,
				spay_session_id,
				spst_session_id
			FROM
				sstl_journal_adj (nolock)
			UNION ALL
			SELECT  NULL adj_id ,* FROM sstl_journal_131(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_132(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_130(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_129(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_128(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_127(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_126(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_125(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_124(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_123(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_122(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_121(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_120(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_119(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_118(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_117(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_116(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_115(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_114(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_113(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_112(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_111(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_110(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_109(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_108(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_107(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_106(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_105(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_104(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_103(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_102(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_101(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_100(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_99(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_98(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_97(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_96(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_95(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_94(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_93(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_92(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_91(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_90(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_89(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_88(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_87(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_86(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_85(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_84(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_83(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_82(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_81(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_80(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_79(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_78(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_77(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_76(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_75(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_74(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_73(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_72(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_71(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_70(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_69(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_68(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_67(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_66(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_65(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_64(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_63(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_62(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_61(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_60(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_59(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_58(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_57(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_56(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_55(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_54(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_53(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_52(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_51(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_50(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_49(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_48(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_47(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_46(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_45(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_44(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_43(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_42(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_41(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_40(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_39(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_38(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_37(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_36(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_35(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_34(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_33(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_32(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_31(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_30(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_29(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_28(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_27(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_26(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_25(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_24(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_23(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_22(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_21(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_20(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_19(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_18(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_17(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_16(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_15(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_14(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_13(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_12(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_11(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_10(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_9(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_8(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_7(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_6(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_5(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_4(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_3(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_2(NOLOCK)     UNION ALL SELECT  NULL adj_id ,* FROM sstl_journal_1(NOLOCK) 
				
			
	
GO


