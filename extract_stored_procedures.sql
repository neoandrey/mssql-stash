USE [postilion_office]
GO

/****** Object:  StoredProcedure [dbo].[dbr_get_next_step_number]    Script Date: 10/28/2016 09:04:17 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbr_get_next_step_number]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbr_get_next_step_number]
GO

/****** Object:  StoredProcedure [dbo].[dbr_get_next_stmt_number]    Script Date: 10/28/2016 09:04:17 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbr_get_next_stmt_number]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbr_get_next_stmt_number]
GO

/****** Object:  StoredProcedure [dbo].[extract_status]    Script Date: 10/28/2016 09:04:17 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[extract_status]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[extract_status]
GO

/****** Object:  StoredProcedure [dbo].[mcipm_clean_extract_trans]    Script Date: 10/28/2016 09:04:17 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[mcipm_clean_extract_trans]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[mcipm_clean_extract_trans]
GO

/****** Object:  StoredProcedure [dbo].[mcipm_extract_full_card_acceptor_mapping_info_record]    Script Date: 10/28/2016 09:04:17 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[mcipm_extract_full_card_acceptor_mapping_info_record]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[mcipm_extract_full_card_acceptor_mapping_info_record]
GO

/****** Object:  StoredProcedure [dbo].[mcipm_extract_insert_file]    Script Date: 10/28/2016 09:04:17 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[mcipm_extract_insert_file]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[mcipm_extract_insert_file]
GO

/****** Object:  StoredProcedure [dbo].[mcipm_extract_insert_transmission]    Script Date: 10/28/2016 09:04:17 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[mcipm_extract_insert_transmission]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[mcipm_extract_insert_transmission]
GO

/****** Object:  StoredProcedure [dbo].[mcipm_extract_specific_transmission]    Script Date: 10/28/2016 09:04:17 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[mcipm_extract_specific_transmission]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[mcipm_extract_specific_transmission]
GO

/****** Object:  StoredProcedure [dbo].[mcipm_extract_update_card_acceptor_mapping_info_record]    Script Date: 10/28/2016 09:04:18 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[mcipm_extract_update_card_acceptor_mapping_info_record]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[mcipm_extract_update_card_acceptor_mapping_info_record]
GO

/****** Object:  StoredProcedure [dbo].[mcipm_insert_extract_trans]    Script Date: 10/28/2016 09:04:18 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[mcipm_insert_extract_trans]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[mcipm_insert_extract_trans]
GO

/****** Object:  StoredProcedure [dbo].[mcipm_post_tran_extract_exists]    Script Date: 10/28/2016 09:04:18 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[mcipm_post_tran_extract_exists]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[mcipm_post_tran_extract_exists]
GO

/****** Object:  StoredProcedure [dbo].[mcipm_update_post_tran_extract]    Script Date: 10/28/2016 09:04:18 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[mcipm_update_post_tran_extract]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[mcipm_update_post_tran_extract]
GO

/****** Object:  StoredProcedure [dbo].[opsp_tranqry_getextrextendeddata]    Script Date: 10/28/2016 09:04:18 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[opsp_tranqry_getextrextendeddata]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[opsp_tranqry_getextrextendeddata]
GO

/****** Object:  StoredProcedure [dbo].[osp_cleaner_tran_post_tran_extract]    Script Date: 10/28/2016 09:04:18 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[osp_cleaner_tran_post_tran_extract]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[osp_cleaner_tran_post_tran_extract]
GO

/****** Object:  StoredProcedure [dbo].[osp_extr_reg_method]    Script Date: 10/28/2016 09:04:18 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[osp_extr_reg_method]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[osp_extr_reg_method]
GO

/****** Object:  StoredProcedure [dbo].[osp_extr_rem_method]    Script Date: 10/28/2016 09:04:18 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[osp_extr_rem_method]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[osp_extr_rem_method]
GO

/****** Object:  StoredProcedure [dbo].[osp_extract_cleaner]    Script Date: 10/28/2016 09:04:18 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[osp_extract_cleaner]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[osp_extract_cleaner]
GO

/****** Object:  StoredProcedure [dbo].[osp_extract_close_bd_all]    Script Date: 10/28/2016 09:04:18 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[osp_extract_close_bd_all]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[osp_extract_close_bd_all]
GO

/****** Object:  StoredProcedure [dbo].[osp_extract_close_bd_srcsnk]    Script Date: 10/28/2016 09:04:18 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[osp_extract_close_bd_srcsnk]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[osp_extract_close_bd_srcsnk]
GO

/****** Object:  StoredProcedure [dbo].[osp_extract_get_entity_parameters]    Script Date: 10/28/2016 09:04:18 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[osp_extract_get_entity_parameters]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[osp_extract_get_entity_parameters]
GO

/****** Object:  StoredProcedure [dbo].[osp_extract_get_extract_entity_id]    Script Date: 10/28/2016 09:04:18 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[osp_extract_get_extract_entity_id]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[osp_extract_get_extract_entity_id]
GO

/****** Object:  StoredProcedure [dbo].[osp_extract_get_extracted]    Script Date: 10/28/2016 09:04:18 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[osp_extract_get_extracted]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[osp_extract_get_extracted]
GO

/****** Object:  StoredProcedure [dbo].[osp_extract_get_last_batch_where]    Script Date: 10/28/2016 09:04:18 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[osp_extract_get_last_batch_where]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[osp_extract_get_last_batch_where]
GO

/****** Object:  StoredProcedure [dbo].[osp_extract_get_last_closed_batch]    Script Date: 10/28/2016 09:04:18 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[osp_extract_get_last_closed_batch]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[osp_extract_get_last_closed_batch]
GO

/****** Object:  StoredProcedure [dbo].[osp_extract_get_last_completed_session]    Script Date: 10/28/2016 09:04:18 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[osp_extract_get_last_completed_session]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[osp_extract_get_last_completed_session]
GO

/****** Object:  StoredProcedure [dbo].[osp_extract_get_last_post_tran_id]    Script Date: 10/28/2016 09:04:18 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[osp_extract_get_last_post_tran_id]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[osp_extract_get_last_post_tran_id]
GO

/****** Object:  StoredProcedure [dbo].[osp_extract_get_last_screened_norm_session]    Script Date: 10/28/2016 09:04:18 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[osp_extract_get_last_screened_norm_session]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[osp_extract_get_last_screened_norm_session]
GO

/****** Object:  StoredProcedure [dbo].[osp_extract_get_max_datetime]    Script Date: 10/28/2016 09:04:18 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[osp_extract_get_max_datetime]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[osp_extract_get_max_datetime]
GO

/****** Object:  StoredProcedure [dbo].[osp_extract_get_max_post_tran_id]    Script Date: 10/28/2016 09:04:18 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[osp_extract_get_max_post_tran_id]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[osp_extract_get_max_post_tran_id]
GO

/****** Object:  StoredProcedure [dbo].[osp_extract_get_sessions_to_clean]    Script Date: 10/28/2016 09:04:18 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[osp_extract_get_sessions_to_clean]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[osp_extract_get_sessions_to_clean]
GO

/****** Object:  StoredProcedure [dbo].[osp_extract_ins_tran_10]    Script Date: 10/28/2016 09:04:18 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[osp_extract_ins_tran_10]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[osp_extract_ins_tran_10]
GO

/****** Object:  StoredProcedure [dbo].[osp_extract_insert_or_update_extract_tran]    Script Date: 10/28/2016 09:04:18 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[osp_extract_insert_or_update_extract_tran]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[osp_extract_insert_or_update_extract_tran]
GO

/****** Object:  StoredProcedure [dbo].[osp_extract_insert_or_update_post_tran_extract]    Script Date: 10/28/2016 09:04:18 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[osp_extract_insert_or_update_post_tran_extract]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[osp_extract_insert_or_update_post_tran_extract]
GO

/****** Object:  StoredProcedure [dbo].[osp_extract_insert_session]    Script Date: 10/28/2016 09:04:18 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[osp_extract_insert_session]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[osp_extract_insert_session]
GO

/****** Object:  StoredProcedure [dbo].[osp_extract_rollback_session]    Script Date: 10/28/2016 09:04:18 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[osp_extract_rollback_session]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[osp_extract_rollback_session]
GO

/****** Object:  StoredProcedure [dbo].[osp_extract_tran_is_bigint]    Script Date: 10/28/2016 09:04:18 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[osp_extract_tran_is_bigint]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[osp_extract_tran_is_bigint]
GO

/****** Object:  StoredProcedure [dbo].[osp_extract_upd_tran_10]    Script Date: 10/28/2016 09:04:18 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[osp_extract_upd_tran_10]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[osp_extract_upd_tran_10]
GO

/****** Object:  StoredProcedure [dbo].[osp_extract_update_post_tran_extract_extended_data]    Script Date: 10/28/2016 09:04:18 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[osp_extract_update_post_tran_extract_extended_data]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[osp_extract_update_post_tran_extract_extended_data]
GO

/****** Object:  StoredProcedure [dbo].[osp_framework_cs_extended_tran_type_description]    Script Date: 10/28/2016 09:04:18 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[osp_framework_cs_extended_tran_type_description]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[osp_framework_cs_extended_tran_type_description]
GO

/****** Object:  StoredProcedure [dbo].[osp_norm_ext_field_create]    Script Date: 10/28/2016 09:04:18 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[osp_norm_ext_field_create]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[osp_norm_ext_field_create]
GO

/****** Object:  StoredProcedure [dbo].[osp_norm_ext_field_drop]    Script Date: 10/28/2016 09:04:18 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[osp_norm_ext_field_drop]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[osp_norm_ext_field_drop]
GO

/****** Object:  StoredProcedure [dbo].[osp_norm_rerun_update_next_post_tran]    Script Date: 10/28/2016 09:04:18 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[osp_norm_rerun_update_next_post_tran]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[osp_norm_rerun_update_next_post_tran]
GO

/****** Object:  StoredProcedure [dbo].[osp_patch_get_rb_text]    Script Date: 10/28/2016 09:04:18 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[osp_patch_get_rb_text]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[osp_patch_get_rb_text]
GO

/****** Object:  StoredProcedure [dbo].[osp_recon_cs_qry_external_only]    Script Date: 10/28/2016 09:04:18 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[osp_recon_cs_qry_external_only]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[osp_recon_cs_qry_external_only]
GO

/****** Object:  StoredProcedure [dbo].[osp_recon_cs_qry_get_external_file_sources]    Script Date: 10/28/2016 09:04:18 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[osp_recon_cs_qry_get_external_file_sources]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[osp_recon_cs_qry_get_external_file_sources]
GO

/****** Object:  StoredProcedure [dbo].[osp_recon_cs_qry_get_external_files]    Script Date: 10/28/2016 09:04:18 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[osp_recon_cs_qry_get_external_files]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[osp_recon_cs_qry_get_external_files]
GO

/****** Object:  StoredProcedure [dbo].[osp_recon_insert_external_file_source]    Script Date: 10/28/2016 09:04:18 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[osp_recon_insert_external_file_source]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[osp_recon_insert_external_file_source]
GO

/****** Object:  StoredProcedure [dbo].[osp_recon_insert_update_external_file]    Script Date: 10/28/2016 09:04:18 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[osp_recon_insert_update_external_file]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[osp_recon_insert_update_external_file]
GO

/****** Object:  StoredProcedure [dbo].[osp_spay_pop_tt_amount_next_date]    Script Date: 10/28/2016 09:04:18 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[osp_spay_pop_tt_amount_next_date]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[osp_spay_pop_tt_amount_next_date]
GO

/****** Object:  StoredProcedure [dbo].[osp_spay_pop_tt_fee_next_date]    Script Date: 10/28/2016 09:04:18 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[osp_spay_pop_tt_fee_next_date]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[osp_spay_pop_tt_fee_next_date]
GO

/****** Object:  StoredProcedure [dbo].[osp_spst_pop_tt_amount_next_date]    Script Date: 10/28/2016 09:04:18 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[osp_spst_pop_tt_amount_next_date]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[osp_spst_pop_tt_amount_next_date]
GO

/****** Object:  StoredProcedure [dbo].[osp_spst_pop_tt_fee_next_date]    Script Date: 10/28/2016 09:04:18 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[osp_spst_pop_tt_fee_next_date]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[osp_spst_pop_tt_fee_next_date]
GO

/****** Object:  StoredProcedure [dbo].[osp_tranqry_getextrextendeddata]    Script Date: 10/28/2016 09:04:18 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[osp_tranqry_getextrextendeddata]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[osp_tranqry_getextrextendeddata]
GO

/****** Object:  StoredProcedure [dbo].[placeholder_mcipm_extract_full_card_acceptor_mapping_info_record]    Script Date: 10/28/2016 09:04:18 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[placeholder_mcipm_extract_full_card_acceptor_mapping_info_record]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[placeholder_mcipm_extract_full_card_acceptor_mapping_info_record]
GO

USE [postilion_office]
GO

/****** Object:  StoredProcedure [dbo].[sp_extract_cs_qry_extract_sessions_with_entity_id]    Script Date: 10/28/2016 09:04:47 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_extract_cs_qry_extract_sessions_with_entity_id]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[sp_extract_cs_qry_extract_sessions_with_entity_id]
GO

/****** Object:  StoredProcedure [dbo].[sp_extract_cs_qry_extract_sessions_without_entity_id]    Script Date: 10/28/2016 09:04:47 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_extract_cs_qry_extract_sessions_without_entity_id]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[sp_extract_cs_qry_extract_sessions_without_entity_id]
GO

/****** Object:  StoredProcedure [dbo].[sp_extract_cs_qry_open_tran]    Script Date: 10/28/2016 09:04:47 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_extract_cs_qry_open_tran]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[sp_extract_cs_qry_open_tran]
GO

/****** Object:  StoredProcedure [dbo].[sp_extract_cs_qry_open_tran_count]    Script Date: 10/28/2016 09:04:47 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_extract_cs_qry_open_tran_count]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[sp_extract_cs_qry_open_tran_count]
GO

/****** Object:  StoredProcedure [dbo].[sp_extract_cs_qry_select_all_entities]    Script Date: 10/28/2016 09:04:47 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_extract_cs_qry_select_all_entities]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[sp_extract_cs_qry_select_all_entities]
GO

/****** Object:  StoredProcedure [dbo].[sp_extract_cs_qry_tran]    Script Date: 10/28/2016 09:04:47 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_extract_cs_qry_tran]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[sp_extract_cs_qry_tran]
GO

/****** Object:  StoredProcedure [dbo].[sp_extract_cs_qry_tran_count]    Script Date: 10/28/2016 09:04:47 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_extract_cs_qry_tran_count]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[sp_extract_cs_qry_tran_count]
GO

/****** Object:  StoredProcedure [dbo].[sp_extract_plugin_insert]    Script Date: 10/28/2016 09:04:47 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_extract_plugin_insert]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[sp_extract_plugin_insert]
GO

/****** Object:  StoredProcedure [dbo].[sp_recon_check_ext_batch_file]    Script Date: 10/28/2016 09:04:47 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_recon_check_ext_batch_file]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[sp_recon_check_ext_batch_file]
GO

/****** Object:  StoredProcedure [dbo].[sp_recon_get_ext_file_id]    Script Date: 10/28/2016 09:04:47 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_recon_get_ext_file_id]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[sp_recon_get_ext_file_id]
GO

/****** Object:  StoredProcedure [dbo].[sp_recon_get_ext_tran_range]    Script Date: 10/28/2016 09:04:47 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_recon_get_ext_tran_range]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[sp_recon_get_ext_tran_range]
GO

/****** Object:  StoredProcedure [dbo].[sp_recon_get_external_column_property_isidentity]    Script Date: 10/28/2016 09:04:47 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_recon_get_external_column_property_isidentity]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[sp_recon_get_external_column_property_isidentity]
GO

/****** Object:  StoredProcedure [dbo].[sp_recon_get_min_max_prev_ext_only]    Script Date: 10/28/2016 09:04:47 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_recon_get_min_max_prev_ext_only]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[sp_recon_get_min_max_prev_ext_only]
GO

/****** Object:  StoredProcedure [dbo].[sp_recon_get_plugin_table_name_extension]    Script Date: 10/28/2016 09:04:47 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_recon_get_plugin_table_name_extension]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[sp_recon_get_plugin_table_name_extension]
GO

/****** Object:  StoredProcedure [dbo].[sp_recon_insert_and_get_external_file_id]    Script Date: 10/28/2016 09:04:47 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_recon_insert_and_get_external_file_id]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[sp_recon_insert_and_get_external_file_id]
GO

/****** Object:  StoredProcedure [dbo].[sp_recon_insert_external_only]    Script Date: 10/28/2016 09:04:47 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_recon_insert_external_only]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[sp_recon_insert_external_only]
GO

/****** Object:  StoredProcedure [dbo].[sp_recon_insert_into_external_only]    Script Date: 10/28/2016 09:04:47 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_recon_insert_into_external_only]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[sp_recon_insert_into_external_only]
GO

/****** Object:  StoredProcedure [dbo].[sp_recon_update_external_only]    Script Date: 10/28/2016 09:04:47 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_recon_update_external_only]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[sp_recon_update_external_only]
GO

/****** Object:  StoredProcedure [dbo].[sp_recon_update_prev_external_only]    Script Date: 10/28/2016 09:04:47 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_recon_update_prev_external_only]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[sp_recon_update_prev_external_only]
GO

/****** Object:  StoredProcedure [dbo].[visabase2_update_post_tran_extract]    Script Date: 10/28/2016 09:04:47 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[visabase2_update_post_tran_extract]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[visabase2_update_post_tran_extract]
GO

/****** Object:  StoredProcedure [dbo].[visabase2extract_get_0100_pos_entry_mode]    Script Date: 10/28/2016 09:04:47 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[visabase2extract_get_0100_pos_entry_mode]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[visabase2extract_get_0100_pos_entry_mode]
GO

USE [postilion_office]
GO

/****** Object:  StoredProcedure [dbo].[sp_extract_cs_qry_extract_sessions_with_entity_id]    Script Date: 10/28/2016 09:04:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO



CREATE PROCEDURE [dbo].[sp_extract_cs_qry_extract_sessions_with_entity_id]
	@entity_id POST_ID
AS
BEGIN
	SELECT  
		extract_session.session_id,
		extract_session.entity_id,
		extract_session.datetime_creation,
		extract_session.output,
		extract_session.last_post_tran_id,
		extract_session.completed,
		extract_session.business_date,
		extract_entity.*,
		extract_plugin.*
	FROM 
		extract_session WITH (NOLOCK), 
		extract_entity WITH (NOLOCK), 
		extract_plugin WITH (NOLOCK)
	WHERE
		extract_session.entity_id = @entity_id AND 
		extract_session.entity_id = extract_entity.entity_id AND
		extract_entity.plugin_id = extract_plugin.plugin_id
	ORDER BY
		extract_session.session_id DESC
END


GO

/****** Object:  StoredProcedure [dbo].[sp_extract_cs_qry_extract_sessions_without_entity_id]    Script Date: 10/28/2016 09:04:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO



CREATE PROCEDURE [dbo].[sp_extract_cs_qry_extract_sessions_without_entity_id]
AS
BEGIN
	SELECT  
		extract_session.session_id,
		extract_session.entity_id,
		extract_session.datetime_creation,
		extract_session.output,
		extract_session.last_post_tran_id,
		extract_session.completed,
		extract_session.business_date,
		extract_entity.*,
		extract_plugin.*
	FROM 
		extract_session WITH (NOLOCK), 
		extract_entity WITH (NOLOCK), 
		extract_plugin WITH (NOLOCK)
	WHERE
		extract_session.entity_id = extract_entity.entity_id AND
		extract_entity.plugin_id = extract_plugin.plugin_id
	ORDER BY
		extract_session.session_id DESC
END


GO

/****** Object:  StoredProcedure [dbo].[sp_extract_cs_qry_open_tran]    Script Date: 10/28/2016 09:04:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO



-- Do not force the usage of INDEX ix_extract_tran_1.
-- It slows the performance down considerably due to the usage of open_session_id
CREATE PROCEDURE [dbo].[sp_extract_cs_qry_open_tran]
	@session_id POST_ID
AS
BEGIN

	SELECT
		post_tran.post_tran_id,
		post_tran.tran_nr,
		post_tran.sink_node_name,
		post_tran_cust.source_node_name, 
		post_tran_cust.pan,
		post_tran.datetime_tran_local,
		extract_tran.session_id,
		extract_tran.discarded
	FROM
		post_tran WITH (INDEX=ix_post_tran_1 NOLOCK) JOIN post_tran_cust WITH (NOLOCK) ON post_tran.post_tran_cust_id = 		post_tran_cust.post_tran_cust_id,
		extract_tran WITH (NOLOCK)
	WHERE
		extract_tran.open_session_id = @session_id AND
		extract_tran.post_tran_id = post_tran.post_tran_id 

END


GO

/****** Object:  StoredProcedure [dbo].[sp_extract_cs_qry_open_tran_count]    Script Date: 10/28/2016 09:04:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO



-- Do not force the usage of INDEX ix_extract_tran_1.
-- It slows the performance down considerably due to the usage of open_session_id
CREATE PROCEDURE [dbo].[sp_extract_cs_qry_open_tran_count]
        @session_id POST_ID
AS
BEGIN

	SELECT
		count(post_tran.post_tran_id)
	FROM
		post_tran WITH	(INDEX=ix_post_tran_1 NOLOCK) JOIN post_tran_cust WITH (NOLOCK) ON post_tran.post_tran_cust_id = 		post_tran_cust.post_tran_cust_id,
		extract_tran WITH (NOLOCK)
	WHERE
		extract_tran.open_session_id = @session_id AND
		extract_tran.post_tran_id = post_tran.post_tran_id

END


GO

/****** Object:  StoredProcedure [dbo].[sp_extract_cs_qry_select_all_entities]    Script Date: 10/28/2016 09:04:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO



CREATE PROCEDURE [dbo].[sp_extract_cs_qry_select_all_entities]
AS
BEGIN
	SELECT 
		entity_id, 
		name
	FROM 
		extract_entity WITH (NOLOCK)
	ORDER BY
		entity_id
END


GO

/****** Object:  StoredProcedure [dbo].[sp_extract_cs_qry_tran]    Script Date: 10/28/2016 09:04:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO



-- The ORDER BY post_tran_id has been removed due to performance reasons. It doesnt
-- blend well with the delphi console dynamic cursor design

CREATE PROCEDURE [dbo].[sp_extract_cs_qry_tran]
	@session_id POST_ID
AS
BEGIN

	SELECT
		post_tran.post_tran_id,
		post_tran.tran_nr,
		post_tran.sink_node_name,
		post_tran_cust.source_node_name, 
		post_tran_cust.pan,
		post_tran.datetime_tran_local,
		extract_tran.open_session_id,
		extract_tran.discarded
	FROM
		post_tran WITH (INDEX=ix_post_tran_1 NOLOCK) JOIN post_tran_cust WITH (NOLOCK) ON post_tran.post_tran_cust_id = 		post_tran_cust.post_tran_cust_id,
		extract_tran WITH (INDEX=ix_extract_tran_1 NOLOCK)
	WHERE
		extract_tran.session_id = @session_id AND
		extract_tran.post_tran_id = post_tran.post_tran_id

END


GO

/****** Object:  StoredProcedure [dbo].[sp_extract_cs_qry_tran_count]    Script Date: 10/28/2016 09:04:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO



CREATE PROCEDURE [dbo].[sp_extract_cs_qry_tran_count]
        @session_id POST_ID
AS
BEGIN

	SELECT
		count(post_tran.post_tran_id)
	FROM
		post_tran WITH (INDEX=ix_post_tran_1 NOLOCK) JOIN post_tran_cust WITH (NOLOCK) ON post_tran.post_tran_cust_id = 		post_tran_cust.post_tran_cust_id,
		extract_tran WITH (INDEX=ix_extract_tran_1 NOLOCK)
	WHERE
		extract_tran.session_id = @session_id AND
		extract_tran.post_tran_id = post_tran.post_tran_id

END


GO

/****** Object:  StoredProcedure [dbo].[sp_extract_plugin_insert]    Script Date: 10/28/2016 09:04:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO



CREATE PROCEDURE [dbo].[sp_extract_plugin_insert]
   @id                                                                  POST_PLUGIN_ID,
   @description                                                 VARCHAR(50),
   @output_description                          VARCHAR(50),
   @user_param_list_description         VARCHAR(255),
   @extract_class_name                          VARCHAR(100),
   @output_list_description                          VARCHAR(50) = NULL
AS
BEGIN
   IF EXISTS (SELECT *  FROM extract_plugin WHERE plugin_id=@ID)
        BEGIN
        UPDATE extract_plugin
      SET
         description = @description,
         output_description = @output_description,
         output_list_description = @output_list_description,
         user_param_list_description = @user_param_list_description,
         extract_class_name = @extract_class_name
        WHERE
        plugin_id = @id
        END
        ELSE
   BEGIN
        INSERT INTO extract_plugin (
        plugin_id,
        description,
        output_description,
        output_list_description,
        user_param_list_description,
        extract_class_name)
        VALUES (
        @id,
        @description,
        @output_description,
        @output_list_description,
        @user_param_list_description,
        @extract_class_name)
   END
END


GO

/****** Object:  StoredProcedure [dbo].[sp_recon_check_ext_batch_file]    Script Date: 10/28/2016 09:04:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].[sp_recon_check_ext_batch_file]
	@table_name_extension  	VARCHAR(50)
AS
BEGIN
	IF EXISTS(SELECT * FROM sysobjects WHERE xtype = 'u'  AND name='external_batch_' + @table_name_extension )
	BEGIN
		RETURN 1
	END
	ELSE
	BEGIN
		RETURN 0
	END
END

GO

/****** Object:  StoredProcedure [dbo].[sp_recon_get_ext_file_id]    Script Date: 10/28/2016 09:04:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].[sp_recon_get_ext_file_id]
	@table_name_extension 		VARCHAR(50),
	@external_file_id				POST_ID

AS
BEGIN
	DECLARE @exec_str 	VARCHAR(255)
	SELECT @exec_str = '
	SELECT	
		external_file_id 
	FROM 
		external_file_' + @table_name_extension +
	' WHERE 
		external_file_id = ' + CONVERT(VARCHAR,@external_file_id)

	EXEC (@exec_str)
END

GO

/****** Object:  StoredProcedure [dbo].[sp_recon_get_ext_tran_range]    Script Date: 10/28/2016 09:04:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].[sp_recon_get_ext_tran_range]
	@table_name_extension 		VARCHAR(50),
	@external_file_id				POST_ID

AS
BEGIN
	DECLARE @exec_str 	VARCHAR(255)
	SELECT @exec_str = '
	SELECT	
		ISNULL(min(external_tran_id),0), 
		ISNULL(max(external_tran_id),-1) 
	FROM 
		external_tran_' + @table_name_extension +
	' WHERE 
		external_file_id = ' + CONVERT(VARCHAR,@external_file_id) 

	EXEC (@exec_str)
END

GO

/****** Object:  StoredProcedure [dbo].[sp_recon_get_external_column_property_isidentity]    Script Date: 10/28/2016 09:04:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].[sp_recon_get_external_column_property_isidentity]
	@table_name_extension		VARCHAR(50),
	@ext_file_is_identity 		INT OUTPUT,
	@ext_batch_is_identity 		INT OUTPUT, 
	@ext_tran_is_identity 		INT OUTPUT
AS
BEGIN
	-- The out parameters will return 1 of the following values
	-- -1 if the table does not exist
	-- 0 if the column is NOT an identity column
	-- 1 if the column is an identity column

	SELECT @ext_file_is_identity = ISNULL(COLUMNPROPERTY( OBJECT_ID('external_file_' + @table_name_extension), 'external_file_id', 'IsIdentity'),-1)
	SELECT @ext_batch_is_identity = ISNULL(COLUMNPROPERTY( OBJECT_ID('external_batch_' + @table_name_extension), 'external_batch_id', 'IsIdentity'),-1)
	SELECT @ext_tran_is_identity = ISNULL(COLUMNPROPERTY( OBJECT_ID('external_tran_' + @table_name_extension), 'external_tran_id', 'IsIdentity'),-1)
		
	RETURN

END

GO

/****** Object:  StoredProcedure [dbo].[sp_recon_get_min_max_prev_ext_only]    Script Date: 10/28/2016 09:04:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].[sp_recon_get_min_max_prev_ext_only]
	@session_id			POST_ID

AS
BEGIN
	SELECT 
		ISNULL(MIN(external_tran_id),0), ISNULL(MAX(external_tran_id),-1) 
	FROM 
		recon_external_only WITH (NOLOCK) 
	WHERE 
		match_session_id IS NULL 
		AND (( EXISTS (SELECT * FROM recon_match_equal rme WHERE session_id = @session_id AND rme.external_tran_id = recon_external_only.external_tran_id)) OR 				
		(EXISTS (SELECT * FROM recon_match_not_equal rmne WHERE session_id = @session_id AND rmne.external_tran_id = recon_external_only.external_tran_id))) 
END

GO

/****** Object:  StoredProcedure [dbo].[sp_recon_get_plugin_table_name_extension]    Script Date: 10/28/2016 09:04:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].[sp_recon_get_plugin_table_name_extension]
	@entity_id			POST_ID

AS
BEGIN
	SELECT
		recon_plugin.table_name_extension
	FROM
		recon_plugin,
		recon_entity
	WHERE
		(recon_plugin.plugin_id = recon_entity.plugin_id) AND
		(recon_entity.entity_id = @entity_id)
END

GO

/****** Object:  StoredProcedure [dbo].[sp_recon_insert_and_get_external_file_id]    Script Date: 10/28/2016 09:04:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].[sp_recon_insert_and_get_external_file_id]
	@exec_insert_str						VARCHAR(8000),
	@external_file_id						INT OUTPUT
AS
BEGIN

	EXEC (@exec_insert_str)
	SELECT @external_file_id = @@IDENTITY
	
	RETURN @external_file_id

END

GO

/****** Object:  StoredProcedure [dbo].[sp_recon_insert_external_only]    Script Date: 10/28/2016 09:04:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].[sp_recon_insert_external_only]
	@session_id								POST_ID,
	@external_tran_id						BIGINT,
	@state_value							INT,
	@external_settle_amount_impact	POST_MONEY,
	@external_settle_fee_impact		POST_MONEY,
	@external_tran_type					CHAR(2),
	@notes									POST_NOTES
AS
BEGIN
	INSERT INTO recon_external_only 
	(
		session_id,
		external_tran_id,
		state_value,
		external_settle_amount_impact,
		external_settle_fee_impact,
		external_tran_type,
		notes
	)
	VALUES
	(
		@session_id,
		@external_tran_id,
		@state_value,
		@external_settle_amount_impact,
		@external_settle_fee_impact,
		@external_tran_type,
		@notes
	)
END

GO

/****** Object:  StoredProcedure [dbo].[sp_recon_insert_into_external_only]    Script Date: 10/28/2016 09:04:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].[sp_recon_insert_into_external_only]
	@session_id					POST_ID,
	@table_name_extension	VARCHAR(50),
	@status_value				INT,
	@external_file_id			POST_ID,
	@min_tran					BIGINT,
	@max_tran					BIGINT

AS
BEGIN
	DECLARE @exec_str VARCHAR(1024)
	SELECT @exec_str = '
		INSERT INTO recon_external_only 
			(session_id, table_name_extension, external_tran_id, state_value) 
		SELECT ' + CONVERT(VARCHAR,@session_id) +','+ CHAR(39) + @table_name_extension + CHAR(39) + ', external_tran_id ,'+ CONVERT(VARCHAR,@status_value) + '
		FROM 	
			external_tran_' + @table_name_extension + ' trx 
		WHERE 
			(trx.external_tran_id BETWEEN ' + CONVERT(VARCHAR,@min_tran) + ' AND ' + CONVERT(VARCHAR,@max_tran) + ') AND ' +
			'trx.external_file_id = ' + CONVERT(VARCHAR,@external_file_id) + ' AND ' + '                
			NOT EXISTS (SELECT * FROM recon_match_equal rme WITH (NOLOCK) WHERE session_id = ' + CONVERT(VARCHAR,@session_id) + ' AND rme.external_tran_id = trx.external_tran_id) AND 				                  
			NOT EXISTS (SELECT * FROM recon_match_not_equal rmne WITH (NOLOCK) WHERE session_id = ' + CONVERT(VARCHAR,@session_id) + ' AND rmne.external_tran_id = trx.external_tran_id) 
			'

	EXEC (@exec_str)
END

GO

/****** Object:  StoredProcedure [dbo].[sp_recon_update_external_only]    Script Date: 10/28/2016 09:04:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].[sp_recon_update_external_only]
	@session_id					POST_ID,
	@external_tran_id			BIGINT,
	@match_session_id			POST_ID

AS
BEGIN
	UPDATE
		recon_external_only
	SET
		match_session_id = @match_session_id
	WHERE
		session_id = @session_id AND
		external_tran_id = @external_tran_id
		
END

GO

/****** Object:  StoredProcedure [dbo].[sp_recon_update_prev_external_only]    Script Date: 10/28/2016 09:04:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].[sp_recon_update_prev_external_only]
	@session_id 		POST_ID,
	@min_tran			BIGINT,
	@max_tran			BIGINT

AS
BEGIN
	UPDATE recon_external_only 
   SET match_session_id = @session_id
   WHERE 
		(external_tran_id BETWEEN @min_tran AND @max_tran ) AND 
		(match_session_id IS NULL) AND 
		(( EXISTS (SELECT * FROM recon_match_equal rme WHERE session_id = @session_id AND rme.external_tran_id = recon_external_only.external_tran_id)) OR 
		(EXISTS (SELECT * FROM recon_match_not_equal rmne WHERE session_id = @session_id AND rmne.external_tran_id = recon_external_only.external_tran_id))) 
END

GO

/****** Object:  StoredProcedure [dbo].[visabase2_update_post_tran_extract]    Script Date: 10/28/2016 09:04:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO



CREATE PROCEDURE [dbo].[visabase2_update_post_tran_extract]
	@post_tran_id					BIGINT, 
	@primary_file_reference		VARCHAR(32),
	@extr_extended_data			TEXT
AS
BEGIN
	IF EXISTS (SELECT 1 FROM sysobjects o WHERE  o.name = 'post_tran_extract' AND o.type = 'U')
	BEGIN
		IF EXISTS (SELECT 1 FROM post_tran_extract WHERE post_tran_id = @post_tran_id)
		BEGIN
			UPDATE post_tran_extract
			SET primary_file_reference = @primary_file_reference,
				 extr_extended_data = @extr_extended_data
			WHERE post_tran_id = @post_tran_id
		END
		ELSE
		BEGIN
			INSERT INTO post_tran_extract(post_tran_id, primary_file_reference, extr_extended_data)
			VALUES(@post_tran_id, @primary_file_reference, @extr_extended_data)
		END
	END
END


GO

/****** Object:  StoredProcedure [dbo].[visabase2extract_get_0100_pos_entry_mode]    Script Date: 10/28/2016 09:04:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO



	CREATE PROCEDURE [dbo].[visabase2extract_get_0100_pos_entry_mode]
						@cust_id	INT
	AS
		BEGIN
			SELECT post_tran.pos_entry_mode
			FROM post_tran
			WITH (NOLOCK)
			WHERE	(post_tran.post_tran_cust_id = @cust_id)
			AND	(post_tran.message_type = '0100')
			AND	(post_tran.tran_postilion_originated = 1)
			AND	(post_tran.prev_post_tran_id = '0')
			AND NOT	(post_tran.pos_entry_mode IS NULL)
		END 

GO




/****** Object:  StoredProcedure [dbo].[dbr_get_next_step_number]    Script Date: 10/28/2016 09:04:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[dbr_get_next_step_number]
 
	@step_number                   INTEGER OUTPUT
AS
BEGIN
	DECLARE @statement_number              INTEGER
	--
	-- Determine the next SQL step number
	--
	SELECT
		@step_number = COALESCE(MAX(step), 0)+1
	FROM
		dbr_sql_fragments
END

GO

/****** Object:  StoredProcedure [dbo].[dbr_get_next_stmt_number]    Script Date: 10/28/2016 09:04:19 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[dbr_get_next_stmt_number]
 
	@statement_number              INTEGER OUTPUT,
	@step_number                   INTEGER
AS
BEGIN
	--
	-- Determine the next SQL statement number
	--
	SELECT
		@statement_number = COALESCE(MAX(statement_number), 0)+1
	FROM
		dbr_sql_fragments
	WHERE
		step = @step_number
END

GO

/****** Object:  StoredProcedure [dbo].[extract_status]    Script Date: 10/28/2016 09:04:19 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[extract_status]
AS
BEGIN

DECLARE @statement3 INT
set @statement3 = (select  top 1 case result_value
			when 10 then 0
			when 20 then 0
			when 30 then 2
			when 40 then 2
			when 0 then 0
			else 2
			end 
 from post_process_run
where process_name = 'extract'
and datetime_begin > dateadd(d,-1,(LEft(GETDATE(),11)))
order by datetime_end desc
)
if @statement3 is null
begin 
	set @statement3 = 2
end
SELECT @statement3


 

enD
GO

/****** Object:  StoredProcedure [dbo].[mcipm_clean_extract_trans]    Script Date: 10/28/2016 09:04:19 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO



CREATE PROCEDURE [dbo].[mcipm_clean_extract_trans]
   @age 	INTEGER
AS
BEGIN
	DELETE FROM mcipm_extract_trans
	WHERE transmission_nr IN
		(SELECT transmission_nr 
		FROM mcipm_extract_transmission
		WHERE DATEDIFF(day, transmission_datetime, getdate()) > @age)		
END


GO

/****** Object:  StoredProcedure [dbo].[mcipm_extract_full_card_acceptor_mapping_info_record]    Script Date: 10/28/2016 09:04:19 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO



CREATE PROCEDURE [dbo].[mcipm_extract_full_card_acceptor_mapping_info_record]
	@card_acceptor_id				CHAR(15),
	@merchant_id					CHAR(6),
	@card_acceptor_name				VARCHAR(25),
	@street_address					VARCHAR(34),
	@city							VARCHAR(13),
	@postal_code					CHAR(10),
	@card_acceptor_tax_id			CHAR(20)
AS
BEGIN
	INSERT INTO mcipm_card_acceptor_mapping_info
	(
		card_acceptor_id,
		merchant_id,
		card_acceptor_name,
		street_address,
		city,
		postal_code,
		card_acceptor_tax_id
	)
	VALUES 
	(
		@card_acceptor_id, 
		@merchant_id,
		@card_acceptor_name, 
		@street_address, 
		@city, 
		@postal_code,
		@card_acceptor_tax_id
	)
END


GO

/****** Object:  StoredProcedure [dbo].[mcipm_extract_insert_file]    Script Date: 10/28/2016 09:04:19 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO



CREATE PROCEDURE [dbo].[mcipm_extract_insert_file]
   @transmission_nr 	BIGINT
AS
BEGIN

	--SET TRANSACTION ISOLATION LEVEL SERIALIZABLE

	BEGIN TRAN

	DECLARE @date_time DATETIME

	SELECT @date_time = (SELECT transmission_datetime 
							FROM mcipm_extract_transmission (NOLOCK)
							WHERE transmission_nr = @transmission_nr)
							
	DECLARE @file_nr INT

	SELECT @file_nr = ISNULL(
			(SELECT MAX(file_nr) 
				FROM mcipm_extract_file (TABLOCKX), mcipm_extract_transmission (NOLOCK) 
				WHERE 
					mcipm_extract_transmission.transmission_nr = mcipm_extract_file.transmission_nr AND	
					mcipm_extract_transmission.transmission_datetime BETWEEN @date_time - '23:59:59.999' AND @date_time + ' 23:59:59.999')
			, 0) + 1

	INSERT INTO mcipm_extract_file (file_nr, transmission_nr) VALUES (@file_nr,@transmission_nr)

	COMMIT TRAN

   RETURN @file_nr
END


GO

/****** Object:  StoredProcedure [dbo].[mcipm_extract_insert_transmission]    Script Date: 10/28/2016 09:04:19 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO



CREATE PROCEDURE [dbo].[mcipm_extract_insert_transmission]
	@date_time 	DATETIME,
	@session_id	INT
AS
BEGIN

	--SET TRANSACTION ISOLATION LEVEL SERIALIZABLE

	BEGIN TRAN

	DECLARE @transmission_nr BIGINT

	SELECT @transmission_nr = ISNULL((SELECT MAX(transmission_nr) FROM mcipm_extract_transmission (TABLOCKX)), 0) + 1

	DECLARE @sequence_nr INT

	SELECT @sequence_nr = ISNULL(
			(SELECT MAX(sequence_nr) 
				FROM mcipm_extract_transmission (TABLOCKX)
				WHERE transmission_datetime BETWEEN @date_time - '23:59:59.999' AND @date_time + ' 23:59:59.999')
			, 0) + 1

	INSERT INTO mcipm_extract_transmission (transmission_nr, sequence_nr, transmission_datetime, session_id) VALUES (@transmission_nr,@sequence_nr, @date_time, @session_id)

	COMMIT TRAN

   	SELECT transmission_nr, sequence_nr, transmission_datetime 
	FROM mcipm_extract_transmission
	WHERE transmission_nr=@transmission_nr
END


GO

/****** Object:  StoredProcedure [dbo].[mcipm_extract_specific_transmission]    Script Date: 10/28/2016 09:04:19 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO



CREATE PROCEDURE [dbo].[mcipm_extract_specific_transmission]
	@sequence_nr INT,
	@date_time DATETIME,
	@session_id INT
AS
BEGIN

	--SET TRANSACTION ISOLATION LEVEL SERIALIZABLE

	BEGIN TRAN

	DECLARE @transmission_nr BIGINT

	--Already been used for this sequence_nr
	SELECT @transmission_nr = ISNULL(
		(SELECT MAX(transmission_nr) 
		FROM mcipm_extract_transmission (TABLOCKX)
		WHERE transmission_datetime BETWEEN @date_time - '23:59:59.999' AND @date_time + ' 23:59:59.999'
			AND sequence_nr = @sequence_nr), -1)

	IF (@transmission_nr = -1)
	BEGIN
		--Create a new entry
		SELECT @transmission_nr =  (ISNULL((SELECT MAX(transmission_nr) FROM mcipm_extract_transmission (TABLOCKX)), 0) + 1)
	
		INSERT INTO mcipm_extract_transmission (transmission_nr, sequence_nr, transmission_datetime,session_id) VALUES (@transmission_nr,@sequence_nr, @date_time, @session_id)
	END 

	COMMIT TRAN

   	SELECT transmission_nr, sequence_nr,  transmission_datetime
	FROM mcipm_extract_transmission
	WHERE transmission_nr=@transmission_nr
END


GO

/****** Object:  StoredProcedure [dbo].[mcipm_extract_update_card_acceptor_mapping_info_record]    Script Date: 10/28/2016 09:04:19 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO



CREATE PROCEDURE [dbo].[mcipm_extract_update_card_acceptor_mapping_info_record]
	@active_ind					CHAR(1),
	@card_acceptor_id				CHAR(15),
	@merchant_id					CHAR(6),
	@card_acceptor_name				VARCHAR(25),
	@street_address					VARCHAR(34),
	@city						VARCHAR(21),
	@postal_code					CHAR(10),
	@card_acceptor_tax_id			CHAR(20)	
AS
BEGIN
	
	IF @active_ind = 'A'
	BEGIN
		IF EXISTS (SELECT * FROM mcipm_card_acceptor_mapping_info WHERE card_acceptor_id = @card_acceptor_id)

			BEGIN
				UPDATE 	mcipm_card_acceptor_mapping_info
				SET	merchant_id = @merchant_id,
					card_acceptor_name = @card_acceptor_name,
					street_address = @street_address,
					city = @city,
					postal_code = @postal_code,
					card_acceptor_tax_id = @card_acceptor_tax_id
				WHERE	card_acceptor_id = @card_acceptor_id

			END

			ELSE

			BEGIN
				INSERT INTO mcipm_card_acceptor_mapping_info 
				(
					card_acceptor_id, 
					merchant_id,
					card_acceptor_name, 
					street_address, 
					city, 
					postal_code,
					card_acceptor_tax_id
				) 
				VALUES 
				(
					@card_acceptor_id, 
					@merchant_id,
					@card_acceptor_name, 
					@street_address, 
					@city, 
					@postal_code,
					@card_acceptor_tax_id
				)

			END
	END
	ELSE
	BEGIN
		DELETE 	FROM mcipm_card_acceptor_mapping_info
		WHERE	card_acceptor_id = @card_acceptor_id
			
	END
END	


GO

/****** Object:  StoredProcedure [dbo].[mcipm_insert_extract_trans]    Script Date: 10/28/2016 09:04:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO



CREATE PROCEDURE [dbo].[mcipm_insert_extract_trans]
   @transmission_nr 	BIGINT,
   @file_id		CHAR(25),
   @message_nr		INTEGER,
   @post_tran_id	BIGINT,
   @acquirer_ref_no	CHAR(23),
   @ird			CHAR(2)
AS
BEGIN
	--SET TRANSACTION ISOLATION LEVEL SERIALIZABLE

	BEGIN TRAN

	INSERT INTO mcipm_extract_trans (transmission_nr, file_id, message_nr, post_tran_id, acquirer_ref_no, ird) 
		VALUES (@transmission_nr, @file_id, @message_nr, @post_tran_id, @acquirer_ref_no, @ird )

	COMMIT TRAN
END


GO

/****** Object:  StoredProcedure [dbo].[mcipm_post_tran_extract_exists]    Script Date: 10/28/2016 09:04:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO



CREATE PROCEDURE [dbo].[mcipm_post_tran_extract_exists]
AS
BEGIN
	IF EXISTS (SELECT 1 FROM sysobjects o WHERE  o.name = 'post_tran_extract' AND o.type = 'U')
	BEGIN
		SELECT 1
	END
	ELSE
	BEGIN
		SELECT 0
	END
END


GO

/****** Object:  StoredProcedure [dbo].[mcipm_update_post_tran_extract]    Script Date: 10/28/2016 09:04:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO



CREATE PROCEDURE [dbo].[mcipm_update_post_tran_extract]
	@post_tran_id				BIGINT, 
	@primary_file_reference		VARCHAR(32),
	@extr_extended_data			TEXT
AS
BEGIN
	IF EXISTS (SELECT 1 FROM sysobjects o WHERE  o.name = 'post_tran_extract' AND o.type = 'U')
	BEGIN
		IF EXISTS (SELECT 1 FROM post_tran_extract WHERE post_tran_id = @post_tran_id)
		BEGIN
			UPDATE post_tran_extract
			SET primary_file_reference = @primary_file_reference,
				 extr_extended_data = @extr_extended_data
			WHERE post_tran_id = @post_tran_id
		END
		ELSE
		BEGIN
			INSERT INTO post_tran_extract(post_tran_id, primary_file_reference, extr_extended_data)
			VALUES(@post_tran_id, @primary_file_reference, @extr_extended_data)
		END
	END
END


GO

/****** Object:  StoredProcedure [dbo].[opsp_tranqry_getextrextendeddata]    Script Date: 10/28/2016 09:04:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[opsp_tranqry_getextrextendeddata]
	@post_tran_id	BIGINT
AS
BEGIN
	SELECT
		extr_extended_data
	FROM
  		post_tran_extract WITH (NOLOCK)
	WHERE
		post_tran_id = @post_tran_id
END
 


GO

/****** Object:  StoredProcedure [dbo].[osp_cleaner_tran_post_tran_extract]    Script Date: 10/28/2016 09:04:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].[osp_cleaner_tran_post_tran_extract]
		@max_entry 		BIGINT,
		@throttle  INT,
		@batch_size INT,
		@total_delete INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON

   DECLARE @percentage_complete                    INT
	DECLARE @percent_denominator                    FLOAT
	DECLARE @report_string				VARCHAR(255)

	DECLARE @trace_flag				INT
	EXECUTE @trace_flag = osp_cleaner_tracing_enabled

	DECLARE @throttle_reference 	DATETIME
	SET @throttle_reference 	= null

	DECLARE @last_rowcount 		INT
   DECLARE @last_error 		INT
   DECLARE @current			BIGINT

   --If this is the case, then max has to be 0, which means there's nothing to delete.
   SELECT @current = ISNULL(MIN(post_tran_id),0) FROM post_tran_extract WITH (NOLOCK)

   SET @percent_denominator = (@max_entry - @current)*0.01

	SET @total_delete = 0

	exec osp_throttle @throttle, @throttle_reference output

	WHILE @current < @max_entry
	BEGIN
	   --Determine the upper bound for the segment window
	   DECLARE @t BIGINT
	   SET @t = (@current + @batch_size)
	   IF @t > @max_entry
			SET @t = @max_entry

		IF (NOT EXISTS(SELECT 1 FROM post_tran WITH (NOLOCK) WHERE post_tran_id >= @current AND post_tran_id <= @t ))
		BEGIN

			IF @trace_flag = 1
        		INSERT INTO cleaner_trace(description) VALUES ('post_tran_extract delete: '+cast(@current AS VARCHAR)+' to '+cast(@t AS VARCHAR))


         --Report the Current Activity
         IF @percent_denominator > 0
			BEGIN
            SET @percentage_complete = @total_delete/@percent_denominator
            SET @report_string = 'post_tran_extract: Deleting entries from '+cast(@current AS VARCHAR)+' to '+cast(@t AS VARCHAR) + ' (' + cast( @percentage_complete AS VARCHAR) + '% Done)'
			END
         ELSE
            SET @report_string = 'post_tran_extract: Deleting entries from '+cast(@current AS VARCHAR)+' to '+cast(@t AS VARCHAR)

         EXEC osp_report_activity @report_string

			BEGIN TRANSACTION

				DELETE FROM
						post_tran_extract WITH (ROWLOCK)
				WHERE
						post_tran_id >= @current
						AND
						post_tran_id <= @t

            SELECT @last_rowcount = @@ROWCOUNT, @last_error = @@ERROR

         COMMIT TRANSACTION

         IF (@last_error <> 0) -- an error occurred
         BEGIN
            RETURN
         END

         SET @total_delete = @total_delete + @last_rowcount

         IF @trace_flag = 1
            INSERT INTO cleaner_trace(description) VALUES ('post_tran_extract delete count: '+cast(@last_rowcount AS VARCHAR))

         IF (@last_rowcount = 0)
         BEGIN
            SELECT @current = ISNULL(MIN (post_tran_id), @max_entry) from post_tran_extract WITH (NOLOCK)
            WHERE post_tran_id > @t

            IF @trace_flag = 1
               INSERT INTO cleaner_trace(description) VALUES ('post_tran_extract: re-calculated next id: '+cast(@current AS VARCHAR))
         END
         ELSE
         BEGIN
            SET @current = @current + @batch_size + 1
         END

      END
      ELSE
      begin
         SET @current = @current + @batch_size + 1
      end

		EXEC osp_throttle @throttle, @throttle_reference output

	END  -- while

	SET NOCOUNT OFF

END

GO

/****** Object:  StoredProcedure [dbo].[osp_extr_reg_method]    Script Date: 10/28/2016 09:04:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].[osp_extr_reg_method]
	@name 		VARCHAR(40),
	@param_desc VARCHAR(50),
	@class_name VARCHAR (200)
	
AS
BEGIN
	DECLARE @id INT
	SET @id = NULL

	SELECT		
		@id = value
	FROM
		post_lookup
	WHERE
		category = 'extract_method_value'
		AND
		description = @name

	IF (@id IS NULL)
	BEGIN	
		SELECT 
			@id = MAX (value) + 1
		FROM
			post_lookup
		WHERE
			category = 'extract_method_value'

		IF (@id < 1000) SET @id = 1001
	END

	DECLARE @unique_name VARCHAR (61)
	SET @unique_name = 'EXTRACT METHOD:' + CAST (@id AS VARCHAR)
	
	--
	--
	--
	IF EXISTS (SELECT * FROM cfg_custom_classes WHERE unique_name = @unique_name)		
		UPDATE 
			cfg_custom_classes 
		SET
			class_name = @class_name
		WHERE 
			unique_name = @unique_name
	ELSE
		INSERT INTO 
			cfg_custom_classes (unique_name, category, display_name, class_name, parameters, description)
		VALUES
			(@unique_name, 'EXTRACT METHOD', @name, @class_name, NULL, NULL)
	
	--
	--
	--
	IF NOT EXISTS (SELECT * FROM post_lookup WHERE category = 'extract_method_value' AND value = @id)		
		INSERT INTO 
			post_lookup (category, value, description)
		VALUES
			('extract_method_value', @id, @name)

	
	--
	--
	--	
	IF EXISTS (SELECT * FROM post_lookup WHERE category = 'extract_method_param_desc' AND value = @id)		
		UPDATE
			post_lookup
		SET 
			description = @param_desc
		WHERE
			category = 'extract_method_param_desc'
			AND
			value = @id
	ELSE
		INSERT INTO 
			post_lookup (category, value, description)
		VALUES
			('extract_method_param_desc', @id, @param_desc)
	
END


GO

/****** Object:  StoredProcedure [dbo].[osp_extr_rem_method]    Script Date: 10/28/2016 09:04:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].[osp_extr_rem_method]
	@name 		VARCHAR(40)
	
AS
BEGIN
	DECLARE @id INT
	SET @id = NULL

	SELECT		
		@id = value
	FROM
		post_lookup
	WHERE
		category = 'extract_method_value'
		AND
		description = @name

	IF (@id IS NOT NULL)
	BEGIN			
		DECLARE @unique_name VARCHAR (61)
		SET @unique_name = 'EXTRACT METHOD:' + CAST (@id AS VARCHAR)
		DELETE FROM 
			cfg_custom_classes 
		WHERE 
			unique_name = @unique_name
	
		DELETE FROM
			post_lookup
		WHERE
			category = 'extract_method_value'
			AND
			value = @id

		DELETE FROM
			post_lookup
		WHERE
			category = 'extract_method_param_desc'
			AND
			value = @id	
	END
END


GO

/****** Object:  StoredProcedure [dbo].[osp_extract_cleaner]    Script Date: 10/28/2016 09:04:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO



CREATE PROCEDURE [dbo].[osp_extract_cleaner]
@session_id			INT,
@throttle			INT,
@batch_size			INT,
@nr_trans			INT OUTPUT
AS
BEGIN
	DECLARE @prev_session		INT
	DECLARE @deleted_rows		INT
	DECLARE @throttle_reference DATETIME
	
	SET ROWCOUNT @batch_size
	SET NOCOUNT ON

	SET @nr_trans = 0

	-- set up the throttle
	SET @throttle_reference = NULL
	EXEC osp_throttle @throttle, @throttle_reference OUTPUT	
	
	-- clean the current session
	-- delete transactions in current_session
	SET @deleted_rows = 1	
	WHILE @deleted_rows > 0
	BEGIN
		BEGIN TRANSACTION
			DELETE FROM
				extract_tran
			WHERE
				session_id = @session_id
			
			SET @deleted_rows = @@ROWCOUNT
		COMMIT TRANSACTION
		SET @nr_trans = @nr_trans + @deleted_rows
			
		-- allow other processes to run
		EXEC osp_throttle @throttle, @throttle_reference OUTPUT	
	END --WHILE
		
	-- delete current_session if it is not referenced by any transactions
	BEGIN TRANSACTION
		IF NOT EXISTS(SELECT 1 FROM extract_tran WHERE open_session_id = @session_id)
		BEGIN
			DELETE FROM
				extract_session
			WHERE
				session_id = @session_id
		END --IF
	COMMIT TRANSACTION
	SET NOCOUNT OFF
END --osp_extract_cleaner


GO

/****** Object:  StoredProcedure [dbo].[osp_extract_close_bd_all]    Script Date: 10/28/2016 09:04:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO



CREATE PROCEDURE [dbo].[osp_extract_close_bd_all]
AS
BEGIN
	SELECT MAX(settle_date)
	FROM 
		post_batch
	WHERE
		( NOT (datetime_end IS NULL))
END


GO

/****** Object:  StoredProcedure [dbo].[osp_extract_close_bd_srcsnk]    Script Date: 10/28/2016 09:04:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO



CREATE PROCEDURE [dbo].[osp_extract_close_bd_srcsnk]
	@for_all_sink_nodes NUMERIC(1,0)
AS
BEGIN
	SELECT MAX(settle_date)
	FROM 
		post_batch 
		JOIN post_settle_entity 
			ON post_batch.settle_entity_id = post_settle_entity.settle_entity_id
		JOIN post_online_node
			ON	post_settle_entity.node_name = post_online_node.office_node_name
	WHERE
		(post_online_node.is_sink_node = @for_all_sink_nodes AND NOT (datetime_end IS NULL))
END


GO

/****** Object:  StoredProcedure [dbo].[osp_extract_get_entity_parameters]    Script Date: 10/28/2016 09:04:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].[osp_extract_get_entity_parameters]
	@process_name   POST_NAME
AS
BEGIN
	SELECT 
		extract_entity.standard_output,
		extract_entity.user_param_list, 
		extract_plugin.plugin_id, 
		extract_plugin.extract_class_name, 
		extract_entity.method_value, 
		extract_entity.method_param_list, 
		extract_entity.entity_id,
		extract_entity.node_name_list_method,
		extract_entity.node_name_list ,
		extract_entity.extract_pan_in_clear,
		extract_entity.retention_period,
		extract_entity.standard_output_list,
		extract_entity.include_screened_only,
		extract_entity.screened_src_batches_only,
		extract_entity.screened_snk_batches_only,
		extract_entity.primary_extract_entity
	FROM
		extract_plugin WITH (NOLOCK), 
		extract_entity WITH (NOLOCK)
	WHERE 
		(extract_plugin.plugin_id = extract_entity.plugin_id) AND 
		(extract_entity.name = @process_name) 
END

GO

/****** Object:  StoredProcedure [dbo].[osp_extract_get_extract_entity_id]    Script Date: 10/28/2016 09:04:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO



CREATE PROCEDURE [dbo].[osp_extract_get_extract_entity_id]
	@entity_name            POST_NAME
AS
BEGIN   
	SELECT
		entity_id
	FROM
		extract_entity WITH (NOLOCK)
	WHERE
		extract_entity.name = @entity_name
END


GO

/****** Object:  StoredProcedure [dbo].[osp_extract_get_extracted]    Script Date: 10/28/2016 09:04:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].[osp_extract_get_extracted]
	@session_id INT
AS
BEGIN
	
	SELECT 
		post_tran.tran_nr, 
		post_tran.message_type, 
		post_tran.tran_postilion_originated,
		post_tran.online_system_id
	FROM
		post_tran
	INNER JOIN
		extract_tran
	ON
		post_tran.post_tran_id = extract_tran.post_tran_id
	WHERE
		extract_tran.session_id = @session_id
	AND
		(extract_tran.discarded IS NULL OR extract_tran.discarded = '0')
	ORDER BY
		post_tran.tran_nr, 
		post_tran.message_type, 
		post_tran.tran_postilion_originated,
		post_tran.online_system_id
	OPTION(RECOMPILE)
END

GO

/****** Object:  StoredProcedure [dbo].[osp_extract_get_last_batch_where]    Script Date: 10/28/2016 09:04:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].[osp_extract_get_last_batch_where]
	@node_where_clause 		VARCHAR(600)
AS
BEGIN
	EXEC(
		'SELECT MAX(settle_date) ' + 
		'FROM ' + 
			'post_batch JOIN post_settle_entity ' + 
			'ON post_batch.settle_entity_id = post_settle_entity.settle_entity_id ' + 
		'WHERE ' + 
			'(' + @node_where_clause + 
			' AND NOT datetime_end IS NULL)')
END


GO

/****** Object:  StoredProcedure [dbo].[osp_extract_get_last_closed_batch]    Script Date: 10/28/2016 09:04:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].[osp_extract_get_last_closed_batch]
	@node_name_list 		VARCHAR(400)
AS
BEGIN

	DECLARE @node_where_clause VARCHAR(600)
	SET @node_where_clause = ' '
	
	DECLARE @node_list 	VARCHAR (400)
	DECLARE @idx 				INT
	DECLARE @contin 		INT
	
	SET @contin = LEN(@node_name_list)
	SET @node_list = @node_name_list
	
	WHILE (@contin > 0)
	BEGIN
		SET @idx = CHARINDEX(',', @node_list)
		IF (@idx > 0)
		BEGIN
			IF (@idx - 1 > 0)
				SET @node_where_clause = 
					@node_where_clause + ' OR node_name = ''' +  (RTRIM(LTRIM(LEFT(@node_list, @idx - 1)))) + ''''
				
			SET @node_list = SUBSTRING(@node_list, @idx+1,255)
			SET @contin = LEN(@node_list)
		END
		ELSE
		BEGIN
			SET @node_where_clause = '( node_name = ''' + RTRIM(LTRIM(@node_list))+ '''' + @node_where_clause + ')'
			SET @node_list = ' '
			SET @contin = 0
		END
	END

	EXEC osp_extract_get_last_batch_where @node_where_clause
END


GO

/****** Object:  StoredProcedure [dbo].[osp_extract_get_last_completed_session]    Script Date: 10/28/2016 09:04:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO



CREATE PROCEDURE [dbo].[osp_extract_get_last_completed_session]
        @entity_id POST_ID
AS
BEGIN
	SELECT
		completed,
		session_id
	FROM 
		extract_session WITH (NOLOCK)
	WHERE
		(session_id = (SELECT MAX(session_id) FROM extract_session WHERE entity_id = @entity_id))
END


GO

/****** Object:  StoredProcedure [dbo].[osp_extract_get_last_post_tran_id]    Script Date: 10/28/2016 09:04:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].[osp_extract_get_last_post_tran_id]
	@norm_session_id INT,
	@last_post_tran_id BIGINT OUTPUT
AS
BEGIN
	SET @last_post_tran_id = NULL

	-- This proc will return the post_tran_id of the last
	-- leg copied in the Normalization session with ID
	-- @norm_session_id or NULL if no such session exists.

	DECLARE @first_post_tran_id BIGINT

	SELECT
		@first_post_tran_id = (first_post_tran_id - 1)
	FROM
		post_normalization_session
	WHERE
		normalization_session_id = @norm_session_id
	
	IF @first_post_tran_id IS NULL
	BEGIN
		RETURN
	END

	-- If @norm_session_id points to the last Normalization run, return
	-- MAX(post_tran_id), otherwise return the fist_post_tran_cust_id-1
	-- of the next Normalization session.

	SELECT
		@last_post_tran_id = (first_post_tran_id - 1)
	FROM
		post_normalization_session
	WHERE
		normalization_session_id = (@norm_session_id + 1)

	IF @last_post_tran_id IS NULL
	BEGIN

		SELECT
			@last_post_tran_id = MAX(post_tran_id)
		FROM
			post_tran
		WHERE
			post_tran_id >= @first_post_tran_id

		-- do another post_normalization_session check to avoid a race
		-- condition where a new Normalization session was started some
		-- time between doing the first query in the proc and now; in
		-- which case returning MAX(post_tran_id) could potentially be
		-- a post_tran_id value of a leg from a different Normalization
		-- session than the session with ID, @norm_session_id.
	 
		DECLARE @new_last_post_tran_id BIGINT

		SELECT
			@new_last_post_tran_id = (first_post_tran_id - 1)
		FROM
			post_normalization_session
		WHERE
			normalization_session_id = (@norm_session_id + 1)

		IF @new_last_post_tran_id IS NOT NULL
		BEGIN
			SET @last_post_tran_id = @new_last_post_tran_id
		END
	END
END

GO

/****** Object:  StoredProcedure [dbo].[osp_extract_get_last_screened_norm_session]    Script Date: 10/28/2016 09:04:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].[osp_extract_get_last_screened_norm_session]
	@min_last_norm_session_id INT OUTPUT
AS
BEGIN

	-- The below query will find the last normalization session ID that all screening
	-- entities have screened successfully, i.e. the smallest value in the set of
	-- greatest last_norm_session_id's from each Screening entity. If one of the
	-- screening entities has never been run, does not have one completed run or
	-- only has NULL values in the last_norm_session_id column then NULL is returned.
	SET
		@min_last_norm_session_id =
	(SELECT TOP 1
		MAX(scr_ses.last_norm_session_id) AS scr_last_norm_session_id
	FROM 
		extract_entity ext_ent
		LEFT JOIN	-- all screening entities must be considered even those that have not
					-- been run or only has incomplete runs, so we do a left join.
		scr_session scr_ses
		ON
		ext_ent.entity_id = scr_ses.scr_entity_id
		LEFT JOIN  
		extract_session ext_ses
		ON
		scr_ses.scr_session_id = ext_ses.session_id
	WHERE
		ext_ent.plugin_id = 'Screening'
		AND
		(ext_ses.completed = 1 OR ext_ses.completed IS NULL)
	GROUP BY
		ext_ent.entity_id
	ORDER BY
		scr_last_norm_session_id ASC)	-- use ORDER BY ASC and TOP 1 instead of MIN because 
										-- the MIN function filters out NULL rows, which this
										-- query can return if there are Screening entities that
										-- have never been run or only has incomplete runs.
END

GO

/****** Object:  StoredProcedure [dbo].[osp_extract_get_max_datetime]    Script Date: 10/28/2016 09:04:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO



CREATE PROCEDURE [dbo].[osp_extract_get_max_datetime]
AS
BEGIN
	SELECT
		max(datetime_req) 
	FROM
		post_tran WITH (NOLOCK)
END


GO

/****** Object:  StoredProcedure [dbo].[osp_extract_get_max_post_tran_id]    Script Date: 10/28/2016 09:04:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO



CREATE PROCEDURE [dbo].[osp_extract_get_max_post_tran_id]
AS
BEGIN
	SELECT	MAX(post_tran_id)
	FROM	post_tran WITH (NOLOCK)
END


GO

/****** Object:  StoredProcedure [dbo].[osp_extract_get_sessions_to_clean]    Script Date: 10/28/2016 09:04:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO



CREATE PROCEDURE [dbo].[osp_extract_get_sessions_to_clean]
AS
BEGIN

	-- retrieve retention dates for each session
	SELECT
		extract_session.session_id,
		datetime_creation,
		DATEADD(day, -retention_period_cleaner, getdate()) AS retention_end_date
	INTO
		#tt
	FROM
		extract_session,
		extract_entity
	WHERE
		extract_session.entity_id = extract_entity.entity_id

	SELECT
		session_id
	FROM
		#tt
	WHERE
		(datetime_creation < retention_end_date)
	ORDER BY
		session_id ASC
END


GO

/****** Object:  StoredProcedure [dbo].[osp_extract_ins_tran_10]    Script Date: 10/28/2016 09:04:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO



CREATE PROCEDURE [dbo].[osp_extract_ins_tran_10]
	@session_id		INT,
	@is_open			TINYINT,
	@discarded		TINYINT,
	@list1			VARCHAR(8000),
	@list2			VARCHAR(8000),
	@list3			VARCHAR(8000),
	@list4			VARCHAR(8000),
	@list5			VARCHAR(8000),
	@list6			VARCHAR(8000),
	@list7			VARCHAR(8000),
	@list8			VARCHAR(8000),
	@list9			VARCHAR(8000),
	@list10			VARCHAR(8000),
	@rowcount		INT OUTPUT
AS
BEGIN
	-- NOTE: The @list* parameters are each a comma-separated list of numbers.
	-- The numbers come in pairs. The first of each pair is the 
	-- extract_tran_id and the second is the post_tran_id.
	SET NOCOUNT ON
	SET @rowcount = 0

	DECLARE @open_session_id INT

	IF @is_open <> 0
	BEGIN
		-- These rows are all open.
		-- We populate open_session_id.
		-- We leave session_id NULL and we leave discarded 0.
		SET @open_session_id = @session_id
		SET @session_id = NULL
		SET @discarded = 0
	END
	ELSE -- @is_open = 0
	BEGIN
		-- These rows are all closed immediately.
		-- We populate session_id and discarded.
		-- We leave open_session_id NULL.
		SET @open_session_id = NULL
	END

	DECLARE @list VARCHAR(8000)
	DECLARE @last_rowcount INT
	DECLARE @last_error INT

	DECLARE @i INT
	SET @i = 1

	WHILE @i <= 10
	BEGIN
		SET @list =
		CASE @i
			WHEN 1  THEN @list1
			WHEN 2  THEN @list2
			WHEN 3  THEN @list3
			WHEN 4  THEN @list4
			WHEN 5  THEN @list5
			WHEN 6  THEN @list6
			WHEN 7  THEN @list7
			WHEN 8  THEN @list8
			WHEN 9  THEN @list9
			WHEN 10 THEN @list10
		END

		IF @list IS NOT NULL
		BEGIN
			INSERT INTO extract_tran WITH (TABLOCKX, HOLDLOCK)
			(
				extract_tran_id,
				session_id,
				open_session_id,
				post_tran_id,
				discarded
			)
			SELECT
				item, -- extract_tran_id
				@session_id,
				@open_session_id,
				item_2, -- post_tran_id
				@discarded
			FROM dbo.ofn_split_list_2 (@list, ',')

			SELECT @last_rowcount = @@ROWCOUNT, @last_error = @@ERROR
			IF @last_error <> 0
			BEGIN
				RETURN
			END
			ELSE
			BEGIN
				SET @rowcount = @rowcount + @last_rowcount
			END
		END

		SET @i = @i + 1
	END
END


GO

/****** Object:  StoredProcedure [dbo].[osp_extract_insert_or_update_extract_tran]    Script Date: 10/28/2016 09:04:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO



CREATE PROCEDURE [dbo].[osp_extract_insert_or_update_extract_tran]
	@session_id			POST_ID,
	@post_tran_id		BIGINT,
	@is_open				TINYINT,
	@extract_tran_id 	BIGINT =  NULL,
	@discarded			TINYINT	= 0,
	@big_int				TINYINT, 
	@tran_count 		INT
AS
BEGIN
	BEGIN TRAN      

	IF @extract_tran_id IS NULL
	BEGIN	
		
		IF (@big_int = 0)
		BEGIN
			SELECT @extract_tran_id = ISNULL((SELECT max(extract_tran_id) FROM extract_tran WITH (TABLOCKX)),0)+1
		END
		ELSE
		BEGIN
			SELECT @extract_tran_id = @session_id*1000000000000 + @tran_count
		END
		
		IF (@is_open = 0)
		BEGIN
			INSERT INTO extract_tran (
				extract_tran_id,
				session_id,
				post_tran_id,
				discarded)
			VALUES (
				@extract_tran_id,
				@session_id,
				@post_tran_id,
				@discarded)
		END
		ELSE
		BEGIN
			INSERT INTO extract_tran (
				extract_tran_id,
				open_session_id,
				post_tran_id,
				discarded)
			VALUES (
				@extract_tran_id,
				@session_id,
				@post_tran_id,
				@discarded)
		END
	END
	ELSE
	BEGIN
		IF (@is_open = 0)
		BEGIN
			UPDATE extract_tran
			SET
				session_id = @session_id,
				discarded = @discarded
			WHERE
				extract_tran_id = @extract_tran_id
		END
	END

COMMIT TRAN

END


GO

/****** Object:  StoredProcedure [dbo].[osp_extract_insert_or_update_post_tran_extract]    Script Date: 10/28/2016 09:04:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO



CREATE PROCEDURE [dbo].[osp_extract_insert_or_update_post_tran_extract]
	@primary_extract_entity INT
AS
BEGIN
	BEGIN TRANSACTION
	DECLARE @post_tran_id BIGINT
	DECLARE @primary_file_reference VARCHAR(32)
	DECLARE @extr_extended_data VARCHAR(8000)
	DECLARE @cur_extr_extended_data VARCHAR(8000)
	
	DECLARE UpdateCursor CURSOR FOR
	SELECT post_tran_id, primary_file_reference, extr_extended_data
	FROM #temp_post_tran_extract WITH (NOLOCK)
	
	OPEN UpdateCursor

	FETCH NEXT FROM UpdateCursor INTO @post_tran_id, @primary_file_reference, @extr_extended_data

	WHILE @@FETCH_STATUS = 0
	BEGIN
		SELECT @cur_extr_extended_data = extr_extended_data FROM post_tran_extract WITH (TABLOCK XLOCK) WHERE post_tran_id = @post_tran_id
		IF (@@ROWCOUNT = 0)
		BEGIN
			IF (@primary_extract_entity = 1)
			BEGIN
				INSERT INTO post_tran_extract(post_tran_id, primary_file_reference, extr_extended_data)
				VALUES(@post_tran_id, @primary_file_reference, @extr_extended_data)
			END
			ELSE
			BEGIN
				INSERT INTO post_tran_extract(post_tran_id, extr_extended_data)
				VALUES(@post_tran_id, @extr_extended_data)
			END
		END
		ELSE
		BEGIN
			IF (@primary_extract_entity = 1)
			BEGIN
				EXEC osp_extract_update_post_tran_extract_extended_data @cur_extr_extended_data, @extr_extended_data, @post_tran_id
				UPDATE post_tran_extract
				SET primary_file_reference = @primary_file_reference
				WHERE post_tran_id = @post_tran_id
			END
			ELSE
			BEGIN
				EXEC osp_extract_update_post_tran_extract_extended_data @cur_extr_extended_data, @extr_extended_data, @post_tran_id
			END
		END
		-- get next record
		FETCH NEXT FROM UpdateCursor INTO @post_tran_id, @primary_file_reference, @extr_extended_data
	END	-- end of WHILE

	CLOSE UpdateCursor
	DEALLOCATE UpdateCursor
	COMMIT TRANSACTION
END
GRANT EXECUTE ON osp_extract_insert_or_update_post_tran_extract TO postilion


GO

/****** Object:  StoredProcedure [dbo].[osp_extract_insert_session]    Script Date: 10/28/2016 09:04:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO



CREATE PROCEDURE [dbo].[osp_extract_insert_session]
   @entity_id   POST_ID
AS
BEGIN

        --SET TRANSACTION ISOLATION LEVEL SERIALIZABLE

        BEGIN TRAN

        DECLARE @session_id INT

        SELECT @session_id = ISNULL((SELECT MAX(session_id) FROM extract_session WITH (TABLOCKX)), 0) + 1

        INSERT INTO extract_session (session_id, entity_id, output, completed) VALUES (@session_id,@entity_id,'',0)

        COMMIT TRAN

   RETURN @session_id
END


GO

/****** Object:  StoredProcedure [dbo].[osp_extract_rollback_session]    Script Date: 10/28/2016 09:04:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].[osp_extract_rollback_session]
	@session_id     POST_ID,
	@segment_size	INT
AS
BEGIN
	DECLARE
		@exec_str			VARCHAR(3000),
		@status				INT,
		@rows_affected		INT,
		@last_error			INT,
		@counter			INT,
		@entity_id			POST_ID


	-- Status = OK
	SELECT @status = 0

	IF(@status = 0)
	BEGIN
		-- Delete extract_tran open in this session
		SELECT @exec_str = 	'DELETE extract_tran ' + 
							'FROM (SELECT TOP ' + CONVERT(VARCHAR,@segment_size) + ' extract_tran.extract_tran_id ' +
								  'FROM extract_tran ' + 
								  'WHERE open_session_id = ' + CONVERT(VARCHAR,@session_id) + ') ' +
							'AS New_Table ' + 
							'WHERE (extract_tran.extract_tran_id = New_Table.extract_tran_id)'            
		--Initialize the counter
		SELECT @counter = 1

		WHILE @counter <> 0
		BEGIN 
			EXEC(@exec_str)
			SELECT @counter = @@rowcount, @last_error = @@error

			IF (@last_error<>0)
			BEGIN
				SELECT @status = 1
			END
		END
	END

	IF(@status = 0)
	BEGIN
		-- Delete extract_tran closed in this session and not open in other sessions
		SELECT @exec_str = 	'DELETE extract_tran ' +
							'FROM (SELECT TOP ' + CONVERT(VARCHAR,@segment_size) + ' extract_tran.extract_tran_id ' +
								  'FROM extract_tran ' +
								  'WHERE open_session_id IS NULL AND '+
										'session_id = ' + CONVERT(VARCHAR,@session_id)+ ') ' +
							'AS New_Table '+
							'WHERE (extract_tran.extract_tran_id = New_Table.extract_tran_id)'

		--Initialize the counter
		SELECT @counter = 1

		WHILE @counter <> 0
		BEGIN
			EXEC(@exec_str)
			SELECT @counter = @@rowcount, @last_error = @@error

			IF (@last_error<>0)
			BEGIN
				SELECT @status = 1
			END
		END
	END

	IF(@status = 0)
	BEGIN
		-- Update extract_tran closed in this session but open in another session
		SELECT @exec_str = 	'UPDATE extract_tran ' +
							'SET session_id = NULL, discarded = NULL ' + 
							'FROM (SELECT TOP ' + CONVERT(VARCHAR,@segment_size) + ' extract_tran.extract_tran_id ' +
								  'FROM extract_tran ' +
								  'WHERE session_id = ' + CONVERT(VARCHAR,@session_id)+ ') ' +
							'AS New_Table '+
							'WHERE (extract_tran.extract_tran_id = New_Table.extract_tran_id)'

		--Initialize the counter
		SELECT @counter = 1

		WHILE @counter <> 0
		BEGIN
			EXEC(@exec_str)
			SELECT @counter = @@rowcount, @last_error = @@error

			IF (@last_error<>0)
			BEGIN
				SELECT @status = 1
			END
		END
	END

	IF (@status = 0)
	BEGIN

		SELECT @entity_id = entity_id FROM extract_session WHERE session_id =@session_id
		IF (@@error<>0)
		BEGIN
			SELECT @status = 1
		END
		ELSE
		BEGIN
			IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('extract_temp_tran_id_table_' + CONVERT(VARCHAR,@entity_id))) 
			BEGIN 
				SELECT @exec_str = 'DROP TABLE extract_temp_tran_id_table_' + CONVERT(VARCHAR,@entity_id)
				
				EXEC(@exec_str)
		
				IF (@@error<>0)
				BEGIN
					SELECT @status = 1
				END
			END
		END		
	END
	
	IF(@status = 0)
	BEGIN
		-- Delete extract_session
		SELECT @exec_str = 	'DELETE extract_session ' +
							'WHERE extract_session.session_id = ' + CONVERT(VARCHAR,@session_id)
							
		EXEC(@exec_str)

		IF (@@error<>0)
		BEGIN
			SELECT @status = 1
		END
	END

	IF(@status = 0)
	BEGIN
		SELECT 0
	END
	ELSE
	BEGIN
		SELECT 1
	END
END

GO

/****** Object:  StoredProcedure [dbo].[osp_extract_tran_is_bigint]    Script Date: 10/28/2016 09:04:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO



CREATE PROCEDURE [dbo].[osp_extract_tran_is_bigint]
	@extract_tran_id_is_bigint INT OUTPUT
AS
BEGIN
	DECLARE @xtype INT
	SET @xtype = NULL
	
	SELECT @xtype = syscolumns.xtype 
	FROM syscolumns, sysobjects 
	WHERE sysobjects.name = 'extract_tran'
	AND syscolumns.name = 'extract_tran_id'
	AND sysobjects.id = syscolumns.id
	
	IF (@xtype IS NULL) 
	OR (@xtype = 127) -- BIGINT
	BEGIN
		SET @extract_tran_id_is_bigint = 1
	END
	ELSE
	BEGIN
		SET @extract_tran_id_is_bigint = 0
	END
END


GO

/****** Object:  StoredProcedure [dbo].[osp_extract_upd_tran_10]    Script Date: 10/28/2016 09:04:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO



CREATE PROCEDURE [dbo].[osp_extract_upd_tran_10]
	@session_id		INT,
	@discarded		TINYINT,
	@list1			VARCHAR(8000),
	@list2			VARCHAR(8000),
	@list3			VARCHAR(8000),
	@list4			VARCHAR(8000),
	@list5			VARCHAR(8000),
	@list6			VARCHAR(8000),
	@list7			VARCHAR(8000),
	@list8			VARCHAR(8000),
	@list9			VARCHAR(8000),
	@list10			VARCHAR(8000),
	@rowcount		INT OUTPUT
AS
BEGIN
	-- NOTE: The @list* parameters are each a comma-separated list of numbers.
	-- Each number is an extract_tran_id.
	SET NOCOUNT ON
	SET @rowcount = 0

	DECLARE @list VARCHAR(8000)
	DECLARE @last_rowcount INT
	DECLARE @last_error INT

	DECLARE @i INT
	SET @i = 1

	WHILE @i <= 10
	BEGIN
		SET @list =
		CASE @i
			WHEN 1  THEN @list1
			WHEN 2  THEN @list2
			WHEN 3  THEN @list3
			WHEN 4  THEN @list4
			WHEN 5  THEN @list5
			WHEN 6  THEN @list6
			WHEN 7  THEN @list7
			WHEN 8  THEN @list8
			WHEN 9  THEN @list9
			WHEN 10 THEN @list10
		END

		IF @list IS NOT NULL
		BEGIN
			UPDATE extract_tran WITH (TABLOCKX, HOLDLOCK)
			SET
				session_id = @session_id,
				discarded = @discarded
			WHERE
				extract_tran_id IN 
			(
				SELECT item 
				FROM dbo.ofn_split_list (@list, ',')
			)

			SELECT @last_rowcount = @@ROWCOUNT, @last_error = @@ERROR
			IF @last_error <> 0
			BEGIN
				RETURN
			END
			ELSE
			BEGIN
				SET @rowcount = @rowcount + @last_rowcount
			END
		END

		SET @i = @i + 1
	END
END


GO

/****** Object:  StoredProcedure [dbo].[osp_extract_update_post_tran_extract_extended_data]    Script Date: 10/28/2016 09:04:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO



CREATE PROCEDURE [dbo].[osp_extract_update_post_tran_extract_extended_data]
	@existing_ext_data VARCHAR(8000),
	@incoming_ext_data VARCHAR(8000),
	@post_tran_id BIGINT
AS
BEGIN
	DECLARE @length_of_length_indicator	INT
	DECLARE @length_indicator 		INT
	DECLARE @key_value_pairs VARCHAR(8000)
	SET @key_value_pairs = @existing_ext_data

	--temporary table to hold the existing key-value pairs
	CREATE TABLE #existing_key_value_pairs
	(
		existing_key			VARCHAR(4000) NOT NULL,
		existing_value			VARCHAR(4000) NOT NULL
	)

	--populate the above table with the existing values
	
	--parse the existing extended fields string and populate the temporary 'existing' table with this.
	DECLARE @offset INT
	SET @offset = 1

	WHILE(@offset < LEN(@key_value_pairs))
	BEGIN
		DECLARE @current_key VARCHAR(4000)
		DECLARE @current_value VARCHAR(8000)
		
		--get the next key
		SET @length_of_length_indicator = SUBSTRING(@key_value_pairs, @offset, 1)
		SET @offset = @offset + 1		
		SET @length_indicator = SUBSTRING(@key_value_pairs, @offset, @length_of_length_indicator)
		SET @offset = @offset + @length_of_length_indicator
		SET @current_key = SUBSTRING(@key_value_pairs, @offset, @length_indicator)
		SET @offset = @offset + @length_indicator

		--get the value for this key
		SET @length_of_length_indicator = SUBSTRING(@key_value_pairs, @offset, 1)
		SET @offset = @offset + 1
		SET @length_indicator = SUBSTRING(@key_value_pairs, @offset, @length_of_length_indicator)
		SET @offset = @offset + @length_of_length_indicator
		SET @current_value = SUBSTRING(@key_value_pairs, @offset, @length_indicator)
		SET @offset = @offset + @length_indicator

		INSERT INTO #existing_key_value_pairs(existing_key, existing_value) VALUES(@current_key, @current_value)
	END

	--retrieve the incoming extended fields  and parse it into another temporary table
	
	CREATE TABLE #incoming_key_value_pairs
	(
		incoming_key			VARCHAR(4000) NOT NULL,
		incoming_value			VARCHAR(4000) NOT NULL
	)

	SET @key_value_pairs = @incoming_ext_data
	
	--parse the incoming key-value pairs and insert this into the temporary 'incoming' table
	SET @offset = 1
	WHILE(@offset < LEN(@key_value_pairs))
	BEGIN
		DECLARE @incoming_key VARCHAR(4000)
		DECLARE @incoming_value VARCHAR(8000)
		
		--get the next key
		SET @length_of_length_indicator = SUBSTRING(@key_value_pairs, @offset, 1)
		SET @offset = @offset + 1		
		SET @length_indicator = SUBSTRING(@key_value_pairs, @offset, @length_of_length_indicator)
		SET @offset = @offset + @length_of_length_indicator
		SET @incoming_key = SUBSTRING(@key_value_pairs, @offset, @length_indicator)
		SET @offset = @offset + @length_indicator

		--get the value for this key
		SET @length_of_length_indicator = SUBSTRING(@key_value_pairs, @offset, 1)
		SET @offset = @offset + 1
		SET @length_indicator = SUBSTRING(@key_value_pairs, @offset, @length_of_length_indicator)
		SET @offset = @offset + @length_of_length_indicator
		SET @incoming_value = SUBSTRING(@key_value_pairs, @offset, @length_indicator)
		SET @offset = @offset + @length_indicator

		INSERT INTO #incoming_key_value_pairs(incoming_key, incoming_value) VALUES(@incoming_key, @incoming_value)
	END
	
	--for each incoming key-value pair, establish if that key already exists...if so, update the value
	--if it does not exist, then insert the key
	DECLARE IncomingKeyValueCursor CURSOR FOR
	SELECT incoming_key, incoming_value
	FROM #incoming_key_value_pairs WITH (NOLOCK)
	
	OPEN IncomingKeyValueCursor

	FETCH NEXT FROM IncomingKeyValueCursor INTO @current_key, @current_value

	WHILE @@FETCH_STATUS = 0
	BEGIN
		--does this key exist already, if so update the value
		
		IF EXISTS(SELECT 1 FROM #existing_key_value_pairs WHERE existing_key = @current_key)
		BEGIN
			--the key already exists...
			UPDATE #existing_key_value_pairs
			SET existing_value = @current_value
			WHERE existing_key = @current_key
		END
		ELSE	--this key does not exist, insert the value into the table
		BEGIN
			INSERT INTO 
				#existing_key_value_pairs
				(
					existing_key,
					existing_value
				)
				VALUES
				(
					@current_key,
					@current_value
				)
		END
		-- get next record
		FETCH NEXT FROM IncomingKeyValueCursor INTO @current_key, @current_value
	END	-- end of WHILE
	
	CLOSE IncomingKeyValueCursor
	DEALLOCATE IncomingKeyValueCursor	

	--reconstruct the extended fields string from the combined table contents
	SET @key_value_pairs = ''
	
	DECLARE ExistingKeyValueCursor CURSOR FOR
	SELECT existing_key, existing_value
	FROM #existing_key_value_pairs WITH (NOLOCK)
	
	OPEN ExistingKeyValueCursor

	FETCH NEXT FROM ExistingKeyValueCursor INTO @current_key, @current_value

	WHILE @@FETCH_STATUS = 0
	BEGIN
		DECLARE @key_length_indicator					VARCHAR(50)
		DECLARE @key_length_of_length_indicator 	VARCHAR(5)
		DECLARE @value_length_indicator				VARCHAR(50)
		DECLARE @value_length_of_length_indicator	VARCHAR(5)
		
		--construct the various length indicators for this field
		SET @key_length_indicator = CONVERT(VARCHAR, LEN(@current_key))
		SET @key_length_of_length_indicator = CONVERT(VARCHAR, LEN(CONVERT(VARCHAR, LEN(@current_key))))
		SET @value_length_indicator = CONVERT(VARCHAR, LEN(@current_value))
		SET @value_length_of_length_indicator =  CONVERT(VARCHAR, LEN(CONVERT(VARCHAR, LEN(@current_value))))

		SET @key_value_pairs = @key_value_pairs + @key_length_of_length_indicator + @key_length_indicator + @current_key + @value_length_of_length_indicator + @value_length_indicator + @current_value

		-- get next record
		FETCH NEXT FROM ExistingKeyValueCursor INTO @current_key, @current_value
	END	-- end of WHILE

	CLOSE ExistingKeyValueCursor
	DEALLOCATE ExistingKeyValueCursor
	
	UPDATE post_tran_extract
	SET extr_extended_data = @key_value_pairs
	WHERE post_tran_id = @post_tran_id
	
	--clean up
	DROP TABLE #incoming_key_value_pairs
	DROP TABLE #existing_key_value_pairs
END


GO

/****** Object:  StoredProcedure [dbo].[osp_framework_cs_extended_tran_type_description]    Script Date: 10/28/2016 09:04:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO




CREATE PROCEDURE [dbo].[osp_framework_cs_extended_tran_type_description]
	@tran_type	CHAR (2),
	@extended_tran_type	CHAR (4),
	@display_indicator	INT 					-- 0 = Grid, 1 - Detail Dialog

AS
BEGIN
	DECLARE @tt		VARCHAR (60)
	DECLARE @ett	VARCHAR (60)

	IF (@display_indicator = 0)
	BEGIN
		SET @tt = dbo.formatTranTypeStr(@tran_type, @extended_tran_type, NULL)
		SET @ett = ''
	END
	ELSE
	BEGIN
		SELECT
			@tt = description
		FROM
			post_tran_types

		WHERE
			code = @tran_type

		SELECT
			@ett = description
		FROM
			post_tran_types

		WHERE
			code = @extended_tran_type
	END

	SELECT @tt, @ett
END


GO

/****** Object:  StoredProcedure [dbo].[osp_norm_ext_field_create]    Script Date: 10/28/2016 09:04:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


-------------------------------------------------------------------------------
--Creating proc to add custom field extensions for generic normalization'
--------------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[osp_norm_ext_field_create] 
	@column_name VARCHAR(30),
	@column_size INT
AS
BEGIN
	DECLARE @SQL nvarchar(500)
	SET @SQL ='IF NOT EXISTS (SELECT * FROM syscolumns '+
		'WHERE id = object_id(N''[dbo].[post_tran]'') AND name = ''' +	@column_name + ''') '+
		'BEGIN ALTER TABLE [dbo].[post_tran] ADD ' + 
			@column_name+ ' VARCHAR (' + CAST(@column_size AS VARCHAR) + ') NULL ' + 'END'			
	EXEC(@SQL)
END

GO

/****** Object:  StoredProcedure [dbo].[osp_norm_ext_field_drop]    Script Date: 10/28/2016 09:04:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


-------------------------------------------------------------------------------
--Creating proc to remove custom field extensions for generic normalization'
--------------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[osp_norm_ext_field_drop] 
	@column_name VARCHAR(30)
AS
BEGIN
	DECLARE @SQL nvarchar(500)
	SET @SQL = 'IF EXISTS(SELECT * FROM syscolumns '+
		'WHERE id = object_id(N''[dbo].[post_tran]'') AND name = ''' +	@column_name + ''') '+
		'BEGIN ALTER TABLE [dbo].[post_tran] DROP COLUMN ' + @column_name + ' END'	
	EXEC(@SQL)	
END

GO

/****** Object:  StoredProcedure [dbo].[osp_norm_rerun_update_next_post_tran]    Script Date: 10/28/2016 09:04:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO



CREATE PROCEDURE [dbo].[osp_norm_rerun_update_next_post_tran]
	@post_tran_id			BIGINT,
	@prev_post_tran_id	BIGINT,
							@prev_tran_approved	INT
AS
BEGIN

		-- During Normalization reruns, we need to set the prev_post_tran_id of the
		-- next leg to the newly inserted / updated leg. This also allow for the current
		-- leg to be re-touched by the trigger on the post_tran table

		-- HEAT 763301
		-- If the previous transaction was not a financial one, we mustn't update the
		-- prev_tran_approved field. This field dictates whether the previous 
		-- financial transaction was approved.

		DECLARE @message_type CHAR (4)
		
		SELECT 
			@message_type = message_type
		FROM
			post_tran WITH (NOLOCK)
		WHERE
			post_tran_id = @prev_post_tran_id

		IF (dbo.fn_isFinancialTran(@message_type) = 1)
		BEGIN
			UPDATE
					post_tran
			SET
					prev_post_tran_id = @prev_post_tran_id,
					prev_tran_approved = @prev_tran_approved
			WHERE		
					post_tran_id = @post_tran_id
		END
		ELSE
		BEGIN
			UPDATE
					post_tran
			SET
					prev_post_tran_id = @prev_post_tran_id
			WHERE		
					post_tran_id = @post_tran_id
		END

END


GO

/****** Object:  StoredProcedure [dbo].[osp_patch_get_rb_text]    Script Date: 10/28/2016 09:04:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].[osp_patch_get_rb_text]
	@action	VARCHAR(8000),
	@text VARCHAR(8000) OUTPUT
AS
BEGIN
	SET @text = NULL
	
	DECLARE @patch VARCHAR(8000)
	EXEC osp_patch_get_curr @patch OUTPUT
	IF @@ERROR <> 0 RETURN
	
	SELECT @text = [text]
	FROM post_patch_rb
	WHERE patch = @patch
	AND [action] = @action
END

GO

/****** Object:  StoredProcedure [dbo].[osp_recon_cs_qry_external_only]    Script Date: 10/28/2016 09:04:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].[osp_recon_cs_qry_external_only]
	@entity_id						POST_ID,
	@session_id						POST_ID = NULL,
	@external_file_source_id	POST_ID = NULL,
	@hide_resolved					INT = NULL,
	@resolution_state_code		INT = NULL,
	@show_matched					INT = NULL,
	@external_tran_id				BIGINT = NULL,
	@pan								VARCHAR(19) = NULL,
	@pan_reference					CHAR(42) = NULL,
	@datetime_tran_local_from	DATETIME	= NULL,
	@datetime_tran_local_to		DATETIME = NULL,
	@card_acceptor_id_code		CHAR(15) = NULL,
	@terminal_id					CHAR(8) = NULL,
	@system_trace_audit_nr		CHAR(6) = NULL,
	@max_result_rows				INT = NULL,
	@total_row_count				INT = NULL OUTPUT
AS
BEGIN
	DECLARE @external_tran_table_name VARCHAR(64)
	SELECT
		@external_tran_table_name = 'external_tran_' + recon_plugin.table_name_extension
	FROM
		recon_entity WITH (NOLOCK)
	INNER JOIN
		recon_plugin WITH (NOLOCK)
	ON
		recon_plugin.plugin_id = recon_entity.plugin_id
	WHERE
		recon_entity.entity_id = @entity_id

	DECLARE @sql_fields NVARCHAR(4000)	
	SET @sql_fields = N'
			reo.state_value AS po_state_value,
			reo.session_id AS po_session_id,
			CAST(reo.external_tran_id AS BIGINT) AS po_external_tran_id,
			reo.notes AS po_notes,
			reo.match_session_id AS po_match_session_id,
			reo.is_resolved AS po_is_resolved,
			reo.resolution_state_code AS po_resolution_state_code,
			reo.external_file_source_id AS po_external_file_source_id,
			reo.external_file_id AS po_external_file_id,
			ref.filename AS po_filename'

	DECLARE @sql_from NVARCHAR(4000)	
	SET @sql_from = N'
		FROM recon_external_only reo WITH (NOLOCK)
		LEFT JOIN ' + @external_tran_table_name + ' et WITH (NOLOCK)
		ON et.external_tran_id = reo.external_tran_id
		LEFT JOIN recon_external_file ref WITH (NOLOCK)
		ON ref.external_file_id = reo.external_file_id
		AND ref.entity_id = reo.entity_id'

	DECLARE @sql_where NVARCHAR(4000)	
	SET @sql_where = N'
		WHERE'

	DECLARE @sql_pan_where_1 NVARCHAR(4000)	
	DECLARE @sql_pan_where_2 NVARCHAR(4000)	
	SET @sql_pan_where_1 = N''
	SET @sql_pan_where_2 = N''

	-- Do not filter on entity_id if filtering on session_id
	IF @session_id IS NULL
	BEGIN
		SET @sql_where = @sql_where + N' reo.entity_id = @entity_id'
 		-- In order to support legacy recon sessions, where entity_id is NULL.
 		-- This will decrease query performance.
		-- SET @sql_where = @sql_where + N'
		-- 	reo.entity_id IN (SELECT session_id FROM recon_session WHERE entity_id = @entity_id)'
	END

	ELSE
	BEGIN
		SET @sql_where = @sql_where + N' (1=1)'
	END



	IF @session_id IS NOT NULL
	BEGIN
		IF @show_matched IS NOT NULL AND @show_matched > 0
		BEGIN
			SET @sql_where = @sql_where + N'
		AND
		(
			reo.session_id = @session_id
			OR reo.match_session_id = @session_id
		)'
		END
		ELSE
		BEGIN
			SET @sql_where = @sql_where + N'
		AND reo.session_id = @session_id'
		END
	END
	ELSE
	BEGIN
		IF @show_matched IS NULL OR @show_matched = 0
		BEGIN
			SET @sql_where = @sql_where + N'
		AND reo.match_session_id IS NULL'
		END
	END

	IF @external_file_source_id IS NOT NULL
	BEGIN
		SET @sql_where = @sql_where + N'
		AND reo.external_file_source_id = @external_file_source_id'
	END

	IF @hide_resolved IS NOT NULL AND @hide_resolved > 0
	BEGIN
		SET @sql_where = @sql_where + N'
		AND ISNULL(reo.is_resolved, 0) = 0
		AND reo.match_session_id IS NULL'
	END

	IF @resolution_state_code IS NOT NULL
	BEGIN
		SET @sql_where = @sql_where + N'
		AND reo.resolution_state_code = @resolution_state_code'
	END

	IF @external_tran_id IS NOT NULL
	BEGIN
		SET @sql_where = @sql_where + N'
		AND reo.external_tran_id = @external_tran_id'
	END

	IF (@pan_reference IS NOT NULL) OR (@pan IS NOT NULL)
	BEGIN
		IF @pan_reference IS NOT NULL
		BEGIN
			IF EXISTS
			(
				SELECT * 
				FROM syscolumns
	  			WHERE ID=object_id(@external_tran_table_name) 
				AND name='x_pan_reference'
			)
			BEGIN
				SET @sql_pan_where_1 = @sql_pan_where_1 + N'
		AND et.x_pan_reference = @pan_reference'
			END
		END

		IF @pan IS NOT NULL
		BEGIN
			IF EXISTS
			(
				SELECT * 
				FROM syscolumns
	  			WHERE ID=object_id(@external_tran_table_name) 
				AND name='x_pan'
			)
			BEGIN
				SET @sql_pan_where_2 = @sql_pan_where_2 + N'
		AND et.x_pan = @pan'
			END
		END

		IF (LEN(@sql_pan_where_1) = 0) AND (LEN(@sql_pan_where_2) > 0)
		BEGIN
			SET @sql_pan_where_1 = @sql_pan_where_2
			SET @sql_pan_where_2 = N''
		END
	END

	IF @datetime_tran_local_from IS NOT NULL AND @datetime_tran_local_to IS NOT NULL
	BEGIN
		IF EXISTS
		(
			SELECT * 
			FROM syscolumns
  			WHERE ID=object_id(@external_tran_table_name) 
			AND name='x_datetime'
		)
		BEGIN
			SET @sql_where = @sql_where + N'
		AND et.x_datetime >= @datetime_tran_local_from
		AND et.x_datetime < @datetime_tran_local_to'
		END
	END

	IF @card_acceptor_id_code IS NOT NULL
	BEGIN
		IF EXISTS
		(
			SELECT * 
			FROM syscolumns
  			WHERE ID=object_id(@external_tran_table_name) 
			AND name='x_card_acceptor_id'
		)
		BEGIN
			SET @sql_where = @sql_where + N'
		AND et.x_card_acceptor_id = @card_acceptor_id_code'
		END
	END

	IF @terminal_id IS NOT NULL
	BEGIN
		IF EXISTS
		(
			SELECT * 
			FROM syscolumns
  			WHERE ID=object_id(@external_tran_table_name) 
			AND name='x_terminal_id'
		)
		BEGIN
			SET @sql_where = @sql_where + N'
		AND et.x_terminal_id = @terminal_id'
		END
	END

	IF @system_trace_audit_nr IS NOT NULL
	BEGIN
		IF EXISTS
		(
			SELECT * 
			FROM syscolumns
  			WHERE ID=object_id(@external_tran_table_name) 
			AND name='x_reference_nr'
		)
		BEGIN
			SET @sql_where = @sql_where + N'
		AND et.x_reference_nr = @system_trace_audit_nr'
		END
	END

	DECLARE @sql_order_by NVARCHAR(4000)	
	SET @sql_order_by = N'
		ORDER BY reo.external_tran_id'

	DECLARE @sql NVARCHAR(4000)

	IF LEN(@sql_pan_where_2) = 0
	BEGIN
		SET @sql = N'
			SELECT @total_row_count = COUNT(*)' +
			@sql_from +
			@sql_where +
			@sql_pan_where_1
	END
	ELSE
	BEGIN
		SET @sql = N'
	SELECT @total_row_count = COUNT(*)
	FROM
	(
		SELECT
			reo.external_tran_id' +
		@sql_from +
		@sql_where +
		@sql_pan_where_1 + '
		UNION
		SELECT
			reo.external_tran_id' +
		@sql_from +
		@sql_where +
		@sql_pan_where_2 + '
	)
	AS subquery'
	END

	EXEC sp_executesql
		@sql,
		N'
		@total_row_count				INT OUTPUT,
		@entity_id						INT,
		@session_id						INT,
		@external_file_source_id	INT,
		@hide_resolved					INT,
		@resolution_state_code		INT,
		@external_tran_id				BIGINT,
		@pan								VARCHAR(19),
		@pan_reference					CHAR(42),
		@datetime_tran_local_from	DATETIME,
		@datetime_tran_local_to		DATETIME,
		@card_acceptor_id_code		CHAR(15),
		@terminal_id					CHAR(8),
		@system_trace_audit_nr		CHAR(6)',
		@total_row_count = @total_row_count OUTPUT,
		@entity_id = @entity_id,
		@session_id = @session_id,
		@external_file_source_id = @external_file_source_id,
		@hide_resolved = @hide_resolved,
		@resolution_state_code = @resolution_state_code,
		@external_tran_id = @external_tran_id,
		@pan = @pan,
		@pan_reference = @pan_reference,
		@datetime_tran_local_from = @datetime_tran_local_from,
		@datetime_tran_local_to = @datetime_tran_local_to,
		@card_acceptor_id_code = @card_acceptor_id_code,
		@terminal_id = @terminal_id,
		@system_trace_audit_nr = @system_trace_audit_nr

	DECLARE @sql_top NVARCHAR(4000)

	IF @max_result_rows IS NOT NULL
	BEGIN
		SET @sql_top = N'
		TOP ' + CAST(@max_result_rows AS NVARCHAR)
	END
	ELSE
	BEGIN
		SET @sql_top = ''
	END

	IF LEN(@sql_pan_where_2) = 0
	BEGIN
		SET @sql = N'
		SELECT' + 
		@sql_top +
		@sql_fields + ',
		et.*' +
		@sql_from +
		@sql_where +
		@sql_pan_where_1 +
		@sql_order_by
	END
	ELSE
	BEGIN
		SET @sql = N'
	SELECT' + 
		@sql_top + '
		subquery.*,
		et.*
	FROM
	(
		SELECT' +
		@sql_fields +
		@sql_from +
		@sql_where +
		@sql_pan_where_1 + '
		UNION
		SELECT' + 
		@sql_fields +
		@sql_from +
		@sql_where +
		@sql_pan_where_2 + '
	)
	AS subquery
	INNER JOIN ' + @external_tran_table_name + ' et WITH (NOLOCK)
	ON et.external_tran_id = subquery.po_external_tran_id
	ORDER BY subquery.po_external_tran_id' 
	END

	EXEC sp_executesql
		@sql,
		N'
		@entity_id						INT,
		@session_id						INT,
		@external_file_source_id	INT,
		@hide_resolved					INT,
		@resolution_state_code		INT,
		@external_tran_id				BIGINT,
		@pan								VARCHAR(19),
		@pan_reference					CHAR(42),
		@datetime_tran_local_from	DATETIME,
		@datetime_tran_local_to		DATETIME,
		@card_acceptor_id_code		CHAR(15),
		@terminal_id					CHAR(8),
		@system_trace_audit_nr		CHAR(6)',
		@entity_id = @entity_id,
		@session_id = @session_id,
		@external_file_source_id = @external_file_source_id,
		@hide_resolved = @hide_resolved,
		@resolution_state_code = @resolution_state_code,
		@external_tran_id = @external_tran_id,
		@pan = @pan,
		@pan_reference = @pan_reference,
		@datetime_tran_local_from = @datetime_tran_local_from,
		@datetime_tran_local_to = @datetime_tran_local_to,
		@card_acceptor_id_code = @card_acceptor_id_code,
		@terminal_id = @terminal_id,
		@system_trace_audit_nr = @system_trace_audit_nr
END

GO

/****** Object:  StoredProcedure [dbo].[osp_recon_cs_qry_get_external_file_sources]    Script Date: 10/28/2016 09:04:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].[osp_recon_cs_qry_get_external_file_sources]
	@entity_id				POST_ID,
	@filter_is_active		INT = NULL,
	@filter_file_source	VARCHAR(100) = NULL,
	@max_result_rows		INT = NULL,
	@total_row_count		INT = NULL OUTPUT
AS
BEGIN
	DECLARE @sql_fields NVARCHAR(4000)	
	SET @sql_fields = N'
			refs.external_file_source_id,
			refs.source_node_name,
			refs.sink_node_name,
			refs.acquiring_inst_id_code,
			refs.card_acceptor_id_code,
			refs.mapped_card_acceptor_id_code,
			refs.terminal_id,
			refs.custom_source,
			refs.description,
			refs.session_id,
			refs.datetime_added,
			refs.is_active,
			refs.mapped_terminal_id'

	DECLARE @sql_from NVARCHAR(4000)	
	SET @sql_from = N'
		FROM recon_external_file_source refs WITH (NOLOCK)'
	
	DECLARE @sql_where NVARCHAR(4000)	
	SET @sql_where = N'
		WHERE refs.entity_id = @entity_id'
	
	IF @filter_is_active IS NOT NULL
	BEGIN
		SET @sql_where = @sql_where + N'
		AND refs.is_active = @filter_is_active'
	END
	
	IF @filter_file_source IS NOT NULL AND LEN(@filter_file_source) > 0
	BEGIN
		SET @sql_where = @sql_where + N'
		AND
		(
			refs.source_node_name LIKE ''%'' + @filter_file_source + ''%''
			OR refs.sink_node_name LIKE ''%'' + @filter_file_source + ''%''
			OR refs.acquiring_inst_id_code LIKE ''%'' + @filter_file_source + ''%''
			OR refs.card_acceptor_id_code LIKE ''%'' + @filter_file_source + ''%''
			OR refs.mapped_card_acceptor_id_code LIKE ''%'' + @filter_file_source + ''%''
			OR refs.terminal_id LIKE ''%'' + @filter_file_source + ''%''
			OR refs.custom_source LIKE ''%'' + @filter_file_source + ''%''
			OR refs.mapped_terminal_id LIKE ''%'' + @filter_file_source + ''%''
		)'
	END
	
	DECLARE @sql_order_by NVARCHAR(4000)	
	SET @sql_order_by = N'
		ORDER BY
			refs.source_node_name,
			refs.sink_node_name,
			refs.acquiring_inst_id_code,
			refs.card_acceptor_id_code,
			refs.mapped_card_acceptor_id_code,
			refs.terminal_id,
			refs.custom_source,
			refs.mapped_terminal_id'
	
	DECLARE @sql NVARCHAR(4000)
	SET @sql = N'
		SELECT @total_row_count = COUNT(*)' +
		@sql_from	

	EXEC sp_executesql
		@sql, N'
		@total_row_count 			INT OUTPUT,
		@entity_id					INT,
		@filter_is_active			INT,
		@filter_file_source 		VARCHAR(100)',
		@total_row_count = @total_row_count OUTPUT,
		@entity_id = @entity_id,
		@filter_is_active = @filter_is_active,
		@filter_file_source = @filter_file_source

	IF @max_result_rows IS NOT NULL
	BEGIN
		SET @sql = N'
			SELECT TOP ' + CAST(@max_result_rows AS NVARCHAR) +
			@sql_fields +
			@sql_from +
			@sql_where +
			@sql_order_by
	END
	ELSE
	BEGIN
		SET @sql = N'
			SELECT' +
			@sql_fields +
			@sql_from +
			@sql_where +
			@sql_order_by
	END

	EXEC sp_executesql
		@sql, N'
		@entity_id					INT,
		@filter_is_active			INT,
		@filter_file_source 		VARCHAR(100)',
		@entity_id = @entity_id,
		@filter_is_active = @filter_is_active,
		@filter_file_source = @filter_file_source
END

GO

/****** Object:  StoredProcedure [dbo].[osp_recon_cs_qry_get_external_files]    Script Date: 10/28/2016 09:04:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].[osp_recon_cs_qry_get_external_files]
	@entity_id						POST_ID,
	@session_id						POST_ID = NULL,
	@external_file_source_id	INT = NULL,
	@filter_is_missing			INT = NULL,
	@filter_is_lost				INT = NULL,
	@file_date_from				DATETIME = NULL, 
	@file_date_to					DATETIME = NULL, 
	@filter_filename				VARCHAR(255) = NULL, 
	@max_result_rows				INT = NULL,
	@total_row_count				INT = NULL OUTPUT
AS
BEGIN
	DECLARE @sql_fields NVARCHAR(4000)	
	SET @sql_fields = N'
			ref.external_file_id,
			ref.external_file_source_id,
			ref.file_date,
			ref.file_seq_no,
			ref.missing_session_id,
			ref.session_id,
			ref.filename,
			ref.business_date_from,
			ref.business_date_to,
			ref.min_post_tran_id,
			ref.max_post_tran_id,
			ref.is_lost'

	DECLARE @sql_from NVARCHAR(4000)	
	SET @sql_from = N'
		FROM recon_external_file ref WITH (NOLOCK)'

	DECLARE @sql_where NVARCHAR(4000)	
	SET @sql_where = N'
		WHERE ref.entity_id = @entity_id'
	
	IF @session_id IS NOT NULL
	BEGIN
		SET @sql_where = @sql_where + N'
		AND
		(
			ref.session_id = @session_id
			OR ref.missing_session_id = @session_id
		)'
	END
	
	IF @external_file_source_id IS NOT NULL
	BEGIN
		SET @sql_where = @sql_where + N'
		AND ref.external_file_source_id = @external_file_source_id'
	END
	
	IF @filter_is_missing IS NOT NULL
	BEGIN
		IF @filter_is_missing = 0
		BEGIN
			SET @sql_where = @sql_where + N'
			AND ref.session_id IS NOT NULL'
		END
		ELSE
		BEGIN
			SET @sql_where = @sql_where + N'
			AND ref.session_id IS NULL'
		END
	END
	
	IF @filter_is_lost IS NOT NULL
	BEGIN
		SET @sql_where = @sql_where + N'
		AND ref.is_lost = @filter_is_lost'
	END
	
	IF @file_date_from IS NOT NULL AND @file_date_to IS NOT NULL
	BEGIN
		SET @sql_where = @sql_where + N'
		AND ref.file_date >= @file_date_from
		AND ref.file_date < @file_date_to'
	END

	IF @filter_filename IS NOT NULL
	BEGIN
		SET @sql_where = @sql_where + N'
		AND ref.filename LIKE ''%'' + @filter_filename + ''%'''
	END

	DECLARE @sql_order_by NVARCHAR(4000)	
	SET @sql_order_by = N'
		ORDER BY
			ref.file_date DESC,
			ref.file_seq_no DESC,
			ref.external_file_source_id ASC'
	
	DECLARE @sql NVARCHAR(4000)
	SET @sql = N'
		SELECT @total_row_count = COUNT(*)' +
		@sql_from +
		@sql_where	

	EXEC sp_executesql
		@sql, N'
		@total_row_count				INT OUTPUT,
		@entity_id						INT,
		@session_id						INT,
		@external_file_source_id	INT,
		@filter_is_lost				INT,
		@file_date_from				DATETIME, 
		@file_date_to					DATETIME, 
		@filter_filename				VARCHAR(255)',
		@total_row_count = @total_row_count OUTPUT,
		@entity_id = @entity_id,
		@session_id = @session_id,
		@external_file_source_id = @external_file_source_id,
		@filter_is_lost = @filter_is_lost,
		@file_date_from = @file_date_from, 
		@file_date_to = @file_date_to, 
		@filter_filename = @filter_filename

	IF @max_result_rows IS NOT NULL
	BEGIN
		SET @sql = N'
			SELECT TOP ' + CAST(@max_result_rows AS NVARCHAR) +
			@sql_fields +
			@sql_from +
			@sql_where +
			@sql_order_by
	END
	ELSE
	BEGIN
		SET @sql = N'
			SELECT' +
			@sql_fields +
			@sql_from +
			@sql_where +
			@sql_order_by
	END

	EXEC sp_executesql
		@sql, N'
		@entity_id						INT,
		@session_id						INT,
		@external_file_source_id	INT,
		@filter_is_lost				INT,
		@file_date_from				DATETIME, 
		@file_date_to					DATETIME, 
		@filter_filename				VARCHAR(255)',
		@entity_id = @entity_id,
		@session_id = @session_id,
		@external_file_source_id = @external_file_source_id,
		@filter_is_lost = @filter_is_lost,
		@file_date_from = @file_date_from, 
		@file_date_to = @file_date_to, 
		@filter_filename = @filter_filename
END

GO

/****** Object:  StoredProcedure [dbo].[osp_recon_insert_external_file_source]    Script Date: 10/28/2016 09:04:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].[osp_recon_insert_external_file_source]
   @entity_id							POST_ID,
   @granularity						INT,
	@source_node_name					POST_NAME,
	@sink_node_name					POST_NAME,
	@acquiring_inst_id_code			VARCHAR(11),
	@card_acceptor_id_code			CHAR(15),
	@mapped_card_acceptor_id_code	CHAR(15),
	@terminal_id						CHAR(8),
	@custom_source						VARCHAR(100),
	@description						VARCHAR(255),
	@session_id							POST_ID,
	@mapped_terminal_id				CHAR(8),
	@external_file_source_id		POST_ID OUTPUT,
	@datetime_added					DATETIME OUTPUT
AS
BEGIN
	BEGIN TRAN

	SELECT 
		@external_file_source_id = ISNULL((SELECT MAX(external_file_source_id) FROM recon_external_file_source (TABLOCKX)), 0) + 1

	SET @datetime_added = GETDATE()

	INSERT INTO 
		recon_external_file_source
	(
		external_file_source_id,
		entity_id, 
		granularity,
		source_node_name, 
		sink_node_name, 
		acquiring_inst_id_code, 
		card_acceptor_id_code, 
		mapped_card_acceptor_id_code, 
		terminal_id,
		custom_source,
		description,
		session_id,
		datetime_added,
		mapped_terminal_id	
	)
	VALUES 
	(
		@external_file_source_id,
		@entity_id,
		@granularity,
		@source_node_name, 
		@sink_node_name, 
		@acquiring_inst_id_code, 
		@card_acceptor_id_code, 
		@mapped_card_acceptor_id_code, 
		@terminal_id,
		@custom_source,
		@description,
		@session_id,
		@datetime_added,
		@mapped_terminal_id
	)

	COMMIT TRAN
END

GO

/****** Object:  StoredProcedure [dbo].[osp_recon_insert_update_external_file]    Script Date: 10/28/2016 09:04:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].[osp_recon_insert_update_external_file]
	@external_file_source_id		POST_ID,
	@entity_id							POST_ID,
	@file_date							DATETIME,
	@file_seq_no						INT,
	@session_id							POST_ID,
	@filename							VARCHAR(255),
	@business_date_from				DATETIME,
	@business_date_to					DATETIME,
	@min_post_tran_id					BIGINT,
	@max_post_tran_id					BIGINT,
	@table_name_extension			VARCHAR(50),
	@external_file_id					POST_ID
AS
BEGIN
	IF NOT EXISTS(
		SELECT 1 
		FROM recon_external_file
		WHERE
			external_file_source_id = @external_file_source_id
		AND
			file_date = @file_date
		AND
			file_seq_no = @file_seq_no)
	BEGIN
		INSERT INTO
			recon_external_file
		(
			external_file_id,
			external_file_source_id,
			entity_id,
			file_date,
			file_seq_no,
			session_id,
			filename,
			business_date_from,
			business_date_to,
			min_post_tran_id,
			max_post_tran_id
		)
		VALUES
		(
			@external_file_id,
			@external_file_source_id,
			@entity_id,
			@file_date,
			@file_seq_no,
			@session_id,
			@filename,
			@business_date_from,
			@business_date_to,
			@min_post_tran_id,
			@max_post_tran_id
		)
	END
	ELSE
	BEGIN
		UPDATE recon_external_file
		SET
			external_file_id = @external_file_id,
			session_id = @session_id,
			filename = @filename,
			business_date_from = @business_date_from,
			business_date_to = @business_date_to,
			min_post_tran_id = @min_post_tran_id,
			max_post_tran_id = @max_post_tran_id
		WHERE entity_id = @entity_id
		AND file_date = @file_date
		AND file_seq_no = @file_seq_no
	END
END

GRANT EXECUTE ON osp_recon_insert_update_external_file TO postilion

GO

/****** Object:  StoredProcedure [dbo].[osp_spay_pop_tt_amount_next_date]    Script Date: 10/28/2016 09:04:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].[osp_spay_pop_tt_amount_next_date]
			@spay_session_id	INT,
			@config_set_id		INT
AS
BEGIN
	DELETE FROM
		sstl_tt_amount_next_date


	INSERT INTO
		sstl_tt_amount_next_date
	SELECT
		se_id,
      amount_id,
      MAX ( next_payment_date )
	FROM
      spay_amount_pay_next_date
	WHERE
		config_set_id = @config_set_id
	GROUP BY
      se_id,
      amount_id
END

GO

/****** Object:  StoredProcedure [dbo].[osp_spay_pop_tt_fee_next_date]    Script Date: 10/28/2016 09:04:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].[osp_spay_pop_tt_fee_next_date]
			@spay_session_id	INT,
			@config_set_id		INT
AS
BEGIN
	DELETE FROM
		sstl_tt_fee_next_date


	INSERT INTO
		sstl_tt_fee_next_date
	SELECT
		se_id,
      fee_id,
      MAX ( next_payment_date )
	FROM
      spay_fee_pay_next_date
	WHERE
		config_set_id = @config_set_id
	GROUP BY
      se_id,
      fee_id
END

GO

/****** Object:  StoredProcedure [dbo].[osp_spst_pop_tt_amount_next_date]    Script Date: 10/28/2016 09:04:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].[osp_spst_pop_tt_amount_next_date]
			@spst_session_id	INT,
			@config_set_id		INT
AS
BEGIN
	DELETE FROM
		sstl_tt_amount_next_date


	INSERT INTO
		sstl_tt_amount_next_date
	SELECT
		se_id,
      amount_id,
      MAX ( next_posting_date )
	FROM
      spst_amount_pst_next_date
	WHERE
		config_set_id = @config_set_id
	GROUP BY
      se_id,
      amount_id
END

GO

/****** Object:  StoredProcedure [dbo].[osp_spst_pop_tt_fee_next_date]    Script Date: 10/28/2016 09:04:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].[osp_spst_pop_tt_fee_next_date]
			@spst_session_id	INT,
			@config_set_id		INT
AS
BEGIN
	DELETE FROM
		sstl_tt_fee_next_date


	INSERT INTO
		sstl_tt_fee_next_date
	SELECT
		se_id,
      fee_id,
      MAX ( next_posting_date )
	FROM
      spst_fee_pst_next_date
	WHERE
		config_set_id = @config_set_id
	GROUP BY
      se_id,
      fee_id
END

GO

/****** Object:  StoredProcedure [dbo].[osp_tranqry_getextrextendeddata]    Script Date: 10/28/2016 09:04:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO




CREATE PROCEDURE [dbo].[osp_tranqry_getextrextendeddata]
	@post_tran_id	BIGINT
AS
BEGIN
	SELECT
		extr_extended_data
	FROM
  		post_tran_extract pte WITH (NOLOCK)
	WHERE
		pte.post_tran_id = @post_tran_id
END


GO

/****** Object:  StoredProcedure [dbo].[placeholder_mcipm_extract_full_card_acceptor_mapping_info_record]    Script Date: 10/28/2016 09:04:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].[placeholder_mcipm_extract_full_card_acceptor_mapping_info_record]
	@card_acceptor_id				CHAR(15),
	@merchant_id					CHAR(6),
	@card_acceptor_name				VARCHAR(25),
	@street_address					VARCHAR(34),
	@city							VARCHAR(13),
	@postal_code					CHAR(10),
	@card_acceptor_tax_id			CHAR(20)
AS
BEGIN
	INSERT INTO mcipm_card_acceptor_mapping_info
	(
		card_acceptor_id,
		merchant_id,
		card_acceptor_name,
		street_address,
		city,
		postal_code,
		card_acceptor_tax_id
	)
	VALUES 
	(
		@card_acceptor_id, 
		@merchant_id,
		@card_acceptor_name, 
		@street_address, 
		@city, 
		@postal_code,
		@card_acceptor_tax_id
	)
END

GO


