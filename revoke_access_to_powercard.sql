-- USER SQL
ALTER USER "CYNTHIA_AKUMUO" 
DEFAULT TABLESPACE "POWERCARD_USERS"
TEMPORARY TABLESPACE "POWERCARD_TEMPORARY"
PASSWORD EXPIRE 
ACCOUNT LOCK ;

-- ROLES
REVOKE "R_VISA_BASE_2_PARAM_SIUD" FROM "CYNTHIA_AKUMUO";
REVOKE "R_PURGE_SIU" FROM "CYNTHIA_AKUMUO";
REVOKE "R_POS_PARAM_SIUD" FROM "CYNTHIA_AKUMUO";
REVOKE "R_VAL_POS_FORCE_PARAM_LOAD_M" FROM "CYNTHIA_AKUMUO";
REVOKE "R_MERCHANT_ACCOUNT_SIU" FROM "CYNTHIA_AKUMUO";
REVOKE "ORAFORMS$BGM" FROM "CYNTHIA_AKUMUO";
REVOKE "R_POS_SIU" FROM "CYNTHIA_AKUMUO";
REVOKE "G_ISW_OPERATOR" FROM "CYNTHIA_AKUMUO";
REVOKE "R_RISK_MANAGEMENT_PARAM_SIU" FROM "CYNTHIA_AKUMUO";
REVOKE "R_VISA_BASE_2_PARAM_SIU" FROM "CYNTHIA_AKUMUO";
REVOKE "OEM_MONITOR" FROM "CYNTHIA_AKUMUO";
REVOKE "EXECUTE_CATALOG_ROLE" FROM "CYNTHIA_AKUMUO";
REVOKE "SCHEDULER_ADMIN" FROM "CYNTHIA_AKUMUO";
REVOKE "R_VISA_SIU" FROM "CYNTHIA_AKUMUO";
REVOKE "WM_ADMIN_ROLE" FROM "CYNTHIA_AKUMUO";
REVOKE "AQ_USER_ROLE" FROM "CYNTHIA_AKUMUO";
REVOKE "R_UTILITY_PAYMENT_SIUD" FROM "CYNTHIA_AKUMUO";
REVOKE "G_GTB_UPDATE_ROLE" FROM "CYNTHIA_AKUMUO";
REVOKE "LOGSTDBY_ADMINISTRATOR" FROM "CYNTHIA_AKUMUO";
REVOKE "EXP_FULL_DATABASE" FROM "CYNTHIA_AKUMUO";
REVOKE "R_MERCHANT_PARAM_S" FROM "CYNTHIA_AKUMUO";
REVOKE "AQ_ADMINISTRATOR_ROLE" FROM "CYNTHIA_AKUMUO";
REVOKE "R_MERCHANT_CLAIM_S" FROM "CYNTHIA_AKUMUO";
REVOKE "R_MERCHANT_ACCOUNT_S" FROM "CYNTHIA_AKUMUO";
REVOKE "R_UTILITY_PAYMENT_SIU" FROM "CYNTHIA_AKUMUO";
REVOKE "G_ISW_USER" FROM "CYNTHIA_AKUMUO";
REVOKE "R_MERCHANT_ACCOUNT_SIUD" FROM "CYNTHIA_AKUMUO";
REVOKE "R_VISA_SIUD" FROM "CYNTHIA_AKUMUO";
REVOKE "R_MERCHANT_PARAM_SIUD" FROM "CYNTHIA_AKUMUO";
REVOKE "RECOVERY_CATALOG_OWNER" FROM "CYNTHIA_AKUMUO";
REVOKE "R_MCI_SAFE_SIUD" FROM "CYNTHIA_AKUMUO";
REVOKE "R_POS_SIUD" FROM "CYNTHIA_AKUMUO";
REVOKE "R_VISA_BASE_2_SIUD" FROM "CYNTHIA_AKUMUO";
REVOKE "ORAFORMS$OSC" FROM "CYNTHIA_AKUMUO";
REVOKE "G_GTB_SELECT_ROLE" FROM "CYNTHIA_AKUMUO";
REVOKE "IMP_FULL_DATABASE" FROM "CYNTHIA_AKUMUO";
REVOKE "R_ACCOUNTING_S" FROM "CYNTHIA_AKUMUO";
REVOKE "R_VISA_BASE_1_SIU" FROM "CYNTHIA_AKUMUO";
REVOKE "R_MERCHANT_S" FROM "CYNTHIA_AKUMUO";
REVOKE "R_POS_ADVANCED_PARAM_SIUD" FROM "CYNTHIA_AKUMUO";
REVOKE "R_POS_S" FROM "CYNTHIA_AKUMUO";
REVOKE "R_PURGE_SIUD" FROM "CYNTHIA_AKUMUO";
REVOKE "R_RECYCLING_M" FROM "CYNTHIA_AKUMUO";
REVOKE "R_VISA_BASE_2_SIU" FROM "CYNTHIA_AKUMUO";
REVOKE "R_POS_PARAM_SIU" FROM "CYNTHIA_AKUMUO";
REVOKE "R_VISA_BASE_1_S" FROM "CYNTHIA_AKUMUO";
REVOKE "R_VISA_BASE_2_S" FROM "CYNTHIA_AKUMUO";
REVOKE "ORAFORMS$DBG" FROM "CYNTHIA_AKUMUO";
REVOKE "R_VISA_BASE_2_PARAM_S" FROM "CYNTHIA_AKUMUO";
REVOKE "G_GTB_QUI" FROM "CYNTHIA_AKUMUO";
REVOKE "HS_ADMIN_ROLE" FROM "CYNTHIA_AKUMUO";
REVOKE "DELETE_CATALOG_ROLE" FROM "CYNTHIA_AKUMUO";
REVOKE "R_RELOAD_DATA_ATM_M" FROM "CYNTHIA_AKUMUO";
REVOKE "RESOURCE" FROM "CYNTHIA_AKUMUO";
REVOKE "R_REPLENISH_M" FROM "CYNTHIA_AKUMUO";
REVOKE "R_REPLENISH" FROM "CYNTHIA_AKUMUO";
REVOKE "GATHER_SYSTEM_STATISTICS" FROM "CYNTHIA_AKUMUO";
REVOKE "R_RISK_MANAGEMENT_PARAM_S" FROM "CYNTHIA_AKUMUO";
REVOKE "G_SKYE_U" FROM "CYNTHIA_AKUMUO";
REVOKE "R_VISA_S" FROM "CYNTHIA_AKUMUO";
REVOKE "R_MERCHANT_CLAIM_SIUD" FROM "CYNTHIA_AKUMUO";
REVOKE "R_ACCOUNTING_PARAM_SIUD" FROM "CYNTHIA_AKUMUO";
REVOKE "R_VAL_POS_PARAM_VERS_M" FROM "CYNTHIA_AKUMUO";
REVOKE "R_VISA_BASE_1_SIUD" FROM "CYNTHIA_AKUMUO";
REVOKE "R_PURGE_S" FROM "CYNTHIA_AKUMUO";
REVOKE "R_ACCOUNTING_PARAM_S" FROM "CYNTHIA_AKUMUO";
REVOKE "MGMT_USER" FROM "CYNTHIA_AKUMUO";
REVOKE "R_ACCOUNTING_PARAM_SIU" FROM "CYNTHIA_AKUMUO";
REVOKE "R_MERCHANT_CLAIM_SIU" FROM "CYNTHIA_AKUMUO";
REVOKE "DBA" FROM "CYNTHIA_AKUMUO";
REVOKE "R_POS_PARAM_S" FROM "CYNTHIA_AKUMUO";
REVOKE "R_VAL_POS_PARAM_LOAD_M" FROM "CYNTHIA_AKUMUO";
REVOKE "OEM_ADVISOR" FROM "CYNTHIA_AKUMUO";
ALTER USER "CYNTHIA_AKUMUO" DEFAULT ROLE "R_MERCHANT_PARAM_SIU","R_MERCHANT_SIUD","R_PCI","R_MERCHANT_SIU","SELECT_CATALOG_ROLE","R_POS_ADVANCED_PARAM_S","R_POS_ADVANCED_PARAM_SIU","R_PARAMETER_S","R_PARAMETER_M";

-- SYSTEM PRIVILEGES

-- QUOTAS


ALTER USER "CYNTHIA_AKUMUO"  IDENTIFIED BY Password12 
DEFAULT TABLESPACE "POWERCARD_USERS"
TEMPORARY TABLESPACE "POWERCARD_TEMPORARY"
PASSWORD EXPIRE 
ACCOUNT UNLOCK ;

-- ROLES
ALTER USER "CYNTHIA_AKUMUO" DEFAULT ROLE "R_MERCHANT_PARAM_SIU","R_MERCHANT_SIUD","R_PCI","R_MERCHANT_SIU","SELECT_CATALOG_ROLE","R_POS_ADVANCED_PARAM_S","R_POS_ADVANCED_PARAM_SIU","R_PARAMETER_S","R_PARAMETER_M";

-- SYSTEM PRIVILEGES

-- QUOTAS
