/*****************************************************************************************
Name: transactionItemTrigger
===============================================================================================
===============================================================================================
Purpose:
--------
This is the trigger on Transaction Item.
===============================================================================================
===============================================================================================
History
-------
VERSION        AUTHOR                  	DATE               		DETAILs
1.0            Pavan Kemba         		16th NOV 2020     		Initial Development
******************************************************************************************/
trigger TransactionItemTrigger_TRG on TransactionItem__c (after insert,after delete,after update,before insert,before update,before delete) {
   	
    // IF REQUIRED, WE CAN MAINTAIN CUSTOM SETTINGS TO GET VALUES AND BYPASS TRIGGERS FOR 
    // ANY SPECIFIC USER / PROFILE SO THAT THE ENTIRE LOGIC IS BYPASSED FOR THEM.
    
    if(trigger.isafter && trigger.isInsert)
    	TransactionItemTriggerHandler_CLS.checkForTransactionAIAD(Trigger.new);
    if(trigger.isafter && trigger.isDelete)
        TransactionItemTriggerHandler_CLS.checkForTransactionAIAD(Trigger.old);
}