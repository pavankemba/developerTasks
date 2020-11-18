/*****************************************************************************************
Name: TestUtility
===============================================================================================
===============================================================================================
Purpose:
--------
Test Utility Class 
===============================================================================================
History
-------
VERSION        AUTHOR                  	DATE               		DETAILS
1.0            Pavan Kemba         		18th NOV 2020     		Initial Development
===============================================================================================
 ******************************************************************************************/
@isTest
public class TestUtility {

    // UTILITY TO CREATE RECORDS FOR TRANSACTION RECORDS. NOTE THIS WILL NOT INSERT RECORDS
    public static Transaction__c createTransaction(String name,Integer count){
            Transaction__c transRecord = new Transaction__c();
        	Integer randomNumber = Integer.valueof((Math.random() * 100));
        	transRecord.Name = name+randomNumber;
        	transRecord.Transaction_Count__c = count;
            return transRecord;
    }
    
    // UTILITY TO CREATE RECORDS FOR TRANSACTION ITEMS RECORDS. NOTE THIS WILL NOT INSERT RECORDS
    public static TransactionItem__c createTransactionItem(id TransRec){
            TransactionItem__c transItemRecord = new TransactionItem__c();
        	transItemRecord.Transaction__c = TransRec;
        	transItemRecord.Item_Cost__c = 10.1;
            return transItemRecord;
    }
}