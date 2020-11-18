/*****************************************************************************************
Name: TransactionItemTriggerHandler_CLS
===============================================================================================
===============================================================================================
Purpose:
--------
This is the handler class for TransactionItem.

Note:
	All methods should follows below postfixes
		1. AIAU   -- After Insert & After Update
		2. BIBU   -- Before Insert & Before Update
		3. AIAD   -- After Insert & After Delete
		4. BIBD   -- Before Insert & Before Delete
		5. AIAUAD -- After Insert, After Update & After Delete
		6. BIBUBD -- Before Insert, Before Update & Before Delete
===============================================================================================
History
-------
VERSION        AUTHOR                  	DATE               		DETAILs
1.0            Pavan Kemba         		16th NOV 2020     		Initial Development
===============================================================================================
 ******************************************************************************************/
public with sharing class TransactionItemTriggerHandler_CLS {
    
    public static Integer defItemCost = 0;

    public static void checkForTransactionAIAD(List<TransactionItem__c> transactionItemsList){
        String TIJSONSTRING;
        Map<id,List<TransactionItem__c>> transactionItemMap = new Map<id,List<TransactionItem__c>>();
        List<TransactionItem__c> processTransItemList = new List<TransactionItem__c>();
        set<id> transIds = new set<id>();
        for(TransactionItem__c transItem : transactionItemsList){
            transIds.add(transItem.Transaction__c);
        }
               
        for(Transaction__c trans : [SELECT id,Transaction_Count__c,(SELECT id,Name,Item_Cost__c FROM TransactionItem__r) FROM Transaction__c where ID IN :transIds]){
            if(trans.Transaction_Count__c > 0 && trans.Transaction_Count__c == trans.TransactionItem__r.size()){
                System.debug('Transaction Count matches with Items. Process JSON');
                for(TransactionItem__c traItem : trans.TransactionItem__r){
                    processTransItemList.add(traItem);
                }
            }
        }
        
        if(!processTransItemList.isEmpty()){
            System.debug('CALLING processTIload METHOD');
            TIJSONSTRING = processTIload(processTransItemList);
        }
             // PERFORM CALLOUT HERE ON THE ABOVE PAYLOAD.
     
			 RestCalloutClass_CLS.makeCallout(TIJSONSTRING);
   }
    
    /*
     * THIS METHOD processFirstPayload PREPARES JSON OF TRANSACTION ITEMS, THAT NEEDS TO BE PROCESSED
     * FOR CALL OUT
     */ 
    public static String processTIload(List<TransactionItem__c> processTIList){
        System.debug('IN processTIload METHOD');
        String JSONstring;
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartArray(); 
         // for (Id recordId : createJSON.keySet()){
           for (TransactionItem__c transItem : processTIList){
              gen.writeStartObject();
        		gen.writeFieldName('keys');
        			gen.writeStartObject();
            			gen.writeFieldName('TransactionItemID');
            			gen.writeString(transItem.id);
        			gen.writeEndObject();

            	gen.writeFieldName('values');
        			gen.writeStartObject();
            			gen.writeFieldName('ItemCost');
               			if(transItem.Item_Cost__c != null)
            				gen.writeNumber(transItem.Item_Cost__c);
               			else
            				gen.writeNumber(defItemCost);       
            			gen.writeFieldName('ItemName');
            			gen.writeString(transItem.Name);
        			gen.writeEndObject();
           	  gen.writeEndObject();
        }
    //}
     
     gen.writeEndArray();
     
     System.debug('JSON 1st PAYLOAD : '+gen.getAsString());
     JSONstring = gen.getAsString();
   
     return JSONstring;   
    }
}